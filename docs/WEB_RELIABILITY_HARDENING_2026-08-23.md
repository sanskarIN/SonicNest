# Web Reliability Hardening — 2026-08-23

This note records repository-owned Web recorder and in-session playback hardening added after the earlier capture-control failure work.

## Implemented

- Treat an unexpected clean capture-stream completion (`onDone`) as a fail-closed capture failure, not as a still-running recording.
- Reuse the capture-generation guard so normal Stop/Cancel/dispose transitions ignore late completion callbacks from an older stream.
- Discard incomplete PCM, cancel local capture/amplitude subscriptions, reset timer/amplitude/record state, and return the UI to a restartable stopped state.
- Lock microphone refresh, device selection, channel selection, automatic gain, echo cancellation, and noise suppression while a recorder transition is busy as well as while capture is active.
- Resume a paused in-session recording without reloading its audio source and restarting from the beginning.
- Await playback operations so immediate playback failures are handled by the existing user-visible recovery path and stale playing-row state is cleared.
- Subscribe to `AudioPlayer.errorStream` so player errors emitted after the immediate `_play()` operation are also observed. An active failed row is cleared and the user receives a recoverable playback message.
- Cancel the player-error subscription during widget disposal together with the player-state subscription.
- Clear the previous row before loading a different in-memory WAV source so a failure while loading the new source cannot leave the old recording marked as selected/playing.
- Track whether a player error was already reported for the active recording so the `errorStream` path and the awaited `_play()` catch path do not deliberately show duplicate error messages for the same failure.

The `just_audio` 0.10.x API exposes `AudioPlayer.errorStream` as the player-wide stream of `PlayerException` values, including Web media errors, and its migration guidance recommends `errorStream` for playback errors. This source therefore uses both the awaited operation boundary and the long-lived error stream instead of assuming one path covers every browser/player failure timing.

## Regression contract

`tool/tests/test_web_platform_contract.py` now requires:

- the capture stream `onDone` recovery path;
- the shared busy/active input-settings lock;
- same-recording playback resume behavior;
- awaited playback instead of an unobserved `unawaited(_player.play())` future;
- a typed `StreamSubscription<PlayerException>` for `AudioPlayer.errorStream`;
- disposal of the error subscription;
- stale playing-row cleanup before loading a different recording;
- duplicate-report suppression between the player-wide error stream and the immediate operation catch path.

## Evidence boundary

These repository checks protect source-level behavior. They do not replace real browser testing. Manual QA still needs representative Chromium, Firefox, and Safari/WebKit coverage for device removal, stream termination, input changes, playback pause/resume, source switching, injected/real playback failures, and recovery after browser/media-device interruptions.
