import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String uid;
  final String userName;
  final String userTag;
  final Timestamp postTime;
  final String postTitle;
  final String postBody;
  final String userImage;
  final String postImage;
  final String externalLink;

  PostModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.userTag,
    required this.postTime,
    required this.postTitle,
    required this.postBody,
    required this.userImage,
    required this.postImage,
    required this.externalLink,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      uid: map['uid'],
      userName: map['userName'] ?? 'Unknown',
      userTag: map['userTag'] ?? '',
      postTime: map['timestamp']?? '',
      postTitle: map['caption'] ?? '',
      postBody: map['body'] ?? '',
      userImage: map['profilePictureUrl'] ?? '',
      postImage: map['imageUrl'] ?? '',
      externalLink: map['link'] ?? '',
    );
  }
}
