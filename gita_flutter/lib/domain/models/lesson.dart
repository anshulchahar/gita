import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing a lesson within a chapter
class Lesson {
  final String lessonId;
  final String chapterId;
  final int lessonNumber;
  final String lessonName;
  final String lessonNameEn;
  final int order;
  final int estimatedTime; // in seconds
  final String difficulty; // beginner, intermediate, advanced
  final List<int> shlokasCovered;
  final int xpReward;
  final String? prerequisite;

  const Lesson({
    this.lessonId = '',
    this.chapterId = '',
    this.lessonNumber = 0,
    this.lessonName = '',
    this.lessonNameEn = '',
    this.order = 0,
    this.estimatedTime = 0,
    this.difficulty = 'beginner',
    this.shlokasCovered = const [],
    this.xpReward = 0,
    this.prerequisite,
  });

  factory Lesson.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Lesson(
      lessonId: doc.id,
      chapterId: data['chapterId'] ?? '',
      lessonNumber: data['lessonNumber'] ?? 0,
      lessonName: data['lessonName'] ?? '',
      lessonNameEn: data['lessonNameEn'] ?? '',
      order: data['order'] ?? 0,
      estimatedTime: data['estimatedTime'] ?? 0,
      difficulty: data['difficulty'] ?? 'beginner',
      shlokasCovered: List<int>.from(data['shlokasCovered'] ?? []),
      xpReward: data['xpReward'] ?? 0,
      prerequisite: data['prerequisite'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chapterId': chapterId,
      'lessonNumber': lessonNumber,
      'lessonName': lessonName,
      'lessonNameEn': lessonNameEn,
      'order': order,
      'estimatedTime': estimatedTime,
      'difficulty': difficulty,
      'shlokasCovered': shlokasCovered,
      'xpReward': xpReward,
      'prerequisite': prerequisite,
    };
  }

  Lesson copyWith({
    String? lessonId,
    String? chapterId,
    int? lessonNumber,
    String? lessonName,
    String? lessonNameEn,
    int? order,
    int? estimatedTime,
    String? difficulty,
    List<int>? shlokasCovered,
    int? xpReward,
    String? prerequisite,
  }) {
    return Lesson(
      lessonId: lessonId ?? this.lessonId,
      chapterId: chapterId ?? this.chapterId,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      lessonName: lessonName ?? this.lessonName,
      lessonNameEn: lessonNameEn ?? this.lessonNameEn,
      order: order ?? this.order,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      difficulty: difficulty ?? this.difficulty,
      shlokasCovered: shlokasCovered ?? this.shlokasCovered,
      xpReward: xpReward ?? this.xpReward,
      prerequisite: prerequisite ?? this.prerequisite,
    );
  }
}
