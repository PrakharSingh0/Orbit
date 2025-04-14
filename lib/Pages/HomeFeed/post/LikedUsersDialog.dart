import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Profile/ProfilePage.dart';

class LikedByPage extends StatefulWidget {
  final String postId;
  final ScrollController scrollController;

  const LikedByPage({
    super.key,
    required this.postId,
    required this.scrollController,
  });

  @override
  State<LikedByPage> createState() => _LikedByPageState();
}

class _LikedByPageState extends State<LikedByPage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedUsers();
  }

  Future<void> _loadLikedUsers() async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .get();

    List<Map<String, dynamic>> tempUsers = [];

    for (var doc in likesSnapshot.docs) {
      final userId = doc.id;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        data['uid'] = userId; // Attach userId
        tempUsers.add(data);
      }
    }

    setState(() {
      _users = tempUsers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredUsers = _searchQuery.isEmpty
        ? _users
        : _users.where((user) {
      final name = (user['userName'] ?? '').toString().toLowerCase();
      final tag = (user['userTag'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || tag.contains(_searchQuery);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Liked by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
                // 👇 Expand the sheet when user types
                widget.scrollController.animateTo(
                  widget.scrollController.position.maxScrollExtent / 2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                // filled: true,
                // fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? ListView.builder(
              controller: widget.scrollController,
              itemCount: 6,
              itemBuilder: (_, __) => const _UserTileShimmer(),
            )
                : filteredUsers.isEmpty
                ? const Center(child: Text("No matching users"))
                : ListView.builder(
              controller: widget.scrollController,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final profilePic = user['profilePictureUrl'] ?? '';
                final userName = user['userName'] ?? 'Unknown';
                final userTag = user['userTag'] ?? 'unknown';
                final userId = user['uid'];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: profilePic.isNotEmpty
                        ? NetworkImage(profilePic)
                        : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                  ),
                  title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('@$userTag', style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePage(userId: userId)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTileShimmer extends StatelessWidget {
  const _UserTileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: const CircleAvatar(radius: 26, backgroundColor: Colors.white),
      ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 12, width: 100, color: Colors.white),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 10, width: 80, color: Colors.white),
      ),
    );
  }
}
