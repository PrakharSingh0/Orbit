import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbit/Pages/HomeFeed/post/ThreadCard.dart';
import 'package:orbit/Pages/HomeFeed/post/postModel.dart';
import 'package:shimmer/shimmer.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<String>> followingUidsFuture;

  @override
  void initState() {
    super.initState();
    followingUidsFuture = getFollowingUIDs();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      followingUidsFuture = getFollowingUIDs();
    });
  }

  Future<List<String>> getFollowingUIDs() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final currentUid = currentUser.uid;

    final followingSnapshot = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .get();
    final followingUids = followingSnapshot.docs.map((doc) => doc.id).toList();
    followingUids.add(currentUid); // include your own UID

    return followingUids;
  }

  Stream<List<PostModel>> getPostsFromFollowing(List<String> uids) async* {
    if (uids.isEmpty) {
      yield [];
      return;
    }

    final chunks = <List<String>>[];
    for (var i = 0; i < uids.length; i += 10) {
      chunks.add(uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10));
    }

    yield* Stream.multi((controller) {
      final List<PostModel> allPosts = [];
      int completed = 0;

      for (final chunk in chunks) {
        _firestore
            .collection('posts')
            .where('uid', whereIn: chunk)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          final posts = snapshot.docs.map((doc) {
            final data = doc.data();
            return PostModel(
              id: doc.id,
              userName: data['userName'] ?? 'Unknown',
              userTag: data['userTag'] ?? '',
              postTime: data["timestamp"] ?? '',
              postTitle: data['caption'] ?? '',
              postBody: data['body'] ?? '',
              userImage: data['profilePictureUrl'] ?? '',
              postImage: data['imageUrl'] ?? '',
              externalLink: data['link'] ?? '',
            );
          }).toList();

          allPosts.addAll(posts);
          completed++;

          if (completed == chunks.length) {
            allPosts.sort((a, b) => b.postTime.compareTo(a.postTime));
            controller.add(allPosts);
          }
        });
      }
    });
  }

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with avatar and name
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and tag
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 60,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Post title / caption
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 12,
                color: Colors.white,
              ),

              const SizedBox(height: 16),

              // Post image
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 16),

              // Interaction row (buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (_) {
                  return Container(
                    width: 60,
                    height: 12,
                    color: Colors.white,
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No posts to show",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Follow people or create a post to see activity here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: followingUidsFuture,
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return buildShimmer();
        }

        final uids = uidSnapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: StreamBuilder<List<PostModel>>(
            stream: getPostsFromFollowing(uids),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildShimmer();
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return buildEmptyState();
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return ThreadCard(post: posts[index]);
                },
              );
            },
          ),
        );
      },
    );
  }
}
