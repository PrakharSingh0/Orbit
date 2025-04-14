import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  final String currentUserId;

  const ExplorePage({super.key, required this.currentUserId});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<List<List<DocumentSnapshot>>> _exploreData;

  @override
  void initState() {
    super.initState();
    _exploreData = fetchExploreData();
  }

  Future<List<DocumentSnapshot>> fetchSuggestedUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: widget.currentUserId)
        .limit(10)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchRandomPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
    // .orderBy('createdAt', descending: true) // 👈 temporarily disable
        .limit(30)
        .get();

    return snapshot.docs.where((doc) {
      final data = doc.data();
      return (data['imageUrl'] ?? '').toString().isNotEmpty;
    }).toList();
  }

  Future<List<List<DocumentSnapshot>>> fetchExploreData() {
    return Future.wait([
      fetchSuggestedUsers(),
      fetchRandomPosts(),
    ]);
  }

  Future<bool> isFollowing(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('following')
        .doc(userId)
        .get();
    return doc.exists;
  }

  void followUser(String userId) async {
    final batch = FirebaseFirestore.instance.batch();

    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId);
    final targetUserRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    final followingRef = currentUserRef.collection('following').doc(userId);
    final followerRef = targetUserRef.collection('followers').doc(widget.currentUserId);

    batch.set(followingRef, {'followedAt': Timestamp.now()});
    batch.set(followerRef, {'followedAt': Timestamp.now()});

    await batch.commit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.05);

    return Scaffold(
      body: FutureBuilder<List<List<DocumentSnapshot>>>(
        future: _exploreData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final suggestedUsers = snapshot.data![0];
          final posts = snapshot.data![1];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suggested Users
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Suggested Users',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestedUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final user = suggestedUsers[index].data() as Map<String, dynamic>;
                      final userId = suggestedUsers[index].id;

                      return FutureBuilder<bool>(
                        future: isFollowing(userId),
                        builder: (context, followSnap) {
                          final isFollowing = followSnap.data ?? false;

                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: (user['profilePictureUrl'] ?? '').toString().isNotEmpty
                                      ? CachedNetworkImageProvider(user['profilePictureUrl'])
                                      : const AssetImage('assets/avatar_placeholder.png') as ImageProvider,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user['userName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "@${user['userTag'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                if (!isFollowing)
                                  FractionallySizedBox(
                                    widthFactor: 0.75,
                                    child: ElevatedButton(
                                      onPressed: () => followUser(userId),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        backgroundColor: Colors.blueAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Follow', style: TextStyle(fontSize: 12)),
                                    ),
                                  )
                                else
                                  const Text(
                                    'Following',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Explore Posts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      final imageUrl = post['imageUrl'] ?? '';
                      final caption = post['caption'] ?? '';

                      return Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {}, // 👈 add navigation here if needed
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade300,
                                  ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
                                ),
                                if (caption.isNotEmpty)
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black54,
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        caption,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );}}