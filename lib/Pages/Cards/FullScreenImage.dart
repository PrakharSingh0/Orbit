import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:readmore/readmore.dart';

import '../HomeFeed/post/postModel.dart';
import 'PostOption.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imagePath;
  final String heroTag;
  final PostModel post;

  const FullScreenImagePage({
    super.key,
    required this.imagePath,
    required this.heroTag,
    required this.post,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage>
    with SingleTickerProviderStateMixin {
  late PhotoViewController _photoViewController;
  bool _isZoomed = false;
  double _dragOffset = 0.0;
  bool _uiVisible = true;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;
  int upvotes = 0;

  @override
  void initState() {
    super.initState();

    _photoViewController = PhotoViewController();
    _photoViewController.outputStateStream.listen((state) {
      setState(() {
        _isZoomed = state.scale! > 1.0;
      });
    });

    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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


  void _resetDragOffset() {
    _resetAnimation =
    Tween<double>(begin: _dragOffset, end: 0.0).animate(_resetController)
      ..addListener(() {
        setState(() {
          _dragOffset = _resetAnimation.value;
        });
      });

    _resetController.forward(from: 0);
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _uiVisible = !_uiVisible),
        child: Stack(
          children: [
            // Hero image with drag offset
            Hero(
              tag: widget.heroTag,
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(widget.imagePath),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
                  controller: _photoViewController,
                ),
              ),
            ),

            // Back button
            if (_uiVisible)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                ),
              ),

            // Options menu
            if (_uiVisible)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 12,
                child: IconButton(
                  onPressed: () => PostOptions.show(
                    context,
                    postOwnerUid: post.uid,
                    onDelete: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Post"),
                          content: const Text("Are you sure you want to delete this post?"),
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
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(post.id)
                            .delete();
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(post.uid)
                            .collection('posts')
                            .doc(post.id)
                            .delete();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Post deleted.")),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  icon: Icon(Bootstrap.three_dots, size: 20, color: Colors.white70),
                ),
              ),

            // Bottom Info
            if (_uiVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    // color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: (widget.post.userImage.isNotEmpty)
                                ? CachedNetworkImageProvider(widget.post.userImage)
                                : const AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "@${widget.post.userTag} • ${_getTimeAgo(widget.post.postTime.toDate())}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Post Title
                      if (post.postTitle.isNotEmpty)
                        Text(
                          post.postTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 6),

                      // Post Body
                      if (post.postBody.isNotEmpty)
                        ReadMoreText(
                          post.postBody,
                          trimLines: 2,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: "Read more",
                          trimExpandedText: "Show less",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          moreStyle: const TextStyle(color: Colors.blueAccent),
                          lessStyle: const TextStyle(color: Colors.blueAccent),
                        ),
                    ],
                  ),
                ),
              ),

            if (_uiVisible)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 + 40, // was +80
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      icon: Icons.thumb_up_alt_outlined,
                      label: "$upvotes",
                      onTap: () => setState(() => upvotes++),
                    ),
                    const SizedBox(height: 20),

                    _ActionIcon(
                      icon: Icons.mode_comment_outlined,
                      label: "0",
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("Comments coming soon...", style: TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    _ActionIcon(
                      icon: Icons.share_outlined,
                      label: "Share",
                      onTap: () {
                        // Add repost logic here
                      },
                    ),
                  ],
                ),
              ),



            // Drag gesture with safe zone
            if (!_isZoomed)
              Positioned.fill(
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    final dragY = details.localPosition.dy;
                    if (dragY < MediaQuery.of(context).size.height * 0.3 ||
                        dragY > MediaQuery.of(context).size.height * 0.7) {
                      setState(() {
                        _dragOffset += details.primaryDelta!;
                      });
                    }
                  },
                  onVerticalDragEnd: (_) {
                    if (_dragOffset.abs() > 100) {
                      Navigator.pop(context);
                    } else {
                      _resetDragOffset();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
