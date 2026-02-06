import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of questions available in lessons
enum QuestionType {
  /// Animated story card with Krishna narrating context (10 XP)
  storyCard,
  /// Multiple choice comprehension questions (15 XP)
  multipleChoiceTranslation,
  /// Fill in the blank for verse or teaching (15 XP)
  fillInBlank,
  /// Journal-style personal reflection questions (20 XP)
  reflectionPrompt,
  /// Real-life dilemma solving scenarios (25 XP)
  scenarioChallenge,
  /// Sanskrit-English pair matching (5 XP - optional)
  wordMatching,
  /// Contextual application questions
  contextualApplication,
  /// True/False questions
  trueFalse,
}

extension QuestionTypeExtension on QuestionType {
  String get name {
    switch (this) {
      case QuestionType.storyCard:
        return 'STORY_CARD';
      case QuestionType.multipleChoiceTranslation:
        return 'MULTIPLE_CHOICE_TRANSLATION';
      case QuestionType.fillInBlank:
        return 'FILL_IN_BLANK';
      case QuestionType.reflectionPrompt:
        return 'REFLECTION_PROMPT';
      case QuestionType.scenarioChallenge:
        return 'SCENARIO_CHALLENGE';
      case QuestionType.wordMatching:
        return 'WORD_MATCHING';
      case QuestionType.contextualApplication:
        return 'CONTEXTUAL_APPLICATION';
      case QuestionType.trueFalse:
        return 'TRUE_FALSE';
    }
  }

  /// XP rewards for each activity type (from plan.md)
  int get xpReward {
    switch (this) {
      case QuestionType.storyCard:
        return 10;
      case QuestionType.multipleChoiceTranslation:
      case QuestionType.fillInBlank:
        return 15;
      case QuestionType.reflectionPrompt:
        return 20;
      case QuestionType.scenarioChallenge:
        return 25;
      case QuestionType.wordMatching:
        return 5;
      case QuestionType.contextualApplication:
        return 15;
      case QuestionType.trueFalse:
        return 10;
    }
  }

  static QuestionType fromString(String value) {
    // Handle both uppercase (STORY_CARD) and lowercase (storyCard) formats
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'story_card':
      case 'storycard':
        return QuestionType.storyCard;
      case 'multiple_choice_translation':
      case 'multiplechoice':
      case 'multiplechoicetranslation':
        return QuestionType.multipleChoiceTranslation;
      case 'fill_in_blank':
      case 'fillinblank':
        return QuestionType.fillInBlank;
      case 'reflection_prompt':
      case 'reflectionprompt':
        return QuestionType.reflectionPrompt;
      case 'scenario_challenge':
      case 'scenariochallenge':
        return QuestionType.scenarioChallenge;
      case 'word_matching':
      case 'wordmatching':
        return QuestionType.wordMatching;
      case 'contextual_application':
      case 'contextualapplication':
        return QuestionType.contextualApplication;
      case 'true_false':
      case 'truefalse':
        return QuestionType.trueFalse;
      default:
        return QuestionType.multipleChoiceTranslation;
    }
  }
}

/// Content of a question or activity
class QuestionContent {
  // === Common fields ===
  final String shlokaSanskrit;
  final String shlokaTransliteration;
  final String shlokaNumber;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String realLifeApplication;
  final List<String> keywords;

  // === Story Card fields ===
  /// The main story/context text for Story Card activities
  final String storyText;
  /// Krishna's narrative dialogue for Story Card
  final String krishnaMessage;

  // === Reflection Prompt fields ===
  /// The reflection question for journal-style activities
  final String reflectionQuestion;
  /// Optional hint/guidance for reflection
  final String reflectionHint;

  // === Scenario Challenge fields ===
  /// Description of the real-life dilemma scenario
  final String scenarioDescription;
  /// Context or backstory for the scenario
  final String scenarioContext;
  /// The wisdom teaching that applies to this scenario
  final String scenarioTeaching;

  const QuestionContent({
    this.shlokaSanskrit = '',
    this.shlokaTransliteration = '',
    this.shlokaNumber = '',
    this.questionText = '',
    this.options = const [],
    this.correctAnswerIndex = 0,
    this.explanation = '',
    this.realLifeApplication = '',
    this.keywords = const [],
    // Story Card
    this.storyText = '',
    this.krishnaMessage = '',
    // Reflection Prompt
    this.reflectionQuestion = '',
    this.reflectionHint = '',
    // Scenario Challenge
    this.scenarioDescription = '',
    this.scenarioContext = '',
    this.scenarioTeaching = '',
  });

  factory QuestionContent.fromMap(Map<String, dynamic> data) {
    // STRICT CONTENT PARSING MATCHING unit1.json / unit2.json
    return QuestionContent(
      shlokaSanskrit: _safeString(data, 'shlokaSanskrit'),
      shlokaTransliteration: _safeString(data, 'shlokaTransliteration'),
      shlokaNumber: _safeString(data, 'shlokaNumber'),
      
      // Question Text: prefer 'questionText', fallback for some legacy consistency if needed but aimed at JSON
      questionText: _safeString(data, 'questionText'),
      
      options: _extractOptions(data),
      correctAnswerIndex: _findCorrectAnswerIndex(data),
      
      explanation: _safeString(data, 'explanation'),
      realLifeApplication: _safeString(data, 'realLifeApplication'),
      keywords: _safeStringList(data, 'keywords'),
      
      // Story Card
      // JSON uses 'story' and 'krishnaMessage'
      storyText: _safeString(data, 'story'), 
      krishnaMessage: _safeString(data, 'krishnaMessage'),
      
      // Reflection Prompt
      // JSON uses 'prompt'
      reflectionQuestion: _safeString(data, 'prompt'),
      reflectionHint: _safeString(data, 'hint'), // 'hint' not always present but good fallback
      
      // Scenario Challenge
      // JSON uses 'scenario', 'scenarioTitle'
      scenarioDescription: _safeString(data, 'scenario'),
      scenarioContext: _safeString(data, 'scenarioTitle'),
      scenarioTeaching: _safeString(data, 'scenarioTeaching'),
    );
  }

  /// Safely extract a string value, with optional fallback key
  static String _safeString(Map<String, dynamic> data, String key, {String? fallbackKey}) {
    var value = data[key];
    if (value == null && fallbackKey != null) {
      value = data[fallbackKey];
    }
    if (value is String) return value;
    if (value != null) return value.toString();
    return '';
  }

  /// Safely extract an int value
  static int _safeInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value != null) return int.tryParse(value.toString()) ?? 0;
    return 0;
  }

  /// Safely extract a list of strings
  static List<String> _safeStringList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

  /// Helper to extract options from different data formats
  static List<String> _extractOptions(Map<String, dynamic> data) {
    // Check both 'options' and 'optionsEnglish' if you have dual language in future, 
    // but unit1.json just uses 'options' as list of strings usually.
    final value = data['options'];
    if (value == null) return [];
    if (value is! List) return [];
    
    return value.map((o) {
      if (o is String) return o;
      if (o is Map) return o['text']?.toString() ?? '';
      return o?.toString() ?? '';
    }).toList().map((e) => e.toString()).toList();
  }

  /// Helper to find the correct answer index from options with isOptimal or isCorrect
  static int _findCorrectAnswerIndex(Map<String, dynamic> data) {
    // First check if there's an explicit correctAnswerIndex
    final explicitIndex = data['correctAnswerIndex'];
    if (explicitIndex is int) return explicitIndex;
    if (explicitIndex != null) {
      final parsed = int.tryParse(explicitIndex.toString());
      if (parsed != null) return parsed;
    }
    
    // Otherwise, find the option with isOptimal: true or isCorrect: true
    final options = data['options'];
    if (options is! List) return 0;
    
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      if (option is Map) {
        // Check for isOptimal (scenario challenges)
        if (option['isOptimal'] == true) return i;
        // Check for isCorrect (multiple choice)
        if (option['isCorrect'] == true) return i;
      }
    }
    
    // Default to 0 if no correct answer found
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'shlokaSanskrit': shlokaSanskrit,
      'shlokaTransliteration': shlokaTransliteration,
      'shlokaNumber': shlokaNumber,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'realLifeApplication': realLifeApplication,
      'keywords': keywords,
      // Story Card
      'story': storyText,
      'krishnaMessage': krishnaMessage,
      // Reflection Prompt
      'prompt': reflectionQuestion,
      'hint': reflectionHint,
      // Scenario Challenge
      'scenario': scenarioDescription,
      'scenarioTitle': scenarioContext,
      'scenarioTeaching': scenarioTeaching,
    };
  }
}

/// Domain model representing a question in a lesson
class Question {
  final String questionId;
  final String lessonId;
  final QuestionType type;
  final int order;
  final QuestionContent content;
  final int points;
  final int timeLimit; // in seconds

  const Question({
    this.questionId = '',
    this.lessonId = '',
    this.type = QuestionType.multipleChoiceTranslation,
    this.order = 0,
    this.content = const QuestionContent(),
    this.points = 10,
    this.timeLimit = 60,
  });


  factory Question.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      // SAFE PARSING OF CORE FIELDS
      
      // LessonId
      String lessonId = '';
      if (data['lessonId'] != null) lessonId = data['lessonId'].toString();
      
      // Type
      String typeStr = '';
      if (data['type'] != null) typeStr = data['type'].toString();
      
      // Order, Points, TimeLimit
      int order = _safeInt(data, 'order');
      int points = _safeInt(data, 'points', fallback: 10);
      int timeLimit = _safeInt(data, 'timeLimit', fallback: 60);

      // Content Map
      Map<String, dynamic> contentMap = {};
      if (data['content'] is Map) {
        contentMap = Map<String, dynamic>.from(data['content']);
      }

      return Question(
        questionId: doc.id,
        lessonId: lessonId,
        type: QuestionTypeExtension.fromString(typeStr),
        order: order,
        content: QuestionContent.fromMap(contentMap),
        points: points,
        timeLimit: timeLimit,
      );
    } catch (e, stackTrace) {
      // Log the specific document that failed
      print('❌ Error parsing Question ${doc.id}: $e');
      print(stackTrace);
      // Return a safe 'error' question to prevent app crash
      return Question(
        questionId: doc.id,
        type: QuestionType.storyCard,
        content: QuestionContent(
          questionText: 'Error loading question (${doc.id})',
          explanation: e.toString(),
        ),
      );
    }
  }

  
  static int _safeInt(Map<String, dynamic> data, String key, {int fallback = 0}) {
    final val = data[key];
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? fallback;
    return fallback;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lessonId': lessonId,
      'type': type.name,
      'order': order,
      'content': content.toMap(),
      'points': points,
      'timeLimit': timeLimit,
    };
  }

  Question copyWith({
    String? questionId,
    String? lessonId,
    QuestionType? type,
    int? order,
    QuestionContent? content,
    int? points,
    int? timeLimit,
  }) {
    return Question(
      questionId: questionId ?? this.questionId,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      order: order ?? this.order,
      content: content ?? this.content,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }
}

/// Result of answering a question
class QuestionResult {
  final String questionId;
  final bool isCorrect;
  final int selectedAnswer;
  final int correctAnswer;
  final String explanation;
  final String realLifeApplication;

  const QuestionResult({
    required this.questionId,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    this.explanation = '',
    this.realLifeApplication = '',
  });
}
