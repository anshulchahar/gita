/// Route constants for navigation
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String lesson = '/lesson/:chapterId/:lessonId';
  static const String admin = '/admin';
  
  static String lessonPath(String chapterId, String lessonId) => 
      '/lesson/$chapterId/$lessonId';
}

/// Firebase collection names
class Collections {
  static const String users = 'users';
  static const String chapters = 'chapters';
  static const String lessons = 'lessons';
  static const String questions = 'questions';
}

/// App constants
class AppConstants {
  static const String appName = 'Gita';
  static const String appTitle = 'Wisdom Tree';
  static const int maxEnergy = 5;
  static const int energyRefillMinutes = 30;
}
