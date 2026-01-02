import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/constants.dart';

/// Splash screen - initial loading and auth check
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for "loading"
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Always go to home - users can sign in later if they want
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0599F3),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/Gemini_Generated_Image_iabg3niabg3niabg.webp',
              fit: BoxFit.contain,
              width: 200, // Constrain width to ensure it looks like an icon
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60, // Position at bottom like Duolingo
            child: Text(
              'Gita',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka( // Fredoka is similar to Duolingo's rounded font
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
