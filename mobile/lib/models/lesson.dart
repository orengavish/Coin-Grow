// Data models that mirror the lesson JSON schema produced by the prompt engine.
// Keep these in sync with the schema in prompts/lesson-generator-vX.Y.md.

class LessonModel {
  final LessonMeta lesson;
  final WorldModel world;
  final List<CharacterModel> characters;
  final List<SceneModel> scenes;
  final ScoringModel scoring;
  final DebriefModel debrief;

  const LessonModel({
    required this.lesson,
    required this.world,
    required this.characters,
    required this.scenes,
    required this.scoring,
    required this.debrief,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        lesson: LessonMeta.fromJson(json['lesson']),
        world: WorldModel.fromJson(json['world']),
        characters: (json['characters'] as List).map((c) => CharacterModel.fromJson(c)).toList(),
        scenes: (json['scenes'] as List).map((s) => SceneModel.fromJson(s)).toList(),
        scoring: ScoringModel.fromJson(json['scoring']),
        debrief: DebriefModel.fromJson(json['debrief']),
      );
}

class LessonMeta {
  final String id;
  final String version;
  final String title;
  final String subtitle;
  final String topic;
  final String ageGroup;
  final String difficulty;
  final int estimatedMinutes;
  final List<String> learningObjectives;

  const LessonMeta({
    required this.id,
    required this.version,
    required this.title,
    required this.subtitle,
    required this.topic,
    required this.ageGroup,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.learningObjectives,
  });

  factory LessonMeta.fromJson(Map<String, dynamic> json) => LessonMeta(
        id: json['id'] ?? '',
        version: json['version'] ?? '',
        title: json['title'] ?? '',
        subtitle: json['subtitle'] ?? '',
        topic: json['topic'] ?? '',
        ageGroup: json['age_group'] ?? '',
        difficulty: json['difficulty'] ?? '',
        estimatedMinutes: json['estimated_minutes'] ?? 10,
        learningObjectives: List<String>.from(json['learning_objectives'] ?? []),
      );
}

class WorldModel {
  final String era;
  final String location;
  final String atmosphere;
  final String visualPalette;
  final String ambientSound;

  const WorldModel({
    required this.era,
    required this.location,
    required this.atmosphere,
    required this.visualPalette,
    required this.ambientSound,
  });

  factory WorldModel.fromJson(Map<String, dynamic> json) => WorldModel(
        era: json['era'] ?? '',
        location: json['location'] ?? '',
        atmosphere: json['atmosphere'] ?? '',
        visualPalette: json['visual_palette'] ?? '',
        ambientSound: json['ambient_sound'] ?? '',
      );
}

class CharacterModel {
  final String id;
  final String name;
  final String role;
  final String personality;
  final String visualDescription;
  final String dialogueStyle;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.role,
    required this.personality,
    required this.visualDescription,
    required this.dialogueStyle,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        personality: json['personality'] ?? '',
        visualDescription: json['visual_description'] ?? '',
        dialogueStyle: json['dialogue_style'] ?? '',
      );
}

enum SceneType { cutscene, dialogue, interactive, choice, outcome, debrief, unknown }

SceneType sceneTypeFromString(String s) => switch (s) {
      'cutscene' => SceneType.cutscene,
      'dialogue' => SceneType.dialogue,
      'interactive' => SceneType.interactive,
      'choice' => SceneType.choice,
      'outcome' => SceneType.outcome,
      'debrief' => SceneType.debrief,
      _ => SceneType.unknown,
    };

enum FinancialQuality { optimal, acceptable, poor, catastrophic }

FinancialQuality qualityFromString(String s) => switch (s) {
      'optimal' => FinancialQuality.optimal,
      'acceptable' => FinancialQuality.acceptable,
      'poor' => FinancialQuality.poor,
      'catastrophic' => FinancialQuality.catastrophic,
      _ => FinancialQuality.acceptable,
    };

class SceneModel {
  final String id;
  final SceneType type;
  final String title;
  final String narrative;
  final String visualDescription;
  final String audioCue;
  final List<NpcDialogueLine> npcDialogue;
  final PlayerAction? playerAction;
  final List<ChoiceModel> choices;
  final OutcomeModel? outcome;
  final String? leadsTo;

  const SceneModel({
    required this.id,
    required this.type,
    required this.title,
    required this.narrative,
    required this.visualDescription,
    required this.audioCue,
    required this.npcDialogue,
    this.playerAction,
    required this.choices,
    this.outcome,
    this.leadsTo,
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) => SceneModel(
        id: json['id'] ?? '',
        type: sceneTypeFromString(json['type'] ?? ''),
        title: json['title'] ?? '',
        narrative: json['narrative'] ?? '',
        visualDescription: json['visual_description'] ?? '',
        audioCue: json['audio_cue'] ?? '',
        npcDialogue: ((json['npc_dialogue'] ?? []) as List)
            .map((d) => NpcDialogueLine.fromJson(d))
            .toList(),
        playerAction: json['player_action'] != null
            ? PlayerAction.fromJson(json['player_action'])
            : null,
        choices: ((json['choices'] ?? []) as List)
            .map((c) => ChoiceModel.fromJson(c))
            .toList(),
        outcome: json['outcome'] != null ? OutcomeModel.fromJson(json['outcome']) : null,
        leadsTo: json['leads_to'],
      );
}

class NpcDialogueLine {
  final String characterId;
  final String line;
  final String emotion;
  final String animationHint;

  const NpcDialogueLine({
    required this.characterId,
    required this.line,
    required this.emotion,
    required this.animationHint,
  });

  factory NpcDialogueLine.fromJson(Map<String, dynamic> json) => NpcDialogueLine(
        characterId: json['character_id'] ?? '',
        line: json['line'] ?? '',
        emotion: json['emotion'] ?? 'neutral',
        animationHint: json['animation_hint'] ?? '',
      );
}

class PlayerAction {
  final String type;
  final String instruction;
  final String mechanicDescription;

  const PlayerAction({
    required this.type,
    required this.instruction,
    required this.mechanicDescription,
  });

  factory PlayerAction.fromJson(Map<String, dynamic> json) => PlayerAction(
        type: json['type'] ?? 'none',
        instruction: json['instruction'] ?? '',
        mechanicDescription: json['mechanic_description'] ?? '',
      );
}

class ChoiceModel {
  final String id;
  final String label;
  final String description;
  final FinancialQuality financialQuality;
  final String leadsToScene;

  const ChoiceModel({
    required this.id,
    required this.label,
    required this.description,
    required this.financialQuality,
    required this.leadsToScene,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) => ChoiceModel(
        id: json['id'] ?? '',
        label: json['label'] ?? '',
        description: json['description'] ?? '',
        financialQuality: qualityFromString(json['financial_quality'] ?? ''),
        leadsToScene: json['leads_to_scene'] ?? '',
      );
}

class OutcomeModel {
  final int pointsAwarded;
  final int happinessDelta;
  final String narrativeResult;
  final List<InventoryChange> inventoryChanges;

  const OutcomeModel({
    required this.pointsAwarded,
    required this.happinessDelta,
    required this.narrativeResult,
    required this.inventoryChanges,
  });

  factory OutcomeModel.fromJson(Map<String, dynamic> json) => OutcomeModel(
        pointsAwarded: json['points_awarded'] ?? 0,
        happinessDelta: json['happiness_delta'] ?? 0,
        narrativeResult: json['narrative_result'] ?? '',
        inventoryChanges: ((json['inventory_changes'] ?? []) as List)
            .map((i) => InventoryChange.fromJson(i))
            .toList(),
      );
}

class InventoryChange {
  final String item;
  final int delta;

  const InventoryChange({required this.item, required this.delta});

  factory InventoryChange.fromJson(Map<String, dynamic> json) =>
      InventoryChange(item: json['item'] ?? '', delta: json['delta'] ?? 0);
}

class ScoringModel {
  final int maxPoints;
  final Map<String, int>? gradeThresholds;
  final TrophyModel trophy;
  final ClassroomLeaderboard? classroomLeaderboard;

  const ScoringModel({
    required this.maxPoints,
    this.gradeThresholds,
    required this.trophy,
    this.classroomLeaderboard,
  });

  factory ScoringModel.fromJson(Map<String, dynamic> json) => ScoringModel(
        maxPoints: json['max_points'] ?? 100,
        gradeThresholds: (json['grade_thresholds'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as int)),
        trophy: TrophyModel.fromJson(json['trophy'] ?? {}),
        classroomLeaderboard: json['classroom_leaderboard'] != null
            ? ClassroomLeaderboard.fromJson(json['classroom_leaderboard'])
            : null,
      );
}

class TrophyModel {
  final String name;
  final String iconDescription;
  final String unlockMessage;

  const TrophyModel({
    required this.name,
    required this.iconDescription,
    required this.unlockMessage,
  });

  factory TrophyModel.fromJson(Map<String, dynamic> json) => TrophyModel(
        name: json['name'] ?? '',
        iconDescription: json['icon_description'] ?? '',
        unlockMessage: json['unlock_message'] ?? '',
      );
}

class ClassroomLeaderboard {
  final String metricLabel;
  final String shareableResultTemplate;

  const ClassroomLeaderboard({
    required this.metricLabel,
    required this.shareableResultTemplate,
  });

  factory ClassroomLeaderboard.fromJson(Map<String, dynamic> json) => ClassroomLeaderboard(
        metricLabel: json['metric_label'] ?? '',
        shareableResultTemplate: json['shareable_result_template'] ?? '',
      );
}

class DebriefModel {
  final String conceptName;
  final String conceptExplanation;
  final String realWorldConnection;
  final String reflectionQuestion;
  final String teaserNextLesson;

  const DebriefModel({
    required this.conceptName,
    required this.conceptExplanation,
    required this.realWorldConnection,
    required this.reflectionQuestion,
    required this.teaserNextLesson,
  });

  factory DebriefModel.fromJson(Map<String, dynamic> json) => DebriefModel(
        conceptName: json['concept_name'] ?? '',
        conceptExplanation: json['concept_explanation'] ?? '',
        realWorldConnection: json['real_world_connection'] ?? '',
        reflectionQuestion: json['reflection_question'] ?? '',
        teaserNextLesson: json['teaser_next_lesson'] ?? '',
      );
}
