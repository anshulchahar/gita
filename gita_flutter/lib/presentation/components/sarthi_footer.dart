import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/sarthi_controller.dart';
import 'charioteer_button.dart';

/// Custom footer/bottom navigation bar with a curved notch for the Sarthi button
class SarthiFooter extends ConsumerWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onPlansTap;
  final VoidCallback? onStreaksTap;
  final VoidCallback? onOffersTap;

  const SarthiFooter({
    super.key,
    this.onProfileTap,
    this.onPlansTap,
    this.onStreaksTap,
    this.onOffersTap,
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
          
          // Navigation icons row
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side icons
                _FooterIcon(
                  icon: Icons.local_offer_outlined,
                  onTap: onOffersTap ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Offers coming soon!')),
                    );
                  },
                ),
                _FooterIcon(
                  icon: Icons.local_fire_department_outlined,
                  onTap: onStreaksTap ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Streaks coming soon!')),
                    );
                  },
                ),
                
                // Center spacer for Sarthi button
                const SizedBox(width: 80),
                
                // Right side icons
                _FooterIcon(
                  icon: Icons.workspace_premium_outlined,
                  onTap: onPlansTap ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plans coming soon!')),
                    );
                  },
                ),
                _FooterIcon(
                  icon: Icons.person_outline,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),
          
          // Sarthi button floating above the curve (temporarily disabled)
          Positioned(
            bottom: 25, // Position above the footer
            child: IgnorePointer(
              child: CharioteerButton(
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual footer icon button
class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;

  const _FooterIcon({
    required this.icon,
    this.onTap,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12), // Push icons lower
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: Colors.grey[600],
            ),
          ),
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
