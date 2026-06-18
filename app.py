"""
Coin Grow — Lesson Generator Studio
Streamlit app for generating and inspecting lessons from the prompt engine.
Run: streamlit run app.py
"""

import os
import json
import re
from pathlib import Path
from datetime import datetime

import streamlit as st
import anthropic

PROMPTS_DIR = Path(__file__).parent / "prompts"
LESSONS_DIR = Path(__file__).parent / "lessons"
CURRICULUM_FILE = Path(__file__).parent / "curriculum.json"

st.set_page_config(
    page_title="Coin Grow — Lesson Studio",
    page_icon="🪙",
    layout="wide",
)


# ── Data loaders ────────────────────────────────────────────────────────────

@st.cache_data
def load_curriculum() -> dict:
    return json.loads(CURRICULUM_FILE.read_text(encoding="utf-8"))


def get_prompt_versions() -> list[str]:
    files = sorted(PROMPTS_DIR.glob("lesson-generator-v*.md"), reverse=True)
    return [f.name for f in files]


def load_prompt(filename: str) -> str:
    text = (PROMPTS_DIR / filename).read_text(encoding="utf-8")
    match = re.search(r"## SYSTEM PROMPT\n+(.*)", text, re.DOTALL)
    if match:
        body = match.group(1)
        end = body.find("\n---\n")
        return body[:end].strip() if end != -1 else body.strip()
    return text


def build_lesson_options(curriculum: dict) -> dict[str, dict]:
    """Returns {display_label: lesson_entry} for the selectbox."""
    options = {"— Custom topic —": None}
    for unit in curriculum["units"]:
        for lesson in unit["lessons"]:
            label = f"[{lesson['lesson_number']:02d}] {lesson['topic']}"
            options[label] = lesson
    return options


# ── API call ────────────────────────────────────────────────────────────────

def generate_lesson(system_prompt: str, topic: str, age_group: str,
                    difficulty: str, lesson_number: int,
                    prior_concepts: list[str], setting: str,
                    model: str, api_key: str) -> tuple[dict | None, dict, str]:
    """Returns (lesson_dict_or_None, usage_stats, raw_text)."""
    client = anthropic.Anthropic(api_key=api_key)
    payload = {
        "topic": topic,
        "age_group": age_group,
        "difficulty": difficulty,
        "setting_preference": setting,
        "lesson_number": lesson_number,
        "prior_concepts": prior_concepts,
        "classroom_id": "studio_preview",
    }
    message = client.messages.create(
        model=model,
        max_tokens=8192,
        system=[{"type": "text", "text": system_prompt, "cache_control": {"type": "ephemeral"}}],
        messages=[{"role": "user", "content": json.dumps(payload, indent=2)}],
        extra_headers={"anthropic-beta": "prompt-caching-2024-07-31"},
    )
    raw = message.content[0].text.strip()
    if raw.startswith("```"):
        raw = re.sub(r"^```[a-z]*\n?", "", raw)
        raw = re.sub(r"\n?```$", "", raw)

    usage = message.usage
    stats = {
        "input_tokens": usage.input_tokens,
        "output_tokens": usage.output_tokens,
        "cache_read": getattr(usage, "cache_read_input_tokens", 0) or 0,
        "cache_created": getattr(usage, "cache_creation_input_tokens", 0) or 0,
    }
    try:
        return json.loads(raw), stats, raw
    except json.JSONDecodeError:
        return None, stats, raw


def validate_lesson(lesson: dict) -> list[str]:
    errors = []
    required_top = ["lesson", "world", "characters", "scenes", "scoring", "debrief"]
    for k in required_top:
        if k not in lesson:
            errors.append(f"Missing top-level key: `{k}`")
    scenes = lesson.get("scenes", [])
    scene_ids = {s.get("id") for s in scenes}
    has_choice = False
    for i, scene in enumerate(scenes):
        if scene.get("type") == "choice":
            has_choice = True
            for c in scene.get("choices", []):
                target = c.get("leads_to_scene")
                if target and target not in scene_ids:
                    errors.append(f"Scene `{scene['id']}`: choice leads to unknown scene `{target}`")
        if len(scene.get("narrative", "")) < 30:
            errors.append(f"Scene `{scene.get('id')}`: narrative too short")
    if scenes and not has_choice:
        errors.append("No choice scene found — lesson has no branching")
    tmpl = lesson.get("scoring", {}).get("classroom_leaderboard", {}).get("shareable_result_template", "")
    if tmpl and "{" not in tmpl:
        errors.append("Leaderboard template has no `{placeholders}`")
    return errors


def save_lesson(lesson: dict) -> Path:
    LESSONS_DIR.mkdir(exist_ok=True)
    slug = lesson.get("lesson", {}).get("id", "lesson")
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    path = LESSONS_DIR / f"{slug}_{ts}.json"
    path.write_text(json.dumps(lesson, indent=2, ensure_ascii=False), encoding="utf-8")
    return path


# ── UI ───────────────────────────────────────────────────────────────────────

def render_lesson(lesson: dict):
    l = lesson.get("lesson", {})
    world = lesson.get("world", {})
    scenes = lesson.get("scenes", [])
    scoring = lesson.get("scoring", {})
    debrief = lesson.get("debrief", {})
    chars = lesson.get("characters", [])

    st.subheader(l.get("title", "Untitled"))
    st.caption(l.get("subtitle", ""))

    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Age group", l.get("age_group", "—"))
    col2.metric("Difficulty", l.get("difficulty", "—"))
    col3.metric("Est. time", f"{l.get('estimated_minutes', '?')} min")
    col4.metric("Max points", scoring.get("max_points", "—"))

    st.markdown(f"**Setting:** {world.get('era', '')} — {world.get('location', '')}")
    st.markdown(f"**Atmosphere:** {world.get('atmosphere', '')}")

    with st.expander("Learning objectives"):
        for obj in l.get("learning_objectives", []):
            st.markdown(f"- {obj}")

    st.divider()

    # Characters
    with st.expander(f"Characters ({len(chars)})"):
        for char in chars:
            st.markdown(f"**{char.get('name')}** — *{char.get('role')}*")
            st.markdown(f"> {char.get('personality', '')}")
            st.markdown(f"Dialogue style: {char.get('dialogue_style', '')}")
            st.markdown("---")

    # Scene flow
    st.markdown("### Scene flow")
    for scene in scenes:
        icon = {"cutscene": "🎬", "dialogue": "💬", "interactive": "🎮",
                "choice": "🔀", "outcome": "📊", "debrief": "💡"}.get(scene.get("type", ""), "▪")
        with st.expander(f"{icon} `{scene.get('id')}` — {scene.get('title', scene.get('type', ''))}"):
            st.markdown(f"**Narrative:**\n\n{scene.get('narrative', '')}")
            if scene.get("npc_dialogue"):
                st.markdown("**Dialogue:**")
                for line in scene["npc_dialogue"]:
                    st.markdown(f"- **{line.get('character_id')}** *({line.get('emotion', '')})*: \"{line.get('line', '')}\"")
            if scene.get("choices"):
                st.markdown("**Choices:**")
                for c in scene["choices"]:
                    quality_color = {"optimal": "🟢", "acceptable": "🟡", "poor": "🟠", "catastrophic": "🔴"}.get(c.get("financial_quality", ""), "⚪")
                    st.markdown(f"{quality_color} **{c.get('label')}** → `{c.get('leads_to_scene')}` ({c.get('financial_quality')})")
            if scene.get("outcome"):
                out = scene["outcome"]
                st.markdown(f"**Outcome:** {out.get('narrative_result', '')} *(+{out.get('points_awarded', 0)} pts)*")

    st.divider()

    # Debrief
    st.markdown("### Debrief")
    st.markdown(f"**Concept:** {debrief.get('concept_name', '')}")
    st.markdown(debrief.get("concept_explanation", ""))
    st.markdown(f"**Real-world:** {debrief.get('real_world_connection', '')}")
    st.info(f"🗣 Discussion question: *{debrief.get('reflection_question', '')}*")
    st.markdown(f"**Next lesson teaser:** {debrief.get('teaser_next_lesson', '')}")

    # Trophy
    trophy = scoring.get("trophy", {})
    if trophy:
        st.markdown("### Trophy")
        st.success(f"🏆 **{trophy.get('name')}** — {trophy.get('unlock_message', '')}")

    # Leaderboard
    lb = scoring.get("classroom_leaderboard", {})
    if lb:
        st.markdown("### Classroom leaderboard")
        st.markdown(f"Metric: **{lb.get('metric_label', '')}**")
        st.markdown(f"Share template: *{lb.get('shareable_result_template', '')}*")


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    st.title("🪙 Coin Grow — Lesson Studio")
    st.caption("Generate and inspect financial literacy lessons from the prompt engine.")

    curriculum = load_curriculum()
    lesson_options = build_lesson_options(curriculum)
    prompt_versions = get_prompt_versions()

    # ── Sidebar ──────────────────────────────────────────────────────────────
    with st.sidebar:
        st.header("Configuration")

        api_key = st.text_input(
            "Anthropic API key",
            value=os.environ.get("ANTHROPIC_API_KEY", ""),
            type="password",
            help="Set ANTHROPIC_API_KEY env var to pre-fill this",
        )

        st.divider()
        st.subheader("Prompt")
        prompt_file = st.selectbox("Prompt version", prompt_versions)
        model = st.selectbox("Model", ["claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5-20251001"])

        st.divider()
        st.subheader("Lesson")
        selected_label = st.selectbox("Pick from curriculum", list(lesson_options.keys()))
        selected_lesson = lesson_options[selected_label]

        if selected_lesson:
            topic = st.text_input("Topic", value=selected_lesson["topic"])
            age_group = st.selectbox(
                "Age group",
                ["8-11", "12-15", "16+"],
                index=["8-11", "12-15", "16+"].index(
                    selected_lesson["age_variants"][0] if selected_lesson["age_variants"] else "12-15"
                ),
            )
            lesson_number = selected_lesson["lesson_number"]
            prior_concepts = selected_lesson["prior_concepts"]
            setting = selected_lesson["setting_preference"]
        else:
            topic = st.text_input("Topic", value="What is money and why does it exist?")
            age_group = st.selectbox("Age group", ["8-11", "12-15", "16+"], index=1)
            lesson_number = 1
            prior_concepts = []
            setting = st.selectbox("Setting", ["historical", "modern", "fantasy", "auto"])

        difficulty = st.selectbox("Difficulty", ["beginner", "intermediate", "advanced"])

        if prior_concepts:
            st.markdown(f"**Prior concepts:** {', '.join(prior_concepts)}")

        st.divider()
        generate_btn = st.button("⚡ Generate lesson", type="primary", use_container_width=True)

    # ── Main panel ───────────────────────────────────────────────────────────
    if generate_btn:
        if not api_key:
            st.error("Enter your Anthropic API key in the sidebar.")
            return

        system_prompt = load_prompt(prompt_file)

        with st.spinner(f"Generating lesson {lesson_number}: {topic}..."):
            lesson, stats, raw = generate_lesson(
                system_prompt=system_prompt,
                topic=topic,
                age_group=age_group,
                difficulty=difficulty,
                lesson_number=lesson_number,
                prior_concepts=prior_concepts,
                setting=setting,
                model=model,
                api_key=api_key,
            )

        # Cache / cost info
        col1, col2, col3 = st.columns(3)
        col1.metric("Input tokens", f"{stats['input_tokens']:,}")
        col2.metric("Output tokens", f"{stats['output_tokens']:,}")
        if stats["cache_read"]:
            col3.metric("Cache", "HIT ✅", help=f"{stats['cache_read']:,} tokens read from cache")
        elif stats["cache_created"]:
            col3.metric("Cache", "MISS (written)", help=f"{stats['cache_created']:,} tokens cached for next call")

        if lesson is None:
            st.error("Failed to parse JSON from model output.")
            st.code(raw, language="text")
            return

        # Validation
        errors = validate_lesson(lesson)
        if errors:
            st.warning(f"**{len(errors)} validation issue(s):**")
            for e in errors:
                st.markdown(f"- {e}")
        else:
            st.success("Validation passed ✅")

        st.divider()
        render_lesson(lesson)

        # Save + raw JSON
        st.divider()
        col1, col2 = st.columns(2)
        with col1:
            if st.button("💾 Save to lessons/"):
                path = save_lesson(lesson)
                st.success(f"Saved: `{path.name}`")
        with col2:
            with st.expander("Raw JSON"):
                st.code(json.dumps(lesson, indent=2, ensure_ascii=False), language="json")

    else:
        st.info("Configure a lesson in the sidebar and click **Generate lesson** to start.")
        st.markdown("### Curriculum")
        for unit in curriculum["units"]:
            with st.expander(f"Unit {unit['unit']}: {unit['title']}"):
                st.caption(unit["theme"])
                for lesson in unit["lessons"]:
                    ages = " · ".join(lesson["age_variants"])
                    st.markdown(f"**{lesson['lesson_number']}.** {lesson['topic']}  \n`{lesson['concept']}` — Ages: {ages}")


if __name__ == "__main__":
    main()
