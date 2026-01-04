import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/sarthi_controller.dart';
import 'dart:math' as math;

class CharioteerButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;

  const CharioteerButton({super.key, required this.onPressed});

  @override
  ConsumerState<CharioteerButton> createState() => _CharioteerButtonState();
}

class _CharioteerButtonState extends ConsumerState<CharioteerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Use multiple animations to simulate a complex "voice" reaction
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
     _rippleAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sarthiState = ref.watch(sarthiProvider);
    
    // "Big Blue Circular Icon"
    // We'll use a specific blue color, or the primary color if it is blue-ish.
    // Let's use a nice vibrant blue.
    const Color buttonColor = Color(0xFF2196F3); // Material Blue 500
    const double size = 90.0; // Increased from 72.0

    // Adjust animation speed based on state
    if (sarthiState.isListening) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
      _controller.duration = const Duration(milliseconds: 800); // Faster beat when listening
    } else if (sarthiState.isSpeaking) {
       if (!_controller.isAnimating) _controller.repeat(reverse: true);
      _controller.duration = const Duration(milliseconds: 400); // Fast talk
    } else if (sarthiState.isProcessing) {
       if (!_controller.isAnimating) _controller.repeat(reverse: true);
      _controller.duration = const Duration(milliseconds: 1000); // Thinking
    } else {
      // Idle
      _controller.stop();
      _controller.value = 0.0; // Reset
    }

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Base scale from pulse animation
          double baseScale = 1.0;
          if (sarthiState.isSessionActive || sarthiState.isListening) {
             baseScale = _scaleAnimation.value;
          }
          
          // Voice scale from sound level in state
          double voiceScale = 0.0;
          if (sarthiState.isListening) {
            voiceScale = sarthiState.soundLevel * 0.4;
          }

          final totalScale = (baseScale + voiceScale).clamp(1.0, 1.8);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect when active
              if (sarthiState.isSessionActive || sarthiState.isListening)
                Container(
                  width: size + _rippleAnimation.value * 2 + (voiceScale * 20),
                  height: size + _rippleAnimation.value * 2 + (voiceScale * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor.withOpacity(0.3 - (_controller.value * 0.3).clamp(0.0, 0.3)),
                  ),
                ),
                
              // Main Button
              Transform.scale(
                scale: totalScale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonColor,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.4),
                        blurRadius: 10 + (voiceScale * 20),
                        spreadRadius: 2 + (voiceScale * 5),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
