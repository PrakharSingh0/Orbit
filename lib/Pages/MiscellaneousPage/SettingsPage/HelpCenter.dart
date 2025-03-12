import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionTitle("Support", isDarkMode),
          _buildListTile("Contact Support", Icons.support_agent, isDarkMode, () {
            // TODO: Add navigation to contact support
          }),
          _buildListTile("Report a Problem", Icons.report, isDarkMode, () {
            // TODO: Add navigation to report a problem
          }),
          _buildListTile("Feedback & Suggestions", Icons.feedback, isDarkMode, () {
            // TODO: Add navigation to feedback page
          }),

          const SizedBox(height: 20),

          _buildSectionTitle("Resources", isDarkMode),
          _buildListTile("User Guide", Icons.menu_book, isDarkMode, () {
            // TODO: Add navigation to user guide
          }),
          _buildListTile("Community Support", Icons.people, isDarkMode, () {
            // TODO: Add navigation to community support
          }),

          const SizedBox(height: 20),

          _buildSectionTitle("Legal & Policies", isDarkMode),
          _buildListTile("Privacy Policy", Icons.privacy_tip, isDarkMode, () {
            // TODO: Add navigation to privacy policy
          }),
          _buildListTile("Terms of Service", Icons.description, isDarkMode, () {
            // TODO: Add navigation to terms of service
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white70 : Colors.black54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, bool isDarkMode, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black54),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}