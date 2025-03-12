import 'package:flutter/material.dart';
import 'package:orbit/Pages/MiscellaneousPage/SettingsPage/AccountSettings.dart';
import 'package:orbit/Pages/MiscellaneousPage/SettingsPage/FAQs.dart';
import 'package:orbit/Pages/MiscellaneousPage/SettingsPage/HelpCenter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ThemeData/theme_provider.dart';
import 'Application Info.dart';
import 'notification.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _selectedTextSize = 'Medium';
  String _selectedMediaQuality = 'Standard';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTextSize = prefs.getString('textSize') ?? 'Medium';
      _selectedMediaQuality = prefs.getString('mediaQuality') ?? 'Standard';
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> _openGitHubIssue() async {
    final Uri url = Uri.parse("https://github.com/PrakharSingh0/Orbit/issues");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the URL")),
      );
    }
  }

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from right (default page transition)
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad, // ✅ Smooth easing effect
          ));

          // Scale effect (slight pop)
          final scaleAnimation = Tween<double>(
            begin: 0.95, // Start slightly smaller
            end: 1.0,    // Full size
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // ✅ Natural transition feel
          ));

          return SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appliedTheme = themeProvider.getAdaptiveTheme(context);
    final isDarkMode = appliedTheme == ThemeMode.dark;
    final isSystemTheme = themeProvider.themeMode == ThemeMode.system;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionTitle("General", isDarkMode),
          _buildListTile("Account Settings", Icons.person_outline, isDarkMode, () {_navigateWithSlide(context, const AccountSettingsPage());
          }),
          _buildListTile("Notifications", Icons.notifications_none, isDarkMode, () {_navigateWithSlide(context, const NotificationSettingsPage());}),

          _buildDivider(),

          _buildSectionTitle("Theme", isDarkMode),
          _buildSwitchTile(
            "Use System Theme",
            Icons.settings,
            isSystemTheme,
                (bool value) {
              themeProvider.setTheme(value ? ThemeMode.system : ThemeMode.light);
            },
            isDarkMode,
          ),
          _buildSwitchTile(
            "Dark Mode",
            Icons.dark_mode,
            isDarkMode,
                (bool value) {
              if (!isSystemTheme) {
                themeProvider.setTheme(value ? ThemeMode.dark : ThemeMode.light);
              }
            },
            isDarkMode,
            disabled: isSystemTheme, // ✅ Disable if System Theme is ON
          ),

          _buildDivider(),

          _buildSectionTitle("Accessibility", isDarkMode),
          _buildDropdownTile(
            title: "Text Size",
            icon: Icons.text_fields,
            value: _selectedTextSize,
            options: ['Small', 'Medium', 'Large'],
            onChanged: (value) {
              setState(() {
                _selectedTextSize = value!;
                _saveSetting('textSize', value);
              });
            },
            isDarkMode: isDarkMode,
          ),
          _buildDropdownTile(
            title: "Media Quality",
            icon: Icons.high_quality_outlined,
            value: _selectedMediaQuality,
            options: ['Data Saver', 'Standard', 'High Resolution'],
            onChanged: (value) {
              setState(() {
                _selectedMediaQuality = value!;
                _saveSetting('mediaQuality', value);
              });
            },
            isDarkMode: isDarkMode,
          ),

          _buildDivider(),

          _buildSectionTitle("About", isDarkMode),
          _buildListTile("Application Info", Icons.info_outline, isDarkMode, () {_navigateWithSlide(context, const ApplicationInfoPage());}),

          _buildDivider(),

          _buildSectionTitle("Support", isDarkMode),
          _buildListTile("Help Center", Icons.help_outline, isDarkMode, () {_navigateWithSlide(context, const HelpCenterPage());}),
          _buildListTile("FAQs", Icons.question_answer_outlined, isDarkMode, () {_navigateWithSlide(context, const FAQsPage());}),
          _buildListTile(
            "Report an Issue on GitHub",
            Icons.bug_report_outlined,
            isDarkMode,
            _openGitHubIssue, // ✅ Opens external URL
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
          IntrinsicWidth( // ✅ Adapts width to the longest option
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                alignment: Alignment.centerRight, // ✅ Right-aligns selected value
                isExpanded: false, // ✅ Ensures dropdown doesn't stretch too wide
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



  Widget _buildListTile(String title, IconData icon, bool isDarkMode, VoidCallback onTap) {
    return GestureDetector( // ✅ Wrap entire tile
      onTap: onTap, // ✅ Now the whole tile is tappable
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Same padding as switchTile
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
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
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // ✅ No need for GestureDetector here
          ],
        ),
      ),
    );
  }



  Widget _buildSwitchTile(
      String title,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      bool isDarkMode, {
        bool disabled = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: disabled
                    ? Colors.grey[500] // Softer icon when disabled
                    : (isDarkMode ? Colors.white : Colors.black87),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: disabled
                      ? Colors.grey[500] // Light gray text when disabled
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: disabled ? null : () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: disabled
                    ? Colors.grey[400] // 🔥 Keeps previous color but muted
                    : (value ? Colors.blueAccent : Colors.grey[300]), // 🔥 Smooth OFF state
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    left: value ? 24 : 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: disabled
                            ? Colors.grey[300] // 🔥 Soft muted dot when disabled
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            blurRadius: 2,
                            spreadRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDivider() {
    return Divider(color: Colors.grey.withAlpha((0.3 * 255).toInt()), thickness: 0.8, height: 20);
  }
}
