import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing a Journey (group of chapters)
class Journey {
  final String id;
  final int journeyNumber;
  final String title;
  final String description;
  final String shlokasCovered;
  final String color;

  const Journey({
    this.id = '',
    this.journeyNumber = 0,
    this.title = '',
    this.description = '',
    this.shlokasCovered = '',
    this.color = '',
  });

  factory Journey.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return Journey(
        id: doc.id,
        journeyNumber: _safeInt(data, 'journeyNumber'),
        title: _safeString(data, 'title'),
        description: _safeString(data, 'description'),
        shlokasCovered: _safeString(data, 'shlokasCovered'),
        color: _safeString(data, 'color'),
      );
    } catch (e) {
      print('❌ Error parsing Journey ${doc.id}: $e');
      return Journey(id: doc.id, title: 'Error loading journey');
    }
  }

  static String _safeString(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is String) return val;
    if (val != null) return val.toString();
    return '';
  }

  static int _safeInt(Map<String, dynamic> data, String key) {
    final val = data[key];
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}
