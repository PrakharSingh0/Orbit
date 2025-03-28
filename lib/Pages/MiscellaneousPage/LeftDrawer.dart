import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Auth/Pages/welcomePage.dart';
import '../../ThemeData/theme_provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    // Detect the current system brightness
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    // Determine whether dark mode is active
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    String formattedDate = DateFormat('EEEE, MMM d').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          color: theme.colorScheme.surface, // ✅ Adaptive background color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface, // ✅ Adaptive text color
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface, // ✅ Adaptive text color
                      ),
                    ),
                    Divider(color: theme.colorScheme.onSurface.withAlpha((0.3 * 255).toInt())),
                    // ✅ Softer divider
                    Text(
                      "App Version 1.0.0",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()), // ✅ Adaptive text
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Divider(color: theme.colorScheme.onSurface.withAlpha((0.3 * 255).toInt())),

              // Dark Mode Toggle
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SwitchListTile(
                    title: Text(
                      "Dark Mode",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface, // ✅ Adaptive text color
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    secondary: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: RotationTransition(
                            turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isDarkMode ? Icons.bedtime : Icons.wb_sunny_rounded,
                        key: ValueKey<bool>(isDarkMode),
                        color: theme.colorScheme.secondary, // ✅ Adaptive icon color
                        size: 24,
                      ),
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      AntDesign.logout_outline,
                      color: theme.colorScheme.onSurface, // ✅ Error color adapts to theme
                    ),
                    title: Text(
                      "Log Out",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface, // ✅ Adaptive text color
                      ),
                    ),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to the Welcome Screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) =>  WelcomeScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: ${e.toString()}")),
      );
    }
  }
}
