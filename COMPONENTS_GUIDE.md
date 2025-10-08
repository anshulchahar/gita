# Quick Reference: New Home Screen Components

## Overview
This guide shows how to use the new Duolingo-style components created for the home screen.

---

## Components

### 1. SectionHeader

**Purpose**: Display chapter/section headers

**Usage**:
```kotlin
SectionHeader(
    sectionNumber = 1,
    unitNumber = 1,
    description = "Order food and drink"
)
```

**Parameters**:
- `sectionNumber: Int` - The section number to display
- `unitNumber: Int` - The unit number to display  
- `description: String` - The chapter/unit description
- `modifier: Modifier = Modifier` - Optional modifier

---

### 2. LessonNode

**Purpose**: Display individual lesson as a circular button

**Usage**:
```kotlin
LessonNode(
    lessonNumber = 1,
    isUnlocked = true,
    isCompleted = false,
    isCurrent = true,
    description = "Greetings and basics",
    onClick = { /* Navigate to lesson */ }
)
```

**Parameters**:
- `lessonNumber: Int` - The lesson number
- `isUnlocked: Boolean` - Whether the lesson is unlocked
- `isCompleted: Boolean` - Whether the lesson is completed
- `isCurrent: Boolean` - Whether this is the current lesson (highlighted)
- `description: String = ""` - Optional lesson description shown below
- `onClick: () -> Unit` - Click handler
- `modifier: Modifier = Modifier` - Optional modifier

**Visual States**:
- **Locked** (gray): Lock icon, not clickable
- **Unlocked** (green): Star icon (faded), clickable
- **Completed** (green): Star icon (solid), clickable
- **Current** (bright green): Star icon, larger size, shadow effect

---

### 3. ProgressPath

**Purpose**: Vertical line connecting lesson nodes

**Usage**:
```kotlin
ProgressPath(
    isUnlocked = true,
    height = 32
)
```

**Parameters**:
- `isUnlocked: Boolean` - Whether the path is unlocked (affects opacity)
- `height: Int = 40` - Height in dp
- `modifier: Modifier = Modifier` - Optional modifier

**Appearance**:
- 4dp width
- Light gray color (#E0E0E0)
- Reduced opacity when locked

---

### 4. ChapterMilestone

**Purpose**: Special achievement markers

**Usage**:
```kotlin
ChapterMilestone(
    type = MilestoneType.TREASURE,
    isUnlocked = true,
    onClick = { /* Show reward */ }
)
```

**Parameters**:
- `type: MilestoneType` - Type of milestone
- `isUnlocked: Boolean` - Whether unlocked
- `onClick: (() -> Unit)? = null` - Optional click handler
- `modifier: Modifier = Modifier` - Optional modifier

**Milestone Types**:
- `MilestoneType.TREASURE` - 🎁 Treasure chest
- `MilestoneType.CHARACTER` - 🦜 Mascot/character
- `MilestoneType.TROPHY` - 🏆 Achievement trophy
- `MilestoneType.KRISHNA` - 🪷 Krishna lotus

---

## Example: Complete Progression Path

```kotlin
LazyColumn {
    // Section header
    item {
        SectionHeader(
            sectionNumber = 1,
            unitNumber = 1,
            description = "Chapter 1: Arjuna's Dilemma"
        )
    }
    
    // First lesson
    item {
        LessonNode(
            lessonNumber = 1,
            isUnlocked = true,
            isCompleted = true,
            isCurrent = false,
            description = "Introduction to the Gita",
            onClick = { navigateToLesson(1) }
        )
    }
    
    // Path between lessons
    item {
        ProgressPath(isUnlocked = true, height = 32)
    }
    
    // Second lesson (current)
    item {
        LessonNode(
            lessonNumber = 2,
            isUnlocked = true,
            isCompleted = false,
            isCurrent = true,
            description = "Arjuna's confusion",
            onClick = { navigateToLesson(2) }
        )
    }
    
    // Path to locked lesson
    item {
        ProgressPath(isUnlocked = false, height = 32)
    }
    
    // Locked lesson
    item {
        LessonNode(
            lessonNumber = 3,
            isUnlocked = false,
            isCompleted = false,
            isCurrent = false,
            description = "Krishna's wisdom",
            onClick = { /* Won't be called */ }
        )
    }
    
    // Milestone after 3 lessons
    item {
        ProgressPath(isUnlocked = true, height = 40)
    }
    item {
        ChapterMilestone(
            type = MilestoneType.TREASURE,
            isUnlocked = true
        )
    }
}
```

---

## Styling Guide

### Colors
All components use Material Design 3 theme colors:
- Primary: Chapter/section highlights
- Surface: Background containers
- On-surface: Text colors
- Custom greens: Lesson states (#4CAF50, #66BB6A)

### Spacing
Standard spacing from `Spacing` object:
- `space4` - 4dp
- `space8` - 8dp
- `space16` - 16dp
- `space24` - 24dp

### Typography
- Section headers: `labelLarge`, `titleMedium`
- Lesson descriptions: `bodyMedium`
- Numbers/stats: `titleSmall`

---

## Layout Tips

### LazyColumn Setup
```kotlin
LazyColumn(
    modifier = Modifier.fillMaxSize(),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.spacedBy(4.dp)
) {
    // Items here
}
```

### Milestone Placement
Add milestones every 3 lessons:
```kotlin
if ((lessonIndex + 1) % 3 == 0) {
    // Add path and milestone
}
```

### Chapter Separation
Add extra spacing between chapters:
```kotlin
if (chapterIndex < chapters.size - 1) {
    item {
        Spacer(modifier = Modifier.height(24.dp))
    }
}
```

---

## Accessibility

All components include:
- Content descriptions for icons
- Proper click feedback
- High contrast colors
- Readable text sizes
- Touch targets ≥ 48dp

---

## Performance Notes

- Use `item(key = ...)` for stable LazyColumn items
- Avoid nested LazyColumns
- Keep composables pure (no side effects)
- Use `remember` for expensive calculations

---

*Last updated: October 9, 2025*
