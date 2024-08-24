
import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  @override
  _ProgressDialogState createState() => _ProgressDialogState();

  // Méthode statique pour mettre à jour la progression
  static void updateProgress(int current, int total) {
    _ProgressDialogState? state = _progressDialogKey.currentState;
    if (state != null) {
      state.updateProgress(current, total);
    }
  }

  // Clé globale pour accéder à l'état du ProgressDialog
  static final GlobalKey<_ProgressDialogState> _progressDialogKey = GlobalKey<_ProgressDialogState>();
}

class _ProgressDialogState extends State<ProgressDialog> {
  int _current = 0;
  int _total = 1;

  void updateProgress(int current, int total) {
    setState(() {
      _current = current;
      _total = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Importation en cours... $_current/$_total'),
        ],
      ),
    );
  }
}