import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ThemeData/theme_provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width*.6,
      child: Drawer(
        child: Column(
          children: [
            const Spacer(),
            SwitchListTile(
                title: const Text("Dark Mode"),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                })
          ],
        ),
      ),
    );
  }
}
