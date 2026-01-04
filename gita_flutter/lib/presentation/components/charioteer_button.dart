import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/sarthi_controller.dart';

class CharioteerButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;

  const CharioteerButton({super.key, required this.onPressed});

  @override
  ConsumerState<CharioteerButton> createState() => _CharioteerButtonState();
}

class _CharioteerButtonState extends ConsumerState<CharioteerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We can listen to state to change color/icon based on status
    final sarthiState = ref.watch(sarthiProvider);

    Color buttonColor;
    if (sarthiState.errorMessage != null) {
      buttonColor = Colors.red;
    } else if (sarthiState.isListening) {
      buttonColor = Colors.redAccent;
    } else if (sarthiState.isSpeaking) {
      buttonColor = Colors.green;
    } else if (sarthiState.isProcessing) {
      buttonColor = Colors.amber;
    } else {
      buttonColor = Colors.orange; // Default "Wisdom" orange
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: sarthiState.isSessionActive ? _scaleAnimation.value : 1.0,
          child: FloatingActionButton(
            backgroundColor: buttonColor,
            onPressed: widget.onPressed,
            child: Icon(
              sarthiState.isListening ? Icons.mic : Icons.record_voice_over,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
