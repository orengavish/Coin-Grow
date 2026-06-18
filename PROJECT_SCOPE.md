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
Working prompt engine that generates validated, playable lesson JSON. No mobile shell yet.

## Feature Scope

### In Scope Now
- Lesson generator prompt (versioned)
- Test harness with validation and caching
- Curriculum map (18 lessons, 6 units)
- GitHub versioning and CI discipline

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

## Non-Goals
- This is not a simulation game (no open-ended free play in v1)
- This is not a quiz app (no multiple choice — all experiential)
- This is not a parent app (school/classroom is the primary distribution channel)
