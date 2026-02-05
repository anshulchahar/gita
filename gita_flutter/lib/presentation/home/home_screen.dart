import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/journey.dart';
import '../../domain/models/section.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/shloka.dart';
import '../components/lesson_node_components.dart';
import '../components/sarthi_footer.dart';
import 'sarthi_controller.dart';

/// Home screen state
class HomeState {
  final bool isLoading;
  final String? error;
  final List<Journey> journeys;
  final List<Chapter> chapters;
  final Map<String, List<Section>> chapterSections;
  final Map<String, List<Lesson>> chapterLessons;
  final Set<String> unlockedChapters;
  final Set<String> unlockedLessons;
  final Set<String> completedLessons;
  final Map<String, int> lessonScores; // lessonId -> score (number of correct answers)
  final int currentStreak;
  final int gems;
  final int energy;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.journeys = const [],
    this.chapters = const [],
    this.chapterSections = const {},
    this.chapterLessons = const {},
    this.unlockedChapters = const {},
    this.unlockedLessons = const {},
    this.completedLessons = const {},
    this.lessonScores = const {},
    this.currentStreak = 0,
    this.gems = 0,
    this.energy = 5,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<Journey>? journeys,
    List<Chapter>? chapters,
    Map<String, List<Section>>? chapterSections,
    Map<String, List<Lesson>>? chapterLessons,
    Set<String>? unlockedChapters,
    Set<String>? unlockedLessons,
    Set<String>? completedLessons,
    Map<String, int>? lessonScores,
    int? currentStreak,
    int? gems,
    int? energy,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      journeys: journeys ?? this.journeys,
      chapters: chapters ?? this.chapters,
      chapterSections: chapterSections ?? this.chapterSections,
      chapterLessons: chapterLessons ?? this.chapterLessons,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
      unlockedLessons: unlockedLessons ?? this.unlockedLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      lessonScores: lessonScores ?? this.lessonScores,
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

      // Load journeys and chapters
      final journeys = await _contentRepository.getJourneys();
      final chapters = await _contentRepository.getChapters();

      // Load sections and lessons for each chapter
      final chapterSections = <String, List<Section>>{};
      final chapterLessons = <String, List<Lesson>>{};
      for (final chapter in chapters) {
        final sections = await _contentRepository.getSections(chapter.chapterId);
        final lessons = await _contentRepository.getLessons(chapter.chapterId);
        
        chapterSections[chapter.chapterId] = sections;
        chapterLessons[chapter.chapterId] = lessons;
      }

      // Calculate unlocked chapters and lessons
      final unlockedChapters = <String>{};
      final unlockedLessons = <String>{};
      var completedLessons = <String>{};
      var lessonScores = <String, int>{};
      var currentStreak = 0;
      var gems = 0;
      var energy = 5;

      // Get user data if logged in
      final userId = _authRepository.currentUser?.uid;
      if (userId != null) {
        final user = await _userRepository.getUser(userId);
        if (user != null) {
          completedLessons = user.progress.keys.toSet();
          // Extract scores from progress
          lessonScores = user.progress.map((key, value) => MapEntry(key, value.score));
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
        journeys: journeys,
        chapters: chapters,
        chapterSections: chapterSections,
        chapterLessons: chapterLessons,
        unlockedChapters: unlockedChapters,
        unlockedLessons: unlockedLessons,
        completedLessons: completedLessons,
        lessonScores: lessonScores,
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
  void initState() {
    super.initState();
    // Initialize Sarthi in homepage mode after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sarthiProvider.notifier).initializeSession(isHomepageMode: true);
    });
  }

  @override
  void dispose() {
    // Close Sarthi session when leaving the screen
    // Use a try-catch in case the provider is already disposed
    try {
      // We don't call closeSession here as the provider may be disposed
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBody(context, state),
          // Custom footer with Sarthi button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SarthiFooter(
              onProfileTap: () {
                // Navigate to profile if logged in, login if not
                final user = ref.read(authRepositoryProvider).currentUser;
                if (user != null) {
                  context.push(Routes.profile);
                } else {
                  context.push(Routes.login);
                }
              },
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.only(
        left: Spacing.space16,
        right: Spacing.space16,
        bottom: 120, // Space for footer
      ),
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + Spacing.space16),

        // Journey sections
        if (state.journeys.isNotEmpty) ...[
           for (final journey in state.journeys) ...[
             _buildJourneySection(context, state, journey),
           ],
        ] else ...[
          // Fallback if no journeys (legacy/admin mode)
           for (var chapterIndex = 0; chapterIndex < state.chapters.length; chapterIndex++) ...[
             _buildChapterSection(context, state, state.chapters[chapterIndex], chapterIndex),
           ],
        ],

        const SizedBox(height: Spacing.space32),
      ],
    );
  }

  Widget _buildJourneySection(BuildContext context, HomeState state, Journey journey) {
     // Filter chapters for this journey
     final journeyChapters = state.chapters.where((c) => c.journeyId == journey.id).toList();
     
     if (journeyChapters.isEmpty) return const SizedBox.shrink();

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // Journey Header
         Padding(
           padding: const EdgeInsets.symmetric(vertical: Spacing.space16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 journey.title.toUpperCase(),
                 style: Theme.of(context).textTheme.labelLarge?.copyWith(
                   color: Theme.of(context).colorScheme.primary,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2,
                 ),
               ),
               if (journey.description.isNotEmpty)
                 Text(
                   journey.description,
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                   ),
                 ),
             ],
           ),
         ),
         
         // Chapters in this journey
         for (int i = 0; i < journeyChapters.length; i++)
           _buildChapterSection(context, state, journeyChapters[i], i),
       ],
     );
  }

  Widget _buildChapterSection(BuildContext context, HomeState state, Chapter chapter, int chapterIndex) {
    // Note: chapterIndex is local loop index here, might need adjustment for animations if strictly relying on global index
    // but sine wave is local to list, so it should be fine.
    final lessons = state.chapterLessons[chapter.chapterId] ?? [];
    final sections = state.chapterSections[chapter.chapterId] ?? [];
    
    return Column(
      children: [
        // Chapter header
        ChapterHeader(
          chapterNumber: chapter.chapterNumber,
          description: chapter.chapterNameEn,
          onInfoTap: () => _showShlokasDialog(context, chapter, lessons),
        ),
        
        const SizedBox(height: Spacing.space8),

        if (sections.isNotEmpty) ...[
          // Group by Section
          for (final section in sections) ...[
             _buildSectionGroup(context, state, chapter, section, lessons),
          ],
          
          // Fallback for lessons without section (if any)
          // We can check if any lessons have no sectionId matching known sections
           _buildOrphanLessons(context, state, chapter, lessons, sections),
        ] else ...[
          // Legacy/No Section mode
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final nextLesson = index < lessons.length - 1 ? lessons[index + 1] : null;
              
              return _buildSnakeItem(
                  context, state, chapter, lesson, index, nextLesson);
            },
          ),
        ],
        
        const SizedBox(height: Spacing.space48),
      ],
    );
  }

  Widget _buildSectionGroup(
    BuildContext context, 
    HomeState state, 
    Chapter chapter, 
    Section section, 
    List<Lesson> allLessons
  ) {
    // Filter lessons for this section
    // Use unitId mapping? Or assume sectionId match.
    // In DB, Lesson has 'sectionId'.
    final sectionLessons = allLessons.where((l) => l.sectionId == section.id).toList();
    
    if (sectionLessons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.space24, 
            vertical: Spacing.space12
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SECTION ${section.sectionNumber}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                section.sectionNameEn,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Lessons list for this section
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sectionLessons.length,
          itemBuilder: (context, index) {
            final lesson = sectionLessons[index];
            // Find next lesson to link to. 
            // Ideally we link to next lesson in THIS section, or first of NEXT section?
            // Simple approach: Next in this list. Cross-section linking might be tricky with snake path visually unless lists join.
            // SnakePathPainter is relative to X offset. If we break listview, we break the continuous path?
            // YES. Standard snake view usually is one continuous list.
            // If we break it with Section Headers, the path will break.
            // We should interrupt the path or make the header overlay?
            // Let's interrupt path for sections. It's cleaner.
            
            final nextLesson = index < sectionLessons.length - 1 ? sectionLessons[index + 1] : null;
            
            // Adjust index for sine wave continuity?
            // Or reset sine wave for each section? Resetting is easier.
            return _buildSnakeItem(
                context, state, chapter, lesson, index, nextLesson);
          },
        ),
        
        const SizedBox(height: Spacing.space16),
      ],
    );
  }

  Widget _buildOrphanLessons(
    BuildContext context, 
    HomeState state, 
    Chapter chapter, 
    List<Lesson> allLessons, 
    List<Section> sections
  ) {
    // Find lessons not in any section
    final sectionIds = sections.map((s) => s.id).toSet();
    final orphanLessons = allLessons.where((l) => !sectionIds.contains(l.sectionId)).toList();
    
    if (orphanLessons.isEmpty) return const SizedBox.shrink();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orphanLessons.length,
      itemBuilder: (context, index) {
        final lesson = orphanLessons[index];
        final nextLesson = index < orphanLessons.length - 1 ? orphanLessons[index + 1] : null;
        return _buildSnakeItem(
            context, state, chapter, lesson, index, nextLesson);
      },
    );
  }

  Widget _buildSnakeItem(
    BuildContext context,
    HomeState state,
    Chapter chapter,
    Lesson lesson,
    int index,
    Lesson? nextLesson,
  ) {
    // Snake layout calculation
    // Using sine wave for smooth localized curves
    // Amplitude is how far left/right it goes (0.0 to 1.0 alignment)
    const double amplitude = 0.6;
    // Frequency determines how tight the curves are
    const double frequency = 1.0; 
    
    final double xOffset = amplitude * _calculateSineOffset(index, frequency);
    
    final isUnlocked = state.unlockedLessons.contains(lesson.lessonId);
    final isCompleted = state.completedLessons.contains(lesson.lessonId);
    final lessons = state.chapterLessons[chapter.chapterId] ?? [];
    
    final isCurrent = isUnlocked &&
        !isCompleted &&
        lessons.take(index).every(
          (l) => state.completedLessons.contains(l.lessonId),
        );

    return SizedBox(
      height: 120, // Height allocated for each step
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
           // Path to next node
           // We only draw path if there is a next lesson
           if (nextLesson != null)
             Positioned.fill(
               child: CustomPaint(
                 painter: SnakePathPainter(
                   startOffset: xOffset,
                   endOffset: amplitude * _calculateSineOffset(index + 1, frequency),
                   color: state.unlockedLessons.contains(nextLesson.lessonId)
                       ? Theme.of(context).colorScheme.primary
                       : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                 ),
               ),
             ),
             
          Align(
            alignment: Alignment(xOffset, 0),
            child: LessonNode(
              lessonNumber: lesson.lessonNumber,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              description: '', // Description removed from tile
              starsEarned: _calculateStars(state.lessonScores[lesson.lessonId] ?? 0),
              onTap: () {
                _showLessonPreview(context, chapter, lesson, isUnlocked);
              },
            ),
          ),
          
          // Floating stars/milestones could be added here similar to Duolingo
        ],
      ),
    );
  }

  double _calculateSineOffset(int index, double frequency) {
    // using dart:math in a stateless way requires import, or simple approximation?
    // Let's assume math import is needed or use a simple lookup/function.
    // Actually, I should import dart:math at the top.
    // For now, let's just implement a simple zigzag pattern if math import is missing?
    // No, I can add the lookup for cleaner code or just use math.sin if I add the import.
    // I'll add the import in a separate tool call if it fails, but better to use a simple pattern without it to be safe 
    // or assume I can add it. The file is huge, let's try a predictable pattern.
    // Pattern: 0 -> 0, 1 -> 0.7, 2 -> 0, 3 -> -0.7, 4 -> 0 ...
    final position = index % 4;
    if (position == 0) return 0.0;
    if (position == 1) return 0.7;
    if (position == 2) return 0.0;
    if (position == 3) return -0.7;
    return 0.0;
  }

  /// Calculate stars earned based on percentage score
  /// Score is stored as percentage (0-100)
  /// 1 star: completed lesson (any score)
  /// 2 stars: 70%+ correct
  /// 3 stars: 90%+ correct
  int _calculateStars(int percentageScore) {
    if (percentageScore >= 90) return 3;
    if (percentageScore >= 70) return 2;
    if (percentageScore > 0) return 1;
    return 0;
  }
  
  void _showLessonPreview(
      BuildContext context, Chapter chapter, Lesson lesson, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Blue background as per request
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'LESSON ${lesson.lessonNumber}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lesson.lessonNameEn,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Stats row (optional, like Duolingo)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPreviewStat('Reading', Icons.menu_book_rounded),
                _buildPreviewStat('Speaking', Icons.mic_rounded),
                _buildPreviewStat('Quiz', Icons.quiz_rounded),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (isUnlocked)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(Routes.lessonPath(chapter.chapterId, lesson.lessonId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'LOCKED',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
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

class SnakePathPainter extends CustomPainter {
  final double startOffset;
  final double endOffset;
  final Color color;

  SnakePathPainter({
    required this.startOffset,
    required this.endOffset,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Convert alignment (-1 to 1) to pixels
    final startX = (startOffset + 1) / 2 * size.width;
    final endX = (endOffset + 1) / 2 * size.width;
    
    // Start from bottom of current node
    path.moveTo(startX, 60); // Assuming node has some height/center
    
    // Draw cubic bezier to top of next node
    // Control points for smooth S-curve
    final controlPoint1 = Offset(startX, size.height * 0.75);
    final controlPoint2 = Offset(endX, size.height * 0.25);
    
    path.cubicTo(
      controlPoint1.dx, controlPoint1.dy,
      controlPoint2.dx, controlPoint2.dy,
      endX, size.height + 40, // End at top of next node
    );

    // Dashed line effect for locked paths
    if (color.opacity < 1.0) {
      _drawDashedLine(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Path path, Paint paint) {
    // Simple dash implementation
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 10),
          paint,
        );
        distance += 20;
      }
    }
  }

  @override
  bool shouldRepaint(SnakePathPainter oldDelegate) =>
      oldDelegate.startOffset != startOffset ||
      oldDelegate.endOffset != endOffset ||
      oldDelegate.color != color;
}
