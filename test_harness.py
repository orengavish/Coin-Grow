"""
Coin Grow — Lesson Generator Test Harness
Calls the Claude API with the lesson generator prompt and validates the output.

Usage:
    python test_harness.py
    python test_harness.py --topic "Why save money?" --age 12-15 --difficulty beginner
    python test_harness.py --save  # saves generated lesson to lessons/ directory

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

PROMPT_FILE = Path(__file__).parent / "prompts" / "lesson-generator-v0.1.md"
LESSONS_DIR = Path(__file__).parent / "lessons"
CURRICULUM_FILE = Path(__file__).parent / "curriculum.json"

REQUIRED_TOP_LEVEL_KEYS = ["lesson", "world", "characters", "scenes", "scoring", "debrief"]
REQUIRED_LESSON_KEYS = ["id", "title", "topic", "age_group", "difficulty", "estimated_minutes", "learning_objectives"]
REQUIRED_SCENE_KEYS = ["id", "type", "narrative", "visual_description"]
REQUIRED_DEBRIEF_KEYS = ["concept_name", "concept_explanation", "real_world_connection", "teaser_next_lesson"]
VALID_SCENE_TYPES = {"cutscene", "dialogue", "interactive", "choice", "outcome", "debrief"}
VALID_FINANCIAL_QUALITY = {"optimal", "acceptable", "poor", "catastrophic"}


def load_system_prompt() -> str:
    text = PROMPT_FILE.read_text(encoding="utf-8")
    # Strip everything up to and including "## SYSTEM PROMPT"
    match = re.search(r"## SYSTEM PROMPT\n+(.*)", text, re.DOTALL)
    if match:
        # Cut off at the first "---" separator after the system prompt header
        body = match.group(1)
        end = body.find("\n---\n")
        if end != -1:
            return body[:end].strip()
        return body.strip()
    return text  # fallback: use the whole file


def load_curriculum() -> dict:
    return json.loads(CURRICULUM_FILE.read_text(encoding="utf-8"))


def find_lesson_in_curriculum(lesson_number: int) -> dict | None:
    curriculum = load_curriculum()
    for unit in curriculum["units"]:
        for lesson in unit["lessons"]:
            if lesson["lesson_number"] == lesson_number:
                return lesson
    return None


def build_user_message(topic: str, age_group: str, difficulty: str, lesson_number: int = 1,
                       prior_concepts: list | None = None, setting_preference: str = "historical") -> str:
    payload = {
        "topic": topic,
        "age_group": age_group,
        "difficulty": difficulty,
        "setting_preference": setting_preference,
        "lesson_number": lesson_number,
        "prior_concepts": prior_concepts or [],
        "classroom_id": "classroom_demo_001"
    }
    return json.dumps(payload, indent=2)


def call_api(system_prompt: str, user_message: str, model: str = "claude-sonnet-4-6") -> str:
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    print(f"  Calling {model}...")
    message = client.messages.create(
        model=model,
        max_tokens=8192,
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
    # Strip markdown fences if the model included them despite instructions
    raw = raw.strip()
    if raw.startswith("```"):
        raw = re.sub(r"^```[a-z]*\n?", "", raw)
        raw = re.sub(r"\n?```$", "", raw)
    return json.loads(raw)


def validate(lesson: dict) -> list[str]:
    errors = []

    # Top-level keys
    for key in REQUIRED_TOP_LEVEL_KEYS:
        if key not in lesson:
            errors.append(f"Missing top-level key: '{key}'")

    if "lesson" in lesson:
        l = lesson["lesson"]
        for key in REQUIRED_LESSON_KEYS:
            if key not in l:
                errors.append(f"lesson.{key} is missing")
        if "learning_objectives" in l and not isinstance(l["learning_objectives"], list):
            errors.append("lesson.learning_objectives must be a list")

    if "scenes" in lesson:
        scenes = lesson["scenes"]
        if not scenes:
            errors.append("scenes array is empty")
        scene_ids = {s.get("id") for s in scenes if "id" in s}
        has_choice_scene = False
        for i, scene in enumerate(scenes):
            prefix = f"scenes[{i}]"
            for key in REQUIRED_SCENE_KEYS:
                if key not in scene:
                    errors.append(f"{prefix}: missing '{key}'")
            if scene.get("type") not in VALID_SCENE_TYPES:
                errors.append(f"{prefix}: invalid type '{scene.get('type')}'")
            if scene.get("type") == "choice":
                has_choice_scene = True
                choices = scene.get("choices", [])
                if len(choices) < 2:
                    errors.append(f"{prefix}: choice scene must have at least 2 choices")
                for c in choices:
                    if c.get("financial_quality") not in VALID_FINANCIAL_QUALITY:
                        errors.append(f"{prefix}: choice '{c.get('id')}' has invalid financial_quality")
                    target = c.get("leads_to_scene")
                    if target and target not in scene_ids:
                        errors.append(f"{prefix}: choice leads_to_scene '{target}' not found in scene ids")
            narrative = scene.get("narrative", "")
            if len(narrative) < 30:
                errors.append(f"{prefix}: narrative too short ({len(narrative)} chars)")
        if not has_choice_scene:
            errors.append("No 'choice' type scene found — lesson has no branching")

    if "debrief" in lesson:
        for key in REQUIRED_DEBRIEF_KEYS:
            if key not in lesson["debrief"]:
                errors.append(f"debrief.{key} is missing")

    if "scoring" in lesson:
        s = lesson["scoring"]
        if "classroom_leaderboard" in s:
            tmpl = s["classroom_leaderboard"].get("shareable_result_template", "")
            if "{" not in tmpl:
                errors.append("scoring.classroom_leaderboard.shareable_result_template has no {placeholders}")

    return errors


def print_summary(lesson: dict):
    l = lesson.get("lesson", {})
    world = lesson.get("world", {})
    scenes = lesson.get("scenes", [])
    scoring = lesson.get("scoring", {})
    debrief = lesson.get("debrief", {})

    print("\n" + "="*60)
    print(f"  {l.get('title', 'Untitled')}")
    print(f"  {l.get('subtitle', '')}")
    print("="*60)
    print(f"  Topic       : {l.get('topic')}")
    print(f"  Age group   : {l.get('age_group')}  |  Difficulty: {l.get('difficulty')}")
    print(f"  Est. time   : {l.get('estimated_minutes')} min")
    print(f"  Setting     : {world.get('era')}, {world.get('location')}")
    print(f"  Scenes      : {len(scenes)} total")
    choice_scenes = [s for s in scenes if s.get("type") == "choice"]
    print(f"  Choice pts  : {len(choice_scenes)} branching moment(s)")
    print(f"  Max points  : {scoring.get('max_points')}")
    trophy = scoring.get("trophy", {})
    print(f"  Trophy      : {trophy.get('name')}")
    print(f"\n  Concept     : {debrief.get('concept_name')}")
    print(f"  Debrief     : {debrief.get('concept_explanation', '')[:120]}...")
    print(f"  Next lesson : {debrief.get('teaser_next_lesson')}")
    print()

    print("  Learning objectives:")
    for obj in l.get("learning_objectives", []):
        print(f"    - {obj}")
    print()

    print("  Scene flow:")
    for scene in scenes:
        marker = ">" if scene.get("type") == "choice" else " "
        print(f"  {marker} [{scene.get('type'):12s}] {scene.get('id'):12s} — {scene.get('title', '')}")
    print()


def save_lesson(lesson: dict, topic: str):
    LESSONS_DIR.mkdir(exist_ok=True)
    slug = lesson.get("lesson", {}).get("id", "lesson")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = LESSONS_DIR / f"{slug}_{timestamp}.json"
    filename.write_text(json.dumps(lesson, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"  Saved to: {filename}")
    return filename


def main():
    parser = argparse.ArgumentParser(description="Coin Grow lesson generator test harness")
    parser.add_argument("--lesson-number", type=int, default=None,
                        help="Load topic/prior_concepts/setting from curriculum.json by lesson number")
    parser.add_argument("--topic", default=None, help="Override or set topic manually")
    parser.add_argument("--age", default="12-15", choices=["8-11", "12-15", "16+"])
    parser.add_argument("--difficulty", default="beginner", choices=["beginner", "intermediate", "advanced"])
    parser.add_argument("--save", action="store_true", help="Save generated lesson JSON to lessons/")
    parser.add_argument("--model", default="claude-sonnet-4-6")
    parser.add_argument("--list", action="store_true", help="List all lessons in the curriculum and exit")
    args = parser.parse_args()

    if args.list:
        curriculum = load_curriculum()
        print(f"\nCoin Grow Curriculum — {len(curriculum['units'])} units\n")
        for unit in curriculum["units"]:
            print(f"  Unit {unit['unit']}: {unit['title']}")
            for lesson in unit["lessons"]:
                ages = ", ".join(lesson["age_variants"])
                print(f"    [{lesson['lesson_number']:2d}] {lesson['topic']}")
                print(f"          Ages: {ages}  |  Concept: {lesson['concept']}")
        print()
        return 0

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: ANTHROPIC_API_KEY environment variable not set.")
        print("  Set it with: $env:ANTHROPIC_API_KEY = 'sk-ant-...'")
        return 1

    # Resolve lesson params from curriculum or CLI args
    prior_concepts = []
    setting_preference = "historical"
    lesson_number = args.lesson_number or 1

    if args.lesson_number is not None:
        entry = find_lesson_in_curriculum(args.lesson_number)
        if entry:
            topic = args.topic or entry["topic"]
            prior_concepts = entry["prior_concepts"]
            setting_preference = entry["setting_preference"]
            lesson_number = entry["lesson_number"]
        else:
            print(f"ERROR: lesson_number {args.lesson_number} not found in curriculum.json")
            return 1
    else:
        topic = args.topic or "What is money and why does it exist?"

    print(f"\nCoin Grow Lesson Generator — Test Harness")
    print(f"  Prompt  : {PROMPT_FILE.name}")
    print(f"  Lesson  : #{lesson_number} — {topic}")
    print(f"  Age     : {args.age}  |  Difficulty: {args.difficulty}")
    print(f"  Prior   : {prior_concepts or 'none'}")
    print()

    system_prompt = load_system_prompt()
    user_message = build_user_message(topic, args.age, args.difficulty, lesson_number,
                                      prior_concepts, setting_preference)

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
    errors = validate(lesson)

    if errors:
        print(f"\nVALIDATION: {len(errors)} issue(s) found:")
        for err in errors:
            print(f"  - {err}")
    else:
        print("  Validation: PASS — all checks passed")

    print_summary(lesson)

    if args.save:
        save_lesson(lesson, args.topic)

    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
