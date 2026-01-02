import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/question.dart';
import '../../domain/models/user.dart';
import '../components/krishna_mascot.dart';

/// Lesson screen state
class LessonState {
  final bool isLoading;
  final String? error;
  final Lesson? lesson;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, int> selectedAnswers;
  final Map<String, QuestionResult> questionResults;
  final int score;
  final bool showResults;
  final bool showFeedback;
  final bool isSavingProgress;
  final bool progressSaved;
  final int xpEarned;

  const LessonState({
    this.isLoading = false,
    this.error,
    this.lesson,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.questionResults = const {},
    this.score = 0,
    this.showResults = false,
    this.showFeedback = false,
    this.isSavingProgress = false,
    this.progressSaved = false,
    this.xpEarned = 0,
  });

  LessonState copyWith({
    bool? isLoading,
    String? error,
    Lesson? lesson,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, int>? selectedAnswers,
    Map<String, QuestionResult>? questionResults,
    int? score,
    bool? showResults,
    bool? showFeedback,
    bool? isSavingProgress,
    bool? progressSaved,
    int? xpEarned,
  }) {
    return LessonState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lesson: lesson ?? this.lesson,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      questionResults: questionResults ?? this.questionResults,
      score: score ?? this.score,
      showResults: showResults ?? this.showResults,
      showFeedback: showFeedback ?? this.showFeedback,
      isSavingProgress: isSavingProgress ?? this.isSavingProgress,
      progressSaved: progressSaved ?? this.progressSaved,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}

/// Lesson screen controller
class LessonController extends StateNotifier<LessonState> {
  final ContentRepository _contentRepository;
  final UserRepository _userRepository;

  LessonController(
    this._contentRepository,
    this._userRepository,
  ) : super(const LessonState());

  Future<void> loadLesson(String chapterId, String lessonId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final lesson = await _contentRepository.getLesson(lessonId);
      final questions = await _contentRepository.getQuestions(lessonId);

      state = state.copyWith(
        isLoading: false,
        lesson: lesson,
        questions: questions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    final newSelectedAnswers = Map<String, int>.from(state.selectedAnswers);
    newSelectedAnswers[questionId] = optionIndex;
    state = state.copyWith(selectedAnswers: newSelectedAnswers);
  }

  void submitAnswer() {
    if (state.questions.isEmpty) return;

    final currentQuestion = state.questions[state.currentQuestionIndex];
    final selectedAnswer = state.selectedAnswers[currentQuestion.questionId];
    if (selectedAnswer == null) return;

    final isCorrect = selectedAnswer == currentQuestion.content.correctAnswerIndex;
    
    final result = QuestionResult(
      questionId: currentQuestion.questionId,
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: currentQuestion.content.correctAnswerIndex,
      explanation: currentQuestion.content.explanation,
      realLifeApplication: currentQuestion.content.realLifeApplication,
    );

    final newResults = Map<String, QuestionResult>.from(state.questionResults);
    newResults[currentQuestion.questionId] = result;

    final newScore = state.score + (isCorrect ? 1 : 0);

    state = state.copyWith(
      questionResults: newResults,
      score: newScore,
      showFeedback: true,
    );
  }

  void hideFeedback() {
    state = state.copyWith(showFeedback: false);
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
        showFeedback: false,
      );
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        showFeedback: false,
      );
    } else {
      // Show results
      state = state.copyWith(showResults: true, showFeedback: false);
    }
  }

  int? getSelectedOptionForCurrentQuestion() {
    if (state.questions.isEmpty) return null;
    final currentQuestion = state.questions[state.currentQuestionIndex];
    return state.selectedAnswers[currentQuestion.questionId];
  }

  bool isCurrentQuestionAnswered() {
    if (state.questions.isEmpty) return false;
    final currentQuestion = state.questions[state.currentQuestionIndex];
    return state.questionResults.containsKey(currentQuestion.questionId);
  }

  int? getCorrectOptionForCurrentQuestion() {
    if (state.questions.isEmpty) return null;
    final currentQuestion = state.questions[state.currentQuestionIndex];
    return currentQuestion.content.correctAnswerIndex;
  }

  Future<void> saveLessonCompletion(
    String userId,
    String chapterId,
    String lessonId,
  ) async {
    if (state.progressSaved) return;

    try {
      state = state.copyWith(isSavingProgress: true);

      final xpEarned = (state.lesson?.xpReward ?? 50) * state.score ~/ state.questions.length;

      // Save lesson progress
      await _userRepository.saveLessonProgress(
        userId,
        lessonId,
        LessonProgress(
          completedAt: DateTime.now(),
          score: state.score,
          attempts: 1,
          timeSpent: 0,
        ),
      );

      // Add XP
      if (xpEarned > 0) {
        await _userRepository.addWisdomPoints(userId, xpEarned);
      }

      state = state.copyWith(
        isSavingProgress: false,
        progressSaved: true,
        xpEarned: xpEarned,
      );
    } catch (e) {
      state = state.copyWith(
        isSavingProgress: false,
        error: e.toString(),
      );
    }
  }

  void resetLesson() {
    state = state.copyWith(
      currentQuestionIndex: 0,
      selectedAnswers: {},
      questionResults: {},
      score: 0,
      showResults: false,
      showFeedback: false,
      isSavingProgress: false,
      progressSaved: false,
      xpEarned: 0,
    );
  }
}

final lessonControllerProvider =
    StateNotifierProvider.autoDispose<LessonController, LessonState>((ref) {
  return LessonController(
    ref.watch(contentRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

/// Lesson screen widget
class LessonScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.chapterId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lessonControllerProvider.notifier)
          .loadLesson(widget.chapterId, widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonControllerProvider);
    final userId = ref.read(authRepositoryProvider).currentUser?.uid;

    // Save progress when results are shown
    if (state.showResults && !state.progressSaved && userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(lessonControllerProvider.notifier)
            .saveLessonCompletion(userId, widget.chapterId, widget.lessonId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.lesson?.lessonNameEn ?? 'Loading...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Chapter ${widget.chapterId} - Lesson ${state.lesson?.lessonNumber ?? ""}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, LessonState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: Spacing.space8),
            Text(state.error!),
          ],
        ),
      );
    }

    if (state.showResults) {
      return _buildResultsScreen(context, state);
    }

    if (state.lesson != null) {
      return _buildLessonContent(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLessonContent(BuildContext context, LessonState state) {
    final controller = ref.read(lessonControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(Spacing.space16),
      children: [
        // Lesson info card
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesson ${state.lesson?.lessonNumber ?? ""}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: Spacing.space4),
                Text(
                  state.lesson?.lessonNameEn ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: Spacing.space8),
                Text(
                  'Answer all questions to complete this lesson',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.space16),

        // Progress indicator
        if (state.questions.isNotEmpty) ...[
          LinearProgressIndicator(
            value: (state.currentQuestionIndex + 1) / state.questions.length,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: Spacing.space4),
          Text(
            'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Spacing.space16),

          // Question card
          _buildQuestionCard(context, state),
          const SizedBox(height: Spacing.space16),

          // Feedback card
          if (state.showFeedback)
            _buildFeedbackCard(context, state),

          const SizedBox(height: Spacing.space16),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: state.currentQuestionIndex > 0 && !state.showFeedback
                    ? () => controller.previousQuestion()
                    : null,
                child: const Text('Previous'),
              ),
              if (state.showFeedback)
                FilledButton(
                  onPressed: () {
                    controller.hideFeedback();
                    controller.nextQuestion();
                  },
                  child: Text(
                    state.currentQuestionIndex < state.questions.length - 1
                        ? 'Next Question'
                        : 'View Results',
                  ),
                )
              else if (controller.isCurrentQuestionAnswered())
                FilledButton(
                  onPressed: () => controller.nextQuestion(),
                  child: Text(
                    state.currentQuestionIndex < state.questions.length - 1
                        ? 'Next'
                        : 'Finish',
                  ),
                )
              else
                FilledButton(
                  onPressed: controller.getSelectedOptionForCurrentQuestion() != null
                      ? () => controller.submitAnswer()
                      : null,
                  child: const Text('Submit'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, LessonState state) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final controller = ref.read(lessonControllerProvider.notifier);
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
            Text(
              currentQuestion.content.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.space16),
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

  Widget _buildFeedbackCard(BuildContext context, LessonState state) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final result = state.questionResults[currentQuestion.questionId];
    if (result == null) return const SizedBox.shrink();

    return Card(
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
                KrishnaMascot(
                  emotion: result.isCorrect
                      ? KrishnaEmotion.celebrating
                      : KrishnaEmotion.sad,
                  animation: result.isCorrect
                      ? KrishnaAnimation.bounce
                      : KrishnaAnimation.none,
                  size: 80,
                ),
                const SizedBox(width: Spacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            result.isCorrect ? Icons.check : Icons.close,
                            color: result.isCorrect
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: Spacing.space8),
                          Text(
                            result.isCorrect ? 'Correct! 🎉' : 'Not quite right',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.space8),
                      Text(
                        result.isCorrect
                            ? KrishnaMessages.random(KrishnaMessages.correctAnswer)
                            : KrishnaMessages.random(KrishnaMessages.wrongAnswer),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: Spacing.space32),
            if (result.explanation.isNotEmpty) ...[
              Text(
                '📖 Explanation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.space8),
              Text(result.explanation),
            ],
            if (result.realLifeApplication.isNotEmpty) ...[
              const SizedBox(height: Spacing.space16),
              Text(
                '🌟 Real-Life Application',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Spacing.space8),
              Text(result.realLifeApplication),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, LessonState state) {
    final scorePercentage = (state.score * 100) ~/ state.questions.length;
    final controller = ref.read(lessonControllerProvider.notifier);

    KrishnaEmotion emotion;
    KrishnaAnimation animation;
    String message;

    if (scorePercentage >= 90) {
      emotion = KrishnaEmotion.celebrating;
      animation = KrishnaAnimation.bounce;
      message = KrishnaMessages.random(KrishnaMessages.highScore);
    } else if (scorePercentage >= 70) {
      emotion = KrishnaEmotion.happy;
      animation = KrishnaAnimation.pulse;
      message = KrishnaMessages.random(KrishnaMessages.mediumScore);
    } else {
      emotion = KrishnaEmotion.sad;
      animation = KrishnaAnimation.idleFloat;
      message = KrishnaMessages.random(KrishnaMessages.lowScore);
    }

    return ListView(
      padding: const EdgeInsets.all(Spacing.space24),
      children: [
        Center(
          child: Column(
            children: [
              KrishnaMascot(
                emotion: emotion,
                animation: animation,
                size: 150,
              ),
              const SizedBox(height: Spacing.space16),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.space16),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.space24),
        Text(
          'Lesson Complete!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.space24),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.space24),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.space8),
                Text(
                  '${state.score} / ${state.questions.length}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Spacing.space8),
                Text(
                  '$scorePercentage% Correct',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.progressSaved && state.xpEarned > 0) ...[
                  const Divider(height: Spacing.space32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: Spacing.space8),
                      Text(
                        '+${state.xpEarned} Wisdom Points',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (state.isSavingProgress) ...[
                  const SizedBox(height: Spacing.space16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: Spacing.space8),
                      Text(
                        'Saving progress...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.space32),
        FilledButton(
          onPressed: () => controller.resetLesson(),
          child: const Text('Retry Lesson'),
        ),
        const SizedBox(height: Spacing.space12),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}
