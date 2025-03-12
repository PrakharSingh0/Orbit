import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool allowNotifications = true;
  bool directMessage = true;
  bool chatMessage = true;
  bool mention = true;
  bool commentOnPost = true;
  bool likeOnPost = true;
  bool likeOnComment = true;
  bool replyOnComment = true;
  bool newFollower = true;
  bool newPostFromFollowing = true;
  bool announcements = true;
  bool recommendations = true;
  bool advertisements = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Settings"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSwitchTile(
            "Allow Notifications",  // ✅ Title (String)
            Icons.notifications_active_outlined, // ✅ Icon (IconData)
            allowNotifications,  // ✅ Value (bool)
                (value) {  // ✅ onChanged function
              setState(() => allowNotifications = value);
            },
            isDarkMode, // ✅ isDarkMode (bool)
          ),



          _buildSectionTitle("Messages", isDarkMode),
          _buildSwitchTile("Direct Message", Icons.mail_outline, directMessage, (value) {
            setState(() => directMessage = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Chat Message", Icons.chat_bubble_outline, chatMessage, (value) {
            setState(() => chatMessage = value);
          }, isDarkMode, disabled: !allowNotifications),

          _buildSectionTitle("Activity", isDarkMode),
          _buildSwitchTile("@Mention", Icons.alternate_email, mention, (value) {
            setState(() => mention = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Comment on your Post", Icons.comment_outlined, commentOnPost, (value) {
            setState(() => commentOnPost = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Like on your Post", Icons.thumb_up_outlined, likeOnPost, (value) {
            setState(() => likeOnPost = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Like on your Comment", Icons.favorite_border, likeOnComment, (value) {
            setState(() => likeOnComment = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Replies on your Comment", Icons.reply_outlined, replyOnComment, (value) {
            setState(() => replyOnComment = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("New Follower", Icons.person_add_alt, newFollower, (value) {
            setState(() => newFollower = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("New Post from Following", Icons.post_add_outlined, newPostFromFollowing, (value) {
            setState(() => newPostFromFollowing = value);
          }, isDarkMode, disabled: !allowNotifications),

          _buildSectionTitle("Other", isDarkMode),
          _buildSwitchTile("Announcements", Icons.campaign_outlined, announcements, (value) {
            setState(() => announcements = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Recommendations", Icons.recommend_outlined, recommendations, (value) {
            setState(() => recommendations = value);
          }, isDarkMode, disabled: !allowNotifications),
          _buildSwitchTile("Advertisements", Icons.shopping_bag_outlined, advertisements, (value) {
            setState(() => advertisements = value);
          }, isDarkMode, disabled: !allowNotifications),
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
                            color: Colors.black.withOpacity(0.1),
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

}
