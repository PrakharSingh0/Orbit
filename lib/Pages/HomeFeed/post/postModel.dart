class PostModel {
  final String id;
  final String userName;
  final String userTag;
  final String postTime;
  final String postTitle;
  final String postBody;
  final String userImage;
  final String postImage;
  final String externalLink;

  PostModel({
    required this.id,
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
      userName: map['userName'] ?? 'Unknown',
      userTag: map['userTag'] ?? '',
      postTime: map['timestamp']?.toDate().toString() ?? '',
      postTitle: map['caption'] ?? '',
      postBody: map['body'] ?? '',
      userImage: map['profilePictureUrl'] ?? '',
      postImage: map['imageUrl'] ?? '',
      externalLink: map['link'] ?? '',
    );
  }
}
