# Coin Grow — Platform & Animation Options

## Project Context (for the AI reading this)

Coin Grow is a mobile educational game (iOS + Android) that teaches financial literacy through
story-driven animated scenes. Content is 100% AI-generated: a Claude prompt produces a JSON
lesson object that the game engine must render as animated scenes with characters, dialogue,
player choices, and emotional outcomes.

Key constraints:
- Two founders, pre-funding, small team
- Core product is the AI prompt engine — the game shell is a delivery vehicle
- Lesson content is structured JSON (scenes, characters, choices, outcomes)
- Social layer: classrooms compete, school-vs-school leaderboards
- Future paid tier: market simulator (investment competition between classes)
- Must ship on Google Play + Apple App Store
- Art style not yet decided

The lesson JSON schema has these scene types: `cutscene`, `dialogue`, `interactive`,
`choice`, `outcome`, `debrief`. Each scene has characters with personality/dialogue style,
NPC dialogue lines with emotions and animation hints, and player choices with financial quality
ratings (optimal → catastrophic) that branch to different scenes.

---

## Decision 1: Game Framework

### Option A — Flutter + Flame ⭐ (current preference)

**What it is:** Flutter is Google's cross-platform UI framework (Dart language). Flame is a
2D game engine built on top of Flutter. Flutter handles the app shell (menus, leaderboards,
login, dashboards). Flame handles the game scenes.

**Pros:**
- One language (Dart), one codebase, ships to iOS + Android + Web
- Flutter's widget system handles the "app" parts natively (no hacks needed for UI)
- Flame's component model maps cleanly to lesson JSON scenes
- Google owns Flutter — Play Store integration is first-class
- Strong data-driven rendering: JSON → scene components is a natural pattern
- Hot reload speeds up iteration significantly
- Growing ecosystem, good hiring pool

**Cons:**
- Dart is less common than JavaScript/C# — smaller global talent pool
- Flame is less mature than Unity for complex animation rigs
- Less asset store content than Unity

**Best for:** Small teams building data-driven 2D games that also need a full app shell.
This is exactly our use case.

**Animation in Flame:** Sprite sheets, Rive integration, Lottie for UI effects.

---

### Option B — Unity

**What it is:** Industry-standard game engine. C# language. Dominant in mobile gaming.

**Pros:**
- Massive ecosystem, huge asset store, easy to hire for
- Excellent 2D animation tools (Unity Animator, Spine integration)
- Battle-tested at scale — millions of shipped mobile games
- Best choice if the market simulator needs complex real-time simulation
- Unity Gaming Services handles leaderboards, analytics, IAP natively

**Cons:**
- Heavy — startup time, build times, and binary size are all larger
- C# + Unity Editor has a steep learning curve for non-game developers
- The "app shell" parts (teacher dashboard, login, settings) feel unnatural in Unity
- Unity's recent licensing controversy (2023) caused industry concern
- Overkill for a dialogue-driven 2D educational game

**Best for:** Teams with game development experience building complex or 3D games.

**Animation in Unity:** Unity Animator (built-in), Spine (industry standard skeletal animation),
Lottie4Unity for UI effects.

---

### Option C — Godot

**What it is:** Open-source game engine. GDScript (Python-like) or C#. Godot 4 released 2023.

**Pros:**
- Fully free and open-source — no royalties, no licensing risk
- Excellent 2D support — arguably better than Unity for pure 2D
- Lightweight builds, fast iteration
- Godot 4 is a serious commercial-grade engine now
- Scene system maps well to lesson JSON scenes

**Cons:**
- Smaller hiring pool than Unity
- Less mature mobile export pipeline (improving but not Unity-level)
- Fewer ready-made solutions for the app shell (login, payments, leaderboards)
- Less industry recognition — harder to impress investors with

**Best for:** Technically strong founders who want full control and no licensing costs,
building a pure game (no heavy app-shell requirements).

**Animation in Godot:** AnimationPlayer (built-in), Spine integration via plugin.

---

### Option D — React Native + Skia/Reanimated

**What it is:** React Native for the app shell, React Native Skia + Reanimated for
game-like animations. JavaScript/TypeScript.

**Pros:**
- Web developers can contribute immediately
- React Native is excellent for the app shell (leaderboards, dashboards, teacher portal)
- Large ecosystem

**Cons:**
- Not designed for games — animated scenes will feel like workarounds
- Performance ceiling is lower than native game engines
- Complex interactive scenes (haggling mechanics, drag interactions) are painful to build

**Best for:** Apps that are primarily UI with some light animations. Not recommended for
a game with rich scene interactions.

---

### Option E — Capacitor (Web App Wrapped)

**What it is:** Build a web app (React/Vue/Svelte), wrap it in a native shell using Capacitor.
Ship to both stores.

**Pros:**
- Fastest to prototype
- Web developers can work on it immediately
- Shares code with any web dashboard

**Cons:**
- Performance and feel are noticeably worse than native
- App stores are increasingly strict about "web wrapper" apps
- Animation quality is limited compared to native game engines

**Best for:** Prototypes and MVPs only. Not recommended for a shipped game product.

---

## Decision 2: Character Animation Library

### Option A — Rive ⭐ (current preference)

**What it is:** Modern interactive animation tool. You design characters with states
(idle, happy, sad, talking, surprised) connected by a state machine. In code you trigger
state changes and Rive handles the transitions.

**Why it fits Coin Grow perfectly:** Our lesson JSON has `emotion` and `animation_hint`
fields on every dialogue line. Rive's state machine maps directly: receive emotion from JSON
→ trigger state → animation plays. Characters react to player choices automatically.

**Pros:**
- Native Flutter integration (first-class support)
- State machines make choice-driven scenes trivial to animate
- Web + mobile + all platforms
- Designer-friendly tool (similar to Figma)
- Real-time, interactive — not pre-rendered video

**Cons:**
- Smaller artist community than Spine
- Less powerful for complex skeletal rigs than Spine

**Best for:** Dialogue-driven games where character emotion changes based on player input.

---

### Option B — Spine

**What it is:** Industry-standard 2D skeletal animation (Esoteric Software). Used by
Hollow Knight, Ori, and thousands of mobile games.

**Pros:**
- Most powerful 2D skeletal animation available
- Huge artist community, many studios know it
- Runtime available for Unity, Godot, Flutter, and custom engines
- Best choice if you want AAA-quality character animation

**Cons:**
- Expensive license (~$300/user for editor)
- Steeper artist learning curve than Rive
- More complex integration than Rive
- Overkill for our current scope

**Best for:** Teams with dedicated animators targeting high-quality character animation.
Recommended if the art direction requires console-level quality.

---

### Option C — Lottie

**What it is:** JSON-based animations exported from Adobe After Effects. Used for UI
animations (buttons, transitions, icons, celebratory effects).

**Pros:**
- Perfect for UI effects: coins flying, trophy appearing, progress bars
- Works on Flutter, React Native, web, iOS, Android
- Huge free library at LottieFiles.com
- Designers can create without coding

**Cons:**
- Not designed for interactive character animation
- Pre-rendered — cannot react to state changes like Rive can

**Best for:** UI effects and decorative animations. Use alongside Rive, not instead of it.

---

### Option D — Sprite Sheets (Traditional 2D)

**What it is:** Classic frame-by-frame animation. Character has a spritesheet with frames
for each animation (walk, talk, happy, sad). Code cycles through frames.

**Pros:**
- Simple, works in every engine
- Any pixel-art or hand-drawn style
- No runtime dependency

**Cons:**
- No smooth skeletal animation
- Large file sizes for complex characters
- Hard to add new emotions/states without redrawing

**Best for:** Pixel art style games. If the art direction goes pixel art, this is the answer.

---

## Summary Comparison

| | Flutter+Flame | Unity | Godot | React Native | Capacitor |
|---|---|---|---|---|---|
| Game scenes | ✅ Good | ✅ Best | ✅ Great | ⚠️ Limited | ❌ Poor |
| App shell | ✅ Native | ⚠️ Awkward | ⚠️ Limited | ✅ Best | ✅ Good |
| iOS + Android | ✅ | ✅ | ✅ | ✅ | ✅ |
| Small team fit | ✅ | ⚠️ | ✅ | ✅ | ✅ |
| Data-driven JSON | ✅ Natural | ✅ Possible | ✅ Possible | ⚠️ Awkward | ⚠️ Awkward |
| Hiring pool | Medium | Large | Small | Large | Large |
| Licensing risk | None | Medium | None | None | None |

| | Rive | Spine | Lottie | Sprite Sheets |
|---|---|---|---|---|
| Interactive/reactive | ✅ Best | ✅ Good | ❌ No | ❌ No |
| Quality ceiling | High | Highest | N/A | Medium |
| Flutter integration | ✅ Native | ✅ Plugin | ✅ Native | ✅ Native |
| Artist community | Growing | Large | Large | Large |
| Cost | Free tier | ~$300/seat | Free | Free |

---

## DECISION — Confirmed 2026-06-18

**Flutter + Flame + Rive + Lottie** ✅ — validated by second AI review.

## Current Recommendation (archived — see DECISION above)

**Flutter + Flame + Rive + Lottie**

- Flutter: app shell (menus, leaderboards, teacher dashboard, login)
- Flame: game scene rendering (reads lesson JSON, plays scenes)
- Rive: character animation with state machines (emotion → animation)
- Lottie: UI effects (trophies, coins, celebrations)

**Reasoning:** The lesson JSON schema already has `emotion`, `animation_hint`, and
`financial_quality` fields designed for reactive animation. Rive's state machines consume
this directly. Flutter+Flame keeps the whole product in one language and one build pipeline.
The team is small and pre-funding — a monolithic codebase in one language is the right
call until there's a reason to split.

**The one thing that changes this recommendation:** Art style. If the decision is pixel art,
drop Rive and use sprite sheets. If the decision is 3D characters, drop everything and use Unity.

---

## Open Questions (to resolve before building the shell)

1. What is the art style? (Flat vector / hand-drawn / pixel art / 3D)
2. Will we hire an animator or use a generative AI art tool for characters?
3. Does the market simulator need real-time multiplayer or async-only?
4. Teacher dashboard — separate web app or inside the mobile app?
