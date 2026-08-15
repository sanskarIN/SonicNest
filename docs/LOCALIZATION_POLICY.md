# SonicNest Localization and Diagnostic Text Policy

SonicNest separates user-facing product language from low-level technical diagnostics so future locales can be translated consistently without hiding information needed to troubleshoot recording and media failures.

## User-facing product language

UI labels, actions, descriptions, confirmations, progress messages, empty states, validation guidance, and high-level error summaries belong in the application localization layer.

Examples include:

- recording and playback controls;
- Library, Editor, Batch Convert, Settings, About, and startup text;
- confirmation prompts and destructive-action warnings;
- localized explanations such as “the selected destination folder is unavailable” or “some files could not be converted”;
- localized counts and progress summaries.

New presentation strings should not be introduced as inline English literals when they are intended to be shown as ordinary product UI.

## Technical diagnostics

Raw backend details are intentionally retained as technical text instead of being translated automatically. This includes:

- operating-system exception messages;
- FFmpeg/codec diagnostic excerpts;
- plugin/backend error details;
- filesystem paths;
- platform API identifiers;
- exception class names and debugging-oriented values.

These details are not stable translation keys and translating them can make support logs harder to compare with the underlying platform or dependency output.

## Error presentation rule

When an error can reach ordinary users, SonicNest should prefer this structure:

1. a localized, actionable summary that explains what failed;
2. an optional technical detail string containing the original backend information when that information is useful for diagnosis.

A raw exception should not replace an available localized explanation. Conversely, localization should not rewrite or discard technical evidence that maintainers may need to identify a codec, filesystem, permission, or platform failure.

## Privacy rule

Technical diagnostics can contain user-created filenames, paths, titles, tags, notes, or platform information. Diagnostic text must not be uploaded automatically. Support documentation should continue to instruct users to remove private recording names, private audio, secrets, signing material, and unnecessary personal information before sharing logs or screenshots.

## Adding a locale

A locale is release-ready only after:

- translation review by a competent reviewer;
- text-expansion testing on compact phone and desktop layouts;
- plural/count checks;
- right-to-left review when applicable;
- accessibility review of translated controls;
- review of localized error summaries while preserving raw technical diagnostics separately;
- regression testing that untranslated backend details cannot break layout or obscure the localized summary.

## Source-of-truth decision

For future non-English releases, **presentation text is translated; raw backend diagnostic details intentionally remain technical/source-language output** unless a specific backend exposes stable, documented error codes that SonicNest maps to its own localized explanation.
