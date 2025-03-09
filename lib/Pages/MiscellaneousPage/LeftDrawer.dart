import 'package:flutter/material.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child:
      Column(
        children: [
          Text("left")
        ],
      ),);
  }
}
