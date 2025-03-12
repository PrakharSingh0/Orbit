import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationInfoPage extends StatelessWidget {
  const ApplicationInfoPage({super.key});

  final String githubRepoUrl = "https://github.com/PrakharSingh0/Orbit";

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Info",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: "App Overview",
              isDarkMode: isDarkMode,
              items: [
                _buildInfoRow("App Name", "Orbit", Icons.apps, isDarkMode),
                _buildCopyableRow(context, "Version", "1.0.1", Icons.system_update, isDarkMode),
                _buildInfoRow("Build Number", "1001", Icons.code, isDarkMode),
                _buildInfoRow("Release Date", "March 2025", Icons.event, isDarkMode),
              ],
            ),

            _buildInfoCard(
              title: "Developer & Contact",
              isDarkMode: isDarkMode,
              items: [
                _buildInfoRow("Developer", "Prakhar Singh", Icons.person, isDarkMode),
                _buildCopyableRow(context, "Email", "prakhar2ps@gmail.com", Icons.email, isDarkMode),
              ],
            ),

            _buildInfoCard(
              title: "Open Source",
              isDarkMode: isDarkMode,
              items: [_buildGitHubButton(isDarkMode)],
            ),
        _buildInfoCard(
          title: "Packages Used",
          isDarkMode: isDarkMode,
          items: [
            _buildInfoRow("State Management", "Provider", Icons.widgets, isDarkMode),
            _buildInfoRow("Animations", "Lottie", Icons.animation, isDarkMode),
            _buildInfoRow("Font", "Google Font", Icons.font_download, isDarkMode),
            _buildInfoRow("Icons", "Icon Plus", Icons.insert_emoticon, isDarkMode),
          ],
        ),

        _buildInfoCard(
          title: "Acknowledgments",
          isDarkMode: isDarkMode,
          items: [
            _buildInfoRow("Special Thanks", "Flutter Community", Icons.favorite, isDarkMode),
])
          ],
        ),
      ),
    );
  }

  /// Card-style container for sections
  Widget _buildInfoCard({required String title, required List<Widget> items, required bool isDarkMode}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withAlpha((0.1 * 255).toInt()) : Colors.grey.withAlpha((0.2 * 255).toInt()),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Column(children: items),
        ],
      ),
    );
  }

  /// Standard Row with Icon
  Widget _buildInfoRow(String title, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDarkMode ? Colors.white70 : Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: _textStyle(isDarkMode, bold: false)),
          ),
          Text(value, style: _textStyle(isDarkMode, bold: true)),
        ],
      ),
    );
  }

  /// Row with Copy-to-Clipboard Button
  Widget _buildCopyableRow(BuildContext context, String title, String value, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDarkMode ? Colors.white70 : Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: _textStyle(isDarkMode, bold: false)),
          ),
          GestureDetector(
            onTap: () => _copyToClipboard(context, value),
            child: Row(
              children: [
                Text(value, style: _textStyle(isDarkMode, bold: true)),
                const SizedBox(width: 5),
                Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// GitHub Button
  Widget _buildGitHubButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _launchURL(githubRepoUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blueAccent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.open_in_new, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "View on GitHub",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Copy to Clipboard Function with Snackbar
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied: $text"),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// URL Launcher
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Text Style
  TextStyle _textStyle(bool isDarkMode, {bool bold = false}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w500 : FontWeight.w400,
      color: isDarkMode ? Colors.white : Colors.black,
    );
  }
}
