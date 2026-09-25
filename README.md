# Thaheen — Mini Offline LMS

A small, Arabic-first learning app for health-sciences courses, built as a Flutter take-home task. Students browse courses, watch video lessons, and unlock lessons one after another as they complete them. Everything runs **fully offline**: course data and videos are bundled with the app.

🎬 **Demo video:** [Watch on Google Drive](https://drive.google.com/file/d/1JCahzs8IHP_5PpUN_NOluQn7PSSJhjYl/view?usp=sharing)

## Features

### Required

| Feature | Notes |
|---|---|
| Courses screen | Thumbnail, title, instructor, lesson count, course progress |
| Continue Watching | Shown only for a lesson with `position > 0 && !completed`; picks the most recently watched one |
| Course details | Course info, sections, lessons, duration, status (Not started / In progress / Completed / Locked) |
| Sequential unlocking | First lesson always open; each next lesson unlocks when the previous one is completed — across sections |
| Locked lessons | Tapping one shows a friendly message; the player also refuses locked lessons by itself |
| Lesson player | `video_player` with bundled assets: play/pause, seek bar, ±10 s, position/duration, speed (1×, 1.25×, 1.5×, 2×), fullscreen landscape |
| Resume | Reopening a lesson continues from the saved position (restarts if it was saved at the very end) |
| Completion at 90% | `position / duration >= 0.90`; safe for zero duration |
| Next Lesson | Enabled only after completion; last lesson shows a "course completed" card |
| Progress persistence | `shared_preferences`, one JSON entry for all lessons, throttled saves |
| Arabic RTL | Arabic is the default; layout uses directional padding/alignment throughout |
| Loading / empty / error states | No red screens: missing or invalid JSON, empty catalog, course without lessons, no search results, missing/corrupt video |

### Optional

- **English switch** — persisted; switches UI text, course content and text direction instantly.
- **Search** — Arabic and English titles and instructor names; case-insensitive for English and tolerant of common Arabic spelling variants (أ/إ/آ → ا, ة → ه, ى → ي, diacritics).
- **Dark mode** — follows the system until the user picks light or dark; the choice is persisted.
- **Remember last playback speed** — the speed chosen in the player applies to every lesson and survives restarts.
- **Widget and flow tests** — in addition to the required unit tests.

## Running the project

Requirements: Flutter **3.44** (Dart **3.12**) or newer.

```bash
flutter pub get
flutter run                 # on a connected device or simulator
flutter test                # all tests
flutter analyze             # static analysis
flutter build apk --release # Android release build (see Known issues about signing)
```

No API keys, backend or network access are needed.

## Architecture

A lightweight, feature-oriented structure. Shared layers live at the top level because all three features use the same catalog and progress store; each feature owns only its presentation.

```text
lib/
├── core/            constants, extensions, localization, router, theme, utils, shared widgets
├── data/
│   ├── local/       asset + SharedPreferences data sources
│   ├── models/      JSON models (fromJson / toEntity)
│   └── repositories/ CourseRepository, ProgressRepository
├── domain/
│   ├── entities/    Course, Section, Lesson, LessonProgress, LocalizedText, …
│   └── services/    pure business rules (see below)
├── features/
│   ├── courses/         cubit/ screens/ widgets/
│   ├── course_details/  cubit/ screens/ widgets/
│   └── lesson_player/   cubit/ screens/ widgets/
├── app.dart         providers + MaterialApp
└── main.dart        composition root
```

**Data flow:** `courses.json` → `CourseLocalDataSource` → models → entities → `CourseRepository` → Cubit → UI. Widgets never read JSON or SharedPreferences directly.

**Content vs. user state:** `Lesson` holds only content (id, title, duration, video path). User state lives in `LessonProgress` (position, completed, last watched). A lesson's status is derived from content + progress + the unlock rule — it is never stored.

**Business rules** (`domain/services/`) are pure Dart functions with no Flutter imports, so they are trivial to unit test:

| File | Rule |
|---|---|
| `completion_rule.dart` | `isLessonCompleted(positionSeconds, durationSeconds)` and `watchedFraction` |
| `unlock_rule.dart` | `isLessonUnlocked(course, lessonId, progress)` over the flattened lesson order |
| `lesson_status_resolver.dart` | Completed / Locked / In progress / Not started |
| `progress_calculator.dart` | completed ÷ total, `0.0 → 1.0` |
| `course_filter.dart` | `filterCourses(courses, query)` |
| `continue_watching_finder.dart` | most recent started-but-unfinished lesson |

**Repositories**
- `CourseRepository` parses the bundled catalog once and caches it. Any failure (missing asset, invalid JSON, missing field) becomes a single `CourseLoadException`, with details logged.
- `ProgressRepository` keeps progress in memory for synchronous reads, persists it to SharedPreferences, and exposes a `changes` stream so screens update live (e.g. finishing a lesson unlocks the next one in the details screen behind the player).

**Navigation:** [`go_router`](https://pub.dev/packages/go_router) with nested routes — `/` → `/courses/:courseId` → `/courses/:courseId/lessons/:lessonId`. Nesting gives every location a natural back stack (a lesson opened from Continue Watching goes back to its course details, then home), and unknown paths or ids show a friendly not-found screen. Pages are keyed by their actual location so moving to the next lesson creates a fresh player instead of reusing the previous one. Widgets navigate through extensions (`context.goToCourseDetails(id)`, `context.goToLessonPlayer(...)`) and never see route strings.

## State management

`flutter_bloc` **Cubits**, one per screen plus two app-level ones:

| Cubit | Responsibility |
|---|---|
| `CoursesCubit` | Load catalog + progress, course progress, Continue Watching, search |
| `CourseDetailsCubit` | Course, derived lesson statuses, completed count, live progress updates |
| `LessonPlayerCubit` | Owns the `VideoPlayerController`; playback, resume, remembered speed, 90% detection, throttled persistence, next lesson |
| `LocalizationCubit` | Current locale, persisted |
| `ThemeCubit` | Theme mode, persisted |

Why Cubit: the app's state changes come from a handful of direct user actions and a progress stream — there are no complex event pipelines, so Bloc's event classes would add ceremony without benefit. Cubits keep business logic out of widgets, give explicit sealed states (`Loading` / `Loaded` / `Empty` / `Error`) that map cleanly to UI, and are easy to test.

The `VideoPlayerController` is deliberately **not** part of the state; it lives inside `LessonPlayerCubit` and is disposed in `close()` after the final position is saved. The state only carries UI values (position, duration, playing, speed, completed, next lesson).

## Local persistence

SharedPreferences is enough because the persisted data is tiny and simple:

| Key | Value |
|---|---|
| `lesson_progress` | One JSON object: `{ "<lessonId>": { "position": 42, "completed": false, "lastWatchedAt": 1758800000000 } }` |
| `language_code` | `ar` or `en` |
| `theme_mode` | `light` or `dark` (absent = follow system) |
| `playback_speed` | Last chosen speed: `1.0`, `1.25`, `1.5` or `2.0` (anything else falls back to `1.0`) |

There are no queries, relations or large collections, so a database (Hive, Isar, SQLite) would add setup and migration cost with no real benefit. The course catalog is **not** persisted — it always comes from the bundled JSON.

**When progress is saved:** at most every 5 s while playing, plus immediately on pause, on reaching 90%, when the app goes to the background, and when leaving the player. Saves that would not change anything are skipped. Corrupt stored entries are ignored individually, and a failed write is logged without crashing (in-memory progress stays correct for the session).

## Offline strategy

- **Course data:** `assets/data/courses.json`, bilingual (`{ "ar": …, "en": … }` for every title, description and instructor).
- **Videos:** `assets/videos/*.mp4`, played with `VideoPlayerController.asset`.
- **Images:** `assets/images/*.png` thumbnails.
- **No network code at all** — no HTTP client, no backend SDK, no remote URLs.

## Data format

`assets/data/courses.json` contains the **2 courses** the brief asks for — *Anatomy Fundamentals* and *Introduction to Pharmacology*, each with 2 sections of 2 lessons — plus a third course, *Medical Terminology*, with **no lessons**. That extra course exists only to demonstrate the "course with no lessons" empty state.

```json
{
  "id": "anatomy",
  "title": { "ar": "أساسيات علم التشريح", "en": "Anatomy Fundamentals" },
  "description": { "ar": "…", "en": "…" },
  "instructor": { "ar": "د. سارة المالكي", "en": "Dr. Sara Almalki" },
  "thumbnail": "assets/images/course_anatomy.png",
  "sections": [
    {
      "id": "anatomy_s1",
      "title": { "ar": "مقدمة في التشريح", "en": "Introduction to Anatomy" },
      "lessons": [
        {
          "id": "anatomy_l1",
          "title": { "ar": "ما هو علم التشريح؟", "en": "What Is Anatomy?" },
          "durationSeconds": 10,
          "videoPath": "assets/videos/lesson_1.mp4"
        }
      ]
    }
  ]
}
```

Changes from the suggested shape, and why:

| Change | Reason |
|---|---|
| `title`, `instructor` (and sections/lessons titles) are `{ "ar", "en" }` objects | Content must follow the Arabic/English switch. One reusable `LocalizedText` model avoids parallel fields like `titleEn`. |
| New `description` field | The course details screen shows course information, not just a title. |
| `durationSec` → `durationSeconds` | Unit spelled out, consistent with the rest of the code. |
| `video` → `videoPath` | Makes it explicit that the value is a bundled asset path. |
| Lesson ids are unique across the catalog (`anatomy_l1`, not `l1`) | All progress is stored in one map keyed by lesson id; repeated ids across courses would share progress. |

`durationSeconds` is only used for display before a video loads. Completion always uses the real duration reported by the video player.

## Tests

`flutter test` runs **97 tests**.

**Required unit tests** (`test/domain/`)
- `completion_rule_test.dart` — 89% → false; 90%, 95%, 100% → true; zero and negative durations are safe.
- `unlock_rule_test.dart` — first lesson unlocked; previous incomplete → locked; previous completed → unlocked; unlocking across sections; derived lesson statuses.
- `progress_calculator_test.dart` — 0/6 → 0.0, 3/6 → 0.5, 6/6 → 1.0; zero total lessons → 0.0.

**Additional**
- Domain: course search (case, Arabic variants, instructor), Continue Watching selection, `Course.lessonAfter`.
- Data: catalog parsing and shape (2 courses × 2 sections × 2–3 lessons), error handling, progress persistence, corrupt data and failed writes.
- Cubits: courses, course details, lesson player (the player runs the real `VideoPlayerController` on a fake video platform), localization, theme.
- Navigation: deep link to a lesson and its back stack, next lesson replaces the player, unknown course and unknown path.
- Widget/flow: Arabic RTL start; switching to English LTR and dark mode and keeping both after restart; locked-lesson message; partially watching a lesson → Continue Watching → resume after an app restart; completing a lesson unlocks the next one.

## Trade-offs

- **Shared `data/` and `domain/` layers** instead of per-feature data/domain/presentation folders — the features share one catalog and one progress store, so splitting them would duplicate code.
- **Completion is position-based**, as specified. A user can seek to 90% to complete a lesson; tracking actually-watched time would be stricter but was out of scope.
- **Throttled saves** mean a hard crash can lose up to ~5 s of position; pause, completion, backgrounding and leaving the player are saved immediately.
- **Media controls stay left-to-right in Arabic.** The seek bar and rewind/forward icons describe the video timeline, not reading direction (Material bidirectionality guidance). Everything else is mirrored.
- **Simple hand-written localization** (`AppLocalizations` with Arabic/English getters, including Arabic plural forms) instead of ARB/`intl` code generation — enough for two languages and a few dozen strings.
- **Fullscreen is entered with the button** (landscape, immersive). Rotating the device does not enter fullscreen automatically.

## Known issues

- Three sample clips are reused across the lessons, and they are very short (7–10 s). They keep the repository small and make 90% completion easy to demo, but leave little room to show resume.
- The bundle ID / application ID is still Flutter's default (`com.example.thaheen_task`).
- The Android release build uses the default debug signing config, so the APK is suitable for testing, not store upload.
- The release APK is ~57 MB because it contains all CPU architectures; `flutter build apk --split-per-abi` produces smaller per-device files.
- There are no widget tests for the player UI itself (controls, fullscreen); the player's behaviour is covered at the cubit level and through the flow tests.

## What I would do with more time

- Widget tests for the player controls and fullscreen, and integration tests on real devices.
- Accessibility pass: semantics labels for all controls, larger tap targets, screen-reader testing in Arabic.
- Tablet and landscape layouts for the courses and details screens.
- More robust video error recovery (automatic retry, detecting stalled playback).
- A caching/sync abstraction if the product moves to network-delivered content and videos.
- CI (analyze, test, build) and proper release signing.
- Analytics and crash reporting in a real production environment.
- Richer search and filtering (by progress, category, instructor).

## Time spent

About **3 hours** of planning, research and coding.

## Credits

Sample videos are used under their original licenses:

- `lesson_1.mp4` — *Big Buck Bunny* © Blender Foundation, [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
- `lesson_2.mp4` — *Sintel* © Blender Foundation, [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
- `lesson_3.mp4` — butterfly clip from Flutter's [assets-for-api-docs](https://github.com/flutter/assets-for-api-docs) (BSD-3-Clause).

Course thumbnails were generated for this project.
