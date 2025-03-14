import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class CommentPage extends StatefulWidget {
  final String username;
  final String userId;
  final String userImage;
  final String postTime;
  final String postTitle;
  final String postContent;
  final String postImage;
  final int upvoteCount;
  final int shareCount;
  final bool isUpvoted;
  final bool isDownvoted;

  const CommentPage({
    super.key,
    required this.username,
    required this.userId,
    required this.userImage,
    required this.postTime,
    required this.postTitle,
    required this.postContent,
    required this.postImage,
    required this.upvoteCount,
    required this.shareCount,
    required this.isUpvoted,
    required this.isDownvoted,
  });

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Map<String, dynamic>> comments = [
    {
      "username": "Commenter1",
      "userImage": "assets/avatar.jpg",
      "comment": "This is a great post!",
      "upvotes": 12,
      "isUpvoted": false,
      "isDownvoted": false,
    },
    {
      "username": "Commenter2",
      "userImage": "assets/avatar.jpg",
      "comment": "I totally agree!",
      "upvotes": 5,
      "isUpvoted": false,
      "isDownvoted": false,
    },
  ];

  void _toggleUpvote(int index) {
    setState(() {
      if (comments[index]['isUpvoted']) {
        comments[index]['upvotes'] -= 1;
        comments[index]['isUpvoted'] = false;
      } else {
        comments[index]['upvotes'] += 1;
        comments[index]['isUpvoted'] = true;
        if (comments[index]['isDownvoted']) {
          comments[index]['upvotes'] += 1;
          comments[index]['isDownvoted'] = false;
        }
      }
    });
  }

  void _toggleDownvote(int index) {
    setState(() {
      if (comments[index]['isDownvoted']) {
        comments[index]['upvotes'] += 1;
        comments[index]['isDownvoted'] = false;
      } else {
        comments[index]['upvotes'] -= 1;
        comments[index]['isDownvoted'] = true;
        if (comments[index]['isUpvoted']) {
          comments[index]['upvotes'] -= 1;
          comments[index]['isUpvoted'] = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Animation for Post
              Hero(
                tag: "post-hero",
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(widget.userImage),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  widget.postTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Post Content
                        Text(
                          widget.postTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.postContent,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 8),

                        // Post Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(widget.postImage),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Comment Section
              Text(
                "Comments",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(comments[index]['userImage']),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comments[index]['username'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comments[index]['comment'],
                                style: TextStyle(fontSize: 14),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Bootstrap.arrow_up,
                                      size: 18,
                                      color: comments[index]['isUpvoted']
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    onPressed: () => _toggleUpvote(index),
                                  ),
                                  Text("${comments[index]['upvotes']}"),
                                  IconButton(
                                    icon: Icon(
                                      Bootstrap.arrow_down,
                                      size: 18,
                                      color: comments[index]['isDownvoted']
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    onPressed: () => _toggleDownvote(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
