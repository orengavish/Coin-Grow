# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Coin Grow is an AI-generated financial literacy game for mobile (iOS/Android). The **prompt is the product** — the AI prompt engine generates all lesson content (quests, narratives, branching outcomes, debriefs). The game shell is just a delivery vehicle.

Target audience: kids (8+) through adults. Social layer: classrooms compete against each other, schools against schools. Future tier: market simulator for investment competitions.

Team: two co-founders, pre-funding. Flutter mobile scaffold exists (models, scene router, lesson player). Owl character HTML prototype built. Current milestone: get Flutter running and connect generated lessons to the mobile shell.

## Architecture

```
prompts/                        ← Core IP. Versioned prompt files. Never overwrite.
lessons/                        ← Generated lesson JSON (git-ignored, runtime output)
app.py                          ← Streamlit Studio (primary prompt iteration UI)
test_harness.py                 ← CLI fallback
curriculum.json                 ← Lesson ordering and prior_concepts source of truth
mobile/                         ← Flutter app
  lib/
    main.dart                   ← App entry point
    models/lesson.dart          ← Dart models mirroring lesson JSON schema
    screens/home_screen.dart    ← Home / lesson picker
    screens/lesson_player.dart  ← Scene state machine driver
    game/scenes/                ← One file per scene type (cutscene, dialogue, choice, outcome, debrief)
    widgets/                    ← Shared UI components (NarrativeBox, CharacterPortrait)
    theme/app_theme.dart        ← Colors, text styles, button styles
  assets/lessons/               ← Pre-generated lesson JSON for offline/demo use
  pubspec.yaml                  ← Flutter dependencies (Flame, Rive, Lottie)
```

## Flutter Setup

**Current state:** Flutter 3.44.2 installed at `C:\flutter`. Android Studio at `C:\Program Files\Android\Android Studio`.

**IMPORTANT:** All `flutter` commands must be run from `C:\Projects\Coin-Grow\mobile\` — Flutter looks for `pubspec.yaml` in the working directory and fails if run from the repo root.

Add `C:\flutter\bin` to system PATH via Windows Environment Variables dialog if not already done.

```powershell
# From C:\Projects\Coin-Grow\mobile\
Set-Location "C:\Projects\Coin-Grow\mobile"
C:\flutter\bin\flutter.bat doctor    # verify setup, accept Android licenses
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat run       # launches on connected device or emulator
C:\flutter\bin\flutter.bat build apk
```

## Connecting a Generated Lesson to the App

1. Generate a lesson: `streamlit run app.py` → Save
2. Copy the saved JSON from `lessons/` to `mobile/assets/lessons/sample_lesson.json`
3. `flutter run` — the home screen loads it automatically

### How a lesson is generated

1. `test_harness.py` reads the system prompt from `prompts/lesson-generator-vX.Y.md` (strips the file header, extracts between `## SYSTEM PROMPT` and the next `---` separator)
2. Builds a JSON user message with topic, age group, difficulty, etc.
3. Calls `claude-sonnet-4-6` via the Anthropic SDK
4. Parses the JSON response (strips markdown fences if present)
5. Validates against the lesson schema (see `validate()` in `test_harness.py`)
6. Prints a human-readable summary and optionally saves to `lessons/`

### Lesson JSON schema (top-level keys)

`lesson` · `world` · `characters` · `scenes` · `scoring` · `debrief`

Every scene has: `id`, `type` (cutscene/dialogue/interactive/choice/outcome/debrief), `narrative`, `visual_description`. Choice scenes require ≥2 choices each with a `financial_quality` (optimal/acceptable/poor/catastrophic) and a `leads_to_scene` that references a real scene id.

### Prompt versioning convention

Prompt files are named `lesson-generator-vMAJOR.MINOR.md`. Increment minor for tweaks, major for structural schema changes. The generated lesson JSON records which prompt version created it via `lesson.version`.

## Running the Studio (Streamlit UI)

```powershell
pip install anthropic streamlit
streamlit run app.py
# Opens at http://localhost:8501
# Enter API key in sidebar, pick a lesson, click Generate
```

The studio renders generated lessons with scene-by-scene breakdown, choice quality indicators, validation warnings, cache hit/miss stats, and a save button. It reads prompts from `prompts/` and writes saved lessons to `lessons/`.

## Running the Test Harness (CLI)

```powershell
pip install anthropic

$env:ANTHROPIC_API_KEY = "sk-ant-..."

# Default run (v0.1 prompt, Lesson 1, age 12-15, beginner)
python test_harness.py

# v0.2 prompt with a pre-written input spec
python test_harness.py --prompt-version 0.2 --input-file prompts/lesson-01-input.md --save

# Custom v0.1 lesson
python test_harness.py --topic "Why save money?" --age 8-11 --difficulty beginner --save

# All options
python test_harness.py --prompt-version [0.1|0.2] --input-file prompts/lesson-01-input.md \
    --topic "..." --age [8-11|12-15|16+] --difficulty [beginner|intermediate|advanced] \
    --lesson-number 2 --model claude-sonnet-4-6 --save --list
```

`--save` writes the generated lesson JSON to `lessons/<slug>_<timestamp>.json`.
`--input-file` reads a lesson input `.md` file and extracts the JSON user message block (for v0.2 branching lessons).
`--prompt-version` selects the prompt file; defaults to `0.2` when `--input-file` is given, `0.1` otherwise.

## Prompt Engineering Rules

- **Never edit a prompt file in place.** Copy it to the next version number, then edit.
- The system prompt lives between `## SYSTEM PROMPT` and the next `---` in the `.md` file. Everything outside that block is documentation only.
- The pedagogical principles (Feel Before Understand, Consequence Is The Teacher, Emotion Anchors Memory) are load-bearing — don't remove them, they drive lesson quality.
- The self-verify checklist at the end of the prompt is intentional — it forces the model to self-audit before outputting.

## Key Invariants

- `scoring.max_points` must equal the sum of `points_awarded` across the optimal path — the validator checks this conceptually but not arithmetically yet.
- Every `leads_to_scene` in choices must reference a real `scene.id` — the validator enforces this.
- `scoring.classroom_leaderboard.shareable_result_template` must contain at least one `{placeholder}` — required for the social layer.
