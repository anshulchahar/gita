import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/question.dart';
import '../../core/constants/constants.dart';

/// Provider for ContentSeeder
final contentSeederProvider = Provider<ContentSeeder>((ref) {
  return ContentSeeder(FirebaseFirestore.instance);
});

/// Content seeder for populating initial data
class ContentSeeder {
  final FirebaseFirestore _firestore;

  ContentSeeder(this._firestore);

  /// Seed initial chapters
  Future<void> seedChapters({bool force = false}) async {
    final chaptersCollection = _firestore.collection(Collections.chapters);

    if (!force) {
      final existingChapters = await chaptersCollection.limit(1).get();
      if (existingChapters.docs.isNotEmpty) {
        return; // Already seeded
      }
    }

    final chapters = [
      Chapter(
        chapterNumber: 1,
        chapterName: 'अर्जुन विषाद योग',
        chapterNameEn: 'Arjuna Vishada Yoga',
        description: 'अर्जुन का विषाद',
        descriptionEn: 'The Yoga of Arjuna\'s Dejection',
        shlokaCount: 47,
        order: 1,
        isUnlocked: true,
        icon: '🏹',
        color: '#FF9933',
      ),
      Chapter(
        chapterNumber: 2,
        chapterName: 'सांख्य योग',
        chapterNameEn: 'Sankhya Yoga',
        description: 'ज्ञान योग',
        descriptionEn: 'The Yoga of Knowledge',
        shlokaCount: 72,
        order: 2,
        isUnlocked: false,
        icon: '🧘',
        color: '#4A148C',
      ),
      Chapter(
        chapterNumber: 3,
        chapterName: 'कर्म योग',
        chapterNameEn: 'Karma Yoga',
        description: 'कर्म का योग',
        descriptionEn: 'The Yoga of Action',
        shlokaCount: 43,
        order: 3,
        isUnlocked: false,
        icon: '⚡',
        color: '#FF6F00',
      ),
    ];

    final batch = _firestore.batch();
    for (final chapter in chapters) {
      final docRef = chaptersCollection.doc();
      batch.set(docRef, chapter.toFirestore());
    }
    await batch.commit();
  }

  /// Seed lessons for all chapters
  Future<void> seedLessons({bool force = false}) async {
    final lessonsCollection = _firestore.collection(Collections.lessons);

    if (!force) {
      final existingLessons = await lessonsCollection.limit(1).get();
      if (existingLessons.docs.isNotEmpty) {
        return; // Already seeded
      }
    }

    // Get all chapters
    final chaptersSnapshot = await _firestore
        .collection(Collections.chapters)
        .orderBy('chapterNumber')
        .get();

    final allLessons = <Lesson>[];

    // Chapter 1 Lessons
    final chapter1 = chaptersSnapshot.docs
        .firstWhere((doc) => doc.data()['chapterNumber'] == 1);
    allLessons.addAll([
      Lesson(
        chapterId: chapter1.id,
        lessonNumber: 1,
        lessonName: 'अर्जुन की दुविधा',
        lessonNameEn: 'Arjuna\'s Dilemma',
        order: 1,
        estimatedTime: 300,
        difficulty: 'beginner',
        shlokasCovered: [1, 2, 3],
        xpReward: 50,
      ),
      Lesson(
        chapterId: chapter1.id,
        lessonNumber: 2,
        lessonName: 'कर्तव्य का स्वरूप',
        lessonNameEn: 'The Nature of Duty',
        order: 2,
        estimatedTime: 300,
        difficulty: 'beginner',
        shlokasCovered: [4, 5, 6],
        xpReward: 50,
      ),
      Lesson(
        chapterId: chapter1.id,
        lessonNumber: 3,
        lessonName: 'मार्गदर्शन की खोज',
        lessonNameEn: 'Seeking Guidance',
        order: 3,
        estimatedTime: 300,
        difficulty: 'beginner',
        shlokasCovered: [7, 8, 9],
        xpReward: 50,
      ),
    ]);

    // Chapter 2 Lessons
    final chapter2 = chaptersSnapshot.docs
        .firstWhere((doc) => doc.data()['chapterNumber'] == 2);
    allLessons.addAll([
      Lesson(
        chapterId: chapter2.id,
        lessonNumber: 1,
        lessonName: 'आत्मा का स्वरूप',
        lessonNameEn: 'The Eternal Soul',
        order: 1,
        estimatedTime: 300,
        difficulty: 'intermediate',
        shlokasCovered: [11, 12, 13],
        xpReward: 60,
      ),
      Lesson(
        chapterId: chapter2.id,
        lessonNumber: 2,
        lessonName: 'स्थितप्रज्ञ की विशेषताएं',
        lessonNameEn: 'Characteristics of the Wise',
        order: 2,
        estimatedTime: 300,
        difficulty: 'intermediate',
        shlokasCovered: [54, 55, 56],
        xpReward: 60,
      ),
    ]);

    // Chapter 3 Lessons
    final chapter3 = chaptersSnapshot.docs
        .firstWhere((doc) => doc.data()['chapterNumber'] == 3);
    allLessons.addAll([
      Lesson(
        chapterId: chapter3.id,
        lessonNumber: 1,
        lessonName: 'निष्काम कर्म',
        lessonNameEn: 'Selfless Action',
        order: 1,
        estimatedTime: 300,
        difficulty: 'intermediate',
        shlokasCovered: [1, 2, 3],
        xpReward: 60,
      ),
      Lesson(
        chapterId: chapter3.id,
        lessonNumber: 2,
        lessonName: 'यज्ञ का महत्व',
        lessonNameEn: 'The Importance of Yajna',
        order: 2,
        estimatedTime: 300,
        difficulty: 'intermediate',
        shlokasCovered: [9, 10, 11],
        xpReward: 60,
      ),
    ]);

    final batch = _firestore.batch();
    for (final lesson in allLessons) {
      final docRef = lessonsCollection.doc();
      batch.set(docRef, lesson.toFirestore());
    }
    await batch.commit();
  }

  /// Seed questions for all lessons
  Future<void> seedQuestions({bool force = false}) async {
    final questionsCollection = _firestore.collection(Collections.questions);

    if (!force) {
      final existingQuestions = await questionsCollection.limit(1).get();
      if (existingQuestions.docs.isNotEmpty) {
        return; // Already seeded
      }
    }

    // Get all lessons
    final lessonsSnapshot = await _firestore
        .collection(Collections.lessons)
        .orderBy('order')
        .get();

    final allQuestions = <Question>[];

    for (final lessonDoc in lessonsSnapshot.docs) {
      final lessonId = lessonDoc.id;
      final lessonNumber = lessonDoc.data()['lessonNumber'] as int;
      final chapterId = lessonDoc.data()['chapterId'] as String;

      // Get chapter number
      final chapterDoc = await _firestore
          .collection(Collections.chapters)
          .doc(chapterId)
          .get();
      final chapterNumber = chapterDoc.data()?['chapterNumber'] as int? ?? 0;

      // Add questions based on chapter and lesson
      if (chapterNumber == 1 && lessonNumber == 1) {
        allQuestions.addAll([
          Question(
            lessonId: lessonId,
            type: QuestionType.multipleChoiceTranslation,
            order: 1,
            content: QuestionContent(
              questionText: 'What was Arjuna\'s main dilemma on the battlefield?',
              options: [
                'He was afraid of dying',
                'He had to fight against his relatives and teachers',
                'He didn\'t have good weapons',
                'He was outnumbered',
              ],
              correctAnswerIndex: 1,
              explanation: 'Arjuna\'s dilemma was not about fear or capability, but about having to fight against people he loved and respected.',
              realLifeApplication: 'We often face situations where our emotions conflict with our responsibilities.',
            ),
            points: 10,
            timeLimit: 60,
          ),
          Question(
            lessonId: lessonId,
            type: QuestionType.multipleChoiceTranslation,
            order: 2,
            content: QuestionContent(
              questionText: 'How does Arjuna\'s situation relate to our daily lives?',
              options: [
                'It doesn\'t - we don\'t face battles',
                'We often face conflicts between emotions and responsibilities',
                'It only applies to warriors',
                'It\'s just an ancient story',
              ],
              correctAnswerIndex: 1,
              explanation: 'Arjuna\'s dilemma is universal. We all face situations where our emotions conflict with what we know we should do.',
              realLifeApplication: 'Examples: Having tough conversations, making career changes, standing up for ethics.',
            ),
            points: 10,
            timeLimit: 60,
          ),
        ]);
      } else if (chapterNumber == 1 && lessonNumber == 2) {
        allQuestions.add(
          Question(
            lessonId: lessonId,
            type: QuestionType.multipleChoiceTranslation,
            order: 1,
            content: QuestionContent(
              questionText: 'What is \'dharma\' as explained in the Gita?',
              options: [
                'Following religious rituals only',
                'One\'s righteous duty and responsibility',
                'Avoiding all conflicts',
                'Doing whatever makes you happy',
              ],
              correctAnswerIndex: 1,
              explanation: 'Dharma is one\'s righteous duty based on one\'s role in life.',
              realLifeApplication: 'Your dharma might be being a good parent, honest employee, or responsible citizen.',
            ),
            points: 10,
            timeLimit: 60,
          ),
        );
      }
    }

    final batch = _firestore.batch();
    for (final question in allQuestions) {
      final docRef = questionsCollection.doc();
      batch.set(docRef, question.toFirestore());
    }
    await batch.commit();
  }

  /// Clear all content
  Future<void> clearAllContent() async {
    // Delete questions
    final questions = await _firestore.collection(Collections.questions).get();
    for (final doc in questions.docs) {
      await doc.reference.delete();
    }

    // Delete lessons
    final lessons = await _firestore.collection(Collections.lessons).get();
    for (final doc in lessons.docs) {
      await doc.reference.delete();
    }

    // Delete chapters
    final chapters = await _firestore.collection(Collections.chapters).get();
    for (final doc in chapters.docs) {
      await doc.reference.delete();
    }
  }

  /// Force re-seed (clear and seed)
  Future<void> forceSeed() async {
    await clearAllContent();
    await seedChapters(force: true);
    await seedLessons(force: true);
    await seedQuestions(force: true);
  }

  /// Seed all initial content
  Future<void> seedAll() async {
    await seedChapters();
    await seedLessons();
    await seedQuestions();
  }
}
