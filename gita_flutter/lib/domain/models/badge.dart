// Badge model for the Gita app gamification system
//
// Badges are earned by completing various achievements in the app.
// Categories: Milestone, Streak, Mastery, Special

enum BadgeCategory {
  milestone,  // Lesson completion milestones
  streak,     // Consistency/streak badges
  mastery,    // Perfection/skill badges
  special,    // Time-based or rare achievements
}

enum BadgeId {
  // Milestone Badges
  firstStep,        // Complete first lesson
  seeker,           // Complete 10 lessons
  warriorsHeart,    // Complete 50 lessons
  devotee,          // Complete 100 lessons
  liberatedSoul,    // Complete all 18 chapters

  // Mastery Badges
  perfectKarma,     // 100% on any lesson
  steadyMind,       // 5 perfect lessons in a row
  unshakeable,      // 10 perfect lessons in a row
  wisdomKeeper,     // Master all lessons in a chapter

  // Streak Badges
  weekWarrior,      // 7-day streak
  fortnightFocus,   // 14-day streak
  monthlyMaster,    // 30-day streak
  centuryStreak,    // 100-day streak

  // Special Badges
  nightOwl,         // Complete lesson after 10 PM
  earlyBird,        // Complete lesson before 6 AM
  weekendWarrior,   // Complete on Saturday and Sunday
  reflectiveSoul,   // Complete 10 reflections
  scenarioSage,     // Get 20 scenario challenges correct
}

class Badge {
  final BadgeId id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final int xpBonus;
  final DateTime? earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.xpBonus = 50,
    this.earnedAt,
  });

  /// Create a copy with earned timestamp
  Badge markEarned() {
    return Badge(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      category: category,
      xpBonus: xpBonus,
      earnedAt: DateTime.now(),
    );
  }

  bool get isEarned => earnedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id.name,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }

  factory Badge.fromMap(Map<String, dynamic> data) {
    final badgeId = BadgeId.values.firstWhere(
      (b) => b.name == data['id'],
      orElse: () => BadgeId.firstStep,
    );
    return badgeDefinitions[badgeId]!.copyWith(
      earnedAt: data['earnedAt'] != null 
          ? DateTime.parse(data['earnedAt']) 
          : null,
    );
  }

  Badge copyWith({DateTime? earnedAt}) {
    return Badge(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      category: category,
      xpBonus: xpBonus,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}

/// All badge definitions with their unlock criteria
final Map<BadgeId, Badge> badgeDefinitions = {
  // Milestone Badges
  BadgeId.firstStep: const Badge(
    id: BadgeId.firstStep,
    name: 'First Step',
    description: 'Complete your first lesson',
    emoji: '👣',
    category: BadgeCategory.milestone,
    xpBonus: 25,
  ),
  BadgeId.seeker: const Badge(
    id: BadgeId.seeker,
    name: 'Seeker',
    description: 'Complete 10 lessons',
    emoji: '🔍',
    category: BadgeCategory.milestone,
    xpBonus: 50,
  ),
  BadgeId.warriorsHeart: const Badge(
    id: BadgeId.warriorsHeart,
    name: "Warrior's Heart",
    description: 'Complete 50 lessons',
    emoji: '⚔️',
    category: BadgeCategory.milestone,
    xpBonus: 100,
  ),
  BadgeId.devotee: const Badge(
    id: BadgeId.devotee,
    name: 'Devotee',
    description: 'Complete 100 lessons',
    emoji: '🙏',
    category: BadgeCategory.milestone,
    xpBonus: 200,
  ),
  BadgeId.liberatedSoul: const Badge(
    id: BadgeId.liberatedSoul,
    name: 'Liberated Soul',
    description: 'Complete all 18 chapters',
    emoji: '🕊️',
    category: BadgeCategory.milestone,
    xpBonus: 500,
  ),

  // Mastery Badges
  BadgeId.perfectKarma: const Badge(
    id: BadgeId.perfectKarma,
    name: 'Perfect Karma',
    description: 'Score 100% on any lesson',
    emoji: '✨',
    category: BadgeCategory.mastery,
    xpBonus: 30,
  ),
  BadgeId.steadyMind: const Badge(
    id: BadgeId.steadyMind,
    name: 'Steady Mind',
    description: 'Get 5 perfect lessons in a row',
    emoji: '🧘',
    category: BadgeCategory.mastery,
    xpBonus: 75,
  ),
  BadgeId.unshakeable: const Badge(
    id: BadgeId.unshakeable,
    name: 'Unshakeable',
    description: 'Get 10 perfect lessons in a row',
    emoji: '🔥',
    category: BadgeCategory.mastery,
    xpBonus: 150,
  ),
  BadgeId.wisdomKeeper: const Badge(
    id: BadgeId.wisdomKeeper,
    name: 'Wisdom Keeper',
    description: 'Master all lessons in a chapter',
    emoji: '📜',
    category: BadgeCategory.mastery,
    xpBonus: 100,
  ),

  // Streak Badges
  BadgeId.weekWarrior: const Badge(
    id: BadgeId.weekWarrior,
    name: 'Week Warrior',
    description: 'Maintain a 7-day streak',
    emoji: '🗓️',
    category: BadgeCategory.streak,
    xpBonus: 50,
  ),
  BadgeId.fortnightFocus: const Badge(
    id: BadgeId.fortnightFocus,
    name: 'Fortnight Focus',
    description: 'Maintain a 14-day streak',
    emoji: '💪',
    category: BadgeCategory.streak,
    xpBonus: 100,
  ),
  BadgeId.monthlyMaster: const Badge(
    id: BadgeId.monthlyMaster,
    name: 'Monthly Master',
    description: 'Maintain a 30-day streak',
    emoji: '🏆',
    category: BadgeCategory.streak,
    xpBonus: 200,
  ),
  BadgeId.centuryStreak: const Badge(
    id: BadgeId.centuryStreak,
    name: 'Century Streak',
    description: 'Maintain a 100-day streak',
    emoji: '💯',
    category: BadgeCategory.streak,
    xpBonus: 500,
  ),

  // Special Badges
  BadgeId.nightOwl: const Badge(
    id: BadgeId.nightOwl,
    name: 'Night Owl',
    description: 'Complete a lesson after 10 PM',
    emoji: '🦉',
    category: BadgeCategory.special,
    xpBonus: 25,
  ),
  BadgeId.earlyBird: const Badge(
    id: BadgeId.earlyBird,
    name: 'Early Bird',
    description: 'Complete a lesson before 6 AM',
    emoji: '🐦',
    category: BadgeCategory.special,
    xpBonus: 25,
  ),
  BadgeId.weekendWarrior: const Badge(
    id: BadgeId.weekendWarrior,
    name: 'Weekend Warrior',
    description: 'Complete lessons on both Saturday and Sunday',
    emoji: '🎉',
    category: BadgeCategory.special,
    xpBonus: 40,
  ),
  BadgeId.reflectiveSoul: const Badge(
    id: BadgeId.reflectiveSoul,
    name: 'Reflective Soul',
    description: 'Complete 10 reflection prompts',
    emoji: '🪞',
    category: BadgeCategory.special,
    xpBonus: 75,
  ),
  BadgeId.scenarioSage: const Badge(
    id: BadgeId.scenarioSage,
    name: 'Scenario Sage',
    description: 'Answer 20 scenario challenges correctly',
    emoji: '🎯',
    category: BadgeCategory.special,
    xpBonus: 100,
  ),
};

/// XP thresholds for each level (index = level number)
const List<int> levelThresholds = [
  0,      // Level 1: 0 XP
  100,    // Level 2: 100 XP
  250,    // Level 3: 250 XP
  500,    // Level 4: 500 XP
  850,    // Level 5: 850 XP
  1300,   // Level 6: 1300 XP
  1900,   // Level 7: 1900 XP
  2600,   // Level 8: 2600 XP
  3500,   // Level 9: 3500 XP
  4500,   // Level 10: 4500 XP
  5700,   // Level 11
  7000,   // Level 12
  8500,   // Level 13
  10200,  // Level 14
  12000,  // Level 15
  14000,  // Level 16
  16200,  // Level 17
  18500,  // Level 18 (Enlightened)
];

/// Level titles matching the spiritual journey
const List<String> levelTitles = [
  'Beginner',           // 1
  'Curious Seeker',     // 2
  'Devoted Student',    // 3
  'Aspiring Yogi',      // 4
  'Karma Practitioner', // 5
  'Bhakti Devotee',     // 6
  'Jnana Scholar',      // 7
  'Raja Yogi',          // 8
  'Wisdom Seeker',      // 9
  'Inner Warrior',      // 10
  'Mind Master',        // 11
  'Self-Realized',      // 12
  'Divine Servant',     // 13
  'Enlightened Soul',   // 14
  'Spiritual Guide',    // 15
  'Master Teacher',     // 16
  'Liberated Being',    // 17
  'One with Krishna',   // 18
];

/// Calculate level from total XP
int calculateLevel(int xp) {
  for (int i = levelThresholds.length - 1; i >= 0; i--) {
    if (xp >= levelThresholds[i]) {
      return i + 1;
    }
  }
  return 1;
}

/// Get XP needed for next level
int xpForNextLevel(int currentXp) {
  final currentLevel = calculateLevel(currentXp);
  if (currentLevel >= levelThresholds.length) {
    return 0; // Max level
  }
  return levelThresholds[currentLevel] - currentXp;
}

/// Get progress percentage towards next level (0.0 - 1.0)
double levelProgress(int currentXp) {
  final currentLevel = calculateLevel(currentXp);
  if (currentLevel >= levelThresholds.length) {
    return 1.0; // Max level
  }
  final currentLevelXp = levelThresholds[currentLevel - 1];
  final nextLevelXp = levelThresholds[currentLevel];
  final xpInLevel = currentXp - currentLevelXp;
  final xpNeeded = nextLevelXp - currentLevelXp;
  return xpInLevel / xpNeeded;
}
