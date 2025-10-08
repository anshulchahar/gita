# 🎯 Quick Reference: Using Krishna Mascot

## Import Statements

```kotlin
import com.schepor.gita.presentation.components.KrishnaMascot
import com.schepor.gita.presentation.components.KrishnaEmotion
import com.schepor.gita.presentation.components.KrishnaAnimation
import com.schepor.gita.presentation.components.KrishnaHelperCard
import com.schepor.gita.presentation.components.KrishnaMessageBubble
import com.schepor.gita.presentation.components.KrishnaMessages
```

---

## Basic Usage

### Simple Krishna
```kotlin
KrishnaMascot(
    emotion = KrishnaEmotion.HAPPY,
    animation = KrishnaAnimation.BOUNCE,
    size = 120.dp
)
```

### Krishna with Message (Horizontal)
```kotlin
KrishnaHelperCard(
    emotion = KrishnaEmotion.ENCOURAGING,
    message = "You can do this!",
    animation = KrishnaAnimation.PULSE
)
```

### Krishna with Message (Vertical)
```kotlin
KrishnaMessageBubble(
    emotion = KrishnaEmotion.NEUTRAL,
    message = "Welcome to the lesson!",
    animation = KrishnaAnimation.IDLE_FLOAT,
    krishnaSize = 150.dp
)
```

---

## Common Scenarios

### Quiz Feedback
```kotlin
// Correct answer
KrishnaMascot(
    emotion = KrishnaEmotion.CELEBRATING,
    animation = KrishnaAnimation.BOUNCE,
    size = 100.dp
)

// Wrong answer
KrishnaMascot(
    emotion = KrishnaEmotion.SAD,
    animation = KrishnaAnimation.NONE,
    size = 100.dp
)
```

### Score-Based Display
```kotlin
val scorePercentage = (score * 100) / totalQuestions
val emotion = when {
    scorePercentage >= 90 -> KrishnaEmotion.CELEBRATING
    scorePercentage >= 70 -> KrishnaEmotion.HAPPY
    scorePercentage >= 50 -> KrishnaEmotion.ENCOURAGING
    else -> KrishnaEmotion.SAD
}

KrishnaMascot(
    emotion = emotion,
    animation = KrishnaAnimation.PULSE,
    size = 150.dp
)
```

### Locked Content
```kotlin
KrishnaMessageBubble(
    emotion = KrishnaEmotion.SLEEPING,
    message = KrishnaMessages.LOCKED_CONTENT.random(),
    animation = KrishnaAnimation.BREATHING
)
```

### Welcome Screen
```kotlin
Column(horizontalAlignment = Alignment.CenterHorizontally) {
    KrishnaMascot(
        emotion = KrishnaEmotion.NEUTRAL,
        animation = KrishnaAnimation.IDLE_FLOAT,
        size = 120.dp
    )
    Spacer(modifier = Modifier.height(16.dp))
    Text(text = KrishnaMessages.WELCOME.random())
}
```

### Achievement/Celebration
```kotlin
KrishnaMascot(
    emotion = KrishnaEmotion.CELEBRATING,
    animation = KrishnaAnimation.SPIN,
    size = 200.dp
)
```

---

## All Emotions Quick Reference

| Emotion | Best For | Recommended Animation |
|---------|----------|----------------------|
| `NEUTRAL` | Welcome, idle | `IDLE_FLOAT` |
| `HAPPY` | Good scores, achievements | `PULSE` |
| `CELEBRATING` | Victories, correct answers | `BOUNCE` |
| `SAD` | Wrong answers, low scores | `NONE` or `IDLE_FLOAT` |
| `THINKING` | Quiz questions | `NOD_HEAD` |
| `POINTING` | Tips, teaching | `WIGGLE` |
| `MEDITATING` | Loading, peace | `BREATHING` |
| `SLEEPING` | Locked content | `BREATHING` |
| `AMAZED` | Milestones | `PULSE` |
| `ENCOURAGING` | Medium scores | `IDLE_FLOAT` |
| `DANCING` | Celebrations | `WIGGLE` |
| `FLUTE` | Traditional moments | `BREATHING` |

---

## All Animations Quick Reference

| Animation | Duration | Best For | Loop |
|-----------|----------|----------|------|
| `NONE` | - | Static display | - |
| `IDLE_FLOAT` | 2s | Default, calm | ✅ |
| `BOUNCE` | 500ms | Excitement, joy | ✅ |
| `WIGGLE` | 400ms | Playful, teaching | ✅ |
| `PULSE` | 800ms | Emphasis, attention | ✅ |
| `BREATHING` | 2.5s | Peaceful, meditation | ✅ |
| `SPIN` | 2s | Celebration | ✅ |
| `SHAKE_HEAD` | 200ms | No/disagreement | ✅ |
| `NOD_HEAD` | 300ms | Yes/agreement | ✅ |

---

## Random Messages

```kotlin
// Get random message from category
val message = KrishnaMessages.CORRECT_ANSWER.random()

// Available categories:
KrishnaMessages.WELCOME.random()
KrishnaMessages.CORRECT_ANSWER.random()
KrishnaMessages.WRONG_ANSWER.random()
KrishnaMessages.ENCOURAGEMENT.random()
KrishnaMessages.HIGH_SCORE.random()
KrishnaMessages.MEDIUM_SCORE.random()
KrishnaMessages.LOW_SCORE.random()
KrishnaMessages.LESSON_START.random()
KrishnaMessages.LESSON_COMPLETE.random()
KrishnaMessages.LOCKED_CONTENT.random()
KrishnaMessages.DAILY_WISDOM.random()
```

---

## Tips

✅ **Do:**
- Use `IDLE_FLOAT` for default gentle animation
- Match emotion to context (sad for wrong, happy for correct)
- Use random messages for variety
- Size 80-150dp works best for most screens

❌ **Don't:**
- Don't use too many animations on one screen (performance)
- Don't use `SPIN` for serious moments
- Don't make Krishna too small (<60dp) or too large (>200dp)

---

## File Locations

- **Components:** `/app/src/main/java/com/schepor/gita/presentation/components/`
  - `KrishnaMascot.kt`
  - `KrishnaHelper.kt`

- **Images:** `/app/src/main/res/drawable/`
  - `krishna_*.png` (12 images)

- **Integration Examples:**
  - `HomeScreen.kt` - Lines ~183-199
  - `LessonScreen.kt` - Lines ~556-604 (feedback), ~372-421 (results)

---

**Quick Start:** Copy any example above and customize the emotion, animation, and message! 🎨
