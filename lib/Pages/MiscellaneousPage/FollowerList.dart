import 'package:flutter/material.dart';

class UserFollowerList extends StatefulWidget {
  final int initialTabIndex; // 0 for Followers, 1 for Following

  const UserFollowerList({super.key, required this.initialTabIndex});

  @override
  State<UserFollowerList> createState() => _UserFollowerListState();
}

class _UserFollowerListState extends State<UserFollowerList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> followers = [
    {"name": "john_doe", "isFollowing": false},
    {"name": "alex123", "isFollowing": true},
    {"name": "flutter_dev", "isFollowing": false},
  ];

  final List<Map<String, dynamic>> following = [
    {"name": "coding_pro", "isFollowing": true},
    {"name": "design_tips", "isFollowing": true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex, // ✅ Open the correct tab
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Followers & Following"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: isDarkMode ? Colors.white : Colors.black,
          tabs: const [
            Tab(text: "Followers"),
            Tab(text: "Following"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(followers, true),
          _buildList(following, false),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> users, bool isFollowers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(user["name"][0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Text(user["name"],
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: ElevatedButton(
            onPressed: () {
              setState(() {
                user["isFollowing"] = !user["isFollowing"];
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user["isFollowing"] ? Colors.grey[300] : Colors.blueAccent,
              foregroundColor: user["isFollowing"] ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(user["isFollowing"] ? "Following" : (isFollowers ? "Follow Back" : "Unfollow")),
          ),
        );
      },
    );
  }
}
