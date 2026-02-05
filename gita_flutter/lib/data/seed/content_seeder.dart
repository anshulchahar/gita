import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to seed initial content into Firestore
class ContentSeeder {
  
  ContentSeeder();

  /// Seeds all content if it doesn't exist
  Future<void> seedAll() async {
    // Placeholder implementation
    print('ContentSeeder: seedAll called');
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Forces re-seeding of content (clears existing first)
  Future<void> forceSeed() async {
    // Placeholder implementation
    print('ContentSeeder: forceSeed called');
    await Future.delayed(const Duration(seconds: 1));
  }
  
  /// Clears all content
  Future<void> clearAllContent() async {
    // Placeholder implementation
    print('ContentSeeder: clearAllContent called');
    await Future.delayed(const Duration(seconds: 1));
  }
}

final contentSeederProvider = Provider<ContentSeeder>((ref) {
  return ContentSeeder();
});
