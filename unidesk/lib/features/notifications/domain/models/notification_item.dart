class NotificationItem {
  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: int.tryParse(map['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(map['user_id']?.toString() ?? '') ?? 0,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      data: map['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{},
      isRead: map['is_read'] == true || map['is_read']?.toString() == '1',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  NotificationItem copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
