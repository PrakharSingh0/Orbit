import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:readmore/readmore.dart';

import '../HomeFeed/post/LikedUsersDialog.dart';
import '../HomeFeed/post/postModel.dart';
import 'PostOption.dart';

// Same imports...

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

class _FullScreenImagePageState extends State<FullScreenImagePage> with TickerProviderStateMixin {
  late final PhotoViewController _photoController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  bool _isZoomed = false;
  double _dragOffset = 0.0;
  bool _uiVisible = true;

  int _upvotes = 0;
  bool _isLiked = false;

  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();

    _photoController = PhotoViewController()
      ..outputStateStream.listen((state) {
        setState(() => _isZoomed = state.scale! > 1.0);
      });

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.3)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_scaleController);

    _fetchInitialLikeState();
  }

  Future<void> _fetchInitialLikeState() async {
    final docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(currentUserId);

    final snapshot = await docRef.get();
    final likesSnapshot = await docRef.parent.get();

    setState(() {
      _isLiked = snapshot.exists;
      _upvotes = likesSnapshot.size;
    });
  }

  Future<void> _handleLike() async {
    final likeDoc = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(currentUserId);

    final liked = _isLiked;

    setState(() {
      _isLiked = !liked;
      _upvotes += liked ? -1 : 1;
    });

    _scaleController.forward(from: 0);

    try {
      if (!liked) {
        await likeDoc.set({'uid': currentUserId, 'likedAt': FieldValue.serverTimestamp()});
      } else {
        await likeDoc.delete();
      }
    } catch (e) {
      // Optionally handle error and revert UI
    }
  }

  void _openLikedByPage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => LikedByPage(
          postId: widget.post.id,
          scrollController: controller,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  @override
  void dispose() {
    _photoController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _uiVisible = !_uiVisible),
        onVerticalDragUpdate: (details) {
          if (!_isZoomed) {
            setState(() {
              _dragOffset = (_dragOffset + details.delta.dy).clamp(-100.0, 100.0);
            });
          }
        },
        onVerticalDragEnd: (_) {
          if (_dragOffset.abs() > 80) {
            Navigator.pop(context);
          } else {
            setState(() => _dragOffset = 0.0);
          }
        },
        child: Stack(
          children: [
            _buildImageViewer(),
            if (_uiVisible) ...[
              _buildTopButtons(post),
              _buildBottomOverlay(post),
              _buildRightActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(0, _dragOffset, 0),
      curve: Curves.easeOut,
      child: Hero(
        tag: widget.heroTag,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.imagePath),
          controller: _photoController,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTopButtons(PostModel post) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Bootstrap.three_dots, color: Colors.white70, size: 20),
            onPressed: () => PostOptions.show(
              context,
              postOwnerUid: post.uid,
              onDelete: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Post"),
                    content: const Text("Are you sure you want to delete this post?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseFirestore.instance.collection('posts').doc(post.id).delete();
                  await FirebaseFirestore.instance.collection('users').doc(post.uid).collection('posts').doc(post.id).delete();
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(PostModel post) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userImage.isNotEmpty
                      ? CachedNetworkImageProvider(post.userImage)
                      : const AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    Text("@${post.userTag} • ${_getTimeAgo(post.postTime.toDate())}",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (post.postTitle.isNotEmpty)
              Text(post.postTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            if (post.postBody.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ReadMoreText(
                  post.postBody,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Read more',
                  trimExpandedText: 'Show less',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14),
                  moreStyle: const TextStyle(color: Colors.blueAccent),
                  lessStyle: const TextStyle(color: Colors.blueAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightActions() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 120,
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _handleLike,
              onLongPress: _openLikedByPage,
              child: Column(
                children: [
                  Icon(_isLiked ? AntDesign.like_fill : AntDesign.like_outline,
                      color: _isLiked ? Colors.blueAccent : Colors.white, size: 28),
                  const SizedBox(height: 4),
                  Text("$_upvotes", style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // _ActionIcon(
          //   icon: Icons.mode_comment_outlined,
          //   label: "0", // Can dynamically update later
          //   onTap: () {
          //     showModalBottomSheet(
          //       context: context,
          //       backgroundColor: Colors.black,
          //       shape: const RoundedRectangleBorder(
          //         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          //       ),
          //       builder: (_) => const Padding(
          //         padding: EdgeInsets.all(16),
          //         child: Text("Comments coming soon...", style: TextStyle(color: Colors.white)),
          //       ),
          //     );
          //   },
          // ),
          // const SizedBox(height: 24),
          // _ActionIcon(icon: Icons.share_outlined, label: "Share", onTap: () {}),
        ],
      ),
    );
  }
}
