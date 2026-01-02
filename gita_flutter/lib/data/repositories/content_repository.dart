import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/question.dart';
import '../../core/constants/constants.dart';

/// Provider for ContentRepository
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(FirebaseFirestore.instance);
});

/// Repository for managing content (chapters, lessons, questions)
class ContentRepository {
  final FirebaseFirestore _firestore;

  ContentRepository(this._firestore);

  // CHAPTERS

  /// Get all chapters ordered by chapter number
  Future<List<Chapter>> getChapters() async {
    try {
      final snapshot = await _firestore
          .collection(Collections.chapters)
          .orderBy('chapterNumber')
          .get();
      return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }

  /// Get chapters as a stream for real-time updates
  Stream<List<Chapter>> getChaptersStream() {
    return _firestore
        .collection(Collections.chapters)
        .orderBy('chapterNumber')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList());
  }

  /// Get a single chapter by ID
  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final doc = await _firestore
          .collection(Collections.chapters)
          .doc(chapterId)
          .get();
      if (doc.exists) {
        return Chapter.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get chapter: $e');
    }
  }

  // LESSONS

  /// Get lessons for a specific chapter
  Future<List<Lesson>> getLessons(String chapterId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.lessons)
          .where('chapterId', isEqualTo: chapterId)
          .get();
      final lessons = snapshot.docs.map((doc) => Lesson.fromFirestore(doc)).toList();
      lessons.sort((a, b) => a.order.compareTo(b.order));
      return lessons;
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  /// Get lessons as a stream for real-time updates
  Stream<List<Lesson>> getLessonsStream(String chapterId) {
    return _firestore
        .collection(Collections.lessons)
        .where('chapterId', isEqualTo: chapterId)
        .snapshots()
        .map((snapshot) {
            final lessons = snapshot.docs.map((doc) => Lesson.fromFirestore(doc)).toList();
            lessons.sort((a, b) => a.order.compareTo(b.order));
            return lessons;
        });
  }

  /// Get a single lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final doc = await _firestore
          .collection(Collections.lessons)
          .doc(lessonId)
          .get();
      if (doc.exists) {
        return Lesson.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get lesson: $e');
    }
  }

  // QUESTIONS

  /// Get questions for a specific lesson
  Future<List<Question>> getQuestions(String lessonId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.questions)
          .where('lessonId', isEqualTo: lessonId)
          .get();
      final questions = snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
      questions.sort((a, b) => a.order.compareTo(b.order));
      return questions;
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  /// Get questions as a stream for real-time updates
  Stream<List<Question>> getQuestionsStream(String lessonId) {
    return _firestore
        .collection(Collections.questions)
        .where('lessonId', isEqualTo: lessonId)
        .snapshots()
        .map((snapshot) {
            final questions = snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
            questions.sort((a, b) => a.order.compareTo(b.order));
            return questions;
        });
  }

  // ADMIN FUNCTIONS

  /// Create a chapter (admin function)
  Future<String> createChapter(Chapter chapter) async {
    try {
      final docRef = await _firestore
          .collection(Collections.chapters)
          .add(chapter.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chapter: $e');
    }
  }

  /// Create a lesson (admin function)
  Future<String> createLesson(Lesson lesson) async {
    try {
      final docRef = await _firestore
          .collection(Collections.lessons)
          .add(lesson.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create lesson: $e');
    }
  }

  /// Create a question (admin function)
  Future<String> createQuestion(Question question) async {
    try {
      final docRef = await _firestore
          .collection(Collections.questions)
          .add(question.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  /// Batch create questions (admin function)
  Future<void> createQuestions(List<Question> questions) async {
    try {
      final batch = _firestore.batch();
      for (final question in questions) {
        final docRef = _firestore.collection(Collections.questions).doc();
        batch.set(docRef, question.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create questions: $e');
    }
  }

  /// Clear all content (for debugging)
  Future<void> clearAllContent() async {
    try {
      // Delete all questions
      final questions = await _firestore.collection(Collections.questions).get();
      for (final doc in questions.docs) {
        await doc.reference.delete();
      }

      // Delete all lessons
      final lessons = await _firestore.collection(Collections.lessons).get();
      for (final doc in lessons.docs) {
        await doc.reference.delete();
      }

      // Delete all chapters
      final chapters = await _firestore.collection(Collections.chapters).get();
      for (final doc in chapters.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear content: $e');
    }
  }
}
