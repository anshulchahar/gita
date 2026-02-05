import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/question.dart';
import '../../components/krishna_mascot.dart';

/// Reflection Prompt Activity - Journal-style personal questions
/// 
/// This activity type encourages users to connect teachings to their
/// personal life through reflective writing. Responses are saved
/// as part of the user's spiritual journal.
class ReflectionPromptActivity extends StatefulWidget {
  final QuestionContent content;
  final Function(String response) onSubmit;
  final String? savedResponse;
  final bool isSubmitted;

  const ReflectionPromptActivity({
    super.key,
    required this.content,
    required this.onSubmit,
    this.savedResponse,
    this.isSubmitted = false,
  });

  @override
  State<ReflectionPromptActivity> createState() => _ReflectionPromptActivityState();
}

class _ReflectionPromptActivityState extends State<ReflectionPromptActivity> {
  late TextEditingController _textController;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.savedResponse ?? '');
    _hasContent = _textController.text.isNotEmpty;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasContent = _textController.text.trim().isNotEmpty;
    if (hasContent != _hasContent) {
      setState(() => _hasContent = hasContent);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with journal icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.space8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Reflection',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Take a moment to reflect...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: Spacing.space20),
            
            // Shloka reference if available
            if (widget.content.shlokaSanskrit.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.space12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.content.shlokaSanskrit,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.content.shlokaNumber.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.space4),
                        child: Text(
                          '— ${widget.content.shlokaNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.space16),
            ],
            
            // Reflection question
            Text(
              widget.content.reflectionQuestion.isNotEmpty
                  ? widget.content.reflectionQuestion
                  : widget.content.questionText,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Hint if available
            if (widget.content.reflectionHint.isNotEmpty) ...[
              const SizedBox(height: Spacing.space8),
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: Spacing.space4),
                  Expanded(
                    child: Text(
                      widget.content.reflectionHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: Spacing.space16),
            
            // Text input area
            if (!widget.isSubmitted) ...[
              TextField(
                controller: _textController,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your reflection here...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(Spacing.space16),
                ),
              ),
              
              const SizedBox(height: Spacing.space16),
              
              // Character count and submit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_textController.text.length} characters',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => widget.onSubmit(''),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.space8),
                      ElevatedButton.icon(
                        onPressed: _hasContent
                            ? () => widget.onSubmit(_textController.text.trim())
                            : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Save & Continue'),
                      ),
                    ],
                  ),
                ],
              ),
            ] else ...[
              // Show saved response
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.space16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: Spacing.space8),
                        Text(
                          'Your Reflection',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.space8),
                    Text(
                      widget.savedResponse ?? _textController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: Spacing.space16),
              
              // Krishna's encouragement
              Row(
                children: [
                  const KrishnaMascot(
                    emotion: KrishnaEmotion.encouraging,
                    animation: KrishnaAnimation.none,
                    size: 50,
                  ),
                  const SizedBox(width: Spacing.space12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(Spacing.space12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Beautiful reflection! Self-awareness is the first step on the path to wisdom.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
