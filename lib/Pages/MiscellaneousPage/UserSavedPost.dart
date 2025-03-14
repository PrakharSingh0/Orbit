import 'package:flutter/material.dart';

class UserSavedPost extends StatelessWidget {
  const UserSavedPost({super.key});

  @override
  Widget build(BuildContext context) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Row(children:[const Text("Saved",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),SizedBox(width: 10,),Icon(Icons.bookmark_outline_outlined)]),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
    );
  }
}
