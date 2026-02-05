import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/journey.dart';
import '../../domain/models/section.dart';
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

  // JOURNEYS

  /// Get all journeys ordered by journey number
  Future<List<Journey>> getJourneys() async {
    try {
      final snapshot = await _firestore
          .collection('journeys')
          .orderBy('journeyNumber')
          .get();
      
      final List<Journey> journeys = [];
      for (final doc in snapshot.docs) {
        try {
          journeys.add(Journey.fromFirestore(doc));
        } catch (e) {
          print('❌ Error parsing journey ${doc.id}: $e');
        }
      }
      return journeys;
    } catch (e) {
      throw Exception('Failed to get journeys: $e');
    }
  }

  // CHAPTERS

  /// Get all chapters ordered by chapter number
  Future<List<Chapter>> getChapters() async {
    try {
      final snapshot = await _firestore
          .collection(Collections.chapters)
          .orderBy('chapterNumber')
          .get();
      
      final List<Chapter> chapters = [];
      for (final doc in snapshot.docs) {
        try {
          chapters.add(Chapter.fromFirestore(doc));
        } catch (e) {
          print('❌ Error parsing chapter ${doc.id}: $e');
        }
      }
      return chapters;
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
        .map((snapshot) {
            final List<Chapter> chapters = [];
            for (final doc in snapshot.docs) {
              try {
                chapters.add(Chapter.fromFirestore(doc));
              } catch (e) {
                print('❌ Error parsing chapter ${doc.id}: $e');
              }
            }
            return chapters;
        });
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

  // SECTIONS

  /// Get sections for a specific chapter
  Future<List<Section>> getSections(String chapterId) async {
    try {
      final snapshot = await _firestore
          .collection('sections') // Assuming seeding script uses 'sections'
          .where('journeyId', isGreaterThan: '') // Hack? No.
           // Wait, seeding script creates 'sections' collection.
           // Section has 'unitId' which mapped to 'unit_X'. 
           // But 'chapterId' is NOT on section in unit1.json.
           // populate_db.py: section['journeyId'] = journey_id.
           // It does NOT add chapterId to section.
           // It creates document "sections/section_id".
           // Section has unitId.
           // Chapter ID in app corresponds to Unit ID (e.g. "chapter_1").
           // So we query sections where unitId == "unit_1" (if chapterId passes "unit_1"?)
           // NO. App passes chapterId = "chapter_1".
           // Unit ID in JSON is "unit_1".
           // Seeding: create_document(token, "chapters", "chapter_1", ...)
           // Seeding: create_document(token, "units", "unit_1", ...)
           // Section linkage: "unitId": "unit_1".
           // So I need to map chapterId "chapter_1" to unitId "unit_1".
           // OR just use query where unitId == chapterId.replace('chapter_', 'unit_')?
           // OR look at populate_db.py again.
           // populate_db.py seeds sections with original JSON content + journeyId.
           // unit1.json section has "unitId": "unit_1".
           // App knows "chapter_1".
           // I should update populate_db.py to add `chapterId` to sections for easy querying.
      // For now, let's assume I fix populate_db.py to add chapterId to sections.
      // .where('chapterId', isEqualTo: chapterId)
      // .orderBy('order')
          .get();
      
      // If I can't filter by chapterId yet, I will fail.
      // Let's rely on unitId if I can convert.
      // chapterId is "chapter_1". unitId is "unit_1".
      // Conversion: chapterId.replaceAll('chapter', 'unit')
      
      final unitId = chapterId.replaceAll('chapter', 'unit');
      final snapshot2 = await _firestore
          .collection('sections')
          .where('unitId', isEqualTo: unitId)
          .get();

      final List<Section> sections = [];
      for (final doc in snapshot2.docs) {
        try {
          sections.add(Section.fromFirestore(doc));
        } catch (e) {
          print('❌ Error parsing section ${doc.id}: $e');
        }
      }
      sections.sort((a, b) => a.order.compareTo(b.order));
      return sections;
    } catch (e) {
      throw Exception('Failed to get sections: $e');
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
      
      final List<Lesson> lessons = [];
      for (final doc in snapshot.docs) {
        try {
          lessons.add(Lesson.fromFirestore(doc));
        } catch (e) {
          print('❌ Error parsing lesson ${doc.id}: $e');
        }
      }
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
            final List<Lesson> lessons = [];
            for (final doc in snapshot.docs) {
              try {
                lessons.add(Lesson.fromFirestore(doc));
              } catch (e) {
                print('❌ Error parsing lesson ${doc.id}: $e');
              }
            }
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
      
      final List<Question> questions = [];
      for (final doc in snapshot.docs) {
        try {
          questions.add(Question.fromFirestore(doc));
        } catch (e) {
          print('Error parsing question ${doc.id}: $e');
        }
      }
      
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
            final List<Question> questions = [];
            for (final doc in snapshot.docs) {
              try {
                questions.add(Question.fromFirestore(doc));
              } catch (e) {
                print('Error parsing question ${doc.id}: $e');
              }
            }
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
