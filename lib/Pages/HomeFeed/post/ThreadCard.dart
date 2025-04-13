import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/Cards/FullScreenImage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Profile/ProfilePage.dart';
import 'LikedUsersDialog.dart';
import 'SimpleCoolLikeButton.dart';
import 'postModel.dart';
import '../../Cards/CommentPage.dart';
import '../../Cards/PostOption.dart';

class ThreadCard extends StatefulWidget {
  final PostModel post;

  const ThreadCard({super.key, required this.post});

  @override
  State<ThreadCard> createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard> {
  bool isLiked = false;
  int likeCount = 0;
  int shareCount = 0;
  int commentCount = 0;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();  // Load the like status when the widget is first built
  }


  Future<void> _loadLikeStatus() async {
    final likeDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(currentUserId)
        .get();

    final likeSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .get();

    setState(() {
      isLiked = likeDoc.exists;
      likeCount = likeSnapshot.docs.length;
    });
  }

  Future<void> _handleLike() async {
    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(currentUserId);

    final liked = isLiked;

    setState(() {
      isLiked = !liked;
      likeCount += liked ? -1 : 1;
    });

    if (!liked) {
      await likeRef.set({
        'uid': currentUserId,
        'likedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await likeRef.delete();
    }
  }

  void _openLikedByPage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return LikedByPage(
            postId: widget.post.id!,
            scrollController: scrollController,
          );
        },
      ),
    );
  }




  Widget _buildLikeButton(ThemeData theme) {
    return InkWell(
      onTap: _handleLike,
      onLongPress: _openLikedByPage,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SimpleCoolLikeButton(
              isLiked: isLiked,
              onTap: () {
                setState(() {
                  isLiked = !isLiked;
                  likeCount += isLiked ? 1 : -1;
                });
              },
              iconSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2), // Fine-tune text baseline
            child: Text(
              likeCount == 0 ? "Like" : "$likeCount",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),

    );
  }



  void _handleComment() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => CommentPage(
          username: widget.post.userName,
          userId: "@${widget.post.userTag}",
          userImage: widget.post.userImage,
          postTime: widget.post.postTime.toString(),
          postTitle: widget.post.postTitle,
          postContent: widget.post.postBody,
          postImage: widget.post.postImage,
          upvoteCount: likeCount,
          shareCount: shareCount,
          isUpvoted: isLiked,
          isDownvoted: false,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _handleShare() {
    setState(() {
      shareCount += 1;
    });
  }

  String _formatCount(int count) {
    if (count == 0) return "";
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k";
    }
    return count.toString();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the URL")),
      );
    }
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

  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenImagePage(
          imagePath: widget.post.postImage,
          heroTag: "image_${widget.post.id ?? UniqueKey()}",
          post: widget.post,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilePage(userId: widget.post.uid),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: (widget.post.userImage.isNotEmpty)
                            ? CachedNetworkImageProvider(widget.post.userImage)
                            : const AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(
                            widget.post.userName,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "@${widget.post.userTag}",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ]),

                        Text(
                          _getTimeAgo(widget.post.postTime.toDate()),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => PostOptions.show(
                        context,
                        postOwnerUid: widget.post.uid,
                        onDelete: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Post"),
                              content: const Text("Are you sure you want to delete this post?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            try {
                              final postId = widget.post.id;
                              final uid = widget.post.uid;
                              await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
                              await FirebaseFirestore.instance.collection('users').doc(uid).collection('posts').doc(postId).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Post deleted successfully.")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to delete post: $e")),
                              );
                            }
                          }
                        },
                      ),
                      icon: Icon(
                        Bootstrap.three_dots,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Post Title
                if (widget.post.postTitle.isNotEmpty)
                  Text(
                    widget.post.postTitle,
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                /// Post Body
                if (widget.post.postBody.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.post.postBody,
                    style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],

                /// Post Image
                if (widget.post.postImage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openFullScreenImage(context),
                    child: Hero(
                      tag: "image_${widget.post.id ?? UniqueKey()}",
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.post.postImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 250,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ],

                /// External Link
                if (widget.post.externalLink.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(MingCute.link_2_line),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Open external link", style: GoogleFonts.sanchez(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text(widget.post.externalLink, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _openUrl(widget.post.externalLink),
                          icon: const Icon(EvaIcons.external_link, size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                /// Actions: Like, Comment, Share
                Row(
                  children: [
                    _buildLikeButton(theme),

                    const Spacer(),
                    // COMMENT
                    // InkWell(
                    //   onTap: _handleComment,
                    //   borderRadius: BorderRadius.circular(20),
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Icon(OctIcons.comment_discussion, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    //         const SizedBox(width: 6),
                    //         Text(
                    //           commentCount == 0 ? "Comment" : _formatCount(commentCount),
                    //           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.9)),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    const Spacer(),
                    // SHARE
                    // InkWell(
                    //   onTap: _handleShare,
                    //   borderRadius: BorderRadius.circular(20),
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    //       borderRadius: BorderRadius.circular(20),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Icon(EvaIcons.share, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    //         const SizedBox(width: 6),
                    //         Text(
                    //           shareCount == 0 ? "Share" : _formatCount(shareCount),
                    //           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.9)),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: theme.colorScheme.onSurface.withOpacity(0.2), thickness: 0.5),
        ],
      ),
    );
  }
}