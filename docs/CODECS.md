# Codec and Format Matrix

SonicNest never assumes every encoder exists on every device. The recorder service checks encoder support through the recording API and can fall back to an intermediate capture format for post-recording conversion. Formats that require transcoding use the audio-focused FFmpeg dependency.

| Format | Capture strategy | Typical extension | Notes |
|---|---|---|---|
| M4A/AAC-LC | Native when supported; otherwise intermediate capture + conversion | `.m4a` | Default balanced format |
| WAV PCM16 | Native when supported; otherwise intermediate capture + conversion | `.wav` | Large, lossless/uncompressed target |
| FLAC | Native when supported; otherwise intermediate capture + conversion | `.flac` | Lossless compression |
| Opus | Native when supported; otherwise intermediate capture + conversion | `.opus` | Container/runtime behavior varies by platform |
| MP3 | Intermediate capture + FFmpeg/LAME conversion | `.mp3` | Export/transcoded path |
| OGG/Vorbis | Intermediate capture + FFmpeg/Vorbis conversion | `.ogg` | Export/transcoded path |
| AAC/ADTS | Intermediate capture + FFmpeg AAC conversion | `.aac` | Raw AAC export path |

## Preset validation

Requested bitrate/sample-rate/channel values are passed to the platform recorder, which may adjust them to hardware or codec constraints. SonicNest listens for effective configuration changes where the package exposes them.

## Licensing

The application source is Apache-2.0. Third-party libraries retain their own licenses. Redistributors are responsible for meeting all dependency license and notice requirements for their distribution method.
