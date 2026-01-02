import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing a chapter in the Bhagavad Gita
class Chapter {
  final String chapterId;
  final int chapterNumber;
  final String chapterName;
  final String chapterNameEn;
  final String description;
  final String descriptionEn;
  final int shlokaCount;
  final int order;
  final bool isUnlocked;
  final String icon;
  final String color;

  const Chapter({
    this.chapterId = '',
    this.chapterNumber = 0,
    this.chapterName = '',
    this.chapterNameEn = '',
    this.description = '',
    this.descriptionEn = '',
    this.shlokaCount = 0,
    this.order = 0,
    this.isUnlocked = false,
    this.icon = '',
    this.color = '',
  });

  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Chapter(
      chapterId: doc.id,
      chapterNumber: data['chapterNumber'] ?? 0,
      chapterName: data['chapterName'] ?? '',
      chapterNameEn: data['chapterNameEn'] ?? '',
      description: data['description'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      shlokaCount: data['shlokaCount'] ?? 0,
      order: data['order'] ?? 0,
      isUnlocked: data['isUnlocked'] ?? false,
      icon: data['icon'] ?? '',
      color: data['color'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chapterNumber': chapterNumber,
      'chapterName': chapterName,
      'chapterNameEn': chapterNameEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'shlokaCount': shlokaCount,
      'order': order,
      'isUnlocked': isUnlocked,
      'icon': icon,
      'color': color,
    };
  }

  Chapter copyWith({
    String? chapterId,
    int? chapterNumber,
    String? chapterName,
    String? chapterNameEn,
    String? description,
    String? descriptionEn,
    int? shlokaCount,
    int? order,
    bool? isUnlocked,
    String? icon,
    String? color,
  }) {
    return Chapter(
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapterName: chapterName ?? this.chapterName,
      chapterNameEn: chapterNameEn ?? this.chapterNameEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      shlokaCount: shlokaCount ?? this.shlokaCount,
      order: order ?? this.order,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
