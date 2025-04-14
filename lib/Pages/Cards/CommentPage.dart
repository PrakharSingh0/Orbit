import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icons_plus/icons_plus.dart';

import '../HomeFeed/Profile/ProfilePage.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _replyingToCommentId;
  String? currentUserId;
  String? postOwnerId;
  String? _replyingToUserName;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    getPostOwner();
  }

  Future<void> getPostOwner() async {
    final postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
    if (postSnapshot.exists) {
      setState(() {
        postOwnerId = postSnapshot['uid'];
      });
    }
  }

  Future<void> postComment(String text, {String? parentId}) async {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final userImage = userDoc.data()?.containsKey('profilePictureUrl') == true
        ? userDoc['profilePictureUrl']
        : null;

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc();

    final commentData = {
      'commentId': commentRef.id,
      'uid': user.uid,
      'userName': userDoc['userName'],
      'userTag': userDoc['userTag'],
      'userImage': userImage,
      'commentText': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'parentId': parentId,
    };

    await commentRef.set(commentData);

    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
    });
  }

  Stream<List<QueryDocumentSnapshot>> getCommentsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> handleVote(String commentId, int voteValue) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final voteRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .collection('votes')
        .doc(userId);

    final currentVote = await voteRef.get();

    if (currentVote.exists) {
      final currentValue = currentVote['vote'];
      if (currentValue == voteValue) {
        await voteRef.delete(); // Toggle off
      } else {
        await voteRef.set({'vote': voteValue}); // Change vote
      }
    } else {
      await voteRef.set({'vote': voteValue}); // New vote
    }
  }

  Future<void> deleteComment(String commentId) async {
    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    Future<void> deleteReplies(String parentId) async {
      final replies = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .where('parentId', isEqualTo: parentId)
          .get();

      for (var reply in replies.docs) {
        await deleteReplies(reply.id);
        await reply.reference.delete();
      }
    }

    await deleteReplies(commentId);
    await commentRef.delete();
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} Minute Ago";
    if (diff.inHours < 24) return "${diff.inHours} Hour Ago";
    if (diff.inDays < 7) return "${diff.inDays} Days Ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} Weeks Ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} Months Ago";
    return "${(diff.inDays / 365).floor()} Years Ago";
  }

  void _scrollToTextField() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }


  Widget buildCommentItem(
      Map<String, dynamic> data,
      String id,
      List<QueryDocumentSnapshot> allComments,
      int level,
      ) {
    final replies = allComments.where((doc) => doc['parentId'] == id).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Stack(
        children: [
          if (level > 1)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: Colors.grey.withOpacity(0.4),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: level > 0 ? 10.0 * level + 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfilePage(userId: data['uid']),
                        ),
                      );
                    },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: (data['userImage'] != null &&
                            data['userImage'].toString().isNotEmpty)
                            ? CachedNetworkImageProvider(data['userImage'])
                            : const AssetImage("assets/avatar_placeholder.png")
                        as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['userName'] ?? '',
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          data['createdAt'] != null
                              ? _getTimeAgo((data['createdAt'] as Timestamp).toDate())
                              : '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Padding(padding: const EdgeInsets.only(left: 45), child: Text(data['commentText'])),
                const SizedBox(height: 4),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(id)
                      .collection('votes')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int score = 0;
                    int userVote = 0;

                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final dynamic v = doc['vote'];
                        if (v is int) {
                          score += v;
                          if (doc.id ==
                              FirebaseAuth.instance.currentUser?.uid) {
                            userVote = v;
                          }
                        }
                      }
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(FontAwesome.arrow_up_solid,
                              size: 18,
                              color: userVote == 1
                                  ? Colors.green
                                  : Colors.grey),
                          onPressed: () => handleVote(id, 1),
                        ),
                        Text('$score'),
                        IconButton(
                          icon: Icon(FontAwesome.arrow_down_solid,
                              size: 18,
                              color: userVote == -1
                                  ? Colors.red
                                  : Colors.grey),
                          onPressed: () => handleVote(id, -1),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.reply, size: 18, color: Theme.of(context).colorScheme.onSurface),
                          label: Text("Reply", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _replyingToCommentId = id;
                              _replyingToUserName = data['userName'];
                            });
                            _commentController.text = '';
                            FocusScope.of(context).requestFocus(_focusNode);
                            _scrollToTextField();
                          },
                        ),
                        PopupMenuButton<int>(
                          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface, size: 20),
                          onSelected: (value) async {
                            if (value == 0) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15), // Rounded corners
                                  ),
                                  title: Text('Delete Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                                  content: const Text(
                                    'Are you sure you want to delete this comment and all its replies? This action cannot be undone.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await deleteComment(id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              height: 40, // Increase height for better touch targets
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.onSurface, // onSurface color for consistency
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface, // Use error color for delete
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),


                      ],
                    );
                  },
                ),
                if (replies.isNotEmpty)
                  ...replies.map((reply) => buildCommentItem(
                    reply.data() as Map<String, dynamic>,
                    reply.id,
                    allComments,
                    level + 1,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard if tapping outside the text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Comments')),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: getCommentsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final allComments = snapshot.data!;
                  final topLevelComments = allComments.where((doc) {
                    final parentId = doc['parentId'];
                    return parentId == null || parentId.toString().isEmpty;
                  }).toList();

                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    children: topLevelComments
                        .map((doc) => buildCommentItem(doc.data() as Map<String, dynamic>, doc.id, allComments, 1))
                        .toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: _replyingToCommentId != null
                            ? 'Reply to @$_replyingToUserName...'
                            : 'Add a comment...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => postComment(_commentController.text, parentId: _replyingToCommentId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
