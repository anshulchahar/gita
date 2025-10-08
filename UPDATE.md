# Home Screen UI/UX Update Plan

## Date: October 9, 2025

## Current Issues Identified

Based on the Duolingo-style reference image provided, the following issues need to be addressed:

### 1. **Infinite Canvas Problem**
- **Current State**: Home screen uses an infinite zoom/pan canvas with gesture controls
- **Issue**: Doesn't match Duolingo's fixed scrollable list approach
- **Impact**: Confusing UX, non-standard mobile interaction pattern

### 2. **Wisdom Tree Implementation**
- **Current State**: Tree visualization with dotted lines, zoom controls, pan/zoom gestures
- **Issue**: Over-engineered, doesn't match the simple vertical progression shown in reference
- **Impact**: Cluttered UI, unnecessary complexity

### 3. **Header/TopBar Inefficiency**
- **Current State**: Shows "Wisdom Tree" title and menu/view toggle icons
- **Issue**: Wastes valuable screen space, doesn't show user stats
- **Impact**: User has no visibility into their XP, currency, or powerups from home screen

### 4. **Missing User Statistics Display**
- **Current State**: No visible XP, powerups, or in-game currency on home screen
- **Issue**: Key gamification elements are hidden
- **Impact**: Reduced engagement, no sense of progression

---

## Proposed Solutions

### Phase 1: Header Redesign ✅ Priority: HIGH

**Goal**: Transform header to show user stats like Duolingo

**Changes**:
1. Remove "Wisdom Tree" title text
2. Add three stat indicators in a row:
   - **Flame Icon** + Streak count (e.g., "🔥 0")
   - **Diamond Icon** + Gems/Currency (e.g., "💎 6755")
   - **Lightning Icon** + Powerups/Energy (e.g., "⚡ 25")
3. Keep hamburger menu on left for navigation
4. Optional: Profile picture on far right

**Data Sources**:
- Wisdom Points: `User.gamification.wisdomPoints`
- Current Streak: `User.gamification.currentStreak`
- Currency/Gems: New field needed in `Gamification` model
- Powerups/Energy: New field needed in `Gamification` model

**Files to Modify**:
- `HomeScreen.kt` - TopAppBar component
- `User.kt` - Add gems and energy fields to Gamification
- `HomeViewModel.kt` - Fetch and expose user stats
- `UserRepository.kt` - Methods to get/update gems and energy

---

### Phase 2: Remove Infinite Canvas ✅ Priority: HIGH

**Goal**: Replace infinite zoom/pan canvas with simple scrollable list

**Changes**:
1. Remove `TreeVisualizationScreen` completely
2. Remove zoom controls (+ - reset buttons)
3. Remove pan/zoom gesture detection
4. Remove `scale`, `offsetX`, `offsetY` state variables
5. Keep only the simple `LazyColumn` list view
6. Remove view toggle button (no longer needed)

**Files to Modify**:
- `HomeScreen.kt` - Remove tree view logic, keep only list view
- Remove `TreeVisualizationScreen.kt` entirely
- `HomeViewModel.kt` - Remove tree-related state if any

---

### Phase 3: Simplify Chapter/Lesson Display ✅ Priority: HIGH

**Goal**: Match Duolingo's simple vertical progression with nodes

**New Design**:
1. Vertical scrollable list (LazyColumn)
2. Each chapter shown as:
   - **Section Header**: "SECTION X, UNIT Y" style
   - **Circular Nodes** for lessons/units within chapter
   - **Simple connecting lines** between nodes (no dotted lines)
   - **Treasure chest** icon for completed chapters
   - **Character/Mascot** for checkpoints
   - **Trophy** for chapter completion milestones

**Visual Elements**:
- **Unlocked lessons**: Green circular button with white star
- **Locked lessons**: Gray circular button with lock icon
- **Current lesson**: Larger green circle with glow/highlight
- **Completed lessons**: Green with checkmark or star filled
- **Progress indicators**: Simple text like "Describe your family"

**Layout**:
```
┌─────────────────────────────────┐
│  SECTION 1, UNIT 1              │
│  Order food and drink           │
├─────────────────────────────────┤
│         ⭐ (completed)           │
│          │                       │
│         ⭐ (completed)           │
│          │                       │
│        🎁 (treasure)             │
│          │                       │
│         ⭐ (current)             │
│          │                       │
│        🦜 (character)           │
│          │                       │
│         ☆ (locked)              │
│          │                       │
│        🏆 (trophy)              │
└─────────────────────────────────┘
```

**Files to Create/Modify**:
- `HomeScreen.kt` - Complete redesign of chapter/lesson rendering
- New composables:
  - `SectionHeader` - Shows "SECTION X, UNIT Y" + description
  - `LessonNode` - Circular button for individual lessons
  - `ProgressPath` - Vertical line connecting nodes
  - `ChapterMilestone` - Treasure, character, trophy markers

---

### Phase 4: Data Model Updates ✅ Priority: MEDIUM

**Goal**: Add necessary fields for gamification features

**Changes to `Gamification` data class**:
```kotlin
data class Gamification(
    val wisdomPoints: Int = 0,           // Existing - for XP
    val gems: Int = 0,                    // NEW - in-game currency
    val energy: Int = 5,                  // NEW - hearts/lives system
    val maxEnergy: Int = 5,              // NEW - maximum energy
    val lastEnergyRefill: Timestamp = Timestamp.now(), // NEW
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val lastCompletedDate: String = "",
    val totalLessonsCompleted: Int = 0,
    val perfectScores: Int = 0
)
```

**New Repository Methods**:
- `updateGems(userId: String, amount: Int)`
- `updateEnergy(userId: String, amount: Int)`
- `refillEnergy(userId: String)`

**Files to Modify**:
- `User.kt` - Update Gamification data class
- `UserRepository.kt` - Add new methods
- `HomeViewModel.kt` - Expose user stats in state

---

### Phase 5: Remove Unnecessary Features ✅ Priority: MEDIUM

**Features to Remove**:
1. ❌ Dotted lines between nodes
2. ❌ Zoom in/out controls
3. ❌ Pan gesture detection
4. ❌ Scale transformations
5. ❌ View toggle (tree vs list)
6. ❌ Circular progress rings around chapters
7. ❌ Complex position calculations
8. ❌ PathEffect animations

**Keep**:
- ✅ Simple vertical scrolling
- ✅ Lock/unlock logic
- ✅ Krishna mascot
- ✅ Chapter cards (but simplified)
- ✅ Navigation to lessons
- ✅ User authentication
- ✅ Progress tracking

---

## Implementation Checklist

### Sprint 1: Core Structure (Day 1)
- [ ] Update `User.kt` - Add gems, energy, maxEnergy, lastEnergyRefill to Gamification
- [ ] Update `UserRepository.kt` - Add methods for gems/energy management
- [ ] Update `HomeViewModel.kt` - Add user stats to HomeState
- [ ] Create header stats UI in `HomeScreen.kt`

### Sprint 2: Remove Complexity (Day 1-2)
- [ ] Delete `TreeVisualizationScreen.kt` file
- [ ] Remove tree view toggle from `HomeScreen.kt`
- [ ] Remove zoom controls and gestures
- [ ] Remove infinite canvas logic
- [ ] Simplify to single LazyColumn view

### Sprint 3: New Visual Design (Day 2-3)
- [ ] Create `SectionHeader` composable
- [ ] Create `LessonNode` composable
- [ ] Create `ProgressPath` composable (simple vertical line)
- [ ] Create `ChapterMilestone` composable
- [ ] Implement new home screen layout

### Sprint 4: Polish & Testing (Day 3)
- [ ] Add smooth animations for node states
- [ ] Test with mock data
- [ ] Verify unlock logic works
- [ ] Test navigation flows
- [ ] Adjust spacing and colors
- [ ] Add accessibility labels

---

## Design Specifications

### Colors
- **Unlocked**: `#4CAF50` (Material Green 500)
- **Locked**: `#BDBDBD` (Material Grey 400)
- **Current**: `#66BB6A` (Material Green 400) with elevation/shadow
- **Background**: Material Theme surface colors
- **Lines**: `#E0E0E0` (Light grey)

### Sizes
- **Node diameter**: 56.dp
- **Current node diameter**: 72.dp
- **Line width**: 4.dp
- **Vertical spacing**: 24.dp between nodes
- **Section header padding**: 16.dp vertical, 24.dp horizontal

### Icons
- **Completed lesson**: White star (⭐) or checkmark (✓)
- **Locked lesson**: Lock icon from Material Icons
- **Current lesson**: Star with glow
- **Treasure**: 🎁 emoji or custom drawable
- **Character**: Krishna mascot or 🦜 emoji
- **Trophy**: 🏆 emoji or custom drawable

### Typography
- **Section header**: MaterialTheme.typography.labelLarge
- **Section description**: MaterialTheme.typography.bodyMedium
- **Stats**: MaterialTheme.typography.titleSmall

---

## Testing Strategy

### Unit Tests
- [ ] Test unlock logic with various user progress states
- [ ] Test gems/energy calculations
- [ ] Test streak calculations

### UI Tests
- [ ] Verify scroll behavior
- [ ] Test lesson node clicks
- [ ] Test locked vs unlocked states
- [ ] Verify stats display correctly

### Integration Tests
- [ ] Test navigation from home to lesson
- [ ] Test data loading and error states
- [ ] Test authentication flow

---

## Rollback Plan

If issues arise:
1. Git tag current version as `v1.0-old-tree-view`
2. Keep `TreeVisualizationScreen.kt` in a backup branch
3. Can revert to list-only view at minimum
4. Header stats are additive, can be hidden if needed

---

## Success Metrics

### UX Improvements
- ✅ Reduced taps to start lesson (from 3+ to 1)
- ✅ Clearer visual progression
- ✅ Always-visible user stats
- ✅ Standard mobile scrolling pattern

### Performance
- ✅ Reduced recomposition complexity
- ✅ Faster screen load time
- ✅ Lower memory usage (no canvas operations)

### User Engagement
- ✅ Increased lesson completion rate (target: +20%)
- ✅ Better retention (visible stats/streaks)
- ✅ Clearer gamification loop

---

## Notes

- Maintain all existing Firebase data structures
- No breaking changes to backend
- Progressive enhancement approach
- Keep Krishna mascot prominent
- Follow Material Design 3 guidelines
- Ensure accessibility throughout

---

## Timeline

- **Day 1**: Sprint 1 + half of Sprint 2
- **Day 2**: Complete Sprint 2 + Sprint 3
- **Day 3**: Sprint 4 + testing
- **Total**: 3 days

---

## Future Enhancements (Post-MVP)

1. Add animations when unlocking new lessons
2. Confetti effect on chapter completion
3. Pull-to-refresh functionality
4. Energy refill timer display
5. Shop for gems (in-app purchases)
6. Achievements showcase
7. Leaderboards
8. Social features (compare with friends)

---

*This document will be updated as implementation progresses.*
