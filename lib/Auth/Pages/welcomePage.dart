import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'LoginPage.dart';
import 'SingUpPage.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Name Animation
              Text(
                "Orbit",
                style: TextStyle(
                  fontSize: screenSize.width * 0.12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ).animate().fade(duration: 600.ms).scale(),

              const SizedBox(height: 8),

              // Tagline Animation
              Text(
                "Connect • Share • Explore",
                style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(duration: 700.ms).slideY(begin: -0.1),

              const SizedBox(height: 50),

              // Buttons
              _buildButton(context, "Login", LoginScreen(), screenSize),
              const SizedBox(height: 15),
              _buildButton(context, "Sign Up", SignUpScreen(), screenSize, outlined: true),

              const SizedBox(height: 40),

              // Footer Text
              Text(
                "By continuing, you agree to our Terms & Privacy Policy.",
                style: TextStyle(
                  fontSize: screenSize.width * 0.035,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ).animate().fade(duration: 1100.ms),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button
  Widget _buildButton(BuildContext context, String text, Widget page, Size screenSize,
      {bool outlined = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: screenSize.width * 0.75,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : (isDark ? Colors.white : Colors.black),
          foregroundColor: outlined ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.black : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: outlined ? BorderSide(color: isDark ? Colors.white : Colors.black, width: 1.5) : BorderSide.none,
          ),
          elevation: outlined ? 0 : 3,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: screenSize.width * 0.045, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
