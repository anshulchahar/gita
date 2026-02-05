import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../components/krishna_mascot.dart';
import '../components/question_footer.dart';
import 'practice_controller.dart';

/// Practice screen for daily spaced repetition review
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    // Load practice session on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceControllerProvider.notifier).loadPracticeSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceControllerProvider);
    final controller = ref.read(practiceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Practice'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          // Progress indicator
          if (state.practiceQuestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.space16),
              child: Center(
                child: Text(
                  '${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, state, controller),
    );
  }

  Widget _buildBody(BuildContext context, PracticeState state, PracticeController controller) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: Spacing.space16),
            Text('Finding questions to review...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return _buildErrorView(context, state.error!, controller);
    }

    if (state.showResults) {
      return _buildResultsView(context, state, controller);
    }

    if (state.practiceQuestions.isEmpty) {
      return _buildEmptyView(context);
    }

    return _buildPracticeView(context, state, controller);
  }

  Widget _buildErrorView(BuildContext context, String error, PracticeController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Spacing.space16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Spacing.space24),
            ElevatedButton(
              onPressed: () => controller.loadPracticeSession(),
              child: const Text('Try Again'),
            ),
            const SizedBox(height: Spacing.space12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KrishnaMascot(
              size: 120,
              emotion: KrishnaEmotion.encouraging,
              animation: KrishnaAnimation.idleFloat,
            ),
            const SizedBox(height: Spacing.space24),
            Text(
              'No lessons to review!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.space12),
            Text(
              'Complete some lessons first, then come back for practice.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.space24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go to Lessons'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeView(BuildContext context, PracticeState state, PracticeController controller) {
    return Stack(
      children: [
        Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            
            // Practice content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.space16,
                          Spacing.space8,
                          Spacing.space16,
                          100, // Bottom padding for footer
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuestionCard(context, state, controller),
                            const SizedBox(height: Spacing.space16),
                            
                            // Feedback card
                            if (state.showFeedback)
                              _buildFeedbackCard(context, state),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        // Footer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: QuestionFooter(
            onHintTap: null, // No hints in practice mode
            isCheckEnabled: controller.getSelectedOptionForCurrentQuestion() != null,
            onCheckTap: controller.getSelectedOptionForCurrentQuestion() != null
                ? () => controller.submitAnswer()
                : null,
            showNextButton: state.showFeedback || controller.isCurrentQuestionAnswered(),
            nextButtonText: state.currentQuestionIndex < state.practiceQuestions.length - 1
                ? 'Next'
                : 'Finish',
            onNextTap: () {
              if (state.showFeedback) {
                controller.hideFeedback();
              }
              controller.nextQuestion();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, PracticeState state, PracticeController controller) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return const SizedBox();

    final selectedAnswer = controller.getSelectedOptionForCurrentQuestion();
    final isAnswered = controller.isCurrentQuestionAnswered();
    final correctAnswer = isAnswered ? controller.getCorrectOptionForCurrentQuestion() : null;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.space8,
                vertical: Spacing.space4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Review',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: Spacing.space12),
            
            // Question text
            Text(
              currentQuestion.content.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.space16),
            
            // Options
            ...currentQuestion.content.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedAnswer == index;
              final isCorrect = isAnswered && correctAnswer == index;
              final isWrong = isAnswered && isSelected && correctAnswer != index;

              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.space8),
                child: _buildOptionCard(
                  context,
                  option: option,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  isWrong: isWrong,
                  enabled: !isAnswered,
                  onTap: () => controller.selectAnswer(currentQuestion.questionId, index),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String option,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color borderColor;

    if (isCorrect) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    } else if (isWrong) {
      backgroundColor = Theme.of(context).colorScheme.errorContainer;
      borderColor = Theme.of(context).colorScheme.error;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      borderColor = Theme.of(context).colorScheme.secondary;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surface;
      borderColor = Theme.of(context).colorScheme.outline;
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(Spacing.space12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (isCorrect)
              Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
            if (isWrong)
              Icon(Icons.close, color: Theme.of(context).colorScheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, PracticeState state) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return const SizedBox();

    final result = state.questionResults[currentQuestion.questionId];
    if (result == null) return const SizedBox();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Card(
        color: result.isCorrect
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: result.isCorrect
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: Spacing.space8),
                  Text(
                    result.isCorrect ? 'Correct!' : 'Not quite...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (result.explanation.isNotEmpty) ...[
                const SizedBox(height: Spacing.space12),
                Text(
                  result.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, PracticeState state, PracticeController controller) {
    final score = state.totalQuestions > 0
        ? (state.correctCount * 100) ~/ state.totalQuestions
        : 0;

    // Determine mascot emotion based on score
    final emotion = score >= 80
        ? KrishnaEmotion.celebrating
        : score >= 50
            ? KrishnaEmotion.encouraging
            : KrishnaEmotion.thinking;

    // Save results
    controller.savePracticeResults();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.space24),
      child: Column(
        children: [
          // Mascot
          KrishnaMascot(
            size: 120,
            emotion: emotion,
            animation: KrishnaAnimation.idleFloat,
          ),
          const SizedBox(height: Spacing.space24),

          // Title
          Text(
            score >= 80
                ? 'Excellent Practice!'
                : score >= 50
                    ? 'Good Effort!'
                    : 'Keep Learning!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.space8),
          Text(
            'You reviewed ${state.lessonsCovered.length} lesson${state.lessonsCovered.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Spacing.space32),

          // Stats cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle,
                  value: '${state.correctCount}/${state.totalQuestions}',
                  label: 'Correct',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: Spacing.space12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.star,
                  value: '+${state.xpEarned}',
                  label: 'XP Earned',
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.space12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.show_chart,
                  value: '$score%',
                  label: 'Score',
                  color: score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(width: Spacing.space12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.trending_up,
                  value: '+${state.strengthGained > 0 ? state.strengthGained : 10}',
                  label: 'Strength',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: Spacing.space32),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.reset();
                controller.loadPracticeSession();
              },
              child: const Text('Practice Again'),
            ),
          ),
          const SizedBox(height: Spacing.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: Spacing.space8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
