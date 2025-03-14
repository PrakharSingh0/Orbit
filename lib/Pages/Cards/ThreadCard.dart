import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import 'CommentPage.dart';

class ThreadCard extends StatefulWidget {
  const ThreadCard({super.key});

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

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface, // Adaptive theme
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8), // Space for handle
            _dragHandle(), // Drag Handle at top
            _buildOption(Bootstrap.bookmark, "Save", theme, () {}),
            _buildOption(Bootstrap.person_x, "Block Account", theme, () {}),
            _buildOption(Bootstrap.flag, "Report Post", theme, () {}),
            _buildOption(Bootstrap.eye_slash, "Hide", theme, () {}),
            _buildOption(Bootstrap.share, "Share", theme, () {}),
            _buildOption(Bootstrap.repeat, "Repost", theme, () {}),
            const SizedBox(height: 12), // Bottom spacing
          ],
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String title, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Balanced padding
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurface.withOpacity(0.8)), // Bigger icon
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16, // Increased text size
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Drag Handle for Modal
  Widget _dragHandle() {
    return Container(
      width: 90,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    );
  }




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  onPressed: _showPostOptions,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset("assets/back.webp"),
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