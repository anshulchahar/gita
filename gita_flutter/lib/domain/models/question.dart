import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of questions available in lessons
enum QuestionType {
  multipleChoiceTranslation,
  fillInBlank,
  wordMatching,
  contextualApplication,
  trueFalse,
}

extension QuestionTypeExtension on QuestionType {
  String get name {
    switch (this) {
      case QuestionType.multipleChoiceTranslation:
        return 'MULTIPLE_CHOICE_TRANSLATION';
      case QuestionType.fillInBlank:
        return 'FILL_IN_BLANK';
      case QuestionType.wordMatching:
        return 'WORD_MATCHING';
      case QuestionType.contextualApplication:
        return 'CONTEXTUAL_APPLICATION';
      case QuestionType.trueFalse:
        return 'TRUE_FALSE';
    }
  }

  static QuestionType fromString(String value) {
    switch (value) {
      case 'MULTIPLE_CHOICE_TRANSLATION':
        return QuestionType.multipleChoiceTranslation;
      case 'FILL_IN_BLANK':
        return QuestionType.fillInBlank;
      case 'WORD_MATCHING':
        return QuestionType.wordMatching;
      case 'CONTEXTUAL_APPLICATION':
        return QuestionType.contextualApplication;
      case 'TRUE_FALSE':
        return QuestionType.trueFalse;
      default:
        return QuestionType.multipleChoiceTranslation;
    }
  }
}

/// Content of a question
class QuestionContent {
  final String shlokaSanskrit;
  final String shlokaTransliteration;
  final String shlokaNumber;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String realLifeApplication;
  final List<String> keywords;

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
  });

  factory QuestionContent.fromMap(Map<String, dynamic> data) {
    return QuestionContent(
      shlokaSanskrit: data['shlokaSanskrit'] ?? '',
      shlokaTransliteration: data['shlokaTransliteration'] ?? '',
      shlokaNumber: data['shlokaNumber'] ?? '',
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'] ?? '',
      realLifeApplication: data['realLifeApplication'] ?? '',
      keywords: List<String>.from(data['keywords'] ?? []),
    );
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
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Question(
      questionId: doc.id,
      lessonId: data['lessonId'] ?? '',
      type: QuestionTypeExtension.fromString(data['type'] ?? ''),
      order: data['order'] ?? 0,
      content: QuestionContent.fromMap(data['content'] ?? {}),
      points: data['points'] ?? 10,
      timeLimit: data['timeLimit'] ?? 60,
    );
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
