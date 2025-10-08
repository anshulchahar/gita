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
    suspend fun seedChapters(force: Boolean = false) {
        val chaptersCollection = firestore.collection("chapters")
        
        // Check if chapters already exist (skip if not forcing)
        if (!force) {
            val existingChapters = chaptersCollection.limit(1).get().await()
            if (!existingChapters.isEmpty) {
                return // Already seeded
            }
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
     * Seed lessons for all chapters
     */
    suspend fun seedLessons(force: Boolean = false) {
        val lessonsCollection = firestore.collection("lessons")
        
        // Check if lessons already exist (skip if not forcing)
        if (!force) {
            val existingLessons = lessonsCollection.limit(1).get().await()
            if (!existingLessons.isEmpty) {
                return // Already seeded
            }
        }
        
        // Get all chapters
        val chapters = firestore.collection("chapters")
            .orderBy("chapterNumber")
            .get()
            .await()
            .documents
        
        val allLessons = mutableListOf<Pair<String, Lesson>>()
        
        // Chapter 1 Lessons
        chapters.firstOrNull { it.getLong("chapterNumber") == 1L }?.let { chapter1 ->
            allLessons.addAll(listOf(
                chapter1.id to Lesson(
                    lessonId = "",
                    chapterId = chapter1.id,
                    lessonNumber = 1,
                    lessonName = "अर्जुन की दुविधा",
                    lessonNameEn = "Arjuna's Dilemma",
                    order = 1,
                    estimatedTime = 300,
                    difficulty = "beginner",
                    shlokasCovered = listOf(1, 2, 3),
                    xpReward = 50,
                    prerequisite = null
                ),
                chapter1.id to Lesson(
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
                chapter1.id to Lesson(
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
            ))
        }
        
        // Chapter 2 Lessons
        chapters.firstOrNull { it.getLong("chapterNumber") == 2L }?.let { chapter2 ->
            allLessons.addAll(listOf(
                chapter2.id to Lesson(
                    lessonId = "",
                    chapterId = chapter2.id,
                    lessonNumber = 1,
                    lessonName = "आत्मा का स्वरूप",
                    lessonNameEn = "The Eternal Soul",
                    order = 1,
                    estimatedTime = 300,
                    difficulty = "intermediate",
                    shlokasCovered = listOf(11, 12, 13),
                    xpReward = 60,
                    prerequisite = null
                ),
                chapter2.id to Lesson(
                    lessonId = "",
                    chapterId = chapter2.id,
                    lessonNumber = 2,
                    lessonName = "स्थितप्रज्ञ की विशेषताएं",
                    lessonNameEn = "Characteristics of the Wise",
                    order = 2,
                    estimatedTime = 300,
                    difficulty = "intermediate",
                    shlokasCovered = listOf(54, 55, 56),
                    xpReward = 60,
                    prerequisite = null
                )
            ))
        }
        
        // Chapter 3 Lessons
        chapters.firstOrNull { it.getLong("chapterNumber") == 3L }?.let { chapter3 ->
            allLessons.addAll(listOf(
                chapter3.id to Lesson(
                    lessonId = "",
                    chapterId = chapter3.id,
                    lessonNumber = 1,
                    lessonName = "निष्काम कर्म",
                    lessonNameEn = "Selfless Action",
                    order = 1,
                    estimatedTime = 300,
                    difficulty = "intermediate",
                    shlokasCovered = listOf(1, 2, 3),
                    xpReward = 60,
                    prerequisite = null
                ),
                chapter3.id to Lesson(
                    lessonId = "",
                    chapterId = chapter3.id,
                    lessonNumber = 2,
                    lessonName = "यज्ञ का महत्व",
                    lessonNameEn = "The Importance of Yajna",
                    order = 2,
                    estimatedTime = 300,
                    difficulty = "intermediate",
                    shlokasCovered = listOf(9, 10, 11),
                    xpReward = 60,
                    prerequisite = null
                )
            ))
        }
        
        val batch = firestore.batch()
        allLessons.forEach { (chapterId, lesson) ->
            val docRef = lessonsCollection.document()
            batch.set(docRef, lesson)
        }
        batch.commit().await()
    }
    
    /**
     * Seed questions for all lessons
     */
    suspend fun seedQuestions(force: Boolean = false) {
        val questionsCollection = firestore.collection("questions")
        
        // Check if questions already exist (skip if not forcing)
        if (!force) {
            val existingQuestions = questionsCollection.limit(1).get().await()
            if (!existingQuestions.isEmpty) {
                return // Already seeded
            }
        }
        
        // Get all lessons
        val lessons = firestore.collection("lessons")
            .orderBy("order")
            .get()
            .await()
            .documents
        
        val allQuestions = mutableListOf<Pair<String, Question>>()
        
        // Questions for each lesson
        lessons.forEach { lessonDoc ->
            val lessonId = lessonDoc.id
            val lessonNumber = lessonDoc.getLong("lessonNumber")?.toInt() ?: 0
            val chapterNumber = lessonDoc.getString("chapterId")?.let { chapterId ->
                firestore.collection("chapters").document(chapterId).get().await()
                    .getLong("chapterNumber")?.toInt()
            } ?: 0
            
            when {
                // Chapter 1, Lesson 1
                chapterNumber == 1 && lessonNumber == 1 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
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
                                explanation = "Arjuna's dilemma was not about fear or capability, but about having to fight against people he loved and respected - his teachers, relatives, and elders.",
                                realLifeApplication = "We often face situations where our emotions conflict with our responsibilities - difficult conversations with loved ones, tough decisions at work, or standing up for what's right even when uncomfortable."
                            ),
                            points = 10,
                            timeLimit = 60
                        ),
                        lessonId to Question(
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
                                explanation = "Arjuna's dilemma is universal. We all face situations where our emotions conflict with what we know we should do. The Gita's teachings apply to modern life.",
                                realLifeApplication = "Examples: Having tough conversations with loved ones, making career changes that require leaving comfort zones, standing up for ethics when it's unpopular."
                            ),
                            points = 10,
                            timeLimit = 60
                        ),
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 3,
                            content = QuestionContent(
                                questionText = "What important step does Arjuna take at the end of Chapter 1?",
                                options = listOf(
                                    "He decides to run away",
                                    "He surrenders to Krishna as his teacher and asks for guidance",
                                    "He attacks his enemies",
                                    "He gives up completely"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Arjuna's wisest act was recognizing his confusion and humbly asking Krishna for guidance. This openness to learning is the first step toward wisdom.",
                                realLifeApplication = "In life, seeking guidance from mentors, teachers, therapists, and wise counsel is crucial when facing difficult decisions. Admitting we don't have all answers is strength, not weakness."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 1, Lesson 2
                chapterNumber == 1 && lessonNumber == 2 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "What is 'dharma' as explained in the Gita?",
                                options = listOf(
                                    "Following religious rituals only",
                                    "One's righteous duty and responsibility",
                                    "Avoiding all conflicts",
                                    "Doing whatever makes you happy"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Dharma is one's righteous duty and responsibility based on one's role in life. It's about doing what's right, not what's easy.",
                                realLifeApplication = "Your dharma might be being a good parent, honest employee, or responsible citizen - fulfilling your duties with integrity even when challenging."
                            ),
                            points = 10,
                            timeLimit = 60
                        ),
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 2,
                            content = QuestionContent(
                                questionText = "When facing a difficult duty, what should guide us?",
                                options = listOf(
                                    "What feels comfortable",
                                    "What others think",
                                    "Inner wisdom and righteousness",
                                    "Avoiding the situation"
                                ),
                                correctAnswerIndex = 2,
                                explanation = "The Gita teaches us to be guided by inner wisdom (buddhi) and what is righteous (dharma), not by comfort or others' opinions.",
                                realLifeApplication = "When making tough choices: speak truth even if uncomfortable, do the right thing even if unpopular, fulfill responsibilities even when difficult."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 1, Lesson 3
                chapterNumber == 1 && lessonNumber == 3 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "Why is it important to seek guidance when confused?",
                                options = listOf(
                                    "It shows weakness",
                                    "It helps gain clarity and wisdom",
                                    "It's not important",
                                    "Others will judge you"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Seeking guidance is a sign of wisdom, not weakness. A good teacher can help us see beyond our limited perspective.",
                                realLifeApplication = "In modern life: mentors for career, therapists for mental health, financial advisors for money, coaches for skills - seeking expert guidance accelerates growth."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 2, Lesson 1
                chapterNumber == 2 && lessonNumber == 1 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "According to the Gita, what is the nature of the soul (Atman)?",
                                options = listOf(
                                    "It dies with the body",
                                    "It is eternal and cannot be destroyed",
                                    "It exists only in some people",
                                    "It is created at birth"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "The Gita teaches that the soul is eternal, indestructible, and unchanging. Only the body undergoes birth and death.",
                                realLifeApplication = "Understanding our eternal nature helps reduce fear of death and increases focus on spiritual growth and righteous action in this life."
                            ),
                            points = 10,
                            timeLimit = 60
                        ),
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 2,
                            content = QuestionContent(
                                questionText = "How should we view change and transformation?",
                                options = listOf(
                                    "Fear it and avoid it",
                                    "As a natural and necessary part of life",
                                    "It shouldn't happen",
                                    "Only physical change matters"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Just as the soul changes bodies, change is natural in life. Understanding this helps us adapt and grow.",
                                realLifeApplication = "Career changes, relationship endings, aging - all are natural transformations. Accepting change reduces suffering and enables growth."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 2, Lesson 2
                chapterNumber == 2 && lessonNumber == 2 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "What is a key characteristic of a 'Sthitaprajna' (person of steady wisdom)?",
                                options = listOf(
                                    "Never experiences any emotions",
                                    "Remains balanced in pleasure and pain",
                                    "Avoids all worldly activities",
                                    "Never faces challenges"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "A wise person (Sthitaprajna) maintains equanimity in both pleasure and pain, success and failure. They experience emotions but are not controlled by them.",
                                realLifeApplication = "In modern life: Staying calm during failures, remaining humble during success, not being swayed by criticism or praise, maintaining balance in all situations."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 3, Lesson 1
                chapterNumber == 3 && lessonNumber == 1 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "What is Nishkama Karma (selfless action)?",
                                options = listOf(
                                    "Not doing any work",
                                    "Performing duty without attachment to results",
                                    "Expecting rewards for every action",
                                    "Only doing easy tasks"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Nishkama Karma means performing your duty to the best of your ability without being attached to the results. Focus on the process, not outcomes.",
                                realLifeApplication = "In work: Give your best effort without obsessing over promotion. In relationships: Love without expecting returns. In goals: Focus on daily action, not just end results."
                            ),
                            points = 10,
                            timeLimit = 60
                        ),
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 2,
                            content = QuestionContent(
                                questionText = "Why is action better than inaction according to the Gita?",
                                options = listOf(
                                    "Inaction is impossible - even living requires action",
                                    "Action always brings success",
                                    "Inaction is for lazy people",
                                    "Action makes you important"
                                ),
                                correctAnswerIndex = 0,
                                explanation = "The Gita teaches that complete inaction is impossible - even maintaining the body requires action. Better to act with wisdom than to remain idle.",
                                realLifeApplication = "Taking action, even imperfectly, is better than waiting for the 'perfect' time. Progress comes from doing, learning, and adjusting."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
                
                // Chapter 3, Lesson 2
                chapterNumber == 3 && lessonNumber == 2 -> {
                    allQuestions.addAll(listOf(
                        lessonId to Question(
                            questionId = "",
                            type = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
                            order = 1,
                            content = QuestionContent(
                                questionText = "What is the essence of Yajna (sacrifice) in modern context?",
                                options = listOf(
                                    "Only performing religious rituals",
                                    "Contributing to the greater good beyond self-interest",
                                    "Giving up all pleasures",
                                    "Avoiding work"
                                ),
                                correctAnswerIndex = 1,
                                explanation = "Yajna in modern context means acting for the greater good, contributing to society, and not just living for oneself. It's about giving back.",
                                realLifeApplication = "Volunteering, mentoring others, environmental consciousness, paying taxes honestly, creating value for others - all are modern forms of Yajna."
                            ),
                            points = 10,
                            timeLimit = 60
                        )
                    ))
                }
            }
        }
        
        val batch = firestore.batch()
        allQuestions.forEach { (lessonId, question) ->
            val docRef = questionsCollection.document()
            // Add lessonId to the question
            val questionData = hashMapOf(
                "lessonId" to lessonId,
                "type" to question.type.name,
                "order" to question.order,
                "content" to hashMapOf(
                    "questionText" to question.content.questionText,
                    "options" to question.content.options,
                    "correctAnswerIndex" to question.content.correctAnswerIndex,
                    "explanation" to question.content.explanation,
                    "realLifeApplication" to question.content.realLifeApplication
                ),
                "points" to question.points,
                "timeLimit" to question.timeLimit
            )
            batch.set(docRef, questionData)
        }
        batch.commit().await()
    }
    
    /**
     * Clear all content (for debugging)
     */
    suspend fun clearAllContent() {
        // Delete all questions
        val questions = firestore.collection("questions").get().await()
        questions.documents.forEach { it.reference.delete().await() }
        
        // Delete all lessons
        val lessons = firestore.collection("lessons").get().await()
        lessons.documents.forEach { it.reference.delete().await() }
        
        // Delete all chapters
        val chapters = firestore.collection("chapters").get().await()
        chapters.documents.forEach { it.reference.delete().await() }
    }
    
    /**
     * Force re-seed (clear and seed)
     */
    suspend fun forceSeed() {
        clearAllContent()
        // Use force = true to bypass existence checks
        seedChapters(force = true)
        seedLessons(force = true)
        seedQuestions(force = true)
    }
    
    /**
     * Seed all initial content
     */
    suspend fun seedAll() {
        seedChapters()
        seedLessons()
        seedQuestions()
    }
}
