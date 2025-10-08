package com.schepor.gita.data.seed

import com.google.firebase.firestore.FirebaseFirestore
import com.schepor.gita.domain.model.Chapter
import com.schepor.gita.domain.model.Lesson
import com.schepor.gita.domain.model.Question
import com.schepor.gita.domain.model.QuestionContent
import com.schepor.gita.domain.model.QuestionType
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ContentSeeder @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    
    /**
     * Seed initial chapters
     */
    suspend fun seedChapters() {
        val chaptersCollection = firestore.collection("chapters")
        
        // Check if chapters already exist
        val existingChapters = chaptersCollection.limit(1).get().await()
        if (!existingChapters.isEmpty) {
            return // Already seeded
        }
        
        val chapters = listOf(
            Chapter(
                chapterId = "",
                chapterNumber = 1,
                chapterName = "अर्जुन विषाद योग",
                chapterNameEn = "Arjuna Vishada Yoga",
                description = "अर्जुन का विषाद",
                descriptionEn = "The Yoga of Arjuna's Dejection",
                shlokaCount = 47,
                order = 1,
                isUnlocked = true,
                icon = "🏹",
                color = "#FF9933"
            ),
            Chapter(
                chapterId = "",
                chapterNumber = 2,
                chapterName = "सांख्य योग",
                chapterNameEn = "Sankhya Yoga",
                description = "ज्ञान योग",
                descriptionEn = "The Yoga of Knowledge",
                shlokaCount = 72,
                order = 2,
                isUnlocked = false,
                icon = "🧘",
                color = "#4A148C"
            ),
            Chapter(
                chapterId = "",
                chapterNumber = 3,
                chapterName = "कर्म योग",
                chapterNameEn = "Karma Yoga",
                description = "कर्म का योग",
                descriptionEn = "The Yoga of Action",
                shlokaCount = 43,
                order = 3,
                isUnlocked = false,
                icon = "⚡",
                color = "#FF6F00"
            )
        )
        
        val batch = firestore.batch()
        chapters.forEach { chapter ->
            val docRef = chaptersCollection.document()
            batch.set(docRef, chapter)
        }
        batch.commit().await()
    }
    
    /**
     * Seed lessons for Chapter 1
     */
    suspend fun seedChapter1Lessons() {
        val lessonsCollection = firestore.collection("lessons")
        
        // Get Chapter 1 ID
        val chapter1 = firestore.collection("chapters")
            .whereEqualTo("chapterNumber", 1)
            .limit(1)
            .get()
            .await()
            .documents
            .firstOrNull()
        
        if (chapter1 == null) return
        
        val lessons = listOf(
            Lesson(
                lessonId = "",
                chapterId = chapter1.id,
                lessonNumber = 1,
                lessonName = "अर्जुन की दुविधा",
                lessonNameEn = "Arjuna's Dilemma",
                order = 1,
                estimatedTime = 300, // 5 minutes
                difficulty = "beginner",
                shlokasCovered = listOf(1, 2, 3),
                xpReward = 50,
                prerequisite = null
            ),
            Lesson(
                lessonId = "",
                chapterId = chapter1.id,
                lessonNumber = 2,
                lessonName = "कर्तव्य का स्वरूप",
                lessonNameEn = "The Nature of Duty",
                order = 2,
                estimatedTime = 300,
                difficulty = "beginner",
                shlokasCovered = listOf(4, 5, 6),
                xpReward = 50,
                prerequisite = null
            ),
            Lesson(
                lessonId = "",
                chapterId = chapter1.id,
                lessonNumber = 3,
                lessonName = "मार्गदर्शन की खोज",
                lessonNameEn = "Seeking Guidance",
                order = 3,
                estimatedTime = 300,
                difficulty = "beginner",
                shlokasCovered = listOf(7, 8, 9),
                xpReward = 50,
                prerequisite = null
            )
        )
        
        val batch = firestore.batch()
        lessons.forEach { lesson ->
            val docRef = lessonsCollection.document()
            batch.set(docRef, lesson)
        }
        batch.commit().await()
    }
    
    /**
     * Seed questions for first lesson
     */
    suspend fun seedQuestionsForLesson() {
        val questionsCollection = firestore.collection("questions")
        
        // Get first lesson
        val lesson = firestore.collection("lessons")
            .whereEqualTo("lessonNumber", 1)
            .limit(1)
            .get()
            .await()
            .documents
            .firstOrNull()
        
        if (lesson == null) return
        
        val questions = listOf(
            Question(
                questionId = "",
                type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                order = 1,
                content = QuestionContent(
                    questionText = "What was Arjuna's main dilemma on the battlefield?",
                    options = listOf(
                        "He was afraid of dying",
                        "He had to fight against his relatives and teachers",
                        "He didn't have good weapons",
                        "He was outnumbered"
                    ),
                    correctAnswerIndex = 1,
                    explanation = "Arjuna's dilemma was not about fear or capability, but about having to fight against people he loved and respected.",
                    realLifeApplication = "We often face situations where our emotions conflict with our responsibilities - difficult conversations, tough decisions, or standing up for what's right."
                ),
                points = 10,
                timeLimit = 60
            ),
            Question(
                questionId = "",
                type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                order = 2,
                content = QuestionContent(
                    questionText = "How does Arjuna's situation relate to our daily lives?",
                    options = listOf(
                        "It doesn't - we don't face battles",
                        "We often face conflicts between emotions and responsibilities",
                        "It only applies to warriors",
                        "It's just an ancient story"
                    ),
                    correctAnswerIndex = 1,
                    explanation = "Arjuna's dilemma is universal. We all face situations where our emotions conflict with what we know we should do.",
                    realLifeApplication = "Modern examples: difficult conversations with loved ones, career decisions requiring leaving comfort, standing up for what's right when uncomfortable."
                ),
                points = 10,
                timeLimit = 60
            ),
            Question(
                questionId = "",
                type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                order = 3,
                content = QuestionContent(
                    questionText = "What important step does Arjuna take at the end of Chapter 1?",
                    options = listOf(
                        "He decides to run away from battle",
                        "He surrenders to Krishna as his teacher and asks for guidance",
                        "He attacks his enemies",
                        "He gives up completely"
                    ),
                    correctAnswerIndex = 1,
                    explanation = "Arjuna's wisest act was recognizing his confusion and humbly asking Krishna for guidance. This openness to learning is the first step toward wisdom.",
                    realLifeApplication = "In our lives, seeking guidance from mentors, teachers, and wise counsel is crucial when facing difficult decisions."
                ),
                points = 10,
                timeLimit = 60
            )
        )
        
        val batch = firestore.batch()
        questions.forEach { question ->
            val docRef = questionsCollection.document()
            batch.set(docRef, question)
        }
        batch.commit().await()
    }
    
    /**
     * Seed all initial content
     */
    suspend fun seedAll() {
        seedChapters()
        seedChapter1Lessons()
        seedQuestionsForLesson()
    }
}
