package com.schepor.gita.presentation.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Krishna Helper Card
 * 
 * Displays Baby Krishna with a message in a card format.
 * Perfect for tips, encouragement, feedback, or guidance.
 * 
 * @param emotion Krishna's emotion/pose
 * @param message The message to display
 * @param animation Animation to apply to Krishna
 * @param krishnaSize Size of the Krishna mascot
 * @param modifier Additional modifiers
 */
@Composable
fun KrishnaHelperCard(
    emotion: KrishnaEmotion,
    message: String,
    animation: KrishnaAnimation = KrishnaAnimation.IDLE_FLOAT,
    krishnaSize: Dp = 100.dp,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.secondaryContainer
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Krishna mascot
            KrishnaMascot(
                emotion = emotion,
                animation = animation,
                size = krishnaSize
            )
            
            // Message
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSecondaryContainer,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/**
 * Krishna Message Bubble
 * 
 * Displays Krishna above a speech-bubble style message.
 * 
 * @param emotion Krishna's emotion/pose
 * @param message The message to display
 * @param animation Animation to apply to Krishna
 * @param krishnaSize Size of the Krishna mascot
 * @param modifier Additional modifiers
 */
@Composable
fun KrishnaMessageBubble(
    emotion: KrishnaEmotion,
    message: String,
    animation: KrishnaAnimation = KrishnaAnimation.IDLE_FLOAT,
    krishnaSize: Dp = 120.dp,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Krishna mascot
        KrishnaMascot(
            emotion = emotion,
            animation = animation,
            size = krishnaSize
        )
        
        // Message card
        Card(
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(16.dp)
            )
        }
    }
}

/**
 * Predefined encouraging messages for different scenarios
 */
object KrishnaMessages {
    val WELCOME = listOf(
        "Welcome, seeker of wisdom! 🙏",
        "Namaste! Ready to learn today?",
        "Hari Om! Let's explore the Gita together.",
        "Welcome back! Your journey continues."
    )
    
    val CORRECT_ANSWER = listOf(
        "Excellent! You're on the path of wisdom! 🎉",
        "Perfectly answered! Well done!",
        "Wonderful! Your understanding grows!",
        "Correct! Keep up the great work!",
        "Shabash! You got it right!"
    )
    
    val WRONG_ANSWER = listOf(
        "Don't worry! Every mistake is a lesson. 💫",
        "Keep trying! You're learning and growing.",
        "That's okay! Let's learn from this.",
        "Not quite, but you're on the right path!",
        "Remember: The journey matters more than the destination."
    )
    
    val ENCOURAGEMENT = listOf(
        "You can do this! Stay focused. 💪",
        "Believe in yourself! You're doing great!",
        "Take your time, no rush!",
        "Every step forward is progress!",
        "You're making wonderful progress!"
    )
    
    val HIGH_SCORE = listOf(
        "Outstanding achievement! You're a true scholar! 🌟",
        "Incredible! You've mastered this lesson!",
        "Excellent work! Your dedication shows!",
        "Remarkable! You're becoming wise!"
    )
    
    val MEDIUM_SCORE = listOf(
        "Good job! You're making solid progress! 👍",
        "Well done! Keep practicing!",
        "Nice effort! You're improving!",
        "Great work! Keep it up!"
    )
    
    val LOW_SCORE = listOf(
        "Keep practicing! You'll get better! 💪",
        "Don't give up! Every master was once a beginner.",
        "Learning takes time. Keep going!",
        "Review the lesson and try again. You've got this!"
    )
    
    val LESSON_START = listOf(
        "Let's begin this new lesson! 📖",
        "Ready to explore? Let's start!",
        "A new chapter of wisdom awaits!",
        "Let's dive into this lesson together!"
    )
    
    val LESSON_COMPLETE = listOf(
        "Lesson completed! Well done! ✅",
        "You've finished this lesson! Great job!",
        "Another lesson mastered! Excellent!",
        "Congratulations on completing this lesson!"
    )
    
    val LOCKED_CONTENT = listOf(
        "Complete previous lessons to unlock! 🔒",
        "This will unlock soon. Keep learning!",
        "Finish earlier lessons to access this.",
        "Your journey will lead you here soon!"
    )
    
    val DAILY_WISDOM = listOf(
        "\"You have the right to work, but never to the fruit of work.\" - BG 2.47",
        "\"The soul is neither born, nor does it ever die.\" - BG 2.20",
        "\"Set thy heart upon thy work, but never on its reward.\" - BG 2.47",
        "\"When meditation is mastered, the mind is unwavering like the flame of a lamp in a windless place.\" - BG 6.19"
    )
}

/**
 * Helper to get random message from a list
 */
fun List<String>.random(): String = this.random()
