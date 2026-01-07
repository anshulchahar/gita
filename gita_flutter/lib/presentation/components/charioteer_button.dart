import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
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
    
    const Color buttonColor = Color(0xFF2196F3);
    const double size = 90.0;

    // Animation based on state
    switch (sarthiState.state) {
      case VoiceAssistantState.inactive:
        _controller.stop();
        _controller.value = 0.0;
        break;
      case VoiceAssistantState.connecting:
        _controller.duration = const Duration(milliseconds: 1200);
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
        break;
      case VoiceAssistantState.listening:
        _controller.duration = const Duration(milliseconds: 800);
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
        break;
      case VoiceAssistantState.responding:
        _controller.duration = const Duration(milliseconds: 400);
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
        break;
      case VoiceAssistantState.waitingForUser:
        _controller.duration = const Duration(milliseconds: 2000);
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
        break;
    }

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Base scale from pulse animation
          double baseScale = 1.0;
          if (sarthiState.isActive) {
            baseScale = _scaleAnimation.value;
          }
          
          // Voice scale from sound level
          double voiceScale = 0.0;
          if (sarthiState.isListening) {
            voiceScale = sarthiState.soundLevel * 0.4;
          }

          final totalScale = (baseScale + voiceScale).clamp(1.0, 1.6);

          // Color based on state
          Color currentColor = buttonColor;
          if (sarthiState.isResponding) {
            currentColor = const Color(0xFF4CAF50); // Green when responding
          } else if (sarthiState.isWaitingForUser) {
            currentColor = const Color(0xFFFFC107); // Amber when waiting
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect when active
              if (sarthiState.isActive)
                Container(
                  width: size + _rippleAnimation.value * 2 + (voiceScale * 20),
                  height: size + _rippleAnimation.value * 2 + (voiceScale * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentColor.withValues(alpha: 0.3 - (_controller.value * 0.2).clamp(0.0, 0.3)),
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
                    color: currentColor,
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withValues(alpha: 0.4),
                        blurRadius: 10 + (voiceScale * 15),
                        spreadRadius: 2 + (voiceScale * 3),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/peacock_feather.svg',
                      width: 50,
                      height: 60,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
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
