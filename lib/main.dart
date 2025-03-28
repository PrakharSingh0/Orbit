import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lottie/lottie.dart';
import 'package:orbit/Pages/HomeFeed/HomePageMain.dart';
import 'package:orbit/service/auth_Service.dart';
import 'package:provider/provider.dart';
import 'Auth/Pages/ProfileSetupPage.dart';
import 'Auth/Pages/welcomePage.dart';
import 'ThemeData/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkForUnverifiedUsers();
  }

  Future<void> _checkForUnverifiedUsers() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.delete();
      print("🗑️ Deleted unverified account on app restart");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return WelcomeScreen();
          } else {
            return FutureBuilder<bool>(
              future: AuthService().isProfileSetupComplete(user.uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset('assets/animations/loading.json', width: 100, height: 100),
                  );
                } else if (profileSnapshot.hasData && !profileSnapshot.data!) {
                  return  WelcomeScreen();
                } else {
                  return const HomePageMain();
                }
              },
            );
          }
        }
        return Center(
          child: Lottie.asset('assets/animations/loading.json', width: 100, height: 100),
        );
      },
    );
  }
}
