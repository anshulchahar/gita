import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/question.dart';

/// Scenario Challenge Activity - Real-life dilemma solving
/// 
/// This activity presents a real-life scenario where the user must apply
/// Gita teachings to choose the wisest course of action. It helps bridge
/// ancient wisdom with modern life situations.
class ScenarioChallengeActivity extends StatefulWidget {
  final QuestionContent content;
  final Function(int selectedIndex, bool isCorrect) onAnswer;
  final int? selectedAnswer;
  final bool showFeedback;

  const ScenarioChallengeActivity({
    super.key,
    required this.content,
    required this.onAnswer,
    this.selectedAnswer,
    this.showFeedback = false,
  });

  @override
  State<ScenarioChallengeActivity> createState() => _ScenarioChallengeActivityState();
}

class _ScenarioChallengeActivityState extends State<ScenarioChallengeActivity> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnswered = widget.selectedAnswer != null;
    
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scenario header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.space12,
                vertical: Spacing.space8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.psychology_rounded,
                    color: theme.colorScheme.onSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: Spacing.space8),
                  Text(
                    'Life Scenario',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.space16),
            
            // Scenario context if available
            if (widget.content.scenarioContext.isNotEmpty) ...[
              Text(
                widget.content.scenarioContext,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: Spacing.space12),
            ],
            
            // Scenario description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.space16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.content.scenarioDescription.isNotEmpty
                    ? widget.content.scenarioDescription
                    : widget.content.questionText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: Spacing.space16),
            
            // Question prompt
            Text(
              'What would you do?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: Spacing.space12),
            
            // Options
            ...widget.content.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = widget.selectedAnswer == index;
              final isCorrect = index == widget.content.correctAnswerIndex;
              final showCorrect = widget.showFeedback && isCorrect;
              final showWrong = widget.showFeedback && isSelected && !isCorrect;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.space8),
                child: _buildOptionCard(
                  context,
                  option: option,
                  index: index,
                  isSelected: isSelected,
                  isCorrect: showCorrect,
                  isWrong: showWrong,
                  enabled: !isAnswered,
                  onTap: () {
                    if (!isAnswered) {
                      widget.onAnswer(
                        index,
                        index == widget.content.correctAnswerIndex,
                      );
                    }
                  },
                ),
              );
            }),
            
            // Wisdom teaching (shown after answering)
            if (widget.showFeedback && widget.content.scenarioTeaching.isNotEmpty) ...[
              const SizedBox(height: Spacing.space16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.space16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: Spacing.space8),
                        Text(
                          'Wisdom of Krishna',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.space8),
                    Text(
                      widget.content.scenarioTeaching,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;
    
    if (isCorrect) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green.shade700;
      trailingIcon = Icons.check_circle;
    } else if (isWrong) {
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
      textColor = Colors.red.shade700;
      trailingIcon = Icons.cancel;
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onSurface;
    } else {
      backgroundColor = theme.colorScheme.surface;
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
      textColor = theme.colorScheme.onSurface;
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(Spacing.space16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (isCorrect ? Colors.green : isWrong ? Colors.red : theme.colorScheme.primary)
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D...
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.space12),
              Expanded(
                child: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
