import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Krishna mascot emotions
enum KrishnaEmotion {
  happy,
  sad,
  neutral,
  encouraging,
  celebrating,
  thinking,
}

/// Krishna mascot animations
enum KrishnaAnimation {
  none,
  idleFloat,
  bounce,
  pulse,
  wave,
}

/// Krishna mascot widget
class KrishnaMascot extends StatefulWidget {
  final KrishnaEmotion emotion;
  final KrishnaAnimation animation;
  final double size;

  const KrishnaMascot({
    super.key,
    this.emotion = KrishnaEmotion.neutral,
    this.animation = KrishnaAnimation.idleFloat,
    this.size = 100,
  });

  @override
  State<KrishnaMascot> createState() => _KrishnaMascotState();
}

class _KrishnaMascotState extends State<KrishnaMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _getDuration(),
      vsync: this,
    );
    _animation = _getAnimation();
    
    if (widget.animation != KrishnaAnimation.none) {
      _controller.repeat(reverse: true);
    }
  }

  Duration _getDuration() {
    switch (widget.animation) {
      case KrishnaAnimation.bounce:
        return const Duration(milliseconds: 500);
      case KrishnaAnimation.pulse:
        return const Duration(milliseconds: 800);
      case KrishnaAnimation.wave:
        return const Duration(milliseconds: 600);
      case KrishnaAnimation.idleFloat:
      case KrishnaAnimation.none:
        return const Duration(milliseconds: 1500);
    }
  }

  Animation<double> _getAnimation() {
    switch (widget.animation) {
      case KrishnaAnimation.bounce:
        return Tween<double>(begin: 0, end: -10).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case KrishnaAnimation.pulse:
        return Tween<double>(begin: 1, end: 1.1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case KrishnaAnimation.wave:
        return Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case KrishnaAnimation.idleFloat:
        return Tween<double>(begin: 0, end: -5).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case KrishnaAnimation.none:
        return Tween<double>(begin: 0, end: 0).animate(_controller);
    }
  }

  @override
  void didUpdateWidget(KrishnaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _controller.duration = _getDuration();
      _animation = _getAnimation();
      if (widget.animation != KrishnaAnimation.none) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getEmoji() {
    switch (widget.emotion) {
      case KrishnaEmotion.happy:
        return '😊';
      case KrishnaEmotion.sad:
        return '😢';
      case KrishnaEmotion.neutral:
        return '🙂';
      case KrishnaEmotion.encouraging:
        return '💪';
      case KrishnaEmotion.celebrating:
        return '🎉';
      case KrishnaEmotion.thinking:
        return '🤔';
    }
  }

  Color _getColor() {
    switch (widget.emotion) {
      case KrishnaEmotion.happy:
      case KrishnaEmotion.celebrating:
        return const Color(0xFFFFD700);
      case KrishnaEmotion.sad:
        return const Color(0xFF87CEEB);
      case KrishnaEmotion.encouraging:
        return const Color(0xFFFF9933);
      case KrishnaEmotion.thinking:
        return const Color(0xFF9C27B0);
      case KrishnaEmotion.neutral:
        return const Color(0xFF4A148C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Widget mascot = Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getColor().withOpacity(0.3),
                _getColor().withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _getColor().withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getEmoji(),
              style: TextStyle(fontSize: widget.size * 0.5),
            ),
          ),
        );

        switch (widget.animation) {
          case KrishnaAnimation.bounce:
          case KrishnaAnimation.idleFloat:
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: mascot,
            );
          case KrishnaAnimation.pulse:
            return Transform.scale(
              scale: _animation.value,
              child: mascot,
            );
          case KrishnaAnimation.wave:
            return Transform.rotate(
              angle: _animation.value,
              child: mascot,
            );
          case KrishnaAnimation.none:
            return mascot;
        }
      },
    );
  }
}

/// Krishna messages for different situations
class KrishnaMessages {
  static const List<String> welcome = [
    "Welcome, seeker of wisdom! 🙏",
    "Ready to explore the Gita today?",
    "Let's continue your journey of knowledge!",
    "The path of wisdom awaits you!",
  ];

  static const List<String> correctAnswer = [
    "Excellent! You understood well! 🌟",
    "Your wisdom grows, Arjuna! ✨",
    "Perfect! Continue on this path!",
    "Wonderful understanding! 🎯",
  ];

  static const List<String> wrongAnswer = [
    "Don't worry, learning takes time. 📚",
    "Even the wisest must practice. 🌱",
    "Reflect on this and try again!",
    "Every mistake is a step toward wisdom.",
  ];

  static const List<String> highScore = [
    "Outstanding! You have truly understood! 🏆",
    "Your wisdom shines like the sun! ☀️",
    "Arjuna would be proud! 🎉",
    "Masterful understanding! 🌟",
  ];

  static const List<String> mediumScore = [
    "Good effort! Keep practicing! 💪",
    "You're on the right path! 🌈",
    "Progress comes with persistence! 📈",
    "Continue your journey! 🚶",
  ];

  static const List<String> lowScore = [
    "Don't be discouraged. Try again! 🌱",
    "Every master was once a beginner. 📖",
    "Wisdom comes through practice. 🔄",
    "The journey matters more than the destination.",
  ];

  static String random(List<String> messages) {
    return messages[math.Random().nextInt(messages.length)];
  }
}
