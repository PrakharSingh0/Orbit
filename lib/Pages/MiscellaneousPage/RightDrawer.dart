import 'package:flutter/material.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: MediaQuery.of(context).size.width * 0.5,
      child: const Drawer(
        child:
        Column(
          children: [
            Text("Right")
          ],
        ),),
    );
  }
}
