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
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      // STRICT ENGLISH ONLY & TYPE SAFETY
      // Map 'lessonName' (from DB, which is English) to both lessonName and lessonNameEn
      
      String name = _safeString(data, 'lessonName');
      // If empty, try lessonNameEn just in case
      if (name.isEmpty) {
        name = _safeString(data, 'lessonNameEn');
      }
      
      // Safe extraction of shlokasCovered
      List<int> shlokas = [];
      if (data['shlokasCovered'] is List) {
        shlokas = (data['shlokasCovered'] as List).map((e) {
          if (e is int) return e;
          return int.tryParse(e.toString()) ?? 0;
        }).toList();
      }
      
      return Lesson(
        lessonId: doc.id,
        chapterId: _safeString(data, 'chapterId'),
        lessonNumber: _safeInt(data, 'lessonNumber'),
        lessonName: name, // Force English
        lessonNameEn: name, // Force English
        order: _safeInt(data, 'order'),
        estimatedTime: _safeInt(data, 'estimatedTime'),
        difficulty: _safeString(data, 'difficulty', fallback: 'beginner'),
        shlokasCovered: shlokas,
        xpReward: _safeInt(data, 'xpReward'),
        prerequisite: data['prerequisite']?.toString(), // nullable
      );
    } catch (e, stack) {
      print('❌ Error parsing Lesson ${doc.id}: $e');
      print(stack);
      // Return dummy lesson
      return Lesson(
        lessonId: doc.id,
        lessonName: 'Error loading lesson',
      );
    }
  }

  // --- Type Safety Helpers ---

  static String _safeString(Map<String, dynamic> data, String key, {String fallback = ''}) {
    final val = data[key];
    if (val is String) return val;
    if (val != null) return val.toString();
    return fallback;
  }

  static int _safeInt(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
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
