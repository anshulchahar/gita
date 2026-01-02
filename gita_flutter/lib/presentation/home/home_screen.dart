import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/lesson.dart';
import '../components/krishna_mascot.dart';
import '../components/lesson_node_components.dart';

/// Home screen state
class HomeState {
  final bool isLoading;
  final String? error;
  final List<Chapter> chapters;
  final Map<String, List<Lesson>> chapterLessons;
  final Set<String> unlockedChapters;
  final Set<String> unlockedLessons;
  final Set<String> completedLessons;
  final int currentStreak;
  final int gems;
  final int energy;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.chapters = const [],
    this.chapterLessons = const {},
    this.unlockedChapters = const {},
    this.unlockedLessons = const {},
    this.completedLessons = const {},
    this.currentStreak = 0,
    this.gems = 0,
    this.energy = 5,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<Chapter>? chapters,
    Map<String, List<Lesson>>? chapterLessons,
    Set<String>? unlockedChapters,
    Set<String>? unlockedLessons,
    Set<String>? completedLessons,
    int? currentStreak,
    int? gems,
    int? energy,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      chapters: chapters ?? this.chapters,
      chapterLessons: chapterLessons ?? this.chapterLessons,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
      unlockedLessons: unlockedLessons ?? this.unlockedLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      currentStreak: currentStreak ?? this.currentStreak,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
    );
  }
}

/// Home screen controller
class HomeController extends StateNotifier<HomeState> {
  final ContentRepository _contentRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  HomeController(
    this._contentRepository,
    this._userRepository,
    this._authRepository,
  ) : super(const HomeState(isLoading: true)) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load chapters
      final chapters = await _contentRepository.getChapters();

      // Load lessons for each chapter
      final chapterLessons = <String, List<Lesson>>{};
      for (final chapter in chapters) {
        final lessons = await _contentRepository.getLessons(chapter.chapterId);
        chapterLessons[chapter.chapterId] = lessons;
      }

      // Calculate unlocked chapters and lessons
      final unlockedChapters = <String>{};
      final unlockedLessons = <String>{};
      var completedLessons = <String>{};
      var currentStreak = 0;
      var gems = 0;
      var energy = 5;

      // Get user data if logged in
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final user = await _userRepository.getUser(userId);
        if (user != null) {
          completedLessons = user.progress.keys.toSet();
          currentStreak = user.gamification.currentStreak;
          gems = user.gamification.gems;
          energy = user.gamification.energy;
        }
      }

      // First chapter is always unlocked
      if (chapters.isNotEmpty) {
        unlockedChapters.add(chapters.first.chapterId);
      }

      // Unlock lessons based on completion
      for (int i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        final lessons = chapterLessons[chapter.chapterId] ?? [];
        
        // First lesson of first chapter is always unlocked
        if (i == 0 && lessons.isNotEmpty) {
          unlockedLessons.add(lessons.first.lessonId);
          unlockedChapters.add(chapter.chapterId);
        }

        // Unlock subsequent lessons based on completion
        for (int j = 0; j < lessons.length; j++) {
          final lesson = lessons[j];
          if (j == 0 && i == 0) continue; // Already handled

          // Check if previous lesson is completed
          if (j > 0) {
            final prevLesson = lessons[j - 1];
            if (completedLessons.contains(prevLesson.lessonId)) {
              unlockedLessons.add(lesson.lessonId);
            }
          } else if (i > 0) {
            // First lesson of new chapter - check if previous chapter is complete
            final prevChapter = chapters[i - 1];
            final prevLessons = chapterLessons[prevChapter.chapterId] ?? [];
            if (prevLessons.isNotEmpty &&
                completedLessons.contains(prevLessons.last.lessonId)) {
              unlockedLessons.add(lesson.lessonId);
              unlockedChapters.add(chapter.chapterId);
            }
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        chapters: chapters,
        chapterLessons: chapterLessons,
        unlockedChapters: unlockedChapters,
        unlockedLessons: unlockedLessons,
        completedLessons: completedLessons,
        currentStreak: currentStreak,
        gems: gems,
        energy: energy,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void signOut() {
    _authRepository.signOut();
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    ref.watch(contentRepositoryProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(authRepositoryProvider),
  );
});

/// Home screen widget
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _adminClickCount = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Streak
            Row(
              children: [
                const Text('🔥'),
                const SizedBox(width: 4),
                Text('${state.currentStreak}'),
              ],
            ),
            // Gems
            Row(
              children: [
                const Text('💎'),
                const SizedBox(width: 4),
                Text('${state.gems}'),
              ],
            ),
            // Energy
            Row(
              children: [
                const Text('⚡'),
                const SizedBox(width: 4),
                Text('${state.energy}'),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: Spacing.space8),
                  Text(
                    ref.read(authRepositoryProvider).currentUser?.email ?? 'Guest',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Seeker of Wisdom',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Show Sign In for guests, Logout for authenticated users
            if (ref.read(authRepositoryProvider).currentUser == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign In'),
                subtitle: const Text('Save your progress'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(Routes.login);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(homeControllerProvider.notifier).signOut();
                  context.go(Routes.login);
                },
              ),
          ],
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: Spacing.space8),
            Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.space16),
            FilledButton(
              onPressed: () => ref.read(homeControllerProvider.notifier).loadData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const KrishnaMascot(
              emotion: KrishnaEmotion.neutral,
              animation: KrishnaAnimation.idleFloat,
              size: 120,
            ),
            const SizedBox(height: Spacing.space16),
            Text(
              'No chapters available yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.space8),
            Text(
              'Content will be available soon!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: Spacing.space24),
            // Hidden admin access
            GestureDetector(
              onTap: () {
                _adminClickCount++;
                if (_adminClickCount >= 5) {
                  _adminClickCount = 0;
                  context.push(Routes.admin);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.space8),
                child: Text(
                  'Tap here to refresh',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.space16),
      children: [
        const SizedBox(height: Spacing.space8),
        // Welcome with Krishna
        Center(
          child: Column(
            children: [
              const KrishnaMascot(
                emotion: KrishnaEmotion.happy,
                animation: KrishnaAnimation.idleFloat,
                size: 80,
              ),
              const SizedBox(height: Spacing.space8),
              Text(
                KrishnaMessages.random(KrishnaMessages.welcome),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.space16),

        // Chapters and lessons
        for (var chapterIndex = 0; chapterIndex < state.chapters.length; chapterIndex++) ...[
          _buildChapterSection(context, state, chapterIndex),
        ],

        const SizedBox(height: Spacing.space32),
      ],
    );
  }

  Widget _buildChapterSection(BuildContext context, HomeState state, int chapterIndex) {
    final chapter = state.chapters[chapterIndex];
    final lessons = state.chapterLessons[chapter.chapterId] ?? [];

    return Column(
      children: [
        // Section header
        SectionHeader(
          sectionNumber: chapter.chapterNumber,
          unitNumber: chapter.chapterNumber,
          description: chapter.chapterNameEn,
        ),

        // Lessons
        for (var lessonIndex = 0; lessonIndex < lessons.length; lessonIndex++) ...[
          if (lessonIndex > 0) ProgressPath(
            isUnlocked: state.unlockedLessons.contains(lessons[lessonIndex].lessonId),
          ),
          _buildLessonNode(context, state, chapter, lessons[lessonIndex], lessonIndex),
          
          // Add milestone every 3 lessons
          if ((lessonIndex + 1) % 3 == 0 && lessonIndex < lessons.length - 1) ...[
            ProgressPath(
              isUnlocked: state.completedLessons.contains(lessons[lessonIndex].lessonId),
            ),
            ChapterMilestone(
              type: MilestoneType.values[(lessonIndex ~/ 3) % 3],
              isUnlocked: state.completedLessons.contains(lessons[lessonIndex].lessonId),
            ),
          ],
        ],

        // Chapter completion trophy
        if (lessons.isNotEmpty) ...[
          ProgressPath(
            isUnlocked: lessons.every((l) => state.completedLessons.contains(l.lessonId)),
            height: 40,
          ),
          ChapterMilestone(
            type: MilestoneType.trophy,
            isUnlocked: lessons.every((l) => state.completedLessons.contains(l.lessonId)),
          ),
        ],
        
        if (chapterIndex < state.chapters.length - 1)
          const SizedBox(height: Spacing.space24),
      ],
    );
  }

  Widget _buildLessonNode(
    BuildContext context,
    HomeState state,
    Chapter chapter,
    Lesson lesson,
    int lessonIndex,
  ) {
    final isUnlocked = state.unlockedLessons.contains(lesson.lessonId);
    final isCompleted = state.completedLessons.contains(lesson.lessonId);
    final lessons = state.chapterLessons[chapter.chapterId] ?? [];
    
    final isCurrent = isUnlocked &&
        !isCompleted &&
        lessons.take(lessonIndex).every(
          (l) => state.completedLessons.contains(l.lessonId),
        );

    return LessonNode(
      lessonNumber: lesson.lessonNumber,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      description: lesson.lessonNameEn,
      onTap: () {
        context.push(Routes.lessonPath(chapter.chapterId, lesson.lessonId));
      },
    );
  }
}
