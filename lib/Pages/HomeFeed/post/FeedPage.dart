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
  final User? user = FirebaseAuth.instance.currentUser;

  late Future<List<String>> _followingUidsFuture;

  @override
  void initState() {
    super.initState();
    _followingUidsFuture = _fetchFollowingUIDs();
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _followingUidsFuture = _fetchFollowingUIDs();
    });
  }

  Future<List<String>> _fetchFollowingUIDs() async {
    final currentUser = user?.uid;
    if (currentUser == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser)
        .collection('following')
        .get();

    final followingUids = snapshot.docs.map((doc) => doc.id).toList();
    followingUids.add(currentUser); // Include own posts
    return followingUids;
  }

  Stream<List<PostModel>> _fetchPosts(List<String> uids) async* {
    if (uids.isEmpty) yield [];

    final List<List<String>> uidChunks = [];
    for (var i = 0; i < uids.length; i += 10) {
      uidChunks.add(uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10));
    }

    yield* Stream.multi((controller) {
      final List<PostModel> allPosts = [];
      int completedChunks = 0;

      for (final chunk in uidChunks) {
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
              uid: data['uid'],
              userName: data['userName'] ?? 'Unknown',
              userTag: data['userTag'] ?? '',
              postTime: data["timestamp"] ?? Timestamp.now(),
              postTitle: data['caption'] ?? '',
              postBody: data['body'] ?? '',
              userImage: data['profilePictureUrl'] ?? '',
              postImage: data['imageUrl'] ?? '',
              externalLink: data['link'] ?? '',
            );
          }).toList();

          allPosts.addAll(posts);
          completedChunks++;

          if (completedChunks == uidChunks.length) {
            allPosts.sort((a, b) => b.postTime.compareTo(a.postTime));
            controller.add(allPosts);
          }
        });
      }
    });
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 4,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 12, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 60, height: 10, color: Colors.white),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 12, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 12, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 200, height: 12, color: Colors.white),
              const SizedBox(height: 16),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (_) {
                  return Container(width: 60, height: 12, color: Colors.white);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
      future: _followingUidsFuture,
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer();
        }

        final uids = uidSnapshot.data ?? [];
        if (uids.isEmpty) return _buildEmptyState();

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: StreamBuilder<List<PostModel>>(
            stream: _fetchPosts(uids),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmer();
              }

              final posts = postSnapshot.data ?? [];

              if (posts.isEmpty) {
                return _buildEmptyState();
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
