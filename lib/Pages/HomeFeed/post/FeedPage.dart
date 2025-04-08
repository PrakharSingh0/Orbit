import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbit/Pages/HomeFeed/post/ThreadCard.dart';
import 'package:orbit/Pages/HomeFeed/post/postModel.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: followingUidsFuture,
      builder: (context, uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final uids = uidSnapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: StreamBuilder<List<PostModel>>(
            stream: getPostsFromFollowing(uids),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return const Center(child: Text("No posts available."));
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
