import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/Cards/FullScreenImage.dart';

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
          postTime: widget.post.postTime,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header ---
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (widget.post.userImage.isNotEmpty)
                      ? NetworkImage(widget.post.userImage)
                      : const AssetImage("assets/avatar_placeholder.png")
                  as ImageProvider,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "@${widget.post.userTag}",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => PostOptions.show(context),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            if (widget.post.postBody.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                widget.post.postBody,
                style: const TextStyle(fontSize: 13),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        "assets/avatar.jpg", // Placeholder
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("External Link Headline",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text("Link Description...",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
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
