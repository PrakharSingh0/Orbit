import 'package:flutter/material.dart';

class Premium extends StatelessWidget {
  const Premium({super.key});

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Row(children:[Text("Premium",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),SizedBox(width: 10,),Icon(Icons.history)]),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
    );
  }
}
