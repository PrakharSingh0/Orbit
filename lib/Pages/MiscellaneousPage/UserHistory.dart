import 'package:flutter/material.dart';

class UserHistory extends StatelessWidget {
  const UserHistory({super.key});

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Row(children:[Text("History",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),SizedBox(width: 10,),Icon(Icons.history)]),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
    );
  }
}
