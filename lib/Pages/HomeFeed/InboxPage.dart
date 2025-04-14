import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  final List<Map<String, dynamic>> dummyNotifications = const [
    {
      "type": "like",
      "userName": "Emily Rose",
      "userTag": "emily_r",
      "userImage":
      "https://images.unsplash.com/photo-1531123897727-8f129e1688ce",
      "timeAgo": "2m",
      "postThumbnail":
      "https://images.unsplash.com/photo-1607746882042-944635dfe10e"
    },
    {
      "type": "follow",
      "userName": "Michael Scott",
      "userTag": "dundermifflin",
      "userImage":
      "https://images.unsplash.com/photo-1502767089025-6572583495b9",
      "timeAgo": "10m",
    },
    {
      "type": "comment",
      "userName": "Jane Doe",
      "userTag": "jdoe",
      "userImage":
      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde",
      "timeAgo": "30m",
      "comment": "Love this shot 😍",
      "postThumbnail":
      "https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d"
    },
  ];

  Widget _buildNotificationItem(Map<String, dynamic> item) {
    final type = item["type"];
    final userName = item["userName"];
    final userTag = item["userTag"];
    final userImage = item["userImage"];
    final timeAgo = item["timeAgo"];

    String message;
    if (type == "like") {
      message = "liked your post";
    } else if (type == "follow") {
      message = "started following you";
    } else if (type == "comment") {
      message = "commented: ${item["comment"]}";
    } else {
      message = "sent you a notification";
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: CachedNetworkImageProvider(userImage),
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " "),
            TextSpan(text: message),
          ],
        ),
      ),
      subtitle: Text(
        "@$userTag • $timeAgo",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: type == "follow"
          ? ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: const Text("Follow", style: TextStyle(fontSize: 12)),
      )
          : item["postThumbnail"] != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: item["postThumbnail"],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.amber.shade100,
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20,color: Colors.red,),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This page is under construction. All notifications shown are just previews and not real.",
                    style: TextStyle(fontSize: 13,color: Colors.red,fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: dummyNotifications.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                return _buildNotificationItem(dummyNotifications[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
