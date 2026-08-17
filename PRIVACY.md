# SonicNest Privacy

SonicNest is designed to work offline for its core recording, library, playback, editing, diagnostics, and manual QA-evidence workflows.

- Microphone access is requested only for recording.
- Recordings and metadata are stored locally by default.
- SonicNest does not silently upload recordings or microphone data.
- SonicNest contains no hidden analytics, advertising SDK, or data-sale mechanism.
- Sharing/exporting is user initiated.
- External links such as Gumroad, GitHub, and Buy Me a Coffee open only after user action. The highlighted Gumroad storefront is https://ramsandesh.gumroad.com.
- Optional future network/transcription features must disclose network use before sending audio.
- Diagnostics are generated only after user action and exclude recording content, recording titles, file paths, notes, tags, bookmarks, smart-naming text, and input-device names.
- Manual QA evidence is stored locally and contains only source-controlled check IDs, `Not run`/`Passed`/`Failed`/`Blocked` status values, and timestamps.
- Manual QA evidence deliberately has no free-form tester-note field and does not collect recording/library content, paths, input-device names, or other user-entered recording metadata.
- Diagnostics and manual QA evidence are copied or shared only through explicit user actions; SonicNest does not automatically upload either report type.
- Opening the Gumroad storefront does not automatically attach or transmit recordings, Library metadata, diagnostics, or manual-QA evidence from SonicNest.

The operating system may expose microphone, notification, file-picker, background-audio, or sharing permissions depending on platform and enabled features. Once the user explicitly opens an external service, that destination is governed by its own privacy terms.

See `docs/DIAGNOSTICS_AND_QA.md` for the diagnostics privacy contract, `docs/MANUAL_QA_EVIDENCE.md` for the manual QA evidence storage/export boundary, and `docs/LINKS_AND_PROMOTION.md` for the maintained public-link contract.
