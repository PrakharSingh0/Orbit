import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/Cards/FullScreenImage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Profile/ProfilePage.dart';
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
  int upvoteCount = 20;
  int shareCount = 0;
  int commentCount = 0;
  bool isUpvoted = false;
  bool isDownvoted = false;

  void _handleUpvote() {
    setState(() {
      if (isUpvoted) {
        upvoteCount -= 1;
        isUpvoted = false;
      } else {
        upvoteCount += 1;
        isUpvoted = true;
        if (isDownvoted) {
          upvoteCount += 1;
          isDownvoted = false;
        }
      }
    });
  }

  void _handleDownvote() {
    setState(() {
      if (isDownvoted) {
        upvoteCount += 1;
        isDownvoted = false;
      } else {
        upvoteCount -= 1;
        isDownvoted = true;
        if (isUpvoted) {
          upvoteCount -= 1;
          isUpvoted = false;
        }
      }
    });
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
          upvoteCount: upvoteCount,
          shareCount: shareCount,
          isUpvoted: isUpvoted,
          isDownvoted: isDownvoted,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minute${diff.inMinutes > 1 ? "s" : ""} ago";
    if (diff.inHours < 24) return "${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago";
    if (diff.inDays < 7) return "${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? "s" : ""} ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? "s" : ""} ago";
    return "${(diff.inDays / 365).floor()} year${(diff.inDays / 365).floor() > 1 ? "s" : ""} ago";
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

  Future<void> _openUrl(Url) async {
    final Uri url = Uri.parse(Url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the URL")),
      );
    }
  }

  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenImagePage(
              imagePath: widget.post.postImage,
              heroTag: "image_${widget.post.id ?? UniqueKey()}",
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
          var scaleTween = Tween<double>(begin: 0.9, end: 1.0);
          return FadeTransition(
            opacity: fadeTween.animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: ScaleTransition(
              scale: scaleTween.animate(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header ---
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(
                          userId: widget.post.uid,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: (widget.post.userImage.isNotEmpty)
                        ? NetworkImage(widget.post.userImage)
                        : const AssetImage("assets/avatar_placeholder.png")
                    as ImageProvider,
                  ),
                ),

                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children:[ Text(
                        widget.post.userName,
                        style: GoogleFonts.aBeeZee(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                        const SizedBox(width: 8,),
                        Text(
                          "@${widget.post.userTag}",
                          style: GoogleFonts.aBeeZee(
                            fontWeight: FontWeight.w300,fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((0.4*255).toInt()),
                          ),
                        ),
                    ]),
                    Text(
                      _getTimeAgo(widget.post.postTime.toDate()),
                      style: GoogleFonts.aBeeZee(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha((0.4 * 255).toInt()),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => PostOptions.show(
                    context,
                    postOwnerUid: widget.post.uid, // pass the UID of the post's owner
                      onDelete: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Post"),
                            content: const Text("Are you sure you want to delete this post? This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          try {
                            final postId =  widget.post.id;
                            final uid =  widget.post.uid;

                            // Delete from global posts collection
                            await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

                            // Delete from user's posts subcollection
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('posts')
                                .doc(postId)
                                .delete();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Post deleted successfully.")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to delete post: $e")),
                            );
                          }
                        }
                      }

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

            /// --- Text Content ---
            if (widget.post.postTitle.isNotEmpty)
              Text(
                widget.post.postTitle,
                style: GoogleFonts.abel(
                  fontSize: 18,fontWeight: FontWeight.w600,
                ),
              ),
            if (widget.post.postBody.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                widget.post.postBody,
                style: GoogleFonts.actor(fontSize: 14,fontWeight: FontWeight.w300),
              ),
            ],

            /// --- Image (Optional) ---
            if (widget.post.postImage.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openFullScreenImage(context),
                child: Hero(
                  tag: "image_${widget.post.id ?? UniqueKey()}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        minWidth: double.infinity,
                      ),
                      child: Image.network(
                        widget.post.postImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            /// --- External Link Preview (Optional) ---
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
                           Text("Open external link ",
                              style: GoogleFonts.sanchez(fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),),
                          Text(widget.post.externalLink ,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _openUrl(widget.post.externalLink );
                      },
                      icon: const Icon(
                        EvaIcons.external_link,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            /// --- Actions Row ---
            Row(
              children: [
                // Upvote / Downvote
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _handleUpvote,
                        child: Icon(
                          BoxIcons.bx_upvote,
                          size: 18,
                          color: isUpvoted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        upvoteCount == 0 ? "Upvote" : _formatCount(upvoteCount),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _handleDownvote,
                        child: Icon(
                          BoxIcons.bx_downvote,
                          size: 18,
                          color: isDownvoted
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Comment Button
                InkWell(
                  onTap: _handleComment,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(OctIcons.comment_discussion,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(
                          commentCount == 0 ? "Comment" : _formatCount(commentCount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Share Button
                InkWell(
                  onTap: _handleShare,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(EvaIcons.share,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        const SizedBox(width: 6),
                        Text(
                          shareCount == 0 ? "Share" : _formatCount(shareCount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Divider(),
          ],
        ),
      ),
    );
  }
}
