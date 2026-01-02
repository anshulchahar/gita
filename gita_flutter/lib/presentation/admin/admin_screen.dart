import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/seed/content_seeder.dart';

/// Admin screen state
class AdminState {
  final bool isSeeding;
  final bool isClearing;
  final String? message;
  final bool isError;

  const AdminState({
    this.isSeeding = false,
    this.isClearing = false,
    this.message,
    this.isError = false,
  });

  AdminState copyWith({
    bool? isSeeding,
    bool? isClearing,
    String? message,
    bool? isError,
  }) {
    return AdminState(
      isSeeding: isSeeding ?? this.isSeeding,
      isClearing: isClearing ?? this.isClearing,
      message: message,
      isError: isError ?? this.isError,
    );
  }
}

/// Admin screen controller
class AdminController extends StateNotifier<AdminState> {
  final ContentSeeder _contentSeeder;

  AdminController(this._contentSeeder) : super(const AdminState());

  Future<void> seedContent() async {
    state = state.copyWith(isSeeding: true, message: null);
    try {
      await _contentSeeder.seedAll();
      state = state.copyWith(
        isSeeding: false,
        message: 'Content seeded successfully!',
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSeeding: false,
        message: 'Error seeding content: $e',
        isError: true,
      );
    }
  }

  Future<void> forceSeedContent() async {
    state = state.copyWith(isSeeding: true, message: null);
    try {
      await _contentSeeder.forceSeed();
      state = state.copyWith(
        isSeeding: false,
        message: 'Content force-seeded successfully!',
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSeeding: false,
        message: 'Error force-seeding content: $e',
        isError: true,
      );
    }
  }

  Future<void> clearContent() async {
    state = state.copyWith(isClearing: true, message: null);
    try {
      await _contentSeeder.clearAllContent();
      state = state.copyWith(
        isClearing: false,
        message: 'Content cleared successfully!',
        isError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isClearing: false,
        message: 'Error clearing content: $e',
        isError: true,
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController(ref.watch(contentSeederProvider));
});

/// Admin screen widget
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminControllerProvider);
    final controller = ref.read(adminControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
        title: const Text('Admin Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.space16),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: Spacing.space12),
                    Expanded(
                      child: Text(
                        'Admin Panel - Development Only',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.space24),

            // Message
            if (state.message != null)
              Container(
                padding: const EdgeInsets.all(Spacing.space12),
                margin: const EdgeInsets.only(bottom: Spacing.space16),
                decoration: BoxDecoration(
                  color: state.isError
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isError ? Icons.error : Icons.check_circle,
                      color: state.isError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.space8),
                    Expanded(child: Text(state.message!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => controller.clearMessage(),
                    ),
                  ],
                ),
              ),

            // Actions
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.space16),

            // Seed button
            FilledButton.icon(
              onPressed: state.isSeeding
                  ? null
                  : () => controller.seedContent(),
              icon: state.isSeeding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle),
              label: const Text('Seed Initial Content'),
            ),
            const SizedBox(height: Spacing.space8),
            Text(
              'Adds chapters, lessons, and questions if they don\'t exist',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Spacing.space24),

            // Force seed button
            OutlinedButton.icon(
              onPressed: state.isSeeding
                  ? null
                  : () => controller.forceSeedContent(),
              icon: state.isSeeding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Force Re-Seed'),
            ),
            const SizedBox(height: Spacing.space8),
            Text(
              'Clears all content and re-seeds from scratch',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Spacing.space24),

            // Clear button
            OutlinedButton.icon(
              onPressed: state.isClearing
                  ? null
                  : () => _showClearConfirmation(context, controller),
              icon: state.isClearing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
              label: Text(
                'Clear All Content',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: Spacing.space8),
            Text(
              'Deletes all chapters, lessons, and questions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, AdminController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Content?'),
        content: const Text(
          'This will permanently delete all chapters, lessons, and questions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearContent();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
