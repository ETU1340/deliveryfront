class Message {
  final String senderId;
  final String message;
  final DateTime timestamp;

  Message({required this.senderId, required this.message, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Discussion {
  final String delivererId;
  final String managerId;
  final List<Message> messages;

  Discussion({required this.delivererId, required this.managerId, required this.messages});

  factory Discussion.fromJson(Map<String, dynamic> json) {
    var messages = (json['messages'] as List).map((msg) => Message.fromJson(msg)).toList();
    return Discussion(
      delivererId: json['delivererId'],
      managerId: json['managerId'],
      messages: messages,
    );
  }
}
