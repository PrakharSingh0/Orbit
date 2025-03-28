import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:orbit/Auth/Pages/LoginPage.dart';
import '../../service/auth_Service.dart';
import 'ProfileSetupPage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;


  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();
        _showEmailVerificationDialog(user);

        // Schedule deletion after 2 minutes if not verified
        Future.delayed(const Duration(minutes: 10), () async {
          await user.reload();
          if (!user.emailVerified) {
            await user.delete();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }




  void _showEmailVerificationDialog(User user) {
    bool isVerified = false;
    bool isResendDisabled = true;
    int resendCooldown = 30;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _checkEmailVerification() async {
              for (int i = 120; i > 0; i--) {
                await Future.delayed(const Duration(seconds: 5));
                await user.reload();
                user = FirebaseAuth.instance.currentUser!;
                isVerified = user.emailVerified;

                if (isVerified) {
                  // Save user data after verification
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                    'email': user.email,
                    'createdAt': FieldValue.serverTimestamp(),
                    'profileCompleted': false,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
                    );
                  }
                  return;
                }
                setState(() {});
              }

              if (!isVerified) {
                await user.delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Verification failed. Account deleted."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }

            void _resendVerificationEmail() async {
              try {
                await user.sendEmailVerification();
                setState(() {
                  isResendDisabled = true;
                  resendCooldown = 30;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Verification email resent!"),
                    backgroundColor: Colors.green,
                  ),
                );

                for (int i = 30; i > 0; i--) {
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() => resendCooldown--);
                }
                setState(() => isResendDisabled = false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            _checkEmailVerification();

            return WillPopScope(
              onWillPop: () async {
                await user.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Registration canceled. Account deleted."),
                    backgroundColor: Colors.red,
                  ),
                );
                return true;
              },
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/loading.json',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Verify Your Email",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "A verification email has been sent to:\n${user.email}\nPlease check your inbox.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (!isVerified)
                        Column(
                          children: [
                            const CircularProgressIndicator(color: Colors.blueAccent),
                            const SizedBox(height: 10),
                            Text(
                              "Waiting for verification...",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: isResendDisabled ? null : _resendVerificationEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isResendDisabled ? Colors.grey : Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                isResendDisabled
                                    ? "Resend in $resendCooldown sec"
                                    : "Resend Email",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (isVerified)
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Continue", style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Lottie.asset(
                //   'assets/animations/signup.json',
                //   width: 180,
                //   height: 180,
                //   fit: BoxFit.cover,
                // ),
                const SizedBox(height: 10),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.08,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ).animate().fade(duration: 500.ms).slideY(),

                const SizedBox(height: 10),

                Text(
                  "Sign up with your email and password to get started!",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),textAlign: TextAlign.center,
                ).animate().fade(duration: 700.ms),



                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        errorText: _emailError,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter your email";
                          if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                              .hasMatch(value)) return "Enter a valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        isDark: isDark,
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter your password";
                          if (value.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? Lottie.asset(
                  'assets/animations/loading.json',
                  width: 100,
                  height: 100,
                )
                    : _buildButton("Sign Up", _signUp, isDark),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    TextButton(
                      onPressed: () {Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorText: errorText,
      ),
      validator: validator,
      onTap: () {
        setState(() {
          _emailError = null;
          _passwordError = null;
        });
      },
    );
  }
  Widget _buildButton(String text, VoidCallback onPressed, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(text, style: TextStyle(fontSize: 16, color: isDark ? Colors.black : Colors.white)),
      ),
    );
  }
}
