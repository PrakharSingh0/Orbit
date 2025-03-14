import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:readmore/readmore.dart';

import 'PostOption.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imagePath;
  final String heroTag; // Unique tag for Hero animation

  const FullScreenImagePage({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late PhotoViewController _photoViewController;
  bool _isZoomed = false; // Track if the image is zoomed
  double _dragOffset = 0.0; // Track the vertical drag offset

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _photoViewController.outputStateStream.listen((state) {
      // Update zoom state
      setState(() {
        _isZoomed = state.scale! > 1.0; // Check if the image is zoomed
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Hero Animation for Image
          Hero(
            tag: widget.heroTag, // Use the unique tag
            child: Transform.translate(
              offset: Offset(0, _dragOffset), // Apply drag offset
              child: PhotoView(
                imageProvider: AssetImage(widget.imagePath),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                backgroundDecoration: BoxDecoration(color: Colors.transparent),
                controller: _photoViewController, // Pass the controller
              ),
            ),
          ),

          // Close Button (Always visible)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // More Options Button (Always visible)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: () => PostOptions.show(context),
              icon: Icon(
                Bootstrap.three_dots,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Post Details at Bottom (Always visible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Title
                  Text(
                    "Post Heading goes here...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Post Body (Expandable)
                  ReadMoreText(
                    "Post Body content goes here. This is a sample post description...",
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: "Show more",
                    trimExpandedText: "Show less",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drag-to-Close Gesture Detector
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (!_isZoomed) {
                  // Allow full-screen drag when not zoomed
                  setState(() {
                    _dragOffset += details.primaryDelta!;
                  });
                } else {
                  // Allow drag only in the top 20% of the screen when zoomed
                  if (details.localPosition.dy < MediaQuery.of(context).size.height * 0.2) {
                    setState(() {
                      _dragOffset += details.primaryDelta!;
                    });
                  }
                }
              },
              onVerticalDragEnd: (details) {
                if (_dragOffset > 100) {
                  // Close the page if dragged down significantly
                  Navigator.pop(context);
                } else {
                  // Reset drag offset
                  setState(() {
                    _dragOffset = 0.0;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}