import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../HomeFeed/post/ThreadCard.dart';
import '../HomeFeed/post/postModel.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<PostModel>> _fetchSavedPosts() async {
    final savedSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('saved')
        .orderBy('savedAt', descending: true)
        .get();

    List<PostModel> savedPosts = [];

    for (var doc in savedSnap.docs) {
      final postId = doc.id;

      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (postSnap.exists) {
        savedPosts.add(PostModel.fromMap(postSnap.data()!, postSnap.id));
      }
    }

    return savedPosts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Posts"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _fetchSavedPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No saved posts yet.",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          final savedPosts = snapshot.data!;

          return ListView.builder(
            itemCount: savedPosts.length,
            itemBuilder: (context, index) {
              return ThreadCard(post: savedPosts[index],isFromSavedPage: true,);
            },
          );
        },
      ),
    );
  }
}
