package com.schepor.gita.data.repository

import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.schepor.gita.domain.model.Chapter
import com.schepor.gita.domain.model.Lesson
import com.schepor.gita.domain.model.Question
import com.schepor.gita.util.Resource
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ContentRepository @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    private val chaptersCollection = firestore.collection("chapters")
    private val lessonsCollection = firestore.collection("lessons")
    private val questionsCollection = firestore.collection("questions")

    /**
     * Get all chapters
     */
    suspend fun getChapters(): Resource<List<Chapter>> {
        return try {
            val snapshot = chaptersCollection
                .orderBy("chapterNumber", Query.Direction.ASCENDING)
                .get()
                .await()
            
            val chapters = snapshot.documents.mapNotNull { doc ->
                doc.toObject(Chapter::class.java)?.copy(chapterId = doc.id)
            }
            
            Resource.Success(chapters)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get chapters")
        }
    }

    /**
     * Get chapters as Flow (real-time updates)
     */
    fun getChaptersFlow(): Flow<Resource<List<Chapter>>> = callbackFlow {
        val listenerRegistration = chaptersCollection
            .orderBy("chapterNumber", Query.Direction.ASCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    trySend(Resource.Error(error.message ?: "Failed to listen to chapters"))
                    return@addSnapshotListener
                }

                val chapters = snapshot?.documents?.mapNotNull { doc ->
                    doc.toObject(Chapter::class.java)?.copy(chapterId = doc.id)
                } ?: emptyList()

                trySend(Resource.Success(chapters))
            }

        awaitClose { listenerRegistration.remove() }
    }

    /**
     * Get chapter by ID
     */
    suspend fun getChapter(chapterId: String): Resource<Chapter> {
        return try {
            val snapshot = chaptersCollection.document(chapterId).get().await()
            val chapter = snapshot.toObject(Chapter::class.java)?.copy(chapterId = snapshot.id)
            
            if (chapter != null) {
                Resource.Success(chapter)
            } else {
                Resource.Error("Chapter not found")
            }
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get chapter")
        }
    }

    /**
     * Get lessons for a chapter
     */
    suspend fun getLessons(chapterId: String): Resource<List<Lesson>> {
        return try {
            val snapshot = lessonsCollection
                .whereEqualTo("chapterId", chapterId)
                .get()
                .await()
            
            val lessons = snapshot.documents.mapNotNull { doc ->
                doc.toObject(Lesson::class.java)?.copy(lessonId = doc.id)
            }.sortedBy { it.lessonNumber }
            
            Resource.Success(lessons)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get lessons")
        }
    }

    /**
     * Get lessons as Flow (real-time updates)
     */
    fun getLessonsFlow(chapterId: String): Flow<Resource<List<Lesson>>> = callbackFlow {
        val listenerRegistration = lessonsCollection
            .whereEqualTo("chapterId", chapterId)
            .orderBy("lessonNumber", Query.Direction.ASCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    trySend(Resource.Error(error.message ?: "Failed to listen to lessons"))
                    return@addSnapshotListener
                }

                val lessons = snapshot?.documents?.mapNotNull { doc ->
                    doc.toObject(Lesson::class.java)?.copy(lessonId = doc.id)
                } ?: emptyList()

                trySend(Resource.Success(lessons))
            }

        awaitClose { listenerRegistration.remove() }
    }

    /**
     * Get lesson by ID
     */
    suspend fun getLesson(lessonId: String): Resource<Lesson> {
        return try {
            val snapshot = lessonsCollection.document(lessonId).get().await()
            val lesson = snapshot.toObject(Lesson::class.java)?.copy(lessonId = snapshot.id)
            
            if (lesson != null) {
                Resource.Success(lesson)
            } else {
                Resource.Error("Lesson not found")
            }
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get lesson")
        }
    }

    /**
     * Get questions for a lesson
     */
    suspend fun getQuestions(lessonId: String): Resource<List<Question>> {
        return try {
            val snapshot = questionsCollection
                .whereEqualTo("lessonId", lessonId)
                .get()
                .await()
            
            val questions = snapshot.documents.mapNotNull { doc ->
                doc.toObject(Question::class.java)?.copy(questionId = doc.id)
            }.sortedBy { it.order }
            
            Resource.Success(questions)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get questions")
        }
    }

    /**
     * Get questions as Flow (real-time updates)
     */
    fun getQuestionsFlow(lessonId: String): Flow<Resource<List<Question>>> = callbackFlow {
        val listenerRegistration = questionsCollection
            .whereEqualTo("lessonId", lessonId)
            .orderBy("order", Query.Direction.ASCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    trySend(Resource.Error(error.message ?: "Failed to listen to questions"))
                    return@addSnapshotListener
                }

                val questions = snapshot?.documents?.mapNotNull { doc ->
                    doc.toObject(Question::class.java)?.copy(questionId = doc.id)
                } ?: emptyList()

                trySend(Resource.Success(questions))
            }

        awaitClose { listenerRegistration.remove() }
    }

    /**
     * Create chapter (admin function)
     */
    suspend fun createChapter(chapter: Chapter): Resource<Chapter> {
        return try {
            val docRef = chaptersCollection.add(chapter).await()
            Resource.Success(chapter.copy(chapterId = docRef.id))
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to create chapter")
        }
    }

    /**
     * Create lesson (admin function)
     */
    suspend fun createLesson(lesson: Lesson): Resource<Lesson> {
        return try {
            val docRef = lessonsCollection.add(lesson).await()
            Resource.Success(lesson.copy(lessonId = docRef.id))
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to create lesson")
        }
    }

    /**
     * Create question (admin function)
     */
    suspend fun createQuestion(question: Question): Resource<Question> {
        return try {
            val docRef = questionsCollection.add(question).await()
            Resource.Success(question.copy(questionId = docRef.id))
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to create question")
        }
    }

    /**
     * Batch create questions (admin function)
     */
    suspend fun createQuestions(questions: List<Question>): Resource<List<Question>> {
        return try {
            val batch = firestore.batch()
            val createdQuestions = mutableListOf<Question>()
            
            questions.forEach { question ->
                val docRef = questionsCollection.document()
                batch.set(docRef, question)
                createdQuestions.add(question.copy(questionId = docRef.id))
            }
            
            batch.commit().await()
            Resource.Success(createdQuestions)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to create questions")
        }
    }
}
