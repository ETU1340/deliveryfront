import 'package:flutter/material.dart';
import '../services/discussion_services.dart';
import '../models/discussion.dart';
import '../services/socket_service.dart';
import '../models/livreur.dart';
import 'package:provider/provider.dart';

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
  final String managerId = 'manager_id'; // Remplacez par l'ID réel du manager

  @override
  void initState() {
    super.initState();
    _discussionService = DiscussionService(baseUrl: 'http://localhost:8080');
    _loadLivreurs(); // Charger la liste des livreurs
  }

  Future<void> _loadLivreurs() async {
    // Charger la liste des livreurs disponibles pour le manager
    // Supposons que vous avez un service qui fournit la liste des livreurs
    // Exemple:
    // _livreurs = await LivreurService.getLivreurs();
    setState(() {});
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
        '',
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
                  title: Text(livreur.name),
                  onTap: () => _selectLivreur(livreur),
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
                        child: ListView.builder(
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
