import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge.dart';

/// Domain model representing a user in the app
class AppUser {
  final String userId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Gamification gamification;
  final Map<String, LessonProgress> progress;
  final List<String> weakAreas;
  final List<String> achievements;
  final UserPreferences preferences;

  const AppUser({
    this.userId = '',
    this.email = '',
    this.displayName = '',
    this.photoUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.gamification = const Gamification(),
    this.progress = const {},
    this.weakAreas = const [],
    this.achievements = const [],
    this.preferences = const UserPreferences(),
  });

  factory AppUser.empty() {
    return AppUser(
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      
      // Safe progress parsing
      Map<String, LessonProgress> progressMap = {};
      final progressData = data['progress'] as Map<String, dynamic>?;
      if (progressData != null) {
        progressData.forEach((key, value) {
          if (value is Map) {
            try {
              progressMap[key] = LessonProgress.fromMap(Map<String, dynamic>.from(value));
            } catch (e) {
              print('Error parsing progress for $key: $e');
            }
          }
        });
      }

      // Safe gamification parsing
      Gamification gamificationData;
      try {
        final gData = data['gamification'];
        if (gData is Map) {
          gamificationData = Gamification.fromMap(Map<String, dynamic>.from(gData));
        } else {
          gamificationData = const Gamification();
        }
      } catch (e) {
        gamificationData = const Gamification();
      }

      // Safe preferences parsing
      UserPreferences prefs;
      try {
        final pData = data['preferences'];
        if (pData is Map) {
          prefs = UserPreferences.fromMap(Map<String, dynamic>.from(pData));
        } else {
          prefs = const UserPreferences();
        }
      } catch (e) {
        prefs = const UserPreferences();
      }

      return AppUser(
        userId: doc.id,
        email: _safeString(data, 'email'),
        displayName: _safeString(data, 'displayName'),
        photoUrl: data['photoUrl']?.toString(), 
        createdAt: _safeDate(data, 'createdAt'),
        lastActiveAt: _safeDate(data, 'lastActiveAt'),
        gamification: gamificationData,
        progress: progressMap,
        weakAreas: _safeList<String>(data, 'weakAreas'),
        achievements: _safeList<String>(data, 'achievements'),
        preferences: prefs,
      );
    } catch (e, stack) {
      print('❌ Error parsing User ${doc.id}: $e');
      print(stack);
      // Return minimal user to avoid crash if totally corrupt
      return AppUser(
        userId: doc.id,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        displayName: 'Error Loading User',
      );
    }
  }

  /// Safe helper for String extraction
  static String _safeString(Map<String, dynamic> data, String key, {String fallback = ''}) {
    final val = data[key];
    if (val is String) return val;
    if (val != null) return val.toString();
    return fallback;
  }

  /// Safe helper for Date extraction
  static DateTime _safeDate(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  /// Safe helper for List extraction
  static List<T> _safeList<T>(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is List) {
      // Map everything to string then filter? Or just safe cast?
      // Since T is usually String for us:
      return val.map((e) => e?.toString() ?? '').whereType<T>().toList();
    }
    return [];
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'gamification': gamification.toMap(),
      'progress': progress.map((key, value) => MapEntry(key, value.toMap())),
      'weakAreas': weakAreas,
      'achievements': achievements,
      'preferences': preferences.toMap(),
    };
  }

  AppUser copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Gamification? gamification,
    Map<String, LessonProgress>? progress,
    List<String>? weakAreas,
    List<String>? achievements,
    UserPreferences? preferences,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      gamification: gamification ?? this.gamification,
      progress: progress ?? this.progress,
      weakAreas: weakAreas ?? this.weakAreas,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Gamification data for a user
class Gamification {
  final int wisdomPoints;  // Total XP
  final int gems;
  final int energy;
  final int maxEnergy;
  final DateTime lastEnergyRefill;
  final int currentStreak;
  final int longestStreak;
  final String lastCompletedDate;
  final int totalLessonsCompleted;
  final int perfectScores;
  // New fields for enhanced gamification
  final List<BadgeId> earnedBadges;           // IDs of earned badges
  final Map<String, int> lessonStrength;       // Lesson ID -> strength (0-100)
  final Map<String, DateTime> lastPracticed;   // Lesson ID -> last practice date
  final int consecutivePerfects;               // For tracking perfect streaks
  final int reflectionsCompleted;              // For Reflective Soul badge
  final int scenariosCorrect;                  // For Scenario Sage badge

  const Gamification({
    this.wisdomPoints = 0,
    this.gems = 0,
    this.energy = 5,
    this.maxEnergy = 5,
    DateTime? lastEnergyRefill,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate = '',
    this.totalLessonsCompleted = 0,
    this.perfectScores = 0,
    this.earnedBadges = const [],
    this.lessonStrength = const {},
    this.lastPracticed = const {},
    this.consecutivePerfects = 0,
    this.reflectionsCompleted = 0,
    this.scenariosCorrect = 0,
  }) : lastEnergyRefill = lastEnergyRefill ?? const _DefaultDateTime();

  int get level => calculateLevel(wisdomPoints);
  String get levelTitle => levelTitles[level - 1];
  int get xpToNextLevel => xpForNextLevel(wisdomPoints);
  double get levelProgressPercent => levelProgress(wisdomPoints);
  bool hasBadge(BadgeId badge) => earnedBadges.contains(badge);

  factory Gamification.fromMap(Map<String, dynamic> data) {
    return Gamification(
      wisdomPoints: _safeInt(data, 'wisdomPoints'),
      gems: _safeInt(data, 'gems'),
      energy: _safeInt(data, 'energy', fallback: 5),
      maxEnergy: _safeInt(data, 'maxEnergy', fallback: 5),
      lastEnergyRefill: _safeDate(data, 'lastEnergyRefill'),
      currentStreak: _safeInt(data, 'currentStreak'),
      longestStreak: _safeInt(data, 'longestStreak'),
      lastCompletedDate: _safeString(data, 'lastCompletedDate'),
      totalLessonsCompleted: _safeInt(data, 'totalLessonsCompleted'),
      perfectScores: _safeInt(data, 'perfectScores'),
      
      earnedBadges: (data['earnedBadges'] as List<dynamic>? ?? [])
          .map((e) => BadgeId.values.firstWhere(
                (b) => b.name == e.toString(),
                orElse: () => BadgeId.firstStep,
              ))
          .toList(),
          
      lessonStrength: (data['lessonStrength'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0)),
          
      lastPracticed: (data['lastPracticed'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
                key,
                value is Timestamp ? value.toDate() : (DateTime.tryParse(value.toString()) ?? DateTime.now()),
              )),
              
      consecutivePerfects: _safeInt(data, 'consecutivePerfects'),
      reflectionsCompleted: _safeInt(data, 'reflectionsCompleted'),
      scenariosCorrect: _safeInt(data, 'scenariosCorrect'),
    );
  }

  // Safe helpers duplicated here for simplicity or can be static public
  static int _safeInt(Map<String, dynamic> data, String key, {int fallback = 0}) {
    final val = data[key];
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? fallback;
    return fallback;
  }
  
  static String _safeString(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is String) return val;
    if (val != null) return val.toString();
    return '';
  }

  static DateTime _safeDate(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now(); // Default to now if missing/corrupt
  }

  Map<String, dynamic> toMap() {
    return {
      'wisdomPoints': wisdomPoints,
      'gems': gems,
      'energy': energy,
      'maxEnergy': maxEnergy,
      'lastEnergyRefill': Timestamp.fromDate(lastEnergyRefill),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'totalLessonsCompleted': totalLessonsCompleted,
      'perfectScores': perfectScores,
      'earnedBadges': earnedBadges.map((e) => e.name).toList(),
      'lessonStrength': lessonStrength,
      'lastPracticed': lastPracticed.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
      'consecutivePerfects': consecutivePerfects,
      'reflectionsCompleted': reflectionsCompleted,
      'scenariosCorrect': scenariosCorrect,
    };
  }

  Gamification copyWith({
    int? wisdomPoints,
    int? gems,
    int? energy,
    int? maxEnergy,
    DateTime? lastEnergyRefill,
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    int? totalLessonsCompleted,
    int? perfectScores,
    List<BadgeId>? earnedBadges,
    Map<String, int>? lessonStrength,
    Map<String, DateTime>? lastPracticed,
    int? consecutivePerfects,
    int? reflectionsCompleted,
    int? scenariosCorrect,
  }) {
    return Gamification(
      wisdomPoints: wisdomPoints ?? this.wisdomPoints,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      lastEnergyRefill: lastEnergyRefill ?? this.lastEnergyRefill,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      perfectScores: perfectScores ?? this.perfectScores,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      lessonStrength: lessonStrength ?? this.lessonStrength,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      consecutivePerfects: consecutivePerfects ?? this.consecutivePerfects,
      reflectionsCompleted: reflectionsCompleted ?? this.reflectionsCompleted,
      scenariosCorrect: scenariosCorrect ?? this.scenariosCorrect,
    );
  }
}

class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  bool isAfter(DateTime other) => false;
  @override
  bool isBefore(DateTime other) => true;
  @override
  int compareTo(DateTime other) => -1;
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// Progress data for a specific lesson
class LessonProgress {
  final DateTime completedAt;
  final int score;
  final int attempts;
  final int timeSpent; // in seconds

  const LessonProgress({
    required this.completedAt,
    this.score = 0,
    this.attempts = 0,
    this.timeSpent = 0,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> data) {
    return LessonProgress(
      completedAt: _safeDate(data, 'completedAt'),
      score: _safeInt(data, 'score'),
      attempts: _safeInt(data, 'attempts'),
      timeSpent: _safeInt(data, 'timeSpent'),
    );
  }
  
  static int _safeInt(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is int) return val;
    return int.tryParse(val?.toString() ?? '') ?? 0;
  }
  
  static DateTime _safeDate(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt': Timestamp.fromDate(completedAt),
      'score': score,
      'attempts': attempts,
      'timeSpent': timeSpent,
    };
  }
}

/// User preferences
class UserPreferences {
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final String language;
  final String theme;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.dailyReminderTime = '09:00',
    this.language = 'hi',
    this.theme = 'light',
  });

  factory UserPreferences.fromMap(Map<String, dynamic> data) {
    return UserPreferences(
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
      dailyReminderTime: _safeString(data, 'dailyReminderTime', fallback: '09:00'),
      // STRICTLY ENFORCE STRING for language and theme to fix Map subtype error
      language: _safeString(data, 'language', fallback: 'hi'),
      theme: _safeString(data, 'theme', fallback: 'light'),
    );
  }
  
  static String _safeString(Map<String, dynamic> data, String key, {String fallback = ''}) {
    final val = data[key];
    if (val is String) return val;
    if (val != null) return val.toString();
    return fallback;
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderTime': dailyReminderTime,
      'language': language,
      'theme': theme,
    };
  }
}
