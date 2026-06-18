# Prompt Changelog

This file tracks every change to the lesson generator prompt and the reasoning behind it.
The prompt is the core IP — changes must be documented, not just versioned.

---

## v0.1 — Initial version (2026-06-18)

**File:** `prompts/lesson-generator-v0.1.md`

**What it does:**
- Generates a complete financial literacy lesson as hybrid JSON
- Covers: world setting, characters, scene flow (cutscene/dialogue/choice/outcome/debrief), scoring, classroom leaderboard, debrief
- Includes 5 pedagogical principles as hard constraints
- Self-verify checklist forces model to audit before outputting

**Known limitations:**
- Schema validation is done externally (test_harness.py) — the prompt doesn't self-correct on schema errors
- Setting is always historical by default; modern/fantasy variants untested
- Age adaptation is instructed but not tested across all three age groups
- No multi-lesson continuity (each lesson is stateless)

**Next planned changes:**
- Test age adaptation across 8-11 / 12-15 / 16+ and tighten the language guidance
- Add explicit instruction to vary scene count (currently unspecified, model decides)
- Consider adding a `difficulty_mechanics` field to drive actual game mechanic complexity

---

## v0.2 — Branching + i18n + Owl Library (2026-06-18)

**File:** `prompts/lesson-generator-v0.2.md`
**Lesson 1 input:** `prompts/lesson-01-input.md`

**Why this version exists:**
Lesson 1 (The Orange Quest) required a fundamentally different schema from v0.1. The lesson is non-linear: the player chooses from 3-5 paths, some dead-end, some chain through multiple trades. v0.1's linear scene array cannot represent this.

**What changed:**

*Schema:*
- `scenes` array replaced by `intro_scenes` + `paths` + `ending_scenes` — three zones, only the middle is branching
- Each path has a `card` (what the player sees before committing: label, effort, time, visible reward)
- Dead-end paths have a `dead_end` object with `micro_lesson` and `owl_response`
- Non-dead-end paths have an `outcome` object (what's earned, steps remaining to goal)
- New top-level `owl_library`: pre-generated Q&A pairs the owl can answer in-game
- New top-level `journal_templates`: auto-written entries for My Journey screen
- All player-facing strings are now bilingual objects `{ "en": ..., "it": ... }`

*Pedagogy:*
- The Owl is now formally specified in the prompt with voice rules and minimum library requirements
- Dead ends are required to teach a micro-lesson — they are not failures, they are scenes
- The emotional hook must be established before any path card is shown (Zone 1 must complete first)

*i18n:*
- First version to support Italian alongside English
- Locale variants documented for Tomas (Tommaso) and Dov (Davide)
- Italian must read naturally — the prompt explicitly forbids literal translation

**Known limitations:**
- Chained paths (fish → bread → silk → orange) are described in path notes but the schema does not yet model sub-paths formally — the AI must infer the chain structure from the notes field
- No validation yet for owl_library coverage (checklist is manual)
- Italian quality depends entirely on the model — no human review pass yet

**Next planned changes:**
- Add explicit sub-path schema for chain trades (path within a path)
- Add owl_library validator to test_harness.py
- Test with a human Italian speaker and iterate on voice quality
