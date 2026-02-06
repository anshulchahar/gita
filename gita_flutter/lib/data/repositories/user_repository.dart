import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user.dart';
import '../../core/constants/constants.dart';

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

/// Repository for managing user data
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  /// Get user by ID
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(Collections.users)
          .doc(userId)
          .get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get user as stream for real-time updates
  Stream<AppUser?> getUserStream(String userId) {
    return _firestore
        .collection(Collections.users)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  /// Create or update user
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(user.userId)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  /// Update user gamification data
  Future<void> updateGamification(String userId, Gamification gamification) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .update({'gamification': gamification.toMap()});
    } catch (e) {
      throw Exception('Failed to update gamification: $e');
    }
  }

  /// Save lesson progress
  Future<void> saveLessonProgress(
    String userId,
    String lessonId,
    LessonProgress progress,
  ) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .update({'progress.$lessonId': progress.toMap()});
    } catch (e) {
      throw Exception('Failed to save lesson progress: $e');
    }
  }

  /// Get completed lesson IDs for a user
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    try {
      final doc = await _firestore
          .collection(Collections.users)
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final progress = data['progress'] as Map<String, dynamic>? ?? {};
        return progress.keys.toSet();
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get completed lessons: $e');
    }
  }

  /// Add XP to user
  Future<void> addWisdomPoints(String userId, int points) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .update({
        'gamification.wisdomPoints': FieldValue.increment(points),
      });
    } catch (e) {
      throw Exception('Failed to add wisdom points: $e');
    }
  }

  /// Update streak
  Future<void> updateStreak(String userId, int streak) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .update({
        'gamification.currentStreak': streak,
        'gamification.lastCompletedDate': today,
        'gamification.totalLessonsCompleted': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  /// Update lesson practice data for spaced repetition
  Future<void> updateLessonPractice(
    String userId, 
    String lessonId, 
    DateTime practiceDate,
    int score,
  ) async {
    try {
      final dateString = practiceDate.toIso8601String();
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .update({
        'gamification.lastPracticed.$lessonId': dateString,
        'gamification.lessonStrength.$lessonId': score.clamp(0, 100),
      });
    } catch (e) {
      throw Exception('Failed to update lesson practice: $e');
    }
  }
}
