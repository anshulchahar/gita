import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Types of milestones in the lesson progression
enum MilestoneType {
  treasure,
  character,
  krishna,
  trophy,
}

/// Section header for chapter groupings - Duolingo style
class SectionHeader extends StatelessWidget {
  final int sectionNumber;
  final int unitNumber;
  final String description;
  final VoidCallback? onInfoTap;

  const SectionHeader({
    super.key,
    required this.sectionNumber,
    required this.unitNumber,
    required this.description,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(
        Spacing.space16,
        Spacing.space24,
        Spacing.space16,
        Spacing.space16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECTION $sectionNumber, UNIT $unitNumber',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: Spacing.space4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Shloka info icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 22,
              ),
              onPressed: onInfoTap,
              tooltip: 'View shlokas in this unit',
            ),
          ),
        ],
      ),
    );
  }
}

/// Lesson node in the progression tree
class LessonNode extends StatelessWidget {
  final int lessonNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final String description;
  final VoidCallback onTap;

  const LessonNode({
    super.key,
    required this.lessonNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.description,
    required this.onTap,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.primary;
    } else if (isCurrent) {
      return Theme.of(context).colorScheme.secondary;
    } else if (isUnlocked) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    } else {
      return Theme.of(context).colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap, 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 96 : 80,
            height: isCurrent ? 96 : 80,
            decoration: BoxDecoration(
              color: _getBackgroundColor(context),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    )
                  : Border(
                      bottom: BorderSide(
                        color: _getShadowColor(context),
                        width: 8,
                      ),
                    ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner highlight/shadow for 3D effect
                if (!isCompleted && isUnlocked)
                  Positioned(
                    top: 10,
                    left: 15,
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                
                Center(
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 40,
                        )
                      : isUnlocked
                          ? Icon(
                              Icons.star_rounded,
                              color: isCompleted || isCurrent
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                              size: 40,
                            )
                          : Icon(
                              Icons.lock_rounded,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              size: 32,
                            ),
                ),
                
                // Stars for completed/mastered lessons could go here
                if (isCompleted)
                  Positioned(
                    bottom: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) => Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Colors.amber, // Or theme color
                      )),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getShadowColor(BuildContext context) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.6); // Darker shade
    } else if (isCurrent) {
        return Theme.of(context).colorScheme.secondary.withOpacity(0.6);
    } else if (isUnlocked) {
      return Theme.of(context).colorScheme.outline;
    } else {
      return Colors.grey.shade400;
    }
  }
}

/// Progress path connecting lesson nodes
class ProgressPath extends StatelessWidget {
  final bool isUnlocked;
  final double height;

  const ProgressPath({
    super.key,
    required this.isUnlocked,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Chapter milestone (treasure, character, trophy)
class ChapterMilestone extends StatelessWidget {
  final MilestoneType type;
  final bool isUnlocked;

  const ChapterMilestone({
    super.key,
    required this.type,
    required this.isUnlocked,
  });

  String _getEmoji() {
    switch (type) {
      case MilestoneType.treasure:
        return '📦';
      case MilestoneType.character:
        return '🧘';
      case MilestoneType.krishna:
        return '🪈';
      case MilestoneType.trophy:
        return '🏆';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFD700)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          _getEmoji(),
          style: TextStyle(
            fontSize: 28,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
      ),
    );
  }
}
