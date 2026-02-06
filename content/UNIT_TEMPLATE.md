# Unit Content Template & Guidelines

This master template provides the structure and guidelines for creating all 18 units of the Gita App.

---

## Content Philosophy

### Core Principles
1. **Love-Centered**: All content should be filled with compassion, understanding, and encouragement
2. **Non-Judgmental**: Avoid harsh criticism; guide users with gentle wisdom
3. **Practical Application**: Every teaching should connect to real-life situations
4. **Culturally Sensitive**: Respect diverse backgrounds while staying true to Gita's essence
5. **Empowering**: Help users feel capable of growth, never diminished

### What to Avoid
- ❌ Hate speech or divisive language
- ❌ Fear-based motivation
- ❌ Judgmental or condemning tones
- ❌ Culturally insensitive stereotypes
- ❌ Overly complex philosophical jargon
- ❌ Making users feel guilty or inadequate

### What to Include
- ✅ Warm, encouraging language
- ✅ Relatable modern scenarios
- ✅ Gentle corrections with positive alternatives
- ✅ Practical wisdom for daily life
- ✅ Balance of challenge and comfort
- ✅ Celebrate small victories

---

## Answer Guidelines

### Marking Correct Answers
The `isOptimal: true` answer should always:
1. Align with Krishna's teaching in that section
2. Represent wisdom, not just knowledge
3. Be practically applicable
4. Show emotional intelligence
5. Lead to inner peace, not just external success

### Common Patterns for Correct Answers
| Section Theme | Optimal Response Pattern |
|---------------|-------------------------|
| Facing Dilemmas | Pause, observe, seek clarity |
| Attachment | Acknowledge feelings, but don't let them control |
| Action | Act without obsession over results |
| Wisdom | Steady mind, equanimity in all situations |
| Peace | Self-control, focus, surrender ego |

### Wrong Answer Feedback
Wrong answers should have feedback that:
- Explains WHY it's not optimal (without being harsh)
- Connects to the teaching
- Offers hope and direction
- Uses phrases like "This is natural, but..." or "While understandable..."

---

## JSON Structure Template

```json
{
    "unit": {
        "id": "unit_X",
        "unitNumber": X,
        "unitName": "Unit Title in English",
        "unitNameHi": "यूनिट शीर्षक हिंदी में",
        "chapterNumber": X,
        "theme": "2-4 word theme",
        "difficulty": "beginner|beginner-intermediate|intermediate|advanced",
        "icon": "🔥",
        "color": "#HEXCODE",
        "description": "1-2 sentence description of what the user will learn",
        "descriptionHi": "हिंदी विवरण",
        "journeyId": "journey_1|journey_2|journey_3",
        "shlokasCovered": "X-Y"
    },
    "sections": [
        {
            "id": "section_X_1",
            "unitId": "unit_X",
            "sectionNumber": 1,
            "sectionName": "Section Title",
            "sectionNameHi": "अनुभाग शीर्षक",
            "shlokaRange": "start-end",
            "keyTeaching": "One sentence key teaching",
            "order": 1
        }
    ],
    "lessons": [
        {
            "id": "lesson_X_1_1",
            "sectionId": "section_X_1",
            "unitId": "unit_X",
            "lessonNumber": 1,
            "lessonName": "Lesson Title",
            "lessonNameHi": "पाठ शीर्षक",
            "order": 1,
            "estimatedTime": 300,
            "difficulty": "beginner|intermediate|advanced",
            "shlokasCovered": [1, 2, 3],
            "xpReward": 50,
            "prerequisite": null
        }
    ],
    "questions": []
}
```

---

## Question Types & Templates

### 1. Scenario Challenge
Tests application of wisdom in real-life situations.

```json
{
    "questionId": "q_X_Y_Z_scenario_N",
    "lessonId": "lesson_X_Y_Z",
    "type": "scenarioChallenge",
    "order": 1,
    "xpReward": 25,
    "content": {
        "scenarioTitle": "Short Title (2-4 words)",
        "scenarioTitleHi": "हिंदी शीर्षक",
        "scenario": "A relatable situation (2-3 sentences). End with a question.",
        "scenarioHi": "हिंदी परिदृश्य",
        "options": [
            {
                "text": "Option 1 - A common but suboptimal response",
                "textHi": "विकल्प 1 हिंदी",
                "feedback": "Gentle explanation of why this isn't optimal. Connect to teaching.",
                "feedbackHi": "हिंदी प्रतिक्रिया",
                "isOptimal": false
            },
            {
                "text": "Option 2 - The wisdom-aligned response",
                "textHi": "विकल्प 2 हिंदी",
                "feedback": "Affirming explanation. Connect to the shloka/teaching. Celebrate the insight.",
                "feedbackHi": "हिंदी प्रतिक्रिया",
                "isOptimal": true
            },
            {
                "text": "Option 3 - Another common but suboptimal response",
                "textHi": "विकल्प 3 हिंदी",
                "feedback": "Gentle explanation. Offer hope.",
                "feedbackHi": "हिंदी प्रतिक्रिया",
                "isOptimal": false
            }
        ]
    }
}
```

**Scenarios to Include:**
- Work/Career challenges
- Family relationships
- Friendship dilemmas
- Health/wellness decisions
- Financial choices
- Personal growth moments
- Emotional challenges

### 2. Story Card
Introduces concepts through storytelling.

```json
{
    "questionId": "q_X_Y_Z_story_N",
    "lessonId": "lesson_X_Y_Z",
    "type": "storyCard",
    "order": 2,
    "xpReward": 10,
    "content": {
        "title": "Story Title",
        "titleHi": "कहानी शीर्षक",
        "story": "3-5 sentences introducing or explaining a concept from the shloka. Use vivid imagery. Connect ancient wisdom to modern life.",
        "storyHi": "हिंदी कहानी",
        "krishnaMessage": "A short, memorable insight from Krishna's perspective (1 sentence)"
    }
}
```

### 3. Multiple Choice
Tests conceptual understanding.

```json
{
    "questionId": "q_X_Y_Z_mc_N",
    "lessonId": "lesson_X_Y_Z",
    "type": "multipleChoice",
    "order": 3,
    "xpReward": 15,
    "content": {
        "question": "A clear question about the teaching",
        "questionHi": "हिंदी प्रश्न",
        "options": [
            {
                "text": "Correct answer",
                "textHi": "हिंदी",
                "isCorrect": true
            },
            {
                "text": "Plausible but incorrect",
                "textHi": "हिंदी",
                "isCorrect": false
            },
            {
                "text": "Common misconception",
                "textHi": "हिंदी",
                "isCorrect": false
            },
            {
                "text": "Clearly incorrect for contrast",
                "textHi": "हिंदी",
                "isCorrect": false
            }
        ],
        "explanation": "Why the correct answer is right, with reference to the teaching",
        "explanationHi": "हिंदी स्पष्टीकरण"
    }
}
```

### 4. Reflection Prompt
Encourages personal contemplation.

```json
{
    "questionId": "q_X_Y_Z_reflection_N",
    "lessonId": "lesson_X_Y_Z",
    "type": "reflectionPrompt",
    "order": 5,
    "xpReward": 20,
    "content": {
        "prompt": "An open-ended question for self-reflection. Personal and introspective.",
        "promptHi": "हिंदी संकेत",
        "guidingQuestions": [
            "Optional guiding question 1",
            "Optional guiding question 2"
        ],
        "krishnaWisdom": "An encouraging, gentle wisdom statement"
    }
}
```

---

## Lesson Density Requirements

Each section MUST have **3-5 lessons**:
- Minimum: 3 lessons (for sections with 6-10 shlokas)
- Maximum: 5 lessons (for sections with 20+ shlokas)

Each lesson MUST have **4-5 questions** in this order:
1. `scenarioChallenge` - Apply the wisdom
2. `storyCard` - Learn the context
3. `multipleChoice` - Test understanding
4. `scenarioChallenge` - Another application
5. `reflectionPrompt` - Personal integration

---

## Journey Mapping

| Journey | Chapters | Theme | ID |
|---------|----------|-------|----|
| Tvam (You) | 1-6 | Self-Discovery & Inner Mastery | journey_1 |
| Tat (That) | 7-12 | Understanding the Divine | journey_2 |
| Asi (Union) | 13-18 | Integration & Liberation | journey_3 |

---

## Recommended Icons & Colors by Chapter Theme

| Chapter | Theme | Icon | Color |
|---------|-------|------|-------|
| 1 | Despair | 🏹 | #FF9933 |
| 2 | Wisdom | 🧘 | #4A148C |
| 3 | Action | ⚡ | #FF6F00 |
| 4 | Knowledge | 📚 | #1565C0 |
| 5 | Renunciation | 🕊️ | #00695C |
| 6 | Meditation | 🔮 | #6A1B9A |
| 7 | Divine Knowledge | ✨ | #C62828 |
| 8 | Imperishable | 🌌 | #283593 |
| 9 | Royal Secret | 👑 | #EF6C00 |
| 10 | Divine Glory | 🌟 | #F9A825 |
| 11 | Universal Form | 🌐 | #00838F |
| 12 | Devotion | 💜 | #8E24AA |
| 13 | Field/Knower | 🌾 | #558B2F |
| 14 | Three Gunas | 🎭 | #5D4037 |
| 15 | Supreme Person | 🌳 | #1B5E20 |
| 16 | Divine/Demonic | ⚖️ | #BF360C |
| 17 | Three Faiths | 🙏 | #4527A0 |
| 18 | Liberation | 🔥 | #FF6F00 |

---

## Quality Checklist

Before finalizing any unit, verify:

### Content Quality
- [ ] All isOptimal/isCorrect flags correctly set
- [ ] No hate speech or divisive language
- [ ] Feedback is gentle and encouraging
- [ ] Hindi translations are accurate
- [ ] Scenarios are relatable to modern life
- [ ] Krishna's wisdom statements are memorable

### Technical Quality
- [ ] All IDs follow naming convention
- [ ] Prerequisites chain correctly
- [ ] Order numbers are sequential
- [ ] Shloka coverage is complete for section
- [ ] JSON is valid (no syntax errors)

### Lesson Density  
- [ ] Each section has 3-5 lessons
- [ ] Each lesson has 4-5 questions
- [ ] Question types are in correct order

---

## Example: Correct vs Incorrect Answer Marking

### ❌ WRONG (what to avoid)
```json
{
    "text": "Pause and observe the situation clearly",
    "isOptimal": false  // ← WRONG! This IS the wise response
}
```

### ✅ CORRECT
```json
{
    "text": "Pause and observe the situation clearly",
    "feedback": "Just as Arjuna paused between the armies to see clearly, taking a moment to observe helps us understand the true nature of our challenge.",
    "isOptimal": true  // ← CORRECT! Wisdom-aligned response
}
```

---

## Creating a New Unit

1. Copy this template structure
2. Replace all `X` with unit number
3. Fill in sections based on shloka groupings (aim for 4 sections per unit)
4. Create 3-5 lessons per section
5. Write 4-5 questions per lesson using the templates above
6. Run quality checklist
7. Validate JSON syntax
8. Test in app

---

*Template Version: 1.0*
*Created: February 2026*
