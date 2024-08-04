import 'package:flutter/material.dart';
import '../../models/livreur.dart';

class LivreurDetailsScreen extends StatelessWidget {
  final Livreur livreur;

  LivreurDetailsScreen({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${livreur.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${livreur.name}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Email: ${livreur.email}'),
                  SizedBox(height: 10),
                  Text('Phone: ${livreur.phone}'),
                  SizedBox(height: 10),
                  Text('Address: ${livreur.address}'),
                  SizedBox(height: 10),
                  Text('Role: ${livreur.role}'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unavailable Periods',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (livreur.unavailablePeriods!.isEmpty)
                    Text('No unavailable periods'),
                  for (var period in livreur.unavailablePeriods!)
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date: ${period.startDate.toLocal()}'),
                            Text('End Date: ${period.endDate.toLocal()}'),
                            Text('Reason: ${period.reason}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
