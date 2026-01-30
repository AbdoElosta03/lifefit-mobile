class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
    //option to copy Notification with modified fields
    Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
  //fromJson method to create Notification from JSON from API
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'].toString() ,
      title: json['payload']?['title'] ?? '',
      message: json['payload']?['body'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? false,
    );
  }
  //toJson method to convert Notification to JSON to send to API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'payload': {
        'title': title,
        'body': message, 
      },
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }


}
