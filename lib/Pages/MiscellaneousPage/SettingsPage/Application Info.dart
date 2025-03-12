import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationInfoPage extends StatelessWidget {
  const ApplicationInfoPage({super.key});

  final String githubRepoUrl = "https://github.com/PrakharSingh0/Orbit"; // Replace with actual repo link

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Info"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("App Overview", isDarkMode),
            _buildInfoRow("App Name", "Orbit", isDarkMode),
            _buildInfoRow("Version", "1.0.1", isDarkMode),
            _buildInfoRow("Build Number", "1001", isDarkMode),
            _buildInfoRow("Release Date", "March 2025", isDarkMode),

            const SizedBox(height: 20),

            _buildSectionTitle("Developer & Contact", isDarkMode),
            _buildInfoRow("Developer", "Prakhar Singh", isDarkMode),
            _buildInfoRow("Email", "prakhar2ps@gmail.com", isDarkMode),

            const SizedBox(height: 20),

            _buildSectionTitle("Technologies Used", isDarkMode),
            _buildInfoRow("Flutter SDK", "3.16.0", isDarkMode),
            _buildInfoRow("Dart", "3.2.0", isDarkMode),
            _buildInfoRow("Firebase", "Latest Version", isDarkMode),
            _buildInfoRow("Firestore", "Latest Version", isDarkMode),

            const SizedBox(height: 20),

            _buildSectionTitle("Open Source", isDarkMode),
            GestureDetector(
              onTap: () => _launchURL(githubRepoUrl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("GitHub Repository", style: _textStyle(isDarkMode)),
                  const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Packages Used", isDarkMode),
            _buildInfoRow("State Management", "Provider", isDarkMode),
            _buildInfoRow("Animations", "Lottie", isDarkMode),
            _buildInfoRow("Font", "Google Font", isDarkMode),
            _buildInfoRow("Icom", "Icon Plus", isDarkMode),

            const SizedBox(height: 20),

            _buildSectionTitle("Acknowledgments", isDarkMode),
            _buildInfoRow("Special Thanks", "Flutter Community", isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _textStyle(isDarkMode, bold: false)),
          Text(value, style: _textStyle(isDarkMode, bold: true)),
        ],
      ),
    );
  }

  TextStyle _textStyle(bool isDarkMode, {bool bold = false}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
      color: isDarkMode ? Colors.white : Colors.black,
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
