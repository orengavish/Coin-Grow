# Exceptions, Known Issues & Technical Debt

## Active Issues

### EX-001 — max_points arithmetic not validated
**File:** `test_harness.py` → `validate()`
**Issue:** The validator checks conceptually that `max_points` should equal the sum of optimal-path `points_awarded`, but does not trace the actual optimal path through the scene graph and sum the values arithmetically.
**Workaround:** Manual spot-check when reviewing generated lessons.
**Fix planned:** Add a scene graph traversal that follows `financial_quality: optimal` branches and sums points.

### EX-002 — System prompt extraction is fragile
**File:** `test_harness.py` → `load_system_prompt()`
**Issue:** Extracts system prompt by searching for `## SYSTEM PROMPT` header and cutting at next `---`. If prompt file format changes, this silently fails and sends the whole file as the system prompt.
**Workaround:** Keep the `## SYSTEM PROMPT` / `---` delimiters intact in all prompt files.
**Fix planned:** Add an assertion that extracted prompt is non-empty and under 20K chars.

### EX-003 — No retry on API failure
**File:** `test_harness.py` → `call_api()`
**Issue:** A transient API error or JSON parse failure kills the run with no retry.
**Workaround:** Re-run manually.
**Fix planned:** Add exponential backoff retry (max 3 attempts) for network errors and JSON parse failures.

### EX-004 — Prompt cache only valid within same session
**Note:** Anthropic prompt cache TTL is 5 minutes. If test runs are spaced more than 5 minutes apart, the first call of a new session will always be a cache miss (paying full price). This is expected behavior, not a bug.

## Resolved Issues

*(none yet)*

## Technical Debt

- `test_harness.py` has no unit tests of its own validator logic
- `curriculum.json` has no JSON schema validation — malformed entries will silently produce wrong lesson inputs
