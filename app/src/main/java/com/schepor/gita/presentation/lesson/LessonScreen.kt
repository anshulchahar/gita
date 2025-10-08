package com.schepor.gita.presentation.lesson

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.schepor.gita.presentation.theme.Spacing

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LessonScreen(
    chapterId: String,
    lessonId: String,
    onNavigateBack: () -> Unit,
    viewModel: LessonViewModel = hiltViewModel()
) {
    val lessonState by viewModel.lessonState.collectAsState()
    
    LaunchedEffect(chapterId, lessonId) {
        viewModel.loadLesson(chapterId, lessonId)
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = lessonState.lesson?.lessonNameEn ?: "Loading...",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Chapter $chapterId - Lesson ${lessonState.lesson?.lessonNumber ?: ""}",
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
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when {
                lessonState.isLoading -> {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
                
                lessonState.error != null -> {
                    Column(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .padding(Spacing.space24),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Error",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(Spacing.space8))
                        Text(
                            text = lessonState.error ?: "",
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
                
                lessonState.showResults -> {
                    ResultsScreen(
                        score = lessonState.score,
                        totalQuestions = lessonState.questions.size,
                        onRetry = { viewModel.resetLesson() },
                        onFinish = onNavigateBack
                    )
                }
                
                lessonState.lesson != null -> {
                    LessonContent(
                        lessonState = lessonState,
                        viewModel = viewModel
                    )
                }
            }
        }
    }
}

@Composable
fun LessonContent(
    lessonState: LessonState,
    viewModel: LessonViewModel
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(Spacing.space16),
        verticalArrangement = Arrangement.spacedBy(Spacing.space16)
    ) {
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            ) {
                Column(modifier = Modifier.padding(Spacing.space16)) {
                    Text(
                        text = "Lesson ${lessonState.lesson?.lessonNumber ?: ""}",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Spacer(modifier = Modifier.height(Spacing.space4))
                    Text(
                        text = lessonState.lesson?.lessonNameEn ?: "",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Spacer(modifier = Modifier.height(Spacing.space8))
                    Text(
                        text = "Answer all questions to complete this lesson",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                }
            }
        }
        
        if (lessonState.questions.isNotEmpty()) {
            item {
                Column {
                    LinearProgressIndicator(
                        progress = { (lessonState.currentQuestionIndex + 1).toFloat() / lessonState.questions.size },
                        modifier = Modifier.fillMaxWidth(),
                        color = MaterialTheme.colorScheme.primary
                    )
                    Text(
                        text = "Question ${lessonState.currentQuestionIndex + 1} of ${lessonState.questions.size}",
                        style = MaterialTheme.typography.bodySmall,
                        modifier = Modifier.padding(top = Spacing.space4)
                    )
                }
            }
            
            item {
                val currentQuestion = lessonState.questions[lessonState.currentQuestionIndex]
                QuestionCard(
                    question = currentQuestion,
                    selectedAnswer = viewModel.getSelectedOptionForCurrentQuestion(),
                    isAnswered = viewModel.isCurrentQuestionAnswered(),
                    correctAnswer = if (viewModel.isCurrentQuestionAnswered()) 
                        viewModel.getCorrectOptionForCurrentQuestion() else null,
                    onAnswerSelected = { optionIndex ->
                        viewModel.selectAnswer(currentQuestion.questionId, optionIndex)
                    }
                )
            }
            
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    OutlinedButton(
                        onClick = { viewModel.previousQuestion() },
                        enabled = lessonState.currentQuestionIndex > 0
                    ) {
                        Text("Previous")
                    }
                    
                    if (viewModel.isCurrentQuestionAnswered()) {
                        Button(onClick = { viewModel.nextQuestion() }) {
                            Text(
                                if (lessonState.currentQuestionIndex < lessonState.questions.size - 1)
                                    "Next" else "Finish"
                            )
                        }
                    } else {
                        Button(
                            onClick = { viewModel.submitAnswer() },
                            enabled = viewModel.getSelectedOptionForCurrentQuestion() != null
                        ) {
                            Text("Submit")
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun QuestionCard(
    question: com.schepor.gita.domain.model.Question,
    selectedAnswer: Int?,
    isAnswered: Boolean,
    correctAnswer: Int?,
    onAnswerSelected: (Int) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(modifier = Modifier.padding(Spacing.space16)) {
            Text(
                text = question.content.questionText,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            Spacer(modifier = Modifier.height(Spacing.space16))
            
            question.content.options.forEachIndexed { index, option ->
                OptionItem(
                    text = option,
                    isSelected = selectedAnswer == index,
                    isCorrect = isAnswered && correctAnswer == index,
                    isWrong = isAnswered && selectedAnswer == index && correctAnswer != index,
                    enabled = !isAnswered,
                    onClick = { onAnswerSelected(index) }
                )
                
                if (index < question.content.options.size - 1) {
                    Spacer(modifier = Modifier.height(Spacing.space8))
                }
            }
        }
    }
}

@Composable
fun OptionItem(
    text: String,
    isSelected: Boolean,
    isCorrect: Boolean,
    isWrong: Boolean,
    enabled: Boolean,
    onClick: () -> Unit
) {
    val backgroundColor = when {
        isCorrect -> MaterialTheme.colorScheme.primaryContainer
        isWrong -> MaterialTheme.colorScheme.errorContainer
        isSelected -> MaterialTheme.colorScheme.secondaryContainer
        else -> MaterialTheme.colorScheme.surface
    }
    
    val borderColor = when {
        isCorrect -> MaterialTheme.colorScheme.primary
        isWrong -> MaterialTheme.colorScheme.error
        isSelected -> MaterialTheme.colorScheme.secondary
        else -> MaterialTheme.colorScheme.outline
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(enabled = enabled) { onClick() },
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = backgroundColor),
        border = BorderStroke(2.dp, borderColor)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.space12),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = text,
                style = MaterialTheme.typography.bodyLarge,
                modifier = Modifier.weight(1f)
            )
            
            if (isCorrect) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = "Correct",
                    tint = MaterialTheme.colorScheme.primary
                )
            } else if (isWrong) {
                Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = "Wrong",
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

@Composable
fun ResultsScreen(
    score: Int,
    totalQuestions: Int,
    onRetry: () -> Unit,
    onFinish: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(Spacing.space24),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Lesson Complete!",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Bold
        )
        
        Spacer(modifier = Modifier.height(Spacing.space24))
        
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(Spacing.space24),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Your Score",
                    style = MaterialTheme.typography.titleMedium
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "$score / $totalQuestions",
                    style = MaterialTheme.typography.displayMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "${(score * 100) / totalQuestions}% Correct",
                    style = MaterialTheme.typography.titleMedium
                )
            }
        }
        
        Spacer(modifier = Modifier.height(Spacing.space32))
        
        Button(
            onClick = onRetry,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Retry Lesson")
        }
        
        Spacer(modifier = Modifier.height(Spacing.space12))
        
        OutlinedButton(
            onClick = onFinish,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Back to Home")
        }
    }
}
