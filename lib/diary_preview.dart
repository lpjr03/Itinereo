import 'package:flutter/material.dart';

class DiaryPreview extends StatelessWidget {
  const DiaryPreview({super.key});

  //const DiaryPreview(this.switchScreen, {super.key});

  //final Function() switchScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Journal"),),
      body: Column(
        children: [
          // Contenuto principale della schermata
          Expanded(
            child: Center(
              child: Text('Contenuto', style: TextStyle(fontSize: 24)),
            ),
          ),
            ],
          ),
      );
  }
}
