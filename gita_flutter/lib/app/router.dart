import 'package:go_router/go_router.dart';
import '../core/constants/constants.dart';
import '../presentation/admin/admin_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/lesson/lesson_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/splash/splash_screen.dart';

/// App router configuration using go_router
final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    // Splash
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => const SignupScreen(),
    ),

    // Main app
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.lesson,
      builder: (context, state) {
        final chapterId = state.pathParameters['chapterId'] ?? '';
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return LessonScreen(
          chapterId: chapterId,
          lessonId: lessonId,
        );
      },
    ),

    // Admin
    GoRoute(
      path: Routes.admin,
      builder: (context, state) => const AdminScreen(),
    ),

    // Profile
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
