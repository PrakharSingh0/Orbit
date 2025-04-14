import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/Profile/ProfilePage.dart';
import 'package:orbit/Pages/MiscellaneousPage/FollowerList.dart';
import 'package:orbit/Pages/MiscellaneousPage/Premium.dart';
import 'package:orbit/Pages/MiscellaneousPage/UserHistory.dart';
import 'package:orbit/Pages/MiscellaneousPage/UserSavedPost.dart';
import 'package:orbit/Pages/MiscellaneousPage/SettingsPage/Settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RightDrawer extends StatefulWidget {
  final String? userId;
  const RightDrawer({super.key, this.userId});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  bool _isOnline = true;
  String username = "";
  String userid = "";
  int follower=0;
  int following=0;
  String profilePic = "";
  String userUid = "";
  String? currentUserId;
  bool isOwnProfile = true;

  bool onlineStatus = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    isOwnProfile = widget.userId == null || widget.userId == currentUserId;
    fetchUser();
  }

  /// Fetch user data from Firestore
  Future<void> fetchUser() async {
    if (user == null) return;
    final uid = widget.userId ?? currentUserId;
    DocumentSnapshot userDoc =
    await _firestore.collection("users").doc(user!.uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      final followerCount = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get()
          .then((snap) => snap.docs.length);

      final followingCount = await _firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get()
          .then((snap) => snap.docs.length);

      setState(() {
        // Format username: Capitalize first letter of each word
        userUid=user!.uid;
        String rawUsername = userData.containsKey("userName") ? userData["userName"] : "Unknown";
        username = rawUsername
            .trim()
            .split(' ')
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
            .join(' ');

        // Format userTag: Ensure "@" is present and make it lowercase
        String rawUserTag = userData.containsKey("userTag") ? userData["userTag"] : "unknown";
        userid = rawUserTag.startsWith("@") ? rawUserTag.toLowerCase() : "@${rawUserTag.toLowerCase()}";
        onlineStatus = userData.containsKey("status") ? userData["status"] : false;
        profilePic = userData['profilePictureUrl'] ?? ''; // ✅ fixed
        _isOnline = onlineStatus;
        follower = followerCount;
        following = followingCount;

      });


    } else {
      debugPrint("User document does not exist.");
    }
  }


  /// Toggle online status and update in Firestore
  Future<void> updateOnlineStatus() async {
    if (user == null) return;

    bool newStatus = !_isOnline;

    await _firestore.collection("users").doc(user!.uid).update({
      "status": newStatus,
    });

    setState(() {
      _isOnline = newStatus;
    });
  }

  void _navigateFromDrawer(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Profile Section
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profilePic,
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: 112,
                                      height: 112,
                                      color: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    'assets/avatar_placeholder.png',
                                    width: 112,
                                    height: 112,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                     // Modern, clean color
                                      letterSpacing: 0.5, // Slight spacing for elegance
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),

                                  Text(
                                    userid,
                                    style: const TextStyle(
                                      color: Colors.blueGrey, // Stylish color
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "monospace", // Cool techy font
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Online Status Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isOnline ? Colors.green : Colors.grey,
                              ),
                            ),
                            onPressed: updateOnlineStatus,
                            child: Text(
                              _isOnline ? " Online Status: ON " : " Online Status: OFF ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _isOnline ? Colors.green : Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Follower & Following Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard("Follower", follower.toString(),
                              FollowListPage( userId: userUid,initialPageIndex: 0, currentUserId: widget.userId ?? currentUserId!,)),
                          _buildStatCard("Following", following.toString(),
                              FollowListPage( userId: userUid,initialPageIndex: 1, currentUserId: widget.userId ?? currentUserId!)),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(indent: 10, endIndent: 10),

                      // Drawer Menu Items
                      Column(
                        children: [
                          _buildDrawerItem(Icons.person, "Profile", ProfilePage(userId: user?.uid,)),
                          _buildDrawerItem(Icons.bookmark, "Saved", const SavedPostsPage ()),
                          _buildDrawerItem(Icons.history, "History", const UserHistory()),
                          _buildDrawerItem(Icons.workspace_premium, "Premium", const Premium()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(indent: 10, endIndent: 10),

            // Bottom Actions
            Column(
              children: [
                ListTile(
                  leading: const Icon(AntDesign.user_switch_outline),
                  title: const Text(" Switch User ",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  onTap: () => _showUserSwitchBottomSheet(context),
                ),
                ListTile(
                  leading: const Icon(EvaIcons.settings_outline),
                  title: const Text("Settings",style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  onTap: () => _navigateFromDrawer(context, const SettingPage()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      onTap: () => _navigateFromDrawer(context, page),
    );
  }

  Widget _buildStatCard(String title, String value, Widget page) {
    return GestureDetector(
      onTap: () => _navigateFromDrawer(context, page),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Bootstrap.people, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(value,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserSwitchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return const SizedBox(
          height: 200,
          child: Center(
            child: Text("User Switching Feature is Coming Soon ..."),
          ),
        );
      },
    );
  }
}
