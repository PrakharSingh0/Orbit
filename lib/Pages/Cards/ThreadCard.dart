import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/Cards/FullScreenImage.dart';
import 'package:photo_view/photo_view.dart'; // For full-screen image viewer
import 'package:readmore/readmore.dart';

import 'CommentPage.dart';
import 'PostOption.dart'; // For expandable text

class ThreadCard extends StatefulWidget {
  const ThreadCard({super.key});

  @override
  State<ThreadCard> createState() => _ThreadCardState();
}

class _ThreadCardState extends State<ThreadCard> {
  String ImageUrl="";
  int upvoteCount = 20;
  int shareCount = 0;
  int commentCount = 0;
  bool isUpvoted = false;
  bool isDownvoted = false;
  var imagePath="assets/a1.webp";
  var postId=1;

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
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => CommentPage(
          username: "UserName",
          userId: "@UserID",
          userImage: "assets/avatar.jpg",
          postTime: "2h ago • 1.2k views",
          postTitle: "Post Heading goes here...",
          postContent: "Post Body content goes here...",
          postImage: "assets/back.webp",
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
    if (count == 0) return ""; // Hide count if 0
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k";
    }
    return count.toString();
  }


  // Open Full-Screen Image Viewer
  void _openFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenImagePage(
          imagePath: imagePath,
          heroTag: "image_$postId",
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Scale + Fade Animation
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

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Profile + @UserID + Name + Time + Menu
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/avatar.jpg"),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "UserName  ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: "@UserID",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "2h ago • 1.2k views",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: ()=>PostOptions.show(context),
                  icon: Icon(
                    Bootstrap.three_dots,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Post Content
            const Text(
              "Post Heading goes here...",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              "Post Body content goes here. This is a sample post description...",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),

            // Image (if any)
            GestureDetector(
              onTap: () => _openFullScreenImage(context), // Open full-screen image on tap
              child: Hero(
                tag: "threadImage", // Unique tag for Hero animation
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 300,
                      minWidth: double.infinity, // Maximum height of 300
                    ),
                    child: Image.asset(
                      "assets/a1.webp",
                      fit: BoxFit.cover, // Ensures the image covers the available space
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // External Link Preview
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
                      "assets/avatar.jpg",
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
                        Text(
                          "External Link Headline (optional)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "External Link Description goes here...",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      EvaIcons.external_link,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Bar (Likes, Comments, Share, Save)
            Row(
              children: [
                // Upvote & Downvote Box (Outlined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)), // Outline
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

                // Comment Button (Outlined)
                InkWell(
                  onTap: _handleComment,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)), // Outline
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          OctIcons.comment_discussion,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
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

                // Share Button (Outlined)
                InkWell(
                  onTap: _handleShare,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3)), // Outline
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          EvaIcons.share,
                          size: 18,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
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
          ],
        ),
      ),
    );
  }
}