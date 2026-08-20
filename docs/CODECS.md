# Codec and Format Matrix

SonicNest never assumes every encoder exists on every device or browser. Native `RecorderService` checks encoder support through the recording API and can fall back to an intermediate capture format for post-recording conversion. Native formats that require transcoding use the audio-focused FFmpeg dependency.

The Web branch has a separate, explicit codec boundary: it captures the recording package's Web-supported PCM16 byte stream and packages those bytes into a WAV container in pure Dart. The native FFmpeg dependency is not imported into the browser build.

## Native application formats

| Format | Capture strategy | Typical extension | Notes |
|---|---|---|---|
| M4A/AAC-LC | Native when supported; otherwise intermediate capture + conversion | `.m4a` | Default balanced format |
| WAV PCM16 | Native when supported; otherwise intermediate capture + conversion | `.wav` | Large, lossless/uncompressed target |
| FLAC | Native when supported; otherwise intermediate capture + conversion | `.flac` | Lossless compression |
| Opus | Native when supported; otherwise intermediate capture + conversion | `.opus` | Container/runtime behavior varies by platform |
| MP3 | Intermediate capture + FFmpeg/LAME conversion | `.mp3` | Export/transcoded path |
| OGG/Vorbis | Intermediate capture + FFmpeg/Vorbis conversion | `.ogg` | Export/transcoded path |
| AAC/ADTS | Intermediate capture + FFmpeg AAC conversion | `.aac` | Raw AAC export path |

Native encoder availability remains device/runtime dependent; the table describes SonicNest strategy, not a promise that every native device exposes every direct encoder.

## Web application format

| Format | Capture strategy | Extension | Notes |
|---|---|---|---|
| WAV PCM16 | `AudioRecorder.startStream()` PCM16 capture + pure-Dart RIFF/WAVE packaging | `.wav` | Browser-safe path; no native filesystem or FFmpeg dependency |

The browser path intentionally does not claim MP3, FLAC, Opus, OGG/Vorbis, AAC, or M4A transcoding while the selected FFmpeg dependency has no Web implementation. Adding a format to the native matrix does not automatically add it to the browser matrix.

`lib/core/wav_encoder.dart` performs the browser container step. It validates positive sample rate, mono/stereo channel count, and complete 16-bit PCM samples before writing:

- RIFF chunk header;
- WAVE signature;
- PCM `fmt ` chunk;
- sample rate and byte rate;
- block alignment and 16-bit sample depth;
- `data` chunk length and PCM payload.

`test/wav_encoder_test.dart` covers mono/stereo headers, payload preservation, and invalid-input rejection.

## Preset and browser-constraint validation

Requested bitrate/sample-rate/channel values on native targets are passed to the platform recorder, which may adjust them to hardware or codec constraints. SonicNest listens for effective configuration changes where the package exposes them.

The Web recorder requests a 44.1 kHz PCM16 stream and the selected mono/stereo channel count, plus automatic gain, echo cancellation, and noise suppression settings where requested. Browser/runtime audio constraints may adjust the effective configuration. The recorder configuration callback is used to retain the effective sample rate/channel values used when the WAV header is created.

Browser support is therefore capability-based: a successful compile does not prove that every browser/hardware combination honors every requested audio-processing constraint. Representative browser QA remains required.

## Playback

Native playback uses the existing SonicNest player stack and platform media integrations where available.

Web WAV playback uses a byte-backed `StreamAudioSource` so the in-memory WAV can be played without writing it to a native filesystem path. Share/download is explicit and user initiated.

## Licensing

The application source is Apache-2.0. Third-party libraries retain their own licenses. Redistributors and Web deployers are responsible for meeting all dependency license and notice requirements for their distribution method.
