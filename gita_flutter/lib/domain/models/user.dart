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
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gamification: Gamification.fromMap(data['gamification'] ?? {}),
      progress: (data['progress'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, LessonProgress.fromMap(value))),
      weakAreas: List<String>.from(data['weakAreas'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
    );
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

  /// Calculate user level from XP
  int get level => calculateLevel(wisdomPoints);

  /// Get level title
  String get levelTitle => levelTitles[level - 1];

  /// Get XP needed for next level
  int get xpToNextLevel => xpForNextLevel(wisdomPoints);

  /// Get progress to next level (0.0 - 1.0)
  double get levelProgressPercent => levelProgress(wisdomPoints);

  /// Check if user has earned a specific badge
  bool hasBadge(BadgeId badge) => earnedBadges.contains(badge);

  factory Gamification.fromMap(Map<String, dynamic> data) {
    return Gamification(
      wisdomPoints: data['wisdomPoints'] ?? 0,
      gems: data['gems'] ?? 0,
      energy: data['energy'] ?? 5,
      maxEnergy: data['maxEnergy'] ?? 5,
      lastEnergyRefill: (data['lastEnergyRefill'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastCompletedDate: data['lastCompletedDate'] ?? '',
      totalLessonsCompleted: data['totalLessonsCompleted'] ?? 0,
      perfectScores: data['perfectScores'] ?? 0,
      earnedBadges: (data['earnedBadges'] as List<dynamic>? ?? [])
          .map((e) => BadgeId.values.firstWhere(
                (b) => b.name == e,
                orElse: () => BadgeId.firstStep,
              ))
          .toList(),
      lessonStrength: Map<String, int>.from(data['lessonStrength'] ?? {}),
      lastPracticed: (data['lastPracticed'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
                key,
                value is Timestamp ? value.toDate() : DateTime.parse(value),
              )),
      consecutivePerfects: data['consecutivePerfects'] ?? 0,
      reflectionsCompleted: data['reflectionsCompleted'] ?? 0,
      scenariosCorrect: data['scenariosCorrect'] ?? 0,
    );
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
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      score: data['score'] ?? 0,
      attempts: data['attempts'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
    );
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
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      dailyReminderTime: data['dailyReminderTime'] ?? '09:00',
      language: data['language'] ?? 'hi',
      theme: data['theme'] ?? 'light',
    );
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
