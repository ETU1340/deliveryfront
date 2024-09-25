import 'package:flutter/material.dart';
import '../../models/livreur.dart';

class LivreurDetailsModal extends StatelessWidget {
  final Livreur livreur;

  LivreurDetailsModal({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.6, // Agrandir la taille du modal
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partie gauche avec les détails du livreur
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                NetworkImage(livreur.image ?? 'https://via.placeholder.com/150'),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '${livreur.name} ${livreur.firstName}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    _buildDetailRow('Email', livreur.email),
                    _buildDetailRow('Nom d\'utilisateur', livreur.userName),
                    _buildDetailRow('Téléphone', livreur.phone),
                    _buildDetailRow('Adresse', livreur.address),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      'Transport actuel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      livreur.moyenDeTransport,
                      style: TextStyle(fontSize: 16),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Fermer'),
                       
                      ),
                    ),
                  ],
                ),
              ),
              // Partie droite avec les informations d'indisponibilité
              if (livreur.unavailablePeriods != null)
                ...[
                  SizedBox(width: 20), // Espace entre les deux colonnes
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Indisponibilités',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 10),
                        ..._buildUnavailablePeriods(livreur.unavailablePeriods!),
                      ],
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUnavailablePeriods(List<UnavailablePeriod> periods) {
    List<Widget> widgets = [];
    for (UnavailablePeriod period in periods) {
      widgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Du ${_formatDate(period.startDate)} au ${_formatDate(period.endDate)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Raison: ${period.reason}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Action pour valider l'indisponibilité
                },
                child: Text('Validé'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action pour refuser l'indisponibilité
                },
                child: Text('Non'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ));
    }
    return widgets;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
