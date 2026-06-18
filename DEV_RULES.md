# Coin Grow — Development Rules

## Versioning & Git

- **Push to GitHub after every meaningful step** — no accumulating work locally
- Remote: `https://github.com/orengavish/Coin-Grow`
- Commit message format: `[scope] short description` — e.g. `[prompt] v0.2 adds age adaptation`, `[harness] add batch runner`
- Scopes: `prompt`, `harness`, `curriculum`, `docs`, `config`, `shell`, `backend`
- **Never force-push main.** Feature branches are fine to force-push.
- Tag every prompt version: `prompt-v0.1`, `prompt-v0.2`, etc.

## Prompt Versioning (Core IP Rule)

- **Never edit a prompt file in place.** Always copy to next version: `lesson-generator-v0.2.md`
- The active prompt version is the highest-numbered file in `prompts/`
- Every generated lesson JSON records the prompt version that created it (`lesson.version`)
- When changing the schema (adding/removing fields), increment the major version
- When tuning wording or principles, increment the minor version

## MD Files — Mandatory Review at Each Step

At the end of every dev step, review and update all MD files as needed:

| File | What to keep current |
|---|---|
| `CLAUDE.md` | Commands, architecture, invariants |
| `PROJECT_SCOPE.md` | In/out of scope, milestone, team |
| `DEV_RULES.md` | This file — rules evolve |
| `PROMPT_CHANGELOG.md` | What changed in each prompt version and why |
| `EXCEPTIONS.md` | Known issues, workarounds, technical debt |

If a section is still accurate, leave it. If stale, update it. Never skip this step.

## Session End Checklist

A coding session is not complete until ALL of the following pass:

- [ ] `python test_harness.py --list` shows curriculum correctly
- [ ] No Python syntax errors (`python -m py_compile test_harness.py app.py`)
- [ ] All changed files committed and pushed to GitHub
- [ ] All MD files reviewed and updated
- [ ] `git log --oneline -5` shows clean, meaningful commit messages

Visual tests (game UI, animations) are explicitly excluded until the mobile shell exists.

## Code Style

- Python only for tooling (test harness, validators, batch runners)
- No dependencies beyond `anthropic` unless discussed and added to `requirements.txt`
- No print statements left as debug — use the structured print functions
- Type hints on all new functions

## Cost Discipline

- The system prompt is always sent with `cache_control: ephemeral` — never remove this
- Use `claude-sonnet-4-6` as default model for generation
- Use `claude-haiku-4-5` for any validation-only or cheap tasks
- Batch generation (running multiple lessons) should always use the cached prompt

## File Layout Rules

```
prompts/          ← versioned prompt files only, never delete old versions
lessons/          ← git-ignored, runtime output
curriculum.json   ← single source of truth for lesson ordering
app.py            ← Streamlit UI, primary interface
test_harness.py   ← CLI fallback, same logic as app.py
```
