import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _profileVisibility = true; // Public (true) / Private (false)
  String _whoCanFollow = 'Everyone';
  bool _displayPersonalInfo = true;

  bool _homeFeedRecommendation = true;
  bool _showMatureContent = false;
  bool _newAccountSuggestions = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Settings",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionTitle("Account Management", isDarkMode),
          _buildTile("Change Username", Icons.person_outline, isDarkMode, () {}),
          _buildTile("Update Email", Icons.email_outlined, isDarkMode, () {}),
          _buildTile("Change Password", Icons.lock_outline, isDarkMode, () {}),
          _buildTile("Personal Info", Icons.info_outline, isDarkMode, () {}),

          _buildDivider(),

          _buildSectionTitle("Privacy Settings", isDarkMode),
          _buildTile("Manage Blocked Users", Icons.block, isDarkMode, () {}),
          _buildDropdownTile(
            title: "Profile Visibility",
            icon: Icons.visibility,
            value: _profileVisibility ? 'Public' : 'Private',
            options: ['Public', 'Private'],
            onChanged: (value) {
              setState(() {
                _profileVisibility = value == 'Public';
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildDropdownTile(
            title: "Who Can Follow You",
            icon: Icons.people_alt_outlined,
            value: _whoCanFollow,
            options: ['Everyone', 'Friends'],
            onChanged: (value) {
              setState(() {
                _whoCanFollow = value!;
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildSwitchTile(
            "Display Personal Info on Profile",
            Icons.perm_identity,
            _displayPersonalInfo,
                (value) {
              setState(() {
                _displayPersonalInfo = value;
              });
            },
            isDarkMode,
          ),

          _buildDivider(),

          _buildSectionTitle("Content Control", isDarkMode),
          _buildSwitchTile(
            "Home Feed Recommendation",
            Icons.recommend,
            _homeFeedRecommendation,
                (value) {
              setState(() {
                _homeFeedRecommendation = value;
              });
            },
            isDarkMode,
          ),
          _buildSwitchTile(
            "Show Mature Content",
            Icons.warning_amber_rounded,
            _showMatureContent,
                (value) {
              setState(() {
                _showMatureContent = value;
              });
            },
            isDarkMode,
          ),
          _buildSwitchTile(
            "New Account Suggestions",
            Icons.person_add_alt,
            _newAccountSuggestions,
                (value) {
              setState(() {
                _newAccountSuggestions = value;
              });
            },
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
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

  Widget _buildTile(String title, IconData icon, bool isDarkMode, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      height: 56, // ✅ Matches switch tile height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isDarkMode ? Colors.white : Colors.black87, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      height: 56, // Matches switch tile height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isDarkMode ? Colors.white : Colors.black87, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          IntrinsicWidth( // ✅ Dropdown width matches longest text
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: false, // ✅ Prevents full-width expansion
                alignment: Alignment.centerRight, // ✅ Ensures right alignment
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: onChanged,
                dropdownColor: isDarkMode ? Colors.black : Colors.white,
                style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                icon: const Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      height: 56, // ✅ Consistent height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isDarkMode ? Colors.white : Colors.black87, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withAlpha((0.3 * 255).toInt()), thickness: 0.8, height: 20);
  }
}
