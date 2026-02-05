import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/question.dart';
import '../../components/krishna_mascot.dart';

/// Story Card Activity - Animated context with Krishna narrating
/// 
/// This activity type introduces concepts by having Krishna tell a story
/// or provide context. It uses animated text reveal and the Krishna mascot
/// to create an engaging introduction to teachings.
class StoryCardActivity extends StatefulWidget {
  final QuestionContent content;
  final VoidCallback onComplete;

  const StoryCardActivity({
    super.key,
    required this.content,
    required this.onComplete,
  });

  @override
  State<StoryCardActivity> createState() => _StoryCardActivityState();
}

class _StoryCardActivityState extends State<StoryCardActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  bool _showNarration = false;
  bool _showStory = false;
  bool _showContinue = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start the reveal sequence
    _startRevealSequence();
  }

  Future<void> _startRevealSequence() async {
    // Show Krishna's narration first
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _showNarration = true);
    }
    
    // Then show the main story
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _showStory = true);
      _animationController.forward();
    }
    
    // Finally show the continue button
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _showContinue = true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Krishna mascot
            const KrishnaMascot(
              emotion: KrishnaEmotion.happy,
              animation: KrishnaAnimation.idleFloat,
              size: 120,
            ),
            
            const SizedBox(height: Spacing.space16),
            
            // Krishna's narration dialogue
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showNarration ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.space16,
                  vertical: Spacing.space12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.space8),
                    Flexible(
                      child: Text(
                        widget.content.krishnaMessage.isNotEmpty
                            ? widget.content.krishnaMessage
                            : 'Let me share some wisdom with you...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: Spacing.space24),
            
            // Main story content
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showStory ? 1.0 : 0.0,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Shloka reference if available
                  if (widget.content.shlokaNumber.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.space12,
                        vertical: Spacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Shloka ${widget.content.shlokaNumber}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.space16),
                  ],
                  
                  // Sanskrit verse if available
                  if (widget.content.shlokaSanskrit.isNotEmpty) ...[
                    Text(
                      widget.content.shlokaSanskrit,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.space12),
                  ],
                  
                  // Story/context text
                  Text(
                    widget.content.storyText.isNotEmpty
                        ? widget.content.storyText
                        : widget.content.questionText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Real-life application if available
                  if (widget.content.realLifeApplication.isNotEmpty) ...[
                    const SizedBox(height: Spacing.space16),
                    Container(
                      padding: const EdgeInsets.all(Spacing.space12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: Spacing.space8),
                          Expanded(
                            child: Text(
                              widget.content.realLifeApplication,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.space32),
            
            // Continue button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _showContinue ? 1.0 : 0.0,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showContinue ? widget.onComplete : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.space16),
                  ),
                  child: const Text(
                    'I understand, continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
