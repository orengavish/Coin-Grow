# Lesson 1 — User Message Input

This file documents the exact user message sent to the lesson generator for Lesson 1.
It is paired with lesson-generator-v0.2.md (the system prompt).

---

## USER MESSAGE

Generate Lesson 1 for Coin Grow using the following specification exactly.

```json
{
  "lesson_number": 1,
  "title": "The Orange Quest",
  "topic": "Barter — how trading works without money",
  "concept": "double_coincidence_of_wants",
  "age_group": "8-15",
  "difficulty": "beginner",
  "estimated_minutes": 15,
  "emotional_hook": "Your little brother is burning with fever. The healer says one orange will cure him by morning. You have no money. The village has no money. Everything here is barter.",
  "languages": ["en", "it"],

  "world": {
    "setting": "A warm Mediterranean village market, cobblestone streets, colorful awnings, 500 years ago. Fairy tale tone — storybook illustration style, not gritty.",
    "time_period": "medieval_mediterranean",
    "family_name": { "en": "The Baker family", "it": "La famiglia dei fornai" }
  },

  "characters": {
    "player": {
      "id": "player",
      "default_name": "Eli",
      "role": "player",
      "age": 12,
      "description": "A baker's kid — brave, quick-thinking, a little impulsive. Everyone in the village knows Eli is good at fishing. Acts first, thinks second.",
      "skills": ["fishing", "hard work", "stubbornness"]
    },
    "beni": {
      "id": "beni",
      "name": "Beni",
      "role": "npc",
      "age": 7,
      "description": "Eli's little brother. Pale from fever, wrapped in a blanket. He trusts Eli completely. He barely speaks — he doesn't need to.",
      "appears_in": ["intro", "ending"]
    },
    "owl": {
      "id": "owl",
      "role": "mentor",
      "name": "Prof Penny",
      "named_by_player": false,
      "personality": "Ancient, warm, Socratic. Never gives the answer. Speaks in observations and questions. Refers to things the player has already seen or done. Calm even when the player is panicking."
    },
    "fatima": {
      "id": "fatima",
      "name": "Fatima",
      "role": "gatekeeper",
      "age": 52,
      "description": "The only orange seller in the market. Silk headscarf, hands that have counted goods for thirty years. Kind but firm — she is not the villain, she just needs what she needs.",
      "personality": "Direct, fair, not unkind. Respects a child who tries hard.",
      "needs": ["silk_thread", "sandals", "apples"],
      "primary_need": "silk_thread",
      "secondary_needs_revealed_by": "asking_twice_or_owl",
      "gives": ["orange"]
    },
    "yosef": {
      "id": "yosef",
      "name": "Yosef",
      "role": "npc",
      "age": 68,
      "description": "The apple farmer. Enormous hands, slow careful speech, bad back. Enormous respect for honest work. Watches Eli work without speaking. His nod of approval means more than most compliments.",
      "needs": ["help_harvesting_apples"],
      "gives": ["basket_of_apples"],
      "path": "path_apple_harvest"
    },
    "marco": {
      "id": "marco",
      "name": "Marco",
      "role": "npc",
      "age": 34,
      "description": "The fisherman. Sunburned, laughs easily, knows everyone in the market by name. The market's newspaper — he knows every trader's business.",
      "personality": "Warm, chatty, generous. If you ask him about other traders, he knows.",
      "needs": ["nets_mended"],
      "gives": ["fresh_fish"],
      "path": "path_fish_chain"
    },
    "tomas": {
      "id": "tomas",
      "name": "Tomas",
      "role": "npc",
      "age": 51,
      "description": "The baker. Flour in his hair, always slightly rushed. Easy to deal with — he loves fish and he is happy.",
      "locale_variant_it": "Tommaso",
      "needs": ["fresh_fish"],
      "gives": ["fresh_bread"],
      "path": "path_fish_chain"
    },
    "elena": {
      "id": "elena",
      "name": "Elena",
      "role": "npc",
      "age": 43,
      "description": "The silk weaver. Quiet, precise. Her hands never stop moving even when she talks. Means exactly what she says — no more, no less.",
      "needs": ["fresh_bread"],
      "gives": ["silk_thread"],
      "path": "path_fish_chain"
    },
    "dov": {
      "id": "dov",
      "name": "Dov",
      "role": "npc",
      "age": 54,
      "description": "The cobbler. Quiet workshop full of beautiful things he has collected. Recognizes craftsmanship immediately. He holds the rod for a moment before handing over the sandals — that pause is the lesson.",
      "locale_variant_it": "Davide",
      "needs": ["grandfather_fishing_rod"],
      "gives": ["sandals"],
      "path": "path_fishing_rod"
    }
  },

  "paths": [
    {
      "id": "path_apple_harvest",
      "is_dead_end": false,
      "card": {
        "effort": "high",
        "time_estimate": "About 2 hours",
        "visible_reward": "A basket of apples",
        "npc": "yosef"
      },
      "notes": "Yosef's apple trees are heavy and his back is bad. Two hours of picking earns a full basket. Fatima grew up in apple country — she misses the taste. She trades the orange for the apples directly. This is the most physically demanding path but emotionally satisfying — Yosef's silent nod of approval is the memorable moment."
    },
    {
      "id": "path_fish_chain",
      "is_dead_end": false,
      "card": {
        "effort": "medium",
        "time_estimate": "About an hour",
        "visible_reward": "Fresh fish",
        "npc": "marco"
      },
      "notes": "Three-step chain: mend Marco's nets → earn fish → trade fish to Tomas → earn bread → trade bread to Elena → earn silk thread → give silk to Fatima → get orange. Most steps but intellectually satisfying. This path teaches the barter chain most clearly. Marco can be asked about other traders — he is a source of market intelligence."
    },
    {
      "id": "path_fishing_rod",
      "is_dead_end": false,
      "card": {
        "effort": "low",
        "time_estimate": "A few minutes",
        "visible_reward": "A pair of sandals",
        "npc": "dov"
      },
      "notes": "Eli has grandfather's carved fishing rod in the satchel. Dov the cobbler collects beautiful things — he has wanted this rod for years. He trades good sandals. Fatima's sandals split this morning (she mentions this if asked a second time, or the owl hints). Sandals → orange. Fastest path. Emotional cost: the rod was grandfather's. Dov pauses before handing over the sandals. That pause is the lesson — fast barter has a hidden price."
    },
    {
      "id": "path_miriam_yard",
      "is_dead_end": true,
      "card": {
        "effort": "medium",
        "time_estimate": "About an hour",
        "visible_reward": "A jar of honey",
        "npc": "miriam"
      },
      "notes": "Old Miriam would give honey for yard work — but she left at dawn for a family visit and won't be back until the weekend. Her neighbor explains. Dead end. Micro-lesson: a plan without information is a guess. Owl appears: references something Eli should have checked before going. Honey would not have reached the orange anyway (Fatima doesn't want honey) — but the owl does not say this. Let the player discover it if they ask."
    },
    {
      "id": "path_direct_work",
      "is_dead_end": false,
      "card": {
        "effort": "high",
        "time_estimate": "About an hour",
        "visible_reward": "The orange (direct)",
        "npc": "fatima"
      },
      "notes": "Fatima needs her heavy crates moved before the afternoon rush. Hard physical work — Eli is small and the crates are big. But Fatima watches and at the end says: that earned it. This path is the most direct but most physically costly. The memorable moment: Fatima handing Eli the orange herself, with respect. No trade — pure service for the exact thing needed. Teaches: sometimes the most direct path is the hardest."
    }
  ],

  "ending": {
    "notes": "Same ending for all paths. Eli runs home. Beni drinks the orange juice. His fever breaks by the next scene. Simple, warm, no lecture. The owl appears at the window: 'You did it. How many people did it take to get one orange?' — and then silence. The debrief comes after. The owl's question is the bridge."
  },

  "owl_library_guidance": {
    "required_entries": [
      "What can a basket of apples get me? (path_apple_harvest)",
      "What can fish get me? (path_fish_chain)",
      "What is grandfather's rod worth? (path_fishing_rod)",
      "What will honey get me? (path_miriam_yard — include that Fatima does not want honey, gently)",
      "What does Fatima need? (the goal question — answer hints at primary need, mentions she may have others)",
      "Why didn't Miriam's yard work? (dead end recovery)",
      "What do I do now that I have fish? (mid-chain guidance)",
      "What do I do now that I have bread? (mid-chain guidance)"
    ]
  },

  "scoring": {
    "path_points": {
      "path_apple_harvest": 80,
      "path_fish_chain": 100,
      "path_fishing_rod": 60,
      "path_direct_work": 70
    },
    "max_points": 100,
    "trophy_name": "The Trader",
    "trophy_icon": "handshake_bronze",
    "grade_thresholds": { "gold": 100, "silver": 70 }
  },

  "debrief_guidance": {
    "concept": "Barter works. You just proved it. But it took time, multiple people, and either hard work or something precious. The concept to land: every successful barter required finding the exact person who wanted what you had. In a village of 200 people trading 200 things, that search never ends.",
    "teaser": "The village elders are calling a meeting. They have an idea. Tomorrow."
  }
}
```
