import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/gamification_service.dart';
import '../../domain/models/question.dart';

/// State for daily practice session
class PracticeState {
  final bool isLoading;
  final String? error;
  final List<Question> practiceQuestions;
  final int currentQuestionIndex;
  final Map<String, int> selectedAnswers;
  final Map<String, QuestionResult> questionResults;
  final bool showFeedback;
  final bool showResults;
  final int correctCount;
  final int xpEarned;
  final int strengthGained;
  final List<String> lessonsCovered;

  const PracticeState({
    this.isLoading = false,
    this.error,
    this.practiceQuestions = const [],
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.questionResults = const {},
    this.showFeedback = false,
    this.showResults = false,
    this.correctCount = 0,
    this.xpEarned = 0,
    this.strengthGained = 0,
    this.lessonsCovered = const [],
  });

  PracticeState copyWith({
    bool? isLoading,
    String? error,
    List<Question>? practiceQuestions,
    int? currentQuestionIndex,
    Map<String, int>? selectedAnswers,
    Map<String, QuestionResult>? questionResults,
    bool? showFeedback,
    bool? showResults,
    int? correctCount,
    int? xpEarned,
    int? strengthGained,
    List<String>? lessonsCovered,
  }) {
    return PracticeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      practiceQuestions: practiceQuestions ?? this.practiceQuestions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      questionResults: questionResults ?? this.questionResults,
      showFeedback: showFeedback ?? this.showFeedback,
      showResults: showResults ?? this.showResults,
      correctCount: correctCount ?? this.correctCount,
      xpEarned: xpEarned ?? this.xpEarned,
      strengthGained: strengthGained ?? this.strengthGained,
      lessonsCovered: lessonsCovered ?? this.lessonsCovered,
    );
  }

  int get totalQuestions => practiceQuestions.length;
  double get progress => totalQuestions > 0 
      ? (currentQuestionIndex + 1) / totalQuestions 
      : 0;
  Question? get currentQuestion => practiceQuestions.isNotEmpty 
      ? practiceQuestions[currentQuestionIndex] 
      : null;
}

/// Controller for daily practice sessions with spaced repetition
class PracticeController extends StateNotifier<PracticeState> {
  final ContentRepository _contentRepository;
  final UserRepository _userRepository;
  final String _userId;

  PracticeController(
    this._contentRepository,
    this._userRepository,
    this._userId,
  ) : super(const PracticeState());

  /// Load practice session based on spaced repetition algorithm
  Future<void> loadPracticeSession({
    int questionCount = 10,
    int strengthThreshold = 70,
    int maxDaysSinceReview = 7,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get user's current gamification stats
      final user = await _userRepository.getUser(_userId);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not found',
        );
        return;
      }

      final gamification = user.gamification;

      // Find lessons needing review using spaced repetition logic
      final lessonsNeedingReview = GamificationService.getLessonsNeedingReview(
        lessonStrength: gamification.lessonStrength,
        lastPracticed: gamification.lastPracticed,
        strengthThreshold: strengthThreshold,
        maxDaysSinceReview: maxDaysSinceReview,
      );

      // Collect questions from lessons needing review
      List<Question> allQuestions = [];
      Set<String> coveredLessons = {};

      for (final lessonId in lessonsNeedingReview) {
        if (allQuestions.length >= questionCount * 2) break;
        
        try {
          final questions = await _contentRepository.getQuestions(lessonId);
          if (questions.isNotEmpty) {
            allQuestions.addAll(questions);
            coveredLessons.add(lessonId);
          }
        } catch (e) {
          // Skip lessons that fail to load
          continue;
        }
      }

      // If not enough questions from weak lessons, add from completed lessons
      if (allQuestions.length < questionCount) {
        final completedLessons = user.progress.keys.toList();
        completedLessons.shuffle();
        
        for (final lessonId in completedLessons) {
          if (allQuestions.length >= questionCount * 2) break;
          if (coveredLessons.contains(lessonId)) continue;
          
          try {
            final questions = await _contentRepository.getQuestions(lessonId);
            if (questions.isNotEmpty) {
              allQuestions.addAll(questions);
              coveredLessons.add(lessonId);
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Shuffle and limit to desired count
      allQuestions.shuffle();
      final practiceQuestions = allQuestions.take(questionCount).toList();

      if (practiceQuestions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No practice questions available. Complete some lessons first!',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        practiceQuestions: practiceQuestions,
        lessonsCovered: coveredLessons.toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load practice: ${e.toString()}',
      );
    }
  }

  /// Select an answer for current question
  void selectAnswer(String questionId, int answerIndex) {
    final newAnswers = Map<String, int>.from(state.selectedAnswers);
    newAnswers[questionId] = answerIndex;
    state = state.copyWith(selectedAnswers: newAnswers);
  }

  /// Submit the current answer and show feedback
  void submitAnswer() {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) return;

    final selectedAnswer = state.selectedAnswers[currentQuestion.questionId];
    if (selectedAnswer == null) return;

    final isCorrect = selectedAnswer == currentQuestion.content.correctAnswerIndex;
    
    // Calculate XP for this question
    final xp = GamificationService.calculateXpForActivity(
      type: currentQuestion.type,
      isCorrect: isCorrect,
      isFirstAttempt: true,
      streakDays: 0, // TODO: Get from user stats
    );

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

    state = state.copyWith(
      questionResults: newResults,
      showFeedback: true,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      xpEarned: state.xpEarned + (isCorrect ? xp : (xp ~/ 3)), // Partial XP for wrong
    );
  }

  /// Hide feedback and move to next question
  void hideFeedback() {
    state = state.copyWith(showFeedback: false);
  }

  /// Move to next question or show results
  void nextQuestion() {
    if (state.currentQuestionIndex < state.practiceQuestions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        showFeedback: false,
      );
    } else {
      // Practice complete - show results
      state = state.copyWith(showResults: true, showFeedback: false);
    }
  }

  /// Get selected option for current question
  int? getSelectedOptionForCurrentQuestion() {
    final question = state.currentQuestion;
    if (question == null) return null;
    return state.selectedAnswers[question.questionId];
  }

  /// Check if current question is answered
  bool isCurrentQuestionAnswered() {
    final question = state.currentQuestion;
    if (question == null) return false;
    return state.questionResults.containsKey(question.questionId);
  }

  /// Get correct option for current question
  int? getCorrectOptionForCurrentQuestion() {
    return state.currentQuestion?.content.correctAnswerIndex;
  }

  /// Save practice results and update user stats
  Future<void> savePracticeResults() async {
    try {
      // Calculate score as percentage
      final score = state.totalQuestions > 0
          ? (state.correctCount * 100) ~/ state.totalQuestions
          : 0;

      // Update lesson strength for each covered lesson
      final strengthGained = score >= 70 ? 15 : (score >= 50 ? 10 : 5);

      // Update user's gamification stats
      await _userRepository.addWisdomPoints(_userId, state.xpEarned);

      // Update lesson practice timestamps
      final now = DateTime.now();
      for (final lessonId in state.lessonsCovered) {
        await _userRepository.updateLessonPractice(_userId, lessonId, now, score);
      }

      state = state.copyWith(strengthGained: strengthGained);
    } catch (e) {
      // Silently handle save errors - practice was still completed
    }
  }

  /// Reset practice session
  void reset() {
    state = const PracticeState();
  }
}

/// Provider for practice controller
final practiceControllerProvider = StateNotifierProvider.autoDispose<PracticeController, PracticeState>((ref) {
  final contentRepo = ref.watch(contentRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  // TODO: Get actual user ID from auth
  return PracticeController(contentRepo, userRepo, '');
});
