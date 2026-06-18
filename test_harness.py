"""
Coin Grow — Lesson Generator Test Harness
Calls the Claude API with the lesson generator prompt and validates the output.

Usage:
    python test_harness.py                              # v0.1, default topic
    python test_harness.py --prompt-version 0.2 --input-file prompts/lesson-01-input.md
    python test_harness.py --topic "Why save money?" --age 12-15 --save
    python test_harness.py --list

Requires:
    pip install anthropic
    ANTHROPIC_API_KEY environment variable set
"""

import os
import json
import argparse
import re
from pathlib import Path
from datetime import datetime

import anthropic

PROMPTS_DIR = Path(__file__).parent / "prompts"
LESSONS_DIR = Path(__file__).parent / "lessons"
CURRICULUM_FILE = Path(__file__).parent / "curriculum.json"

# ── v0.1 schema constants ─────────────────────────────────────────────────────
V1_TOP_KEYS = ["lesson", "world", "characters", "scenes", "scoring", "debrief"]
V1_LESSON_KEYS = ["id", "title", "topic", "age_group", "difficulty", "estimated_minutes", "learning_objectives"]
V1_SCENE_KEYS = ["id", "type", "narrative", "visual_description"]
V1_DEBRIEF_KEYS = ["concept_name", "concept_explanation", "real_world_connection", "teaser_next_lesson"]
V1_SCENE_TYPES = {"cutscene", "dialogue", "interactive", "choice", "outcome", "debrief"}
V1_FINANCIAL_QUALITY = {"optimal", "acceptable", "poor", "catastrophic"}

# ── v0.2 schema constants ─────────────────────────────────────────────────────
V2_TOP_KEYS = ["lesson", "world", "characters", "intro_scenes", "paths", "ending_scenes",
               "owl_library", "journal_templates", "scoring", "debrief"]
V2_CARD_KEYS = ["label", "effort", "time_estimate", "visible_reward"]
V2_EFFORT_VALUES = {"low", "medium", "high"}
V2_OWL_ENTRY_KEYS = ["id", "context", "bubble_label", "question", "answer"]


# ── Prompt loading ────────────────────────────────────────────────────────────

def find_prompt_file(version: str) -> Path:
    pattern = f"lesson-generator-v{version}.md"
    p = PROMPTS_DIR / pattern
    if p.exists():
        return p
    # Fallback: search for highest matching version
    candidates = sorted(PROMPTS_DIR.glob(f"lesson-generator-v{version}*.md"))
    if candidates:
        return candidates[-1]
    raise FileNotFoundError(f"No prompt file found for version {version} in {PROMPTS_DIR}")


def load_system_prompt(version: str) -> str:
    path = find_prompt_file(version)
    text = path.read_text(encoding="utf-8")
    match = re.search(r"## SYSTEM PROMPT\n+(.*)", text, re.DOTALL)
    if match:
        body = match.group(1)
        end = body.find("\n---\n")
        if end != -1:
            return body[:end].strip()
        return body.strip()
    return text


def load_input_file(input_path: Path) -> str:
    """Extract the JSON user message from a lesson input markdown file."""
    text = input_path.read_text(encoding="utf-8")
    # Find ```json ... ``` block
    match = re.search(r"```json\s*\n(.*?)```", text, re.DOTALL)
    if match:
        return match.group(1).strip()
    # Fallback: look for ## USER MESSAGE section
    match = re.search(r"## USER MESSAGE\s*\n+(.*)", text, re.DOTALL)
    if match:
        return match.group(1).strip()
    return text.strip()


# ── Curriculum helpers ────────────────────────────────────────────────────────

def load_curriculum() -> dict:
    return json.loads(CURRICULUM_FILE.read_text(encoding="utf-8"))


def find_lesson_in_curriculum(lesson_number: int) -> dict | None:
    curriculum = load_curriculum()
    for unit in curriculum["units"]:
        for lesson in unit["lessons"]:
            if lesson["lesson_number"] == lesson_number:
                return lesson
    return None


def build_user_message_v1(topic: str, age_group: str, difficulty: str, lesson_number: int = 1,
                           prior_concepts: list | None = None, setting_preference: str = "historical") -> str:
    payload = {
        "topic": topic,
        "age_group": age_group,
        "difficulty": difficulty,
        "setting_preference": setting_preference,
        "lesson_number": lesson_number,
        "prior_concepts": prior_concepts or [],
        "classroom_id": "classroom_demo_001",
    }
    return json.dumps(payload, indent=2)


# ── API call ─────────────────────────────────────────────────────────────────

def call_api(system_prompt: str, user_message: str, model: str = "claude-sonnet-4-6") -> str:
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    print(f"  Calling {model}...")
    message = client.messages.create(
        model=model,
        max_tokens=16000,
        system=[
            {
                "type": "text",
                "text": system_prompt,
                "cache_control": {"type": "ephemeral"},
            }
        ],
        messages=[{"role": "user", "content": user_message}],
        extra_headers={"anthropic-beta": "prompt-caching-2024-07-31"},
    )
    usage = message.usage
    cache_read = getattr(usage, "cache_read_input_tokens", 0) or 0
    cache_created = getattr(usage, "cache_creation_input_tokens", 0) or 0
    if cache_read:
        print(f"  Cache: HIT  ({cache_read:,} tokens read from cache — no charge)")
    elif cache_created:
        print(f"  Cache: MISS ({cache_created:,} tokens written to cache for next call)")
    return message.content[0].text


def parse_json(raw: str) -> dict:
    raw = raw.strip()
    if raw.startswith("```"):
        raw = re.sub(r"^```[a-z]*\n?", "", raw)
        raw = re.sub(r"\n?```$", "", raw)
    return json.loads(raw)


# ── Validation helpers ────────────────────────────────────────────────────────

def _is_bilingual(value: object) -> bool:
    return isinstance(value, dict) and "en" in value and "it" in value


def _check_bilingual(obj: dict, key: str, prefix: str, errors: list):
    if key not in obj:
        errors.append(f"{prefix}: missing '{key}'")
        return
    if not _is_bilingual(obj[key]):
        errors.append(f"{prefix}.{key}: must be bilingual {{en, it}} object, got {type(obj[key]).__name__}")


# ── v0.1 validator ────────────────────────────────────────────────────────────

def validate_v1(lesson: dict) -> list[str]:
    errors = []

    for key in V1_TOP_KEYS:
        if key not in lesson:
            errors.append(f"Missing top-level key: '{key}'")

    if "lesson" in lesson:
        l = lesson["lesson"]
        for key in V1_LESSON_KEYS:
            if key not in l:
                errors.append(f"lesson.{key} is missing")
        if "learning_objectives" in l and not isinstance(l["learning_objectives"], list):
            errors.append("lesson.learning_objectives must be a list")

    if "scenes" in lesson:
        scenes = lesson["scenes"]
        if not scenes:
            errors.append("scenes array is empty")
        scene_ids = {s.get("id") for s in scenes if "id" in s}
        has_choice = False
        for i, scene in enumerate(scenes):
            prefix = f"scenes[{i}]"
            for key in V1_SCENE_KEYS:
                if key not in scene:
                    errors.append(f"{prefix}: missing '{key}'")
            if scene.get("type") not in V1_SCENE_TYPES:
                errors.append(f"{prefix}: invalid type '{scene.get('type')}'")
            if scene.get("type") == "choice":
                has_choice = True
                choices = scene.get("choices", [])
                if len(choices) < 2:
                    errors.append(f"{prefix}: choice scene needs ≥ 2 choices")
                for c in choices:
                    if c.get("financial_quality") not in V1_FINANCIAL_QUALITY:
                        errors.append(f"{prefix}: choice '{c.get('id')}' has invalid financial_quality")
                    target = c.get("leads_to_scene")
                    if target and target not in scene_ids:
                        errors.append(f"{prefix}: leads_to_scene '{target}' not found in scene ids")
            if len(scene.get("narrative", "")) < 30:
                errors.append(f"{prefix}: narrative too short")
        if not has_choice:
            errors.append("No 'choice' scene found — lesson has no branching")

    if "debrief" in lesson:
        for key in V1_DEBRIEF_KEYS:
            if key not in lesson["debrief"]:
                errors.append(f"debrief.{key} is missing")

    if "scoring" in lesson:
        s = lesson["scoring"]
        if "classroom_leaderboard" in s:
            tmpl = s["classroom_leaderboard"].get("shareable_result_template", "")
            if "{" not in tmpl:
                errors.append("scoring.classroom_leaderboard.shareable_result_template has no {placeholders}")

    return errors


# ── v0.2 validator ────────────────────────────────────────────────────────────

def validate_v2(lesson: dict) -> list[str]:
    errors = []

    for key in V2_TOP_KEYS:
        if key not in lesson:
            errors.append(f"Missing top-level key: '{key}'")

    # intro_scenes
    intro = lesson.get("intro_scenes", [])
    if not intro:
        errors.append("intro_scenes is empty")
    else:
        last = intro[-1]
        if last.get("next_scene_id") is not None:
            errors.append("intro_scenes: last scene must have next_scene_id: null (triggers path selection)")
        for i, scene in enumerate(intro):
            prefix = f"intro_scenes[{i}]"
            _check_bilingual(scene, "narrative", prefix, errors)

    # paths
    paths = lesson.get("paths", [])
    if not paths:
        errors.append("paths array is empty")

    path_ids = {p.get("id") for p in paths if "id" in p}
    dead_end_count = 0
    live_path_count = 0
    path_points = lesson.get("scoring", {}).get("path_points", {})

    for i, path in enumerate(paths):
        prefix = f"paths[{i}] ({path.get('id', '?')})"
        is_dead = path.get("is_dead_end", False)

        # Card
        card = path.get("card")
        if not card:
            errors.append(f"{prefix}: missing 'card'")
        else:
            for k in V2_CARD_KEYS:
                if k not in card:
                    errors.append(f"{prefix}.card: missing '{k}'")
                elif k in ("label", "time_estimate", "visible_reward"):
                    if not _is_bilingual(card[k]):
                        errors.append(f"{prefix}.card.{k}: must be bilingual {{en, it}}")
            if card.get("effort") not in V2_EFFORT_VALUES:
                errors.append(f"{prefix}.card.effort: invalid '{card.get('effort')}' (must be low/medium/high)")

        if is_dead:
            dead_end_count += 1
            de = path.get("dead_end")
            if not de:
                errors.append(f"{prefix}: is_dead_end=true but missing 'dead_end' block")
            else:
                _check_bilingual(de, "micro_lesson", f"{prefix}.dead_end", errors)
                _check_bilingual(de, "owl_response", f"{prefix}.dead_end", errors)
            if "outcome" in path:
                errors.append(f"{prefix}: dead-end path must not have an 'outcome' block")
        else:
            live_path_count += 1
            outcome = path.get("outcome")
            if not outcome:
                errors.append(f"{prefix}: non-dead-end path missing 'outcome' block")
            else:
                if "earns" not in outcome:
                    errors.append(f"{prefix}.outcome: missing 'earns'")
                if "leads_to_orange" not in outcome:
                    errors.append(f"{prefix}.outcome: missing 'leads_to_orange'")
                if "steps_remaining" not in outcome:
                    errors.append(f"{prefix}.outcome: missing 'steps_remaining'")
            # Live paths should have points defined
            if path.get("id") not in path_points:
                errors.append(f"{prefix}: no entry in scoring.path_points")

    if dead_end_count == 0:
        errors.append("No dead-end paths — lesson has no failure teaching moments")
    if live_path_count == 0:
        errors.append("No live paths — player cannot complete the lesson")

    # ending_scenes
    ending = lesson.get("ending_scenes", [])
    if not ending:
        errors.append("ending_scenes is empty")
    else:
        for i, scene in enumerate(ending):
            _check_bilingual(scene, "narrative", f"ending_scenes[{i}]", errors)

    # owl_library
    owl_lib = lesson.get("owl_library", [])
    if len(owl_lib) < live_path_count + 1:
        errors.append(
            f"owl_library has {len(owl_lib)} entries — needs at least {live_path_count + 1} "
            f"(one per live path + one for the goal item)"
        )
    for i, entry in enumerate(owl_lib):
        prefix = f"owl_library[{i}]"
        for k in V2_OWL_ENTRY_KEYS:
            if k not in entry:
                errors.append(f"{prefix}: missing '{k}'")
        for k in ("bubble_label", "question", "answer"):
            if k in entry and not _is_bilingual(entry[k]):
                errors.append(f"{prefix}.{k}: must be bilingual {{en, it}}")

    # journal_templates
    jt = lesson.get("journal_templates", {})
    if not jt:
        errors.append("journal_templates is empty")
    else:
        for key, val in jt.items():
            if not _is_bilingual(val):
                errors.append(f"journal_templates.{key}: must be bilingual {{en, it}}")

    # scoring
    scoring = lesson.get("scoring", {})
    if path_points:
        max_pts = scoring.get("max_points")
        expected_max = max(path_points.values())
        if max_pts != expected_max:
            errors.append(
                f"scoring.max_points={max_pts} but highest path_points={expected_max} — must match"
            )
    if "trophy" in scoring:
        _check_bilingual(scoring["trophy"], "name", "scoring.trophy", errors)
        _check_bilingual(scoring["trophy"], "unlock_message", "scoring.trophy", errors)
    if "classroom_leaderboard" in scoring:
        tmpl = scoring["classroom_leaderboard"].get("shareable_result_template", {})
        if _is_bilingual(tmpl):
            for lang in ("en", "it"):
                if "{" not in tmpl.get(lang, ""):
                    errors.append(
                        f"scoring.classroom_leaderboard.shareable_result_template.{lang}: "
                        "no {{placeholder}}"
                    )
        else:
            errors.append("scoring.classroom_leaderboard.shareable_result_template must be bilingual")

    # debrief
    debrief = lesson.get("debrief", {})
    for key in ("concept_name", "concept_explanation", "real_world_connection",
                "reflection_question", "teaser_next_lesson"):
        _check_bilingual(debrief, key, "debrief", errors)

    return errors


def validate(lesson: dict, version: str) -> list[str]:
    detected = lesson.get("lesson", {}).get("version", "")
    use_v2 = version.startswith("0.2") or "v0.2" in detected
    return validate_v2(lesson) if use_v2 else validate_v1(lesson)


# ── Summary printers ──────────────────────────────────────────────────────────

def _en(val) -> str:
    if isinstance(val, dict):
        return val.get("en", str(val))
    return str(val) if val is not None else ""


def print_summary_v1(lesson: dict):
    l = lesson.get("lesson", {})
    world = lesson.get("world", {})
    scenes = lesson.get("scenes", [])
    scoring = lesson.get("scoring", {})
    debrief = lesson.get("debrief", {})

    print("\n" + "=" * 60)
    print(f"  {l.get('title', 'Untitled')}")
    print("=" * 60)
    print(f"  Topic       : {l.get('topic')}")
    print(f"  Age group   : {l.get('age_group')}  |  Difficulty: {l.get('difficulty')}")
    print(f"  Est. time   : {l.get('estimated_minutes')} min")
    print(f"  Scenes      : {len(scenes)} total")
    print(f"  Max points  : {scoring.get('max_points')}")
    trophy = scoring.get("trophy", {})
    print(f"  Trophy      : {trophy.get('name')}")
    print(f"\n  Concept     : {debrief.get('concept_name')}")
    print(f"  Next lesson : {debrief.get('teaser_next_lesson')}")
    print()
    print("  Scene flow:")
    for scene in scenes:
        marker = ">" if scene.get("type") == "choice" else " "
        print(f"  {marker} [{scene.get('type'):12s}] {scene.get('id')}")
    print()


def print_summary_v2(lesson: dict):
    l = lesson.get("lesson", {})
    paths = lesson.get("paths", [])
    scoring = lesson.get("scoring", {})
    debrief = lesson.get("debrief", {})
    owl_lib = lesson.get("owl_library", [])

    print("\n" + "=" * 60)
    print(f"  {l.get('title', 'Untitled')}")
    print("=" * 60)
    print(f"  Topic       : {l.get('topic')}")
    print(f"  Concept     : {l.get('concept')}")
    print(f"  Age group   : {l.get('age_group')}  |  Difficulty: {l.get('difficulty')}")
    print(f"  Est. time   : {l.get('estimated_minutes')} min")
    print(f"  Paths       : {len(paths)} total  "
          f"({sum(1 for p in paths if not p.get('is_dead_end'))} live, "
          f"{sum(1 for p in paths if p.get('is_dead_end'))} dead ends)")
    print(f"  Owl library : {len(owl_lib)} entries")
    print(f"  Max points  : {scoring.get('max_points')}")
    trophy = scoring.get("trophy", {})
    print(f"  Trophy      : {_en(trophy.get('name'))}")
    print()
    print(f"  Debrief     : {_en(debrief.get('concept_explanation', ''))[:110]}...")
    print(f"  Next lesson : {_en(debrief.get('teaser_next_lesson'))}")
    print()

    print("  Paths:")
    path_points = scoring.get("path_points", {})
    for path in paths:
        pid = path.get("id", "?")
        card = path.get("card", {})
        dead = path.get("is_dead_end", False)
        effort = card.get("effort", "?")
        reward = _en(card.get("visible_reward", "?"))
        pts = path_points.get(pid, "—")
        dead_tag = " [DEAD END]" if dead else f"  {pts} pts"
        print(f"    {effort:6s}  {_en(card.get('label', pid)):40s}{dead_tag}")
        if not dead:
            outcome = path.get("outcome", {})
            print(f"           earns: {outcome.get('earns', '?')}  |  "
                  f"steps_remaining: {outcome.get('steps_remaining', '?')}")
    print()

    print("  Owl library topics:")
    for entry in owl_lib:
        print(f"    [{entry.get('context', '?'):22s}]  {_en(entry.get('bubble_label', '?'))}")
    print()


def print_summary(lesson: dict, version: str):
    detected = lesson.get("lesson", {}).get("version", "")
    if version.startswith("0.2") or "v0.2" in detected:
        print_summary_v2(lesson)
    else:
        print_summary_v1(lesson)


# ── Save ─────────────────────────────────────────────────────────────────────

def save_lesson(lesson: dict):
    LESSONS_DIR.mkdir(exist_ok=True)
    lesson_id = lesson.get("lesson", {}).get("id") or lesson.get("lesson", {}).get("title", "lesson")
    slug = re.sub(r"[^a-z0-9]+", "_", str(lesson_id).lower()).strip("_")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = LESSONS_DIR / f"{slug}_{timestamp}.json"
    filename.write_text(json.dumps(lesson, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  Saved to: {filename}")
    return filename


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Coin Grow lesson generator test harness")
    parser.add_argument("--prompt-version", default=None,
                        help="Prompt version to use: '0.1' or '0.2' (default: auto)")
    parser.add_argument("--input-file", default=None,
                        help="Path to lesson input .md file (extracts JSON user message)")
    parser.add_argument("--lesson-number", type=int, default=None,
                        help="Load topic/prior_concepts from curriculum.json")
    parser.add_argument("--topic", default=None)
    parser.add_argument("--age", default="12-15", choices=["8-11", "12-15", "16+"])
    parser.add_argument("--difficulty", default="beginner",
                        choices=["beginner", "intermediate", "advanced"])
    parser.add_argument("--save", action="store_true", help="Save generated JSON to lessons/")
    parser.add_argument("--model", default="claude-sonnet-4-6")
    parser.add_argument("--list", action="store_true", help="List curriculum and exit")
    args = parser.parse_args()

    if args.list:
        curriculum = load_curriculum()
        print(f"\nCoin Grow Curriculum — {len(curriculum['units'])} units\n")
        for unit in curriculum["units"]:
            print(f"  Unit {unit['unit']}: {unit['title']}")
            for lesson in unit["lessons"]:
                print(f"    [{lesson['lesson_number']:2d}] {lesson['topic']}")
        print()
        return 0

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: ANTHROPIC_API_KEY environment variable not set.")
        print("  $env:ANTHROPIC_API_KEY = 'sk-ant-...'")
        return 1

    # Resolve prompt version
    if args.input_file:
        version = args.prompt_version or "0.2"
    else:
        version = args.prompt_version or "0.1"

    # Build user message
    if args.input_file:
        input_path = Path(args.input_file)
        if not input_path.exists():
            print(f"ERROR: input file not found: {input_path}")
            return 1
        user_message = load_input_file(input_path)
        label = input_path.name
    else:
        prior_concepts = []
        setting_preference = "historical"
        lesson_number = args.lesson_number or 1
        if args.lesson_number is not None:
            entry = find_lesson_in_curriculum(args.lesson_number)
            if entry:
                topic = args.topic or entry["topic"]
                prior_concepts = entry.get("prior_concepts", [])
                setting_preference = entry.get("setting_preference", "historical")
                lesson_number = entry["lesson_number"]
            else:
                print(f"ERROR: lesson #{args.lesson_number} not in curriculum.json")
                return 1
        else:
            topic = args.topic or "What is money and why does it exist?"
        user_message = build_user_message_v1(topic, args.age, args.difficulty,
                                             lesson_number, prior_concepts, setting_preference)
        label = f"#{lesson_number} — {topic}"

    # Find prompt file
    try:
        prompt_path = find_prompt_file(version)
    except FileNotFoundError as e:
        print(f"ERROR: {e}")
        return 1

    print(f"\nCoin Grow Lesson Generator — Test Harness")
    print(f"  Prompt  : {prompt_path.name}")
    print(f"  Input   : {label}")
    print(f"  Age     : {args.age}  |  Difficulty: {args.difficulty}")
    print()

    system_prompt = load_system_prompt(version)

    print("  [1/3] Calling API...")
    raw = call_api(system_prompt, user_message, model=args.model)

    print("  [2/3] Parsing JSON...")
    try:
        lesson = parse_json(raw)
    except json.JSONDecodeError as e:
        print(f"\nFAIL: JSON parse error — {e}")
        print("\nRaw output (first 500 chars):")
        print(raw[:500])
        return 1

    print("  [3/3] Validating...")
    errors = validate(lesson, version)

    if errors:
        print(f"\nVALIDATION: {len(errors)} issue(s):")
        for err in errors:
            print(f"  - {err}")
    else:
        print("  Validation: PASS")

    print_summary(lesson, version)

    if args.save:
        save_lesson(lesson)

    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
