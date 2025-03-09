import 'package:flutter/material.dart';
import 'package:orbit/HomeScren.dart';
import 'package:orbit/Pages/HomeFeed/HomePageMain.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeData/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme(); // Load saved theme before UI builds
  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode, // Apply the theme mode
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const HomePageMain(),
          );
        },
      ),
    );
  }
}
