# SonicNest Architecture

## Design goals

Reliability and recording safety take priority over visual polish. The project uses service boundaries so recorder, processing, storage, player, and UI logic can be tested and replaced independently.

## Layers

- `lib/models/`: immutable recording and settings data.
- `lib/services/`: filesystem, metadata, microphone recorder, player, FFmpeg processing, external actions.
- `lib/controllers/`: application orchestration and state transitions.
- `lib/screens/`: feature-level presentation.
- `lib/widgets/`: reusable responsive components.
- `lib/core/`: theme, constants, strings, filenames, utility types.

## Storage

Audio files live in the app documents directory under `SonicNest/Recordings`. Metadata is stored separately as JSON under app support. Metadata writes use temporary replacement and backup behavior to reduce corruption risk. Trash moves audio to a dedicated local trash directory until permanent deletion.

## Recording pipeline

1. Validate microphone permission and recorder state.
2. Resolve requested format/preset and query encoder support.
3. Record directly when the requested encoder is supported.
4. Otherwise use a supported intermediate encoder and transcode after stop.
5. Sample dBFS amplitude for the live waveform and persisted envelope.
6. On successful stop, create metadata and persist it.
7. If conversion fails, surface an actionable error rather than claiming success.

## Editor pipeline

All editor operations create a new file. The original remains unchanged. FFmpeg commands are generated from internally managed paths and validated numeric parameters.

## Platform strategy

Flutter host scaffolding changes with Flutter/Gradle/Xcode versions. `tool/bootstrap_platforms.sh` generates host projects from the installed Flutter SDK, then applies SonicNest-specific platform permissions and capabilities from `tool/platform_overrides/`.


## External batch export ordering

Batch conversion treats the managed SonicNest output as the primary transaction. The output is transcoded, registered, probed, waveform-indexed, and persisted before an optional external-folder copy is attempted. This prevents a removable/inaccessible destination from invalidating a successful managed recording. Destination copies are collision-safe. Stop requests are consumed between items rather than forcibly terminating the active FFmpeg write.
