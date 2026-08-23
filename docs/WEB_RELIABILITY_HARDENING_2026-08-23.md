# Web Reliability Hardening — 2026-08-23

This note records repository-owned Web recorder hardening added after the earlier capture-control failure work.

## Implemented

- Treat an unexpected clean capture-stream completion (`onDone`) as a fail-closed capture failure, not as a still-running recording.
- Reuse the capture-generation guard so normal Stop/Cancel/dispose transitions ignore late completion callbacks from an older stream.
- Discard incomplete PCM, cancel local capture/amplitude subscriptions, reset timer/amplitude/record state, and return the UI to a restartable stopped state.
- Lock microphone refresh, device selection, channel selection, automatic gain, echo cancellation, and noise suppression while a recorder transition is busy as well as while capture is active.
- Resume a paused in-session recording without reloading its audio source and restarting from the beginning.
- Await playback operations so asynchronous playback failures are handled by the existing user-visible recovery path and stale playing-row state is cleared.

## Regression contract

`tool/tests/test_web_platform_contract.py` now requires:

- the capture stream `onDone` recovery path;
- the shared busy/active input-settings lock;
- same-recording playback resume behavior;
- awaited playback instead of an unobserved `unawaited(_player.play())` future.

## Evidence boundary

These repository checks protect source-level behavior. They do not replace real browser testing. Manual QA still needs representative Chromium, Firefox, and Safari/WebKit coverage for device removal, stream termination, input changes, playback pause/resume, and recovery after browser/media-device interruptions.
