package com.schepor.gita.presentation.lesson

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.schepor.gita.presentation.theme.Spacing

/**
 * Lesson Screen - Displays a lesson with multiple choice questions
 * This is a placeholder implementation until we connect to Firebase
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LessonScreen(
    chapterId: String,
    lessonId: String,
    onNavigateBack: () -> Unit
) {
    // Sample data for now (will be replaced with Firebase data)
    val lessonTitle = "Understanding Dharma"
    val lessonContent = """
        Dharma is one of the most important concepts in the Bhagavad Gita. It represents 
        righteous duty, moral law, and the path of righteousness.
        
        In Chapter 1, Arjuna faces a dilemma about his dharma as a warrior. Should he fight 
        his own relatives, or should he refuse to participate in the war?
        
        This lesson explores the nature of dharma and how to apply it in real life.
    """.trimIndent()
    
    val questions = listOf(
        Question(
            id = "1",
            text = "What is the primary meaning of Dharma?",
            options = listOf(
                "Religious duty only",
                "Righteous duty and moral law",
                "Fighting in battles",
                "Following traditions blindly"
            ),
            correctAnswer = 1
        ),
        Question(
            id = "2",
            text = "In the Gita, who is facing a dilemma about dharma?",
            options = listOf(
                "Krishna",
                "Arjuna",
                "Duryodhana",
                "Bhishma"
            ),
            correctAnswer = 1
        ),
        Question(
            id = "3",
            text = "What should guide our understanding of dharma?",
            options = listOf(
                "Personal desires",
                "Social pressure",
                "Inner wisdom and righteousness",
                "Material gain"
            ),
            correctAnswer = 2
        )
    )
    
    var currentQuestionIndex by remember { mutableStateOf(0) }
    var selectedAnswers by remember { mutableStateOf(mutableMapOf<Int, Int>()) }
    var showResults by remember { mutableStateOf(false) }
    
    val currentQuestion = questions.getOrNull(currentQuestionIndex)
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = lessonTitle,
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Chapter $chapterId - Lesson $lessonId",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(Spacing.space16),
            verticalArrangement = Arrangement.spacedBy(Spacing.space16)
        ) {
            // Lesson Content
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(Spacing.space16)
                    ) {
                        Text(
                            text = "Lesson Content",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        Spacer(modifier = Modifier.height(Spacing.space8))
                        Text(
                            text = lessonContent,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                }
            }
            
            // Progress Indicator
            item {
                LinearProgressIndicator(
                    progress = (currentQuestionIndex + 1).toFloat() / questions.size,
                    modifier = Modifier.fillMaxWidth(),
                    color = MaterialTheme.colorScheme.primary
                )
                Text(
                    text = "Question ${currentQuestionIndex + 1} of ${questions.size}",
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.padding(top = Spacing.space4)
                )
            }
            
            // Question
            if (currentQuestion != null && !showResults) {
                item {
                    QuestionCard(
                        question = currentQuestion,
                        selectedAnswer = selectedAnswers[currentQuestionIndex],
                        onAnswerSelected = { answerIndex ->
                            selectedAnswers[currentQuestionIndex] = answerIndex
                        }
                    )
                }
                
                // Navigation Buttons
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        // Previous Button
                        if (currentQuestionIndex > 0) {
                            OutlinedButton(
                                onClick = { currentQuestionIndex-- }
                            ) {
                                Text("Previous")
                            }
                        } else {
                            Spacer(modifier = Modifier.width(1.dp))
                        }
                        
                        // Next/Submit Button
                        Button(
                            onClick = {
                                if (currentQuestionIndex < questions.size - 1) {
                                    currentQuestionIndex++
                                } else {
                                    showResults = true
                                }
                            },
                            enabled = selectedAnswers.containsKey(currentQuestionIndex)
                        ) {
                            Text(
                                if (currentQuestionIndex < questions.size - 1) "Next" else "Submit"
                            )
                        }
                    }
                }
            }
            
            // Results
            if (showResults) {
                item {
                    ResultsCard(
                        questions = questions,
                        selectedAnswers = selectedAnswers,
                        onRetry = {
                            currentQuestionIndex = 0
                            selectedAnswers.clear()
                            showResults = false
                        },
                        onContinue = onNavigateBack
                    )
                }
            }
        }
    }
}

@Composable
fun QuestionCard(
    question: Question,
    selectedAnswer: Int?,
    onAnswerSelected: (Int) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(Spacing.space16)
        ) {
            Text(
                text = question.text,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(Spacing.space16))
            
            question.options.forEachIndexed { index, option ->
                AnswerOption(
                    text = option,
                    isSelected = selectedAnswer == index,
                    onClick = { onAnswerSelected(index) }
                )
                if (index < question.options.size - 1) {
                    Spacer(modifier = Modifier.height(Spacing.space8))
                }
            }
        }
    }
}

@Composable
fun AnswerOption(
    text: String,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surface
            }
        ),
        border = if (isSelected) {
            androidx.compose.foundation.BorderStroke(
                2.dp,
                MaterialTheme.colorScheme.primary
            )
        } else null
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.space16),
            verticalAlignment = Alignment.CenterVertically
        ) {
            RadioButton(
                selected = isSelected,
                onClick = onClick
            )
            Spacer(modifier = Modifier.width(Spacing.space8))
            Text(
                text = text,
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

@Composable
fun ResultsCard(
    questions: List<Question>,
    selectedAnswers: Map<Int, Int>,
    onRetry: () -> Unit,
    onContinue: () -> Unit
) {
    val correctCount = questions.indices.count { index ->
        selectedAnswers[index] == questions[index].correctAnswer
    }
    val totalQuestions = questions.size
    val percentage = (correctCount * 100) / totalQuestions
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(Spacing.space24),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.Check,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(Spacing.space16))
            
            Text(
                text = "Lesson Complete!",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(Spacing.space8))
            
            Text(
                text = "Your Score",
                style = MaterialTheme.typography.titleMedium
            )
            
            Text(
                text = "$correctCount / $totalQuestions",
                style = MaterialTheme.typography.displayMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            
            Text(
                text = "$percentage%",
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            
            Spacer(modifier = Modifier.height(Spacing.space16))
            
            // Feedback message
            Text(
                text = when {
                    percentage >= 80 -> "Excellent work! You've mastered this lesson."
                    percentage >= 60 -> "Good job! Review the content to improve further."
                    else -> "Keep practicing! Review the lesson and try again."
                },
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSecondaryContainer
            )
            
            Spacer(modifier = Modifier.height(Spacing.space24))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(Spacing.space8)
            ) {
                OutlinedButton(
                    onClick = onRetry,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Retry")
                }
                
                Button(
                    onClick = onContinue,
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Continue")
                }
            }
        }
    }
}

// Data class for questions
data class Question(
    val id: String,
    val text: String,
    val options: List<String>,
    val correctAnswer: Int
)
