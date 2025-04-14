import 'package:flutter/material.dart';
import 'package:orbit/Pages/HomeFeed/post/postModel.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart'; // adjust path to your PostModel

class PostImageFullScreenPage extends StatefulWidget {
  final PostModel post;

  const PostImageFullScreenPage({Key? key, required this.post})
      : super(key: key);

  @override
  State<PostImageFullScreenPage> createState() =>
      _PostImageFullScreenPageState();
}

class _PostImageFullScreenPageState extends State<PostImageFullScreenPage> {
  bool _showFullText = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final heroTag = "image_${post.id}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 20) {
                Navigator.of(context).pop();
              }
            },
            child: Hero(
              tag: heroTag,
              child: PhotoView(
                imageProvider: NetworkImage(post.postImage),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Options Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
              onPressed: () {
                // You can show a bottom sheet or menu here
              },
            ),
          ),

          // Post content at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.postTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(
                      post.postBody,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      post.postBody,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    crossFadeState: _showFullText
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  if (post.postBody.length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFullText = !_showFullText;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          _showFullText ? 'Show less' : 'Read more',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
