import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/badge.dart';
import '../../domain/models/question.dart';
import '../../domain/models/user.dart';

/// Result of completing a lesson, used to check for new badges
class LessonResult {
  final String lessonId;
  final String chapterId;
  final int score;           // 0-100 percentage
  final int questionsTotal;
  final int questionsCorrect;
  final DateTime completedAt;
  final int xpEarned;
  final int reflectionsCount;
  final int scenariosCorrect;

  const LessonResult({
    required this.lessonId,
    required this.chapterId,
    required this.score,
    required this.questionsTotal,
    required this.questionsCorrect,
    required this.completedAt,
    required this.xpEarned,
    this.reflectionsCount = 0,
    this.scenariosCorrect = 0,
  });

  bool get isPerfect => score == 100;
}

/// Centralized service for all gamification logic
class GamificationService {
  
  /// Calculate XP for completing an activity
  /// Returns base XP + bonuses for first attempt correct, streak, etc.
  static int calculateXpForActivity({
    required QuestionType type,
    required bool isCorrect,
    required bool isFirstAttempt,
    int streakDays = 0,
  }) {
    // Base XP from activity type
    int baseXp = type.xpReward;
    
    // Bonus for correct answer on first attempt
    if (isCorrect && isFirstAttempt) {
      baseXp = (baseXp * 1.2).round(); // 20% bonus
    }
    
    // Streak bonus (5% per day, max 50%)
    if (streakDays > 0) {
      final streakMultiplier = 1.0 + (streakDays.clamp(0, 10) * 0.05);
      baseXp = (baseXp * streakMultiplier).round();
    }
    
    return baseXp;
  }

  /// Calculate total XP for a completed lesson
  static int calculateLessonXp({
    required int baseXp,
    required int score, // 0-100
    required bool isPerfect,
    required int streakDays,
  }) {
    double multiplier = 1.0;
    
    // Score-based multiplier
    if (score >= 90) {
      multiplier += 0.3; // 30% bonus for 90%+
    } else if (score >= 70) {
      multiplier += 0.15; // 15% bonus for 70%+
    }
    
    // Perfect score bonus
    if (isPerfect) {
      multiplier += 0.2; // Additional 20% for perfect
    }
    
    // Streak bonus
    final streakBonus = (streakDays.clamp(0, 10) * 0.05);
    multiplier += streakBonus;
    
    return (baseXp * multiplier).round();
  }

  /// Check which new badges user has earned after completing a lesson
  static List<Badge> checkBadgeUnlocks({
    required Gamification currentStats,
    required LessonResult result,
    required int totalChaptersCompleted,
  }) {
    final List<Badge> newBadges = [];
    final now = result.completedAt;
    
    // Helper to add badge if not already earned
    void checkAndAdd(BadgeId id) {
      if (!currentStats.hasBadge(id)) {
        newBadges.add(badgeDefinitions[id]!.markEarned());
      }
    }

    // ============ MILESTONE BADGES ============
    
    // First Step - First lesson completed
    if (currentStats.totalLessonsCompleted == 0) {
      checkAndAdd(BadgeId.firstStep);
    }
    
    // Seeker - 10 lessons
    if (currentStats.totalLessonsCompleted + 1 >= 10) {
      checkAndAdd(BadgeId.seeker);
    }
    
    // Warrior's Heart - 50 lessons
    if (currentStats.totalLessonsCompleted + 1 >= 50) {
      checkAndAdd(BadgeId.warriorsHeart);
    }
    
    // Devotee - 100 lessons
    if (currentStats.totalLessonsCompleted + 1 >= 100) {
      checkAndAdd(BadgeId.devotee);
    }
    
    // Liberated Soul - All 18 chapters
    if (totalChaptersCompleted >= 18) {
      checkAndAdd(BadgeId.liberatedSoul);
    }

    // ============ MASTERY BADGES ============
    
    // Perfect Karma - 100% on any lesson
    if (result.isPerfect) {
      checkAndAdd(BadgeId.perfectKarma);
    }
    
    // Steady Mind - 5 perfect lessons in a row
    if (result.isPerfect && currentStats.consecutivePerfects + 1 >= 5) {
      checkAndAdd(BadgeId.steadyMind);
    }
    
    // Unshakeable - 10 perfect lessons in a row
    if (result.isPerfect && currentStats.consecutivePerfects + 1 >= 10) {
      checkAndAdd(BadgeId.unshakeable);
    }

    // ============ STREAK BADGES ============
    
    // Week Warrior - 7-day streak
    if (currentStats.currentStreak + 1 >= 7) {
      checkAndAdd(BadgeId.weekWarrior);
    }
    
    // Fortnight Focus - 14-day streak
    if (currentStats.currentStreak + 1 >= 14) {
      checkAndAdd(BadgeId.fortnightFocus);
    }
    
    // Monthly Master - 30-day streak
    if (currentStats.currentStreak + 1 >= 30) {
      checkAndAdd(BadgeId.monthlyMaster);
    }
    
    // Century Streak - 100-day streak
    if (currentStats.currentStreak + 1 >= 100) {
      checkAndAdd(BadgeId.centuryStreak);
    }

    // ============ SPECIAL BADGES ============
    
    // Night Owl - Complete lesson after 10 PM
    if (now.hour >= 22 || now.hour < 4) {
      checkAndAdd(BadgeId.nightOwl);
    }
    
    // Early Bird - Complete lesson before 6 AM
    if (now.hour >= 4 && now.hour < 6) {
      checkAndAdd(BadgeId.earlyBird);
    }
    
    // Weekend Warrior - Check if completing on weekend
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      // TODO: Track if both weekend days were completed this week
      checkAndAdd(BadgeId.weekendWarrior);
    }
    
    // Reflective Soul - 10 reflections completed
    if (currentStats.reflectionsCompleted + result.reflectionsCount >= 10) {
      checkAndAdd(BadgeId.reflectiveSoul);
    }
    
    // Scenario Sage - 20 scenarios correct
    if (currentStats.scenariosCorrect + result.scenariosCorrect >= 20) {
      checkAndAdd(BadgeId.scenarioSage);
    }

    return newBadges;
  }

  /// Update streak based on last completed date
  /// Returns updated (currentStreak, longestStreak, streakBroken)
  static ({int current, int longest, bool broken}) updateStreak({
    required String lastCompletedDate, // YYYY-MM-DD format
    required int currentStreak,
    required int longestStreak,
  }) {
    final today = DateTime.now();
    final todayStr = _formatDate(today);
    
    // Already completed today
    if (lastCompletedDate == todayStr) {
      return (current: currentStreak, longest: longestStreak, broken: false);
    }
    
    // Check if yesterday
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = _formatDate(yesterday);
    
    if (lastCompletedDate == yesterdayStr) {
      // Streak continues
      final newStreak = currentStreak + 1;
      final newLongest = newStreak > longestStreak ? newStreak : longestStreak;
      return (current: newStreak, longest: newLongest, broken: false);
    }
    
    if (lastCompletedDate.isEmpty) {
      // First ever completion
      return (current: 1, longest: 1, broken: false);
    }
    
    // Streak broken - reset to 1
    return (current: 1, longest: longestStreak, broken: true);
  }

  /// Calculate lesson strength for spaced repetition
  /// Strength decays over time and increases with practice
  static int calculateLessonStrength({
    required int currentStrength,
    required int score, // 0-100
    required int daysSinceLastPractice,
  }) {
    // Decay: lose 5 points per day, minimum 0
    final decayedStrength = (currentStrength - (daysSinceLastPractice * 5)).clamp(0, 100);
    
    // Gain: Add score-based increase
    // Perfect scores boost more than poor scores
    final gainMultiplier = score >= 90 ? 1.5 : (score >= 70 ? 1.0 : 0.5);
    final gain = ((100 - decayedStrength) * 0.3 * gainMultiplier).round();
    
    return (decayedStrength + gain).clamp(0, 100);
  }

  /// Get lessons that need review (for spaced repetition)
  static List<String> getLessonsNeedingReview({
    required Map<String, int> lessonStrength,
    required Map<String, DateTime> lastPracticed,
    int strengthThreshold = 70,
    int maxDaysSinceReview = 7,
  }) {
    final now = DateTime.now();
    final needsReview = <String>[];
    
    for (final entry in lessonStrength.entries) {
      final lessonId = entry.key;
      final strength = entry.value;
      final lastDate = lastPracticed[lessonId];
      
      if (strength < strengthThreshold) {
        needsReview.add(lessonId);
        continue;
      }
      
      if (lastDate != null) {
        final daysSince = now.difference(lastDate).inDays;
        if (daysSince > maxDaysSinceReview) {
          needsReview.add(lessonId);
        }
      }
    }
    
    // Sort by priority (lowest strength first)
    needsReview.sort((a, b) => 
      (lessonStrength[a] ?? 0).compareTo(lessonStrength[b] ?? 0)
    );
    
    return needsReview;
  }

  /// Format date as YYYY-MM-DD
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's date string
  static String get todayString => _formatDate(DateTime.now());
}

/// Provider for gamification service
final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});
