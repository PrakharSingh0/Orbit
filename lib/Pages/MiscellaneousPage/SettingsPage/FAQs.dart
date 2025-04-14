import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> faqs = [
      {
        "question": "How do I change my password?",
        "answer": "Go to Account Settings > Change Password and follow the instructions."
      },
      {
        "question": "How can I update my email address?",
        "answer": "Navigate to Account Settings > Update Email to enter a new email address."
      },
      {
        "question": "Can I delete my account?",
        "answer": "Yes, go to Account Settings > Delete Account. Keep in mind that this action is irreversible."
      },
      {
        "question": "Why am I not receiving notifications?",
        "answer": "Ensure that notifications are enabled in Settings > Notifications and also check your device settings."
      },
      {
        "question": "How do I manage blocked users?",
        "answer": "Visit Privacy Settings > Manage Blocked Users to unblock or view the list of blocked users."
      },
      {
        "question": "What is profile visibility?",
        "answer": "Profile visibility controls who can view your profile. You can set it to Public or Private in Privacy Settings."
      },
      {
        "question": "How do I enable dark mode?",
        "answer": "Go to Settings > Theme and switch to Dark Mode."
      },
      {
        "question": "How do I report a bug or issue?",
        "answer": "You can report bugs by going to Help Center > Report an Issue and providing details."
      },
      {
        "question": "Is there a way to recover my deleted posts?",
        "answer": "Unfortunately, deleted posts cannot be recovered."
      },
      {
        "question": "How do I contact customer support?",
        "answer": "You can reach us at support@orbitapp.com or visit Help Center > Contact Support."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs",style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQTile(faqs[index]["question"]!, faqs[index]["answer"]!, isDarkMode);
        },
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: SizedBox(
          height: 36, // ✅ Compact tile height (instead of 56)
          child: Row(
            children: [
              Icon(Icons.help_outline, size: 20, color: isDarkMode ? Colors.white70 : Colors.black87),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 14, // ✅ Slightly smaller text to fit in compact height
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
