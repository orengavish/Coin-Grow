# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

Coin Grow is an AI-generated financial literacy game for mobile (iOS/Android). The **prompt is the product** — the AI prompt engine generates all lesson content (quests, narratives, branching outcomes, debriefs). The game shell is just a delivery vehicle.

Target audience: kids (8+) through adults. Social layer: classrooms compete against each other, schools against schools. Future tier: market simulator for investment competitions.

Team: two co-founders, pre-funding. No game engine or mobile shell exists yet — the current milestone is a working, validated prompt engine.

## Architecture

```
prompts/                  ← Core IP. Versioned prompt files. Never overwrite — always create a new version.
  lesson-generator-v0.1.md
lessons/                  ← Generated lesson JSON files (git-ignored, created at runtime by --save flag)
test_harness.py           ← CLI that calls the API, parses output, validates schema, prints summary
requirements.txt
```

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

## Running the Test Harness

```powershell
pip install anthropic

$env:ANTHROPIC_API_KEY = "sk-ant-..."

# Default run (Lesson 1, age 12-15, beginner)
python test_harness.py

# Custom lesson
python test_harness.py --topic "Why save money?" --age 8-11 --difficulty beginner --save

# All options
python test_harness.py --topic "..." --age [8-11|12-15|16+] --difficulty [beginner|intermediate|advanced] --lesson-number 2 --model claude-sonnet-4-6 --save
```

`--save` writes the generated lesson JSON to `lessons/<slug>_<timestamp>.json`.

## Prompt Engineering Rules

- **Never edit a prompt file in place.** Copy it to the next version number, then edit.
- The system prompt lives between `## SYSTEM PROMPT` and the next `---` in the `.md` file. Everything outside that block is documentation only.
- The pedagogical principles (Feel Before Understand, Consequence Is The Teacher, Emotion Anchors Memory) are load-bearing — don't remove them, they drive lesson quality.
- The self-verify checklist at the end of the prompt is intentional — it forces the model to self-audit before outputting.

## Key Invariants

- `scoring.max_points` must equal the sum of `points_awarded` across the optimal path — the validator checks this conceptually but not arithmetically yet.
- Every `leads_to_scene` in choices must reference a real `scene.id` — the validator enforces this.
- `scoring.classroom_leaderboard.shareable_result_template` must contain at least one `{placeholder}` — required for the social layer.
