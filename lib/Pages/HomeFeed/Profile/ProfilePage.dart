import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../MiscellaneousPage/FollowerList.dart';
import 'EditProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key,required this.userId,});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isExpanded = false;

  String userName = 'Loading...';
  String userTag = '';
  String bio = 'Add Your Bio ... ';
  String dob = 'Not set';
  String joined = 'Not set';
  String location = 'Not set';
  String profession = 'Not set';
  String profilePic = '';
  String profileBanner = '';
  int follower = 0;
  int following = 0;
  bool isLoading = true;

  String? currentUserId;
  bool isOwnProfile = true;
  bool isFollowing = false;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    isOwnProfile = widget.userId == null || widget.userId == currentUserId;
    fetchUserData();
    if (!isOwnProfile) checkFollowingStatus();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final uid = widget.userId ?? currentUserId;
      if (uid != null) {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          Timestamp? createdAt = data['createdAt'] is Timestamp ? data['createdAt'] : null;

          final rawDob = data['dob'];
          String formattedDob = 'Not set';
          if (rawDob != null && rawDob is Timestamp) {
            formattedDob = DateFormat('dd MMMM yyyy').format(rawDob.toDate());
          } else if (rawDob is String && rawDob.trim().isNotEmpty) {
            try {
              final parsedDate = DateTime.parse(rawDob);
              formattedDob = DateFormat('dd MMMM yyyy').format(parsedDate);
            } catch (e) {
              formattedDob = rawDob;
            }
          }

          // Count follower and following documents
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
            userName = data['userName'] ?? 'No name';
            userTag = data['userTag'] ?? 'unknown';

            final rawBio = data['bio']?.toString().trim();
            bio = (rawBio != null && rawBio.isNotEmpty)
                ? rawBio
                : 'Add your Bio ...';

            dob = formattedDob;
            location = data['location'] ?? 'Not set';
            profession = data['profession'] ?? 'Not set';
            joined = createdAt != null
                ? DateFormat('MMMM yyyy').format(createdAt.toDate())
                : 'Not set';
            profilePic = data['profilePictureUrl'] ?? '';
            profileBanner = data['bannerImageUrl'] ?? '';
            follower = followerCount;
            following = followingCount;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> checkFollowingStatus() async {
    final currentUid = currentUserId;
    final targetUid = widget.userId;
    if (currentUid == null || targetUid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .get();

    setState(() => isFollowing = doc.exists);
  }

  Future<void> toggleFollow() async {
    final currentUid = currentUserId;
    final targetUid = widget.userId;
    if (currentUid == null || targetUid == null) return;

    final userRef = FirebaseFirestore.instance.collection('users');
    final followingRef = userRef.doc(currentUid).collection('following').doc(targetUid);
    final followerRef = userRef.doc(targetUid).collection('followers').doc(currentUid);

    try {
      if (isFollowing) {
        await followingRef.delete();
        await followerRef.delete();

        await userRef.doc(currentUid).update({'following': FieldValue.increment(-1)});
        await userRef.doc(targetUid).update({'follower': FieldValue.increment(-1)});
      } else {
        await followingRef.set({'followedAt': Timestamp.now()});
        await followerRef.set({'followedAt': Timestamp.now()});

        await userRef.doc(currentUid).update({'following': FieldValue.increment(1)});
        await userRef.doc(targetUid).update({'follower': FieldValue.increment(1)});
      }

      setState(() {
        isFollowing = !isFollowing;
        follower += isFollowing ? 1 : -1;
      });
    } catch (e) {
      print("Error updating follow status: $e");
    }
  }

  void _navigateFromSide(BuildContext context, Widget page) {
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
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        actions: [
          if (isOwnProfile)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: const BorderSide(color: Colors.white, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                if (updated == true) fetchUserData();
              },
              icon: const Icon(EvaIcons.edit, size: 18),
              label: const Text("Edit"),
            ),
          if (!isOwnProfile)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                foregroundColor: Colors.white,
              ),
              onPressed: toggleFollow,
              child: Text(isFollowing ? 'Following' : 'Follow'),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25)),
                      image: DecorationImage(
                        image: (profileBanner.isNotEmpty)
                            ? CachedNetworkImageProvider(profileBanner)
                            : const AssetImage("assets/background_placeholder.png") as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25)),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: theme.brightness == Brightness.light ? Colors.white : Colors.black54,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 56,
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
                      )
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor)),
                    Text('@$userTag', style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 10),
                    buildBio(bio),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _profileDetail(Icons.work, profession),
                            _profileDetail(Icons.cake, "Born: $dob"),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _profileDetail(Icons.calendar_today, "Joined: $joined"),
                            _profileDetail(Icons.location_on, location),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard("Posts", "0", Icons.grid_view_rounded, test()),
                        const SizedBox(width: 20),
                        _buildStatCard(
                          "Follower",
                          follower.toString(),
                          Icons.person_add_alt_1_rounded,
                          FollowListPage( userId: widget.userId ?? currentUserId!,initialPageIndex: 0, currentUserId: currentUserUid,),
                        ),
                        const SizedBox(width: 20),
                        _buildStatCard(
                          "Following",
                          following.toString(),
                          Icons.person_rounded,
                          FollowListPage( userId: widget.userId ?? currentUserId!,initialPageIndex: 1, currentUserId: currentUserUid),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget buildBio(String bio) {
    const int maxWords = 20;
    List<String> words = bio.split(' ');
    bool shouldTruncate = words.length > maxWords;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
          children: [
            TextSpan(text: isExpanded ? bio : words.take(maxWords).join(' ')),
            if (shouldTruncate)
              TextSpan(
                text: isExpanded ? " Show less" : " Show More ...",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigateFromSide(context, page),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget test() {
    return Placeholder();
  }
}
