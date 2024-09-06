import 'package:flutter/material.dart';
import '../services/discussion_services.dart';
import '../models/discussion.dart';
import '../models/manager.dart';
import '../services/socket_service.dart';
import '../models/livreur.dart';
import 'package:provider/provider.dart';
import '../../services/livreur_service.dart';
import '../../services/manager_service.dart';
import '../utils/api_urls.dart';

class ManagerChatScreen extends StatefulWidget {
  @override
  _ManagerChatScreenState createState() => _ManagerChatScreenState();
}

class _ManagerChatScreenState extends State<ManagerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late DiscussionService _discussionService;
  List<Livreur> _livreurs = [];
  Discussion? _selectedDiscussion;
  String? _selectedLivreurId;
  String managerId = "";

  @override
  void initState() {
    super.initState();
    _initializeManagerId();

    _discussionService = DiscussionService(baseUrl: ApiUrls.socketUrl);
    _loadLivreurs();

      // Écoute les messages reçus en temps réel
  final socketService = Provider.of<SocketService>(context, listen: false);
  socketService.onMessageReceived((messageData) {
    print('MESSAGE');
    print(messageData);
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
  });
  }

  Future<void> _initializeManagerId() async {
    Manager? manager = await ManagerService.getManagerSession();
    final socketService = Provider.of<SocketService>(context, listen: false);
    print("MANAGER_1");
    print(manager!.id);
    socketService.joinRoom(manager!.id);
    setState(() {
      managerId = manager!.id; // Assigner l'identifiant du manager
    });

  }

  Future<void> _loadLivreurs() async {
    final livreurs = await LivreurService.getLivreurs();
    setState(() {
      _livreurs = livreurs;
    });

    if (_livreurs.isNotEmpty) {
      // Charger la discussion du premier livreur par défaut
      _selectLivreur(_livreurs[0]);
    }
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

  void _sendMessage() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (_controller.text.isNotEmpty && _selectedDiscussion != null) {
      socketService.sendMessage(
        managerId,
        _selectedDiscussion!.delivererId,
        _controller.text,
        _selectedDiscussion!.delivererId,
        'manager',
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
        title: Text('Discussions avec les Livreurs'),
      ),
      body: Row(
        children: [
          // Liste des livreurs
          Container(
            width: 250,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: _livreurs.length,
              itemBuilder: (context, index) {
                final livreur = _livreurs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage( 'https://via.placeholder.com/150'),
                  ),
                  title: Text(livreur.name),
                  subtitle: Text(livreur.email), // Exemple d'email comme sous-titre
                  onTap: () => _selectLivreur(livreur),
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
          // Discussion
          Expanded(
            child: _selectedDiscussion == null
                ? Center(child: Text('Sélectionnez un livreur pour voir la discussion'))
                : Column(
                    children: [
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
                                          color: isSentByMe ? Colors.blueAccent : Colors.grey,
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
                                        message.timestamp.toIso8601String(),
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
                              icon: Icon(Icons.send),
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
