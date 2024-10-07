import 'package:flutter/material.dart';
import '../services/discussion_services.dart';
import '../models/discussion.dart';
import '../models/manager.dart';
import '../services/socket_service.dart';
import '../models/livreur.dart';
import 'package:intl/intl.dart'; // Pour formater l'heure
import 'package:provider/provider.dart';
import '../../services/livreur_service.dart';
import '../../services/manager_service.dart';
import '../utils/api_urls.dart';
import 'dart:js' as js;

class ManagerChatScreen extends StatefulWidget {
  @override
  _ManagerChatScreenState createState() => _ManagerChatScreenState();
}

class _ManagerChatScreenState extends State<ManagerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late DiscussionService _discussionService;
  List<Livreur> _livreurs = [];
  List<Livreur> _filteredLivreurs = [];
  Discussion? _selectedDiscussion;
  String? _selectedLivreurId;
  String managerId = "";
  String managerName = "";
  final DateFormat _timeFormat = DateFormat('HH:mm'); // Format d'heure

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLivreurs();
  }
  @override
  void initState() {
    super.initState();
    _initializeManagerId();
    _discussionService = DiscussionService(baseUrl: ApiUrls.socketUrl);
    _loadLivreurs();

    // Écoute les messages reçus en temps réel
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.onMessageReceived((messageData) {
      if (_selectedDiscussion != null && messageData['senderId'] == _selectedDiscussion!.delivererId) {
        setState(() {
          _selectedDiscussion!.messages.add(
            Message(
              senderId: messageData['senderId'],
              message: messageData['message'],
              timestamp: DateTime.parse(messageData['timestamp']),
            ),
          );
        });
      }
      String senderName = messageData['senderName'] ?? 'Manager';
      showWebNotification("$senderName vous a envoyé un message", messageData['message']);
    });

    // Écoute les changements de texte dans la barre de recherche
    _searchController.addListener(_filterLivreurs);
  }
  void showWebNotification(String title, String body) {
  js.context.callMethod('eval', [
    """
    new Notification("$title", {
      body: "$body",
      icon: 'https://flutter.dev/images/favicon.png' // Optional: URL of an icon
    });
    """
  ]);
}



  Future<void> _initializeManagerId() async {
    Manager? manager = await ManagerService.getManagerSession();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.joinRoom(manager!.id);
    setState(() {
      managerName = manager.name;
      managerId = manager.id;
    });
  }

  Future<void> _loadLivreurs() async {
    final livreurs = await LivreurService.getLivreurs();
    setState(() {
      _livreurs = livreurs;
      _filteredLivreurs = livreurs;
    });

    if (_filteredLivreurs.isNotEmpty) {
      _selectLivreur(_filteredLivreurs[0]);
    }
  }

  void _filterLivreurs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLivreurs = _livreurs.where((livreur) {
        return livreur.userName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectLivreur(Livreur livreur) async {
    setState(() {
      _selectedLivreurId = livreur.id;
    });

    try {
      final discussion = await _discussionService.getDiscussion(livreur.id, managerId);
      setState(() {
        _selectedDiscussion = discussion;
      });
    } catch (e) {
      setState(() {
        _selectedDiscussion = Discussion(
          delivererId: livreur.id,
          managerId: managerId,
          messages: [],
        );
      });
    }
  }



  String _getLastMessage(Livreur livreur) {
    final discussion = _selectedDiscussion?.delivererId == livreur.id ? _selectedDiscussion : null;
    if (discussion != null && discussion.messages.isNotEmpty) {
      return discussion.messages.last.message;
    }
    return "Aucun message";
  }

  void _sendMessage() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (_controller.text.isNotEmpty && _selectedDiscussion != null) {
      socketService.sendMessage(
        managerId,
        _selectedDiscussion!.delivererId,
        _controller.text,
        _selectedDiscussion!.delivererId,
        'manager',
        managerName
      );

      setState(() {
        _selectedDiscussion!.messages.add(
          Message(
            senderId: managerId,
            message: _controller.text,
            timestamp: DateTime.now(),
          ),
        );
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discussions avec les Livreurs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Row(
        children: [
          // Liste des livreurs avec barre de recherche
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredLivreurs.length,
                    itemBuilder: (context, index) {
                      final livreur = _filteredLivreurs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('icon.png'),
                        ),
                        title: Text(
                          livreur.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _getLastMessage(livreur),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        onTap: () => _selectLivreur(livreur),
                        tileColor: _selectedLivreurId == livreur.id ? Colors.blue[50] : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _selectedLivreurId == livreur.id ? Colors.blue : Colors.grey,
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Discussion
          Expanded(
            child: _selectedDiscussion == null
                ? Center(
                    child: Text(
                      'Sélectionnez un livreur pour voir la discussion',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      // Affichage des infos du livreur sélectionné
                      if (_selectedLivreurId != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('icon.png'),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _livreurs.firstWhere((l) => l.id == _selectedLivreurId).name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _livreurs.firstWhere((l) => l.id == _selectedLivreurId).email,
                                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Divider(),
                      Expanded(
                        child: _selectedDiscussion!.messages.isEmpty
                            ? Center(child: Text('Aucun message dans cette discussion'))
                            : ListView.builder(
                                itemCount: _selectedDiscussion!.messages.length,
                                itemBuilder: (context, index) {
                                  final message = _selectedDiscussion!.messages[index];
                                  final isSentByMe = message.senderId == managerId;

                                  return ListTile(
                                    title: Align(
                                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSentByMe ? Colors.blueAccent : Colors.grey[400],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          message.message,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    subtitle: Align(
                                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Text(
                                        _timeFormat.format(message.timestamp),
                                        style: TextStyle(color: Colors.grey, fontSize: 10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'Envoyer un message...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.blueAccent),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
