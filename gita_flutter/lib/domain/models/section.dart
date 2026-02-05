import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing a section within a chapter
class Section {
  final String id;
  final String unitId;
  final int sectionNumber;
  final String sectionName;
  final String sectionNameEn; // Fallback to name if not separate
  final String keyTeaching;
  final String shlokaRange;
  final int order;
  final String journeyId;

  const Section({
    this.id = '',
    this.unitId = '',
    this.sectionNumber = 0,
    this.sectionName = '',
    this.sectionNameEn = '',
    this.keyTeaching = '',
    this.shlokaRange = '',
    this.order = 0,
    this.journeyId = '',
  });

  factory Section.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return Section(
        id: doc.id,
        unitId: _safeString(data, 'unitId'),
        sectionNumber: _safeInt(data, 'sectionNumber'),
        sectionName: _safeString(data, 'sectionName'), // Might be Hi?
        // Check if there is specific En/Hi logic needed. 
        // JSON has sectionName (En) and sectionNameHi. 
        // Let's assume standard mapping:
        sectionNameEn: _safeString(data, 'sectionNameEn').isNotEmpty 
            ? _safeString(data, 'sectionNameEn') 
            : _safeString(data, 'sectionName'),
        keyTeaching: _safeString(data, 'keyTeaching'),
        shlokaRange: _safeString(data, 'shlokaRange'),
        order: _safeInt(data, 'order'),
        journeyId: _safeString(data, 'journeyId'),
      );
    } catch (e) {
      print('❌ Error parsing Section ${doc.id}: $e');
      return Section(id: doc.id, sectionName: 'Error loading section');
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
