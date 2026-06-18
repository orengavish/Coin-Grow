// v0.2 lesson models — mirrors lesson-generator-v0.2.md schema.
// All player-facing strings are BilingualText {en, it}.
// AppLocale.current controls which language is displayed.

class AppLocale {
  static String current = 'en';
}

class BilingualText {
  final String en;
  final String it;

  const BilingualText({required this.en, required this.it});

  factory BilingualText.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return BilingualText(
        en: json['en']?.toString() ?? '',
        it: json['it']?.toString() ?? '',
      );
    }
    final s = json?.toString() ?? '';
    return BilingualText(en: s, it: s);
  }

  String get text => AppLocale.current == 'it' ? it : en;
}

class LessonModel {
  final LessonMeta lesson;
  final WorldModel world;
  final Map<String, CharacterModel> characters;
  final List<SceneModel> introScenes;
  final List<PathModel> paths;
  final List<SceneModel> endingScenes;
  final List<OwlLibraryEntry> owlLibrary;
  final Map<String, BilingualText> journalTemplates;
  final ScoringModel scoring;
  final DebriefModel debrief;

  const LessonModel({
    required this.lesson,
    required this.world,
    required this.characters,
    required this.introScenes,
    required this.paths,
    required this.endingScenes,
    required this.owlLibrary,
    required this.journalTemplates,
    required this.scoring,
    required this.debrief,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final charsJson = json['characters'] as Map<String, dynamic>? ?? {};
    final characters = charsJson.map(
      (k, v) => MapEntry(k, CharacterModel.fromJson(v as Map<String, dynamic>)),
    );

    final jtJson = json['journal_templates'] as Map<String, dynamic>? ?? {};
    final journalTemplates = jtJson.map(
      (k, v) => MapEntry(k, BilingualText.fromJson(v)),
    );

    return LessonModel(
      lesson: LessonMeta.fromJson(json['lesson'] as Map<String, dynamic>? ?? {}),
      world: WorldModel.fromJson(json['world'] as Map<String, dynamic>? ?? {}),
      characters: characters,
      introScenes: (json['intro_scenes'] as List? ?? [])
          .map((s) => SceneModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      paths: (json['paths'] as List? ?? [])
          .map((p) => PathModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      endingScenes: (json['ending_scenes'] as List? ?? [])
          .map((s) => SceneModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      owlLibrary: (json['owl_library'] as List? ?? [])
          .map((e) => OwlLibraryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      journalTemplates: journalTemplates,
      scoring: ScoringModel.fromJson(json['scoring'] as Map<String, dynamic>? ?? {}),
      debrief: DebriefModel.fromJson(json['debrief'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class LessonMeta {
  final String version;
  final int lessonNumber;
  final String title;
  final String topic;
  final String concept;
  final String ageGroup;
  final String difficulty;
  final int estimatedMinutes;
  final String emotionalHook;

  const LessonMeta({
    required this.version,
    required this.lessonNumber,
    required this.title,
    required this.topic,
    required this.concept,
    required this.ageGroup,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.emotionalHook,
  });

  factory LessonMeta.fromJson(Map<String, dynamic> json) => LessonMeta(
        version: json['version']?.toString() ?? '',
        lessonNumber: json['lesson_number'] as int? ?? 1,
        title: json['title']?.toString() ?? '',
        topic: json['topic']?.toString() ?? '',
        concept: json['concept']?.toString() ?? '',
        ageGroup: json['age_group']?.toString() ?? '',
        difficulty: json['difficulty']?.toString() ?? '',
        estimatedMinutes: json['estimated_minutes'] as int? ?? 15,
        emotionalHook: json['emotional_hook']?.toString() ?? '',
      );
}

class WorldModel {
  final BilingualText setting;
  final String timePeriod;
  final BilingualText familyName;

  const WorldModel({
    required this.setting,
    required this.timePeriod,
    required this.familyName,
  });

  factory WorldModel.fromJson(Map<String, dynamic> json) => WorldModel(
        setting: BilingualText.fromJson(json['setting']),
        timePeriod: json['time_period']?.toString() ?? '',
        familyName: BilingualText.fromJson(json['family_name']),
      );
}

class CharacterModel {
  final String id;
  final String name;
  final String role;
  final int age;
  final BilingualText description;
  final BilingualText personality;
  final List<String> needs;
  final List<String> gives;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.role,
    required this.age,
    required this.description,
    required this.personality,
    required this.needs,
    required this.gives,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        age: json['age'] as int? ?? 0,
        description: BilingualText.fromJson(
            json['description'] ?? {'en': '', 'it': ''}),
        personality: BilingualText.fromJson(
            json['personality'] ?? {'en': '', 'it': ''}),
        needs: List<String>.from(json['needs'] ?? []),
        gives: List<String>.from(json['gives'] ?? []),
      );
}

enum SceneType { cutscene, dialogue, outcome, debrief, unknown }

SceneType sceneTypeFromString(String s) => switch (s) {
      'cutscene' => SceneType.cutscene,
      'dialogue' => SceneType.dialogue,
      'outcome' => SceneType.outcome,
      'debrief' => SceneType.debrief,
      _ => SceneType.unknown,
    };

class SceneModel {
  final String id;
  final SceneType type;
  final BilingualText narrative;
  final String visualDescription;
  final List<NpcDialogueLine> npcDialogue;
  final String? nextSceneId;

  const SceneModel({
    required this.id,
    required this.type,
    required this.narrative,
    required this.visualDescription,
    required this.npcDialogue,
    this.nextSceneId,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) => SceneModel(
        id: json['id']?.toString() ?? '',
        type: sceneTypeFromString(json['type']?.toString() ?? ''),
        narrative: BilingualText.fromJson(json['narrative']),
        visualDescription: json['visual_description']?.toString() ?? '',
        npcDialogue: (json['npc_dialogue'] as List? ?? [])
            .map((d) => NpcDialogueLine.fromJson(d as Map<String, dynamic>))
            .toList(),
        nextSceneId: json['next_scene_id']?.toString(),
      );
}

class NpcDialogueLine {
  final String characterId;
  final BilingualText line;
  final String emotion;

  const NpcDialogueLine({
    required this.characterId,
    required this.line,
    required this.emotion,
  });

  factory NpcDialogueLine.fromJson(Map<String, dynamic> json) => NpcDialogueLine(
        characterId: json['character_id']?.toString() ?? '',
        line: BilingualText.fromJson(json['line']),
        emotion: json['emotion']?.toString() ?? 'neutral',
      );
}

class PathModel {
  final String id;
  final bool isDeadEnd;
  final PathCard card;
  final List<SceneModel> scenes;
  final DeadEndBlock? deadEnd;
  final PathOutcome? outcome;

  const PathModel({
    required this.id,
    required this.isDeadEnd,
    required this.card,
    required this.scenes,
    this.deadEnd,
    this.outcome,
  });

  factory PathModel.fromJson(Map<String, dynamic> json) => PathModel(
        id: json['id']?.toString() ?? '',
        isDeadEnd: json['is_dead_end'] as bool? ?? false,
        card: PathCard.fromJson(json['card'] as Map<String, dynamic>? ?? {}),
        scenes: (json['scenes'] as List? ?? [])
            .map((s) => SceneModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        deadEnd: json['dead_end'] is Map
            ? DeadEndBlock.fromJson(json['dead_end'] as Map<String, dynamic>)
            : null,
        outcome: json['outcome'] is Map
            ? PathOutcome.fromJson(json['outcome'] as Map<String, dynamic>)
            : null,
      );
}

class PathCard {
  final BilingualText label;
  final String effort;
  final BilingualText timeEstimate;
  final BilingualText visibleReward;

  const PathCard({
    required this.label,
    required this.effort,
    required this.timeEstimate,
    required this.visibleReward,
  });

  factory PathCard.fromJson(Map<String, dynamic> json) => PathCard(
        label: BilingualText.fromJson(json['label']),
        effort: json['effort']?.toString() ?? 'medium',
        timeEstimate: BilingualText.fromJson(json['time_estimate']),
        visibleReward: BilingualText.fromJson(json['visible_reward']),
      );
}

class DeadEndBlock {
  final BilingualText narrative;
  final String visualDescription;
  final BilingualText microLesson;
  final BilingualText owlResponse;

  const DeadEndBlock({
    required this.narrative,
    required this.visualDescription,
    required this.microLesson,
    required this.owlResponse,
  });

  factory DeadEndBlock.fromJson(Map<String, dynamic> json) {
    final sceneJson = json['scene'] as Map<String, dynamic>? ?? {};
    return DeadEndBlock(
      narrative: BilingualText.fromJson(sceneJson['narrative']),
      visualDescription: sceneJson['visual_description']?.toString() ?? '',
      microLesson: BilingualText.fromJson(json['micro_lesson']),
      owlResponse: BilingualText.fromJson(json['owl_response']),
    );
  }
}

class PathOutcome {
  final String earns;
  final bool leadsToOrange;
  final int stepsRemaining;
  final BilingualText journalEntry;

  const PathOutcome({
    required this.earns,
    required this.leadsToOrange,
    required this.stepsRemaining,
    required this.journalEntry,
  });

  factory PathOutcome.fromJson(Map<String, dynamic> json) => PathOutcome(
        earns: json['earns']?.toString() ?? '',
        leadsToOrange: json['leads_to_orange'] as bool? ?? false,
        stepsRemaining: json['steps_remaining'] as int? ?? 0,
        journalEntry: BilingualText.fromJson(json['journal_entry']),
      );
}

class OwlLibraryEntry {
  final String id;
  final String context;
  final BilingualText bubbleLabel;
  final BilingualText question;
  final BilingualText answer;

  const OwlLibraryEntry({
    required this.id,
    required this.context,
    required this.bubbleLabel,
    required this.question,
    required this.answer,
  });

  factory OwlLibraryEntry.fromJson(Map<String, dynamic> json) => OwlLibraryEntry(
        id: json['id']?.toString() ?? '',
        context: json['context']?.toString() ?? '',
        bubbleLabel: BilingualText.fromJson(json['bubble_label']),
        question: BilingualText.fromJson(json['question']),
        answer: BilingualText.fromJson(json['answer']),
      );
}

class ScoringModel {
  final int maxPoints;
  final Map<String, int> pathPoints;
  final TrophyModel trophy;
  final Map<String, int> gradeThresholds;
  final ClassroomLeaderboard? classroomLeaderboard;

  const ScoringModel({
    required this.maxPoints,
    required this.pathPoints,
    required this.trophy,
    required this.gradeThresholds,
    this.classroomLeaderboard,
  });

  factory ScoringModel.fromJson(Map<String, dynamic> json) => ScoringModel(
        maxPoints: json['max_points'] as int? ?? 100,
        pathPoints: (json['path_points'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        trophy: TrophyModel.fromJson(json['trophy'] as Map<String, dynamic>? ?? {}),
        gradeThresholds:
            (json['grade_thresholds'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt())),
        classroomLeaderboard: json['classroom_leaderboard'] is Map
            ? ClassroomLeaderboard.fromJson(
                json['classroom_leaderboard'] as Map<String, dynamic>)
            : null,
      );
}

class TrophyModel {
  final BilingualText name;
  final String icon;
  final BilingualText unlockMessage;

  const TrophyModel({
    required this.name,
    required this.icon,
    required this.unlockMessage,
  });

  factory TrophyModel.fromJson(Map<String, dynamic> json) => TrophyModel(
        name: BilingualText.fromJson(json['name']),
        icon: json['icon']?.toString() ?? '',
        unlockMessage: BilingualText.fromJson(json['unlock_message']),
      );
}

class ClassroomLeaderboard {
  final BilingualText shareableResultTemplate;

  const ClassroomLeaderboard({required this.shareableResultTemplate});

  factory ClassroomLeaderboard.fromJson(Map<String, dynamic> json) =>
      ClassroomLeaderboard(
        shareableResultTemplate:
            BilingualText.fromJson(json['shareable_result_template']),
      );
}

class DebriefModel {
  final BilingualText conceptName;
  final BilingualText conceptExplanation;
  final BilingualText realWorldConnection;
  final BilingualText reflectionQuestion;
  final BilingualText teaserNextLesson;

  const DebriefModel({
    required this.conceptName,
    required this.conceptExplanation,
    required this.realWorldConnection,
    required this.reflectionQuestion,
    required this.teaserNextLesson,
  });

  factory DebriefModel.fromJson(Map<String, dynamic> json) => DebriefModel(
        conceptName: BilingualText.fromJson(json['concept_name']),
        conceptExplanation: BilingualText.fromJson(json['concept_explanation']),
        realWorldConnection:
            BilingualText.fromJson(json['real_world_connection']),
        reflectionQuestion:
            BilingualText.fromJson(json['reflection_question']),
        teaserNextLesson: BilingualText.fromJson(json['teaser_next_lesson']),
      );
}
