import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/sarthi_controller.dart';
import 'charioteer_button.dart';

/// Custom footer for question pages with hint button, Sarthi, and check button
class QuestionFooter extends ConsumerWidget {
  final VoidCallback? onHintTap;
  final VoidCallback? onCheckTap;
  final bool isCheckEnabled;
  final bool showNextButton;
  final VoidCallback? onNextTap;
  final String? nextButtonText;

  const QuestionFooter({
    super.key,
    this.onHintTap,
    this.onCheckTap,
    this.isCheckEnabled = true,
    this.showNextButton = false,
    this.onNextTap,
    this.nextButtonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 100, // Height to accommodate the bump
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // White background with curved notch
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 70),
              painter: _CurvedNotchPainter(),
            ),
          ),
          
          // Hint and Check buttons row
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hint button on the left
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _ActionButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Hint',
                    onTap: onHintTap ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hint feature coming soon!')),
                      );
                    },
                    color: Colors.amber[700]!,
                  ),
                ),
                
                // Center spacer for Sarthi button
                const SizedBox(width: 100),
                
                // Check/Next button on the right
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: showNextButton
                      ? _ActionButton(
                          icon: Icons.arrow_forward,
                          label: nextButtonText ?? 'Next',
                          onTap: onNextTap,
                          color: Colors.blue[600]!,
                        )
                      : _ActionButton(
                          icon: Icons.check_circle_outline,
                          label: 'Check',
                          onTap: isCheckEnabled ? onCheckTap : null,
                          color: isCheckEnabled ? Colors.green[600]! : Colors.grey[400]!,
                        ),
                ),
              ],
            ),
          ),
          
          // Sarthi button floating above the curve
          Positioned(
            bottom: 25, // Position above the footer
            child: CharioteerButton(
              onPressed: () {
                ref.read(sarthiProvider.notifier).toggleListening();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button with icon and label (simple, no container)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final displayColor = isEnabled ? color : Colors.grey[400]!;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: displayColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: displayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the curved notch in the footer
class _CurvedNotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Shadow paint
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    
    // Start from bottom left
    path.moveTo(0, size.height);
    
    // Line up to where curve starts on left
    path.lineTo(0, 15);
    
    // Smooth curve to left edge of notch
    final notchCenterX = size.width / 2;
    const notchRadius = 50.0; // Radius of the notch bump
    
    // Draw left side up to notch
    path.lineTo(notchCenterX - notchRadius - 20, 15);
    
    // Smooth curve into the notch (left side of bump)
    path.quadraticBezierTo(
      notchCenterX - notchRadius, 15, // Control point
      notchCenterX - notchRadius + 10, 0, // End point - start of bump
    );
    
    // Draw the semicircular bump upward
    path.arcToPoint(
      Offset(notchCenterX + notchRadius - 10, 0),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Smooth curve out of notch (right side of bump)
    path.quadraticBezierTo(
      notchCenterX + notchRadius, 15, // Control point
      notchCenterX + notchRadius + 20, 15, // End point
    );
    
    // Complete right side
    path.lineTo(size.width, 15);
    path.lineTo(size.width, size.height);
    
    // Close the path
    path.close();

    // Draw shadow first
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);
    
    // Draw the white background
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
