import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class SocketService extends ChangeNotifier {
  late IO.Socket socket;

  SocketService(String url) {
    // Initialisation de la connexion Socket.IO
    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Événements pour la gestion de la connexion et des erreurs
    socket.on('connect', (_) {
      print('Connected to Socket.IO server');
    });

    socket.on('connect_error', (data) {
      print('Connection Error: $data');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Socket.IO server');
    });
  }


  void sendMessage(String senderId, String receiverId, String message, String roomId, String role) {
    final messageData = {
      'senderId': senderId,
      'roleSender': role,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'roomId': roomId,
    };
    print(messageData);
    socket.emit('sendMessage', messageData);
  }

void onMessageReceived(Function(Map<String, dynamic>) onMessage) {
  socket.on('receiveMessage', (data) {
    onMessage(Map<String, dynamic>.from(data));
  });
}

  void joinRoom(String roomId) {
    socket.emit('joinRoom', roomId);
  }

  void close() {
    socket.disconnect();
  }
}
