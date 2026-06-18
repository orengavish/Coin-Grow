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
