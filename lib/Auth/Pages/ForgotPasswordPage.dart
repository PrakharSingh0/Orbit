import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../service/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _success = false;
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Default duration
    );
  }


  Future<void> _resetPass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _success = false;
    });

    try {
      await AuthService().resetPassword(email: _emailController.text.trim());

      setState(() {
        _isLoading = false;
        _success = true;
      });

      // Wait for Lottie animation to finish, then pop the page
      _successController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Password reset email sent! Check your inbox.')),
            );
          }
        }
      });

      await _successController.forward(); // Play animation
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(colors: [Colors.black87, Colors.black])
              : const LinearGradient(colors: [Color(0xFFe3f2fd), Colors.white]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.08,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ).animate().fade(duration: 700.ms).slideY(),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Enter your email and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ).animate().fade(duration: 900.ms),

                const SizedBox(height: 30),

                // Email Input
                Form(
                  key: _formKey,
                  child: _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter your email";
                      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Button or Loader
                if (_isLoading)
                  Lottie.asset(
                    'assets/animations/loading.json',
                    width: 100,
                    height: 100,
                  )
                else if (_success)
                  Lottie.asset(
                    'assets/animations/success.json',
                    width: 120,
                    height: 120,
                    repeat: false,
                    controller: _successController,
                    onLoaded: (composition) {
                      if (_successController.isDismissed) { // Ensure it's initialized before using
                        _successController.duration = composition.duration;
                        _successController.forward();
                      }
                    },
                  )

                else
                  _buildButton("Send Reset Email", _resetPass, isDark),

                const SizedBox(height: 20),

                // Back to Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Back to Login",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom TextField with Rounded Style
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
      ),
      validator: validator,
    );
  }

  // Custom Button
  Widget _buildButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, color: isDark ? Colors.black : Colors.white)),
      ),
    );
  }
}
