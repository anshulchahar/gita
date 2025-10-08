# Mock Data Setup for Testing

## Overview
The app now includes comprehensive mock data for 3 chapters with multiple lessons and questions. This allows you to fully test the lesson flow, quiz functionality, and progress tracking.

## How to Seed Data

1. **Run the app** and sign in with Google
2. **Access Admin Panel**: Tap "Wisdom Tree" title 5 times on the Home screen
3. **Seed Content**: Tap the "Seed Content" button
4. **Wait for confirmation**: You'll see "Content seeded successfully!"

## What Gets Seeded

### 📚 3 Chapters

#### Chapter 1: Arjuna Vishada Yoga (अर्जुन विषाद योग)
- **Theme**: The Yoga of Arjuna's Dejection
- **Icon**: 🏹
- **Status**: Unlocked
- **Lessons**: 3 lessons
- **Total Questions**: 6 questions

#### Chapter 2: Sankhya Yoga (सांख्य योग)
- **Theme**: The Yoga of Knowledge  
- **Icon**: 🧘
- **Status**: Locked (unlock by completing Chapter 1)
- **Lessons**: 2 lessons
- **Total Questions**: 3 questions

#### Chapter 3: Karma Yoga (कर्म योग)
- **Theme**: The Yoga of Action
- **Icon**: ⚡
- **Status**: Locked (unlock by completing Chapter 2)
- **Lessons**: 2 lessons
- **Total Questions**: 4 questions

---

## Detailed Content Breakdown

### Chapter 1: Arjuna Vishada Yoga

#### Lesson 1: Arjuna's Dilemma (अर्जुन की दुविधा)
- **Difficulty**: Beginner
- **Duration**: ~5 minutes
- **XP Reward**: 50 points
- **Questions**: 3
  1. What was Arjuna's main dilemma?
  2. How does his situation relate to daily life?
  3. What step does Arjuna take at the end?

#### Lesson 2: The Nature of Duty (कर्तव्य का स्वरूप)
- **Difficulty**: Beginner
- **Duration**: ~5 minutes
- **XP Reward**: 50 points
- **Questions**: 2
  1. What is dharma in the Gita?
  2. What should guide difficult duties?

#### Lesson 3: Seeking Guidance (मार्गदर्शन की खोज)
- **Difficulty**: Beginner
- **Duration**: ~5 minutes
- **XP Reward**: 50 points
- **Questions**: 1
  1. Why seek guidance when confused?

---

### Chapter 2: Sankhya Yoga

#### Lesson 1: The Eternal Soul (आत्मा का स्वरूप)
- **Difficulty**: Intermediate
- **Duration**: ~5 minutes
- **XP Reward**: 60 points
- **Questions**: 2
  1. What is the nature of the soul?
  2. How should we view change?

#### Lesson 2: Characteristics of the Wise (स्थितप्रज्ञ की विशेषताएं)
- **Difficulty**: Intermediate
- **Duration**: ~5 minutes
- **XP Reward**: 60 points
- **Questions**: 1
  1. Key characteristic of Sthitaprajna?

---

### Chapter 3: Karma Yoga

#### Lesson 1: Selfless Action (निष्काम कर्म)
- **Difficulty**: Intermediate
- **Duration**: ~5 minutes
- **XP Reward**: 60 points
- **Questions**: 2
  1. What is Nishkama Karma?
  2. Why is action better than inaction?

#### Lesson 2: The Importance of Yajna (यज्ञ का महत्व)
- **Difficulty**: Intermediate
- **Duration**: ~5 minutes
- **XP Reward**: 60 points
- **Questions**: 1
  1. What is Yajna in modern context?

---

## Testing Checklist

After seeding, you can test:

- ✅ **Chapter Display**: See all 3 chapters on Home screen
- ✅ **Lock/Unlock Logic**: Only Chapter 1 is unlocked initially
- ✅ **Lesson Navigation**: Tap chapter → See lessons listed
- ✅ **Quiz Flow**: 
  - Start a lesson
  - Answer multiple choice questions
  - See immediate feedback (green/red)
  - Navigate between questions
  - View final score
- ✅ **Progress Tracking**: Complete lessons and track progress
- ✅ **Real-life Applications**: Each question includes practical wisdom

---

## Question Features

Each question includes:
- **Multiple choice options** (4 options each)
- **Correct answer** with visual feedback
- **Detailed explanation** of why it's correct
- **Real-life application** showing how to apply the teaching
- **Points system** (10 points per question)
- **Time limit** (60 seconds per question)

---

## Data Structure in Firestore

```
chapters/
  └─ {chapterId}
      ├─ chapterNumber: 1
      ├─ chapterName: "अर्जुन विषाद योग"
      ├─ chapterNameEn: "Arjuna Vishada Yoga"
      ├─ description: "..."
      └─ isUnlocked: true

lessons/
  └─ {lessonId}
      ├─ chapterId: {ref to chapter}
      ├─ lessonNumber: 1
      ├─ lessonName: "अर्जुन की दुविधा"
      ├─ lessonNameEn: "Arjuna's Dilemma"
      ├─ difficulty: "beginner"
      └─ xpReward: 50

questions/
  └─ {questionId}
      ├─ lessonId: {ref to lesson}
      ├─ order: 1
      ├─ type: "MULTIPLE_CHOICE_TRANSLATION"
      ├─ content:
      │   ├─ questionText: "..."
      │   ├─ options: ["...", "...", "...", "..."]
      │   ├─ correctAnswerIndex: 1
      │   ├─ explanation: "..."
      │   └─ realLifeApplication: "..."
      └─ points: 10
```

---

## Notes

- **Seeding is idempotent**: Running seed multiple times won't duplicate data
- **Chapters check**: If chapters exist, seeding skips to avoid duplicates
- **Progressive unlock**: Chapters 2 & 3 unlock after completing previous chapters
- **Real Gita wisdom**: All content is based on actual Bhagavad Gita teachings
- **Modern relevance**: Every question connects ancient wisdom to modern life

---

## Next Steps After Testing

1. Test complete lesson flow
2. Verify progress tracking works
3. Test lock/unlock logic
4. Add answer feedback animations
5. Implement completion celebrations
6. Add more chapters and lessons

Enjoy testing your Gita learning app! 🙏
