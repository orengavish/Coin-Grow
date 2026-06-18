# Coin Grow — Project Scope

## Vision
An AI-generated educational financial literacy game for mobile (iOS/Android). Players learn money, saving, interest, investing, and financial goals through immersive story-driven quests with avatars, trophies, and social competition.

## Core Product Insight
**The prompt is the product.** The AI prompt engine generates all lesson content — quests, narratives, branching choices, emotional outcomes, debriefs. The game shell is a delivery vehicle. Each prompt version is a product iteration.

## Target Audience
- Primary: Kids 8–15 (classroom adoption)
- Secondary: Adults (personal finance literacy)
- Content adapts to age group via the prompt engine

## Business Model
- **B2B2C:** Schools/teachers adopt the tool; kids compete and engage
- **Free tier:** Core lesson curriculum
- **Paid tier:** Market simulator — classroom investment competitions
- **Network effect:** Classroom vs. classroom, school vs. school leaderboards

## Current Team
- Founder (technical) — building the prompt engine and infrastructure
- Co-founder (product manager) — product direction
- Pre-funding as of June 2026

## Current Milestone
Flutter mobile scaffold built (Dart models, scene router, all scene types). Owl character prototype live in browser (blue theme). Flutter 3.44.2 downloading; Android Studio installed at `C:\Program Files\Android\Android Studio`.

## Feature Scope

### In Scope Now
- Lesson generator prompt (versioned) ✅
- Streamlit Studio UI ✅
- Test harness with validation and caching ✅
- Curriculum map (18 lessons, 6 units) ✅
- GitHub versioning and CI discipline ✅
- Flutter mobile scaffold — models, scene router, lesson player ✅
- Owl character HTML prototype — blue navy theme, CSS animations ✅
- Flutter environment setup (install in progress)

### In Scope Next
- Flutter: `flutter pub get`, `flutter run` on device/emulator
- Port owl character to Rive for Flutter
- Connect generated lesson JSON to Flutter player
- Teacher dashboard (assign lessons, view class progress)
- Classroom leaderboard backend

### In Scope Next
- Lesson runner / batch generator
- Basic mobile shell (React Native or Flutter — TBD)
- Teacher dashboard (assign lessons, view class progress)
- Classroom leaderboard backend

### Future / Paid Tier
- Market simulator engine
- Investment competition between classrooms
- School vs. school leaderboards
- Analytics dashboard for teachers

### Out of Scope
- Custom character art (TBD with artist)
- Voice acting
- Offline mode (initial version)
- Multiplayer real-time (async only)

## Curriculum Overview
18 lessons across 6 units. See `curriculum.json` for full detail.

| Unit | Theme | Lessons |
|---|---|---|
| 1 | The Story of Money | Barter, Saving, Value & Trust |
| 2 | Earning & Spending | Income, Budgeting, Debt basics |
| 3 | Power of Saving | Goals, Interest, Compound interest |
| 4 | Banks & Borrowing | Banking, Good vs bad debt |
| 5 | Investing & Risk | Investing basics, Risk/return, Diversification, Stock market |
| 6 | Advanced Topics | Inflation, Taxes, Insurance |

## Tech Stack (decided 2026-06-18)

| Layer | Technology |
|---|---|
| Mobile framework | Flutter (Dart) |
| Game scenes | Flame (Flutter game engine) |
| Character animation | Rive (state-machine driven) |
| UI effects | Lottie (coins, trophies, celebrations) |
| AI/prompt engine | Claude API (Anthropic SDK, Python) |
| Studio / dev UI | Streamlit (Python) |
| Backend (future) | TBD — leaderboards, teacher dashboard |

## Non-Goals
- This is not a simulation game (no open-ended free play in v1)
- This is not a quiz app (no multiple choice — all experiential)
- This is not a parent app (school/classroom is the primary distribution channel)
