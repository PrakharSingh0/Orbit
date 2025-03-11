import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../ThemeData/theme_provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            Padding(
              padding: EdgeInsets.only(left: 10,right: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),Text(
                      formattedTime,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    Text(
                      "App Version 1.0.0",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),),
                  ]),
            ),
            // Divider(),

            Spacer(),

            const Divider(),

            // Dark Mode & Logout
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwitchListTile(
                  title: Text(
                    "Dark Mode",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: RotationTransition(
                          turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.bedtime
                          : Icons.wb_sunny_rounded,
                      key: ValueKey<bool>(
                          themeProvider.themeMode == ThemeMode.dark),
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                ListTile(
                  leading: Icon(
                    AntDesign.logout_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    "Log Out",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    // Handle log out
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
