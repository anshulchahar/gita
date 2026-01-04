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
import '../../domain/models/shloka.dart';
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
            const SizedBox(height: Spacing.space16),
            Icon(Icons.book_outlined, size: 80, color: Theme.of(context).colorScheme.outline),
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
          onInfoTap: () => _showShlokasDialog(context, chapter, lessons),
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

  void _showShlokasDialog(BuildContext context, Chapter chapter, List<Lesson> lessons) {
    // Collect all shlokas from lessons
    final allShlokas = <int>{};
    for (final lesson in lessons) {
      allShlokas.addAll(lesson.shlokasCovered);
    }
    final sortedShlokas = allShlokas.toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.space16),
                child: Column(
                  children: [
                    Text(
                      '📖 Shlokas in Chapter ${chapter.chapterNumber}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.space4),
                    Text(
                      chapter.chapterNameEn,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: Spacing.space8),
                    Text(
                      '${sortedShlokas.length} shlokas covered',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: Spacing.space24),
              // Shlokas list
              Expanded(
                child: sortedShlokas.isEmpty
                    ? Center(
                        child: Text(
                          'No shlokas available yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.space16),
                        itemCount: sortedShlokas.length,
                        itemBuilder: (context, index) {
                          final shlokaNum = sortedShlokas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: Spacing.space8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$shlokaNum',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text('Shloka ${chapter.chapterNumber}.$shlokaNum'),
                              subtitle: const Text('Tap to read and recite'),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              onTap: () {
                                final shloka = ShlokaRepository.getShloka(chapter.chapterNumber, shlokaNum);
                                if (shloka != null) {
                                  _showShlokaDetail(context, shloka);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Content for Shloka ${chapter.chapterNumber}.$shlokaNum coming soon!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShlokaDetail(BuildContext context, Shloka shloka) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.space12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(Spacing.space24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.space12,
                            vertical: Spacing.space8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Shloka ${shloka.chapter}.${shloka.verse}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.space32),
                    
                    // Sanskrit
                    Text(
                      'SANSKRIT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.space8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Spacing.space16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        shloka.sanskrit,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                          // fontFamily: 'NotoSansDevanagari', 
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: Spacing.space24),
                    
                    // Transliteration
                    Text(
                      'PRONUNCIATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.space8),
                    Text(
                      shloka.transliteration,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: Spacing.space24),
                    const Divider(),
                    const SizedBox(height: Spacing.space24),
                    
                    // Translation
                    Text(
                      'MEANING',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.space8),
                    Text(
                      shloka.translation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                    
                    if (shloka.wordMeanings != null) ...[
                      const SizedBox(height: Spacing.space24),
                      Text(
                        'WORD MEANINGS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Spacing.space8),
                      Text(
                        shloka.wordMeanings!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: Spacing.space48),
                    
                    // Action Buttons (Play Audio - Placeholder)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Audio recitation coming soon!')),
                             );
                          },
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Listen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.space32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
