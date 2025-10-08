package com.schepor.gita.presentation.components

import androidx.annotation.DrawableRes
import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.schepor.gita.R
import kotlin.math.sin

/**
 * Krishna Mascot Emotions/Poses
 * Maps to the PNG files in drawable folder
 */
enum class KrishnaEmotion(
    @DrawableRes val drawableRes: Int,
    val description: String
) {
    NEUTRAL(R.drawable.krishna_neutral, "Neutral/Idle pose"),
    HAPPY(R.drawable.krishna_happy, "Happy and joyful"),
    CELEBRATING(R.drawable.krishna_celebrating, "Celebrating victory"),
    SAD(R.drawable.krishna_sad, "Sad and empathetic"),
    THINKING(R.drawable.krishna_thinking, "Thinking/Pondering"),
    POINTING(R.drawable.krishna_pointing, "Excited/Pointing"),
    MEDITATING(R.drawable.krishna_meditating, "Meditating peacefully"),
    SLEEPING(R.drawable.krishna_sleeping, "Sleeping/Resting"),
    AMAZED(R.drawable.krishna_amazed, "Surprised/Amazed"),
    ENCOURAGING(R.drawable.krishna_encouraging, "Encouraging/Supportive"),
    DANCING(R.drawable.krishna_dancing, "Dancing playfully"),
    FLUTE(R.drawable.krishna_flute, "Playing flute")
}

/**
 * Animation types for the mascot
 */
enum class KrishnaAnimation {
    NONE,           // No animation
    IDLE_FLOAT,     // Gentle floating up and down
    BOUNCE,         // Happy bouncing
    WIGGLE,         // Side to side wiggle
    PULSE,          // Scale pulsing
    BREATHING,      // Gentle breathing effect (subtle scale)
    SPIN,           // Full 360 spin
    SHAKE_HEAD,     // Shake head (no)
    NOD_HEAD        // Nod head (yes)
}

/**
 * Baby Krishna Mascot Component
 * 
 * A cute Baby Krishna character that displays different emotions and animations
 * to enhance user experience throughout the app.
 * 
 * @param emotion The emotion/pose to display
 * @param animation The animation to apply
 * @param size Size of the mascot (default 120.dp)
 * @param modifier Additional modifiers
 */
@Composable
fun KrishnaMascot(
    emotion: KrishnaEmotion = KrishnaEmotion.NEUTRAL,
    animation: KrishnaAnimation = KrishnaAnimation.IDLE_FLOAT,
    size: Dp = 120.dp,
    modifier: Modifier = Modifier
) {
    // Animation state
    val infiniteTransition = rememberInfiniteTransition(label = "krishna_animation")
    
    // Calculate animation values based on animation type
    val animationValues = getAnimationValues(infiniteTransition, animation)
    
    Box(
        modifier = modifier
            .size(size)
            .graphicsLayer {
                // Apply transformations based on animation
                translationY = animationValues.translationY
                translationX = animationValues.translationX
                rotationZ = animationValues.rotation
                scaleX = animationValues.scale
                scaleY = animationValues.scale
            },
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(emotion.drawableRes),
            contentDescription = emotion.description,
            contentScale = ContentScale.Fit,
            modifier = Modifier.fillMaxSize()
        )
    }
}

/**
 * Animation values container
 */
private data class AnimationValues(
    val translationY: Float = 0f,
    val translationX: Float = 0f,
    val rotation: Float = 0f,
    val scale: Float = 1f
)

/**
 * Calculate animation values based on animation type
 */
@Composable
private fun getAnimationValues(
    infiniteTransition: InfiniteTransition,
    animation: KrishnaAnimation
): AnimationValues {
    return when (animation) {
        KrishnaAnimation.NONE -> AnimationValues()
        
        KrishnaAnimation.IDLE_FLOAT -> {
            val translateY by infiniteTransition.animateFloat(
                initialValue = 0f,
                targetValue = -15f,
                animationSpec = infiniteRepeatable(
                    animation = tween(2000, easing = FastOutSlowInEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "idle_float"
            )
            AnimationValues(translationY = translateY)
        }
        
        KrishnaAnimation.BOUNCE -> {
            val translateY by infiniteTransition.animateFloat(
                initialValue = 0f,
                targetValue = -25f,
                animationSpec = infiniteRepeatable(
                    animation = tween(500, easing = FastOutSlowInEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "bounce"
            )
            AnimationValues(translationY = translateY)
        }
        
        KrishnaAnimation.WIGGLE -> {
            val rotation by infiniteTransition.animateFloat(
                initialValue = -8f,
                targetValue = 8f,
                animationSpec = infiniteRepeatable(
                    animation = tween(400, easing = LinearEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "wiggle"
            )
            AnimationValues(rotation = rotation)
        }
        
        KrishnaAnimation.PULSE -> {
            val scale by infiniteTransition.animateFloat(
                initialValue = 1f,
                targetValue = 1.1f,
                animationSpec = infiniteRepeatable(
                    animation = tween(800, easing = FastOutSlowInEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "pulse"
            )
            AnimationValues(scale = scale)
        }
        
        KrishnaAnimation.BREATHING -> {
            val scale by infiniteTransition.animateFloat(
                initialValue = 1f,
                targetValue = 1.03f,
                animationSpec = infiniteRepeatable(
                    animation = tween(2500, easing = LinearEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "breathing"
            )
            AnimationValues(scale = scale)
        }
        
        KrishnaAnimation.SPIN -> {
            val rotation by infiniteTransition.animateFloat(
                initialValue = 0f,
                targetValue = 360f,
                animationSpec = infiniteRepeatable(
                    animation = tween(2000, easing = LinearEasing),
                    repeatMode = RepeatMode.Restart
                ),
                label = "spin"
            )
            AnimationValues(rotation = rotation)
        }
        
        KrishnaAnimation.SHAKE_HEAD -> {
            val rotation by infiniteTransition.animateFloat(
                initialValue = -10f,
                targetValue = 10f,
                animationSpec = infiniteRepeatable(
                    animation = tween(200, easing = LinearEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "shake_head"
            )
            AnimationValues(rotation = rotation)
        }
        
        KrishnaAnimation.NOD_HEAD -> {
            val translateY by infiniteTransition.animateFloat(
                initialValue = 0f,
                targetValue = 8f,
                animationSpec = infiniteRepeatable(
                    animation = tween(300, easing = FastOutSlowInEasing),
                    repeatMode = RepeatMode.Reverse
                ),
                label = "nod_head"
            )
            AnimationValues(translationY = translateY)
        }
    }
}

/**
 * Helper function to get appropriate emotion based on quiz result
 */
fun getEmotionForQuizResult(isCorrect: Boolean, score: Int? = null): KrishnaEmotion {
    return when {
        isCorrect -> KrishnaEmotion.CELEBRATING
        score != null && score < 50 -> KrishnaEmotion.SAD
        else -> KrishnaEmotion.ENCOURAGING
    }
}

/**
 * Helper function to get appropriate emotion based on final score
 */
fun getEmotionForFinalScore(scorePercentage: Int): KrishnaEmotion {
    return when {
        scorePercentage >= 90 -> KrishnaEmotion.CELEBRATING
        scorePercentage >= 70 -> KrishnaEmotion.HAPPY
        scorePercentage >= 50 -> KrishnaEmotion.ENCOURAGING
        else -> KrishnaEmotion.SAD
    }
}
