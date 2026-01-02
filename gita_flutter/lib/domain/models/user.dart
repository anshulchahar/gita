import 'package:cloud_firestore/cloud_firestore.dart';

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
  final int wisdomPoints;
  final int gems;
  final int energy;
  final int maxEnergy;
  final DateTime lastEnergyRefill;
  final int currentStreak;
  final int longestStreak;
  final String lastCompletedDate;
  final int totalLessonsCompleted;
  final int perfectScores;

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
  }) : lastEnergyRefill = lastEnergyRefill ?? const _DefaultDateTime();

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
    };
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
