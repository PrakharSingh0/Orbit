import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../MiscellaneousPage/FollowerList.dart';
import 'EditProfilePage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isExpanded = false;

  String userName = 'Loading...';
  String userTag = '';
  String bio = 'Add Your Bio ... ';
  String dob = 'Not set';
  String joined = 'Not set';
  String location = 'Not set';
  String profession = 'Not set';
  String profilePic = '';
  int follower = 0;
  int following = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
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

          setState(() {
            userName = data['userName'] ?? 'No name';
            userTag = data['userTag'] ?? 'unknown';

            final rawBio = data['bio']?.toString().trim();
            bio = (rawBio != null && rawBio.isNotEmpty) ? rawBio : 'Add your Bio ...';

            dob = formattedDob;
            location = data['location'] ?? 'Not set';
            profession = data['profession'] ?? 'Not set';
            joined = createdAt != null
                ? DateFormat('MMMM yyyy').format(createdAt.toDate())
                : 'Not set';
            profilePic = data['profilePic'] ?? '';
            follower = data['follower'] ?? 0;
            following = data['following'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => isLoading = false);
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
          IconButton(
            onPressed: () {},
            icon: const Icon(BoxIcons.bx_menu_alt_right, color: Colors.white),
          ),
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
              // Cover section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
                      image: DecorationImage(
                        image: AssetImage("assets/back.webp"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        const BorderRadius.only(bottomRight: Radius.circular(25)),
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
                          color: theme.brightness == Brightness.light
                              ? Colors.white
                              : Colors.black54,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : const AssetImage("assets/avatar.jpg") as ImageProvider,
                        radius: 45,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 0),

              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textColor)),
                    Text('@$userTag',
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 10),
                    buildBio(bio),
                    const SizedBox(height: 10),

                    // Details
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildStatCard("Posts", following.toString(), Icons.grid_view_rounded, const UserFollowerList(initialTabIndex: 1)),
                        const SizedBox(width: 20),
                        _buildStatCard("Follower", follower.toString(), Icons.person_add_alt_1_rounded, const UserFollowerList(initialTabIndex: 0)),
                        const SizedBox(width: 20),
                        _buildStatCard("Following", following.toString(), Icons.person_rounded, const UserFollowerList(initialTabIndex: 1)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customProfileButton(
                          onPressed: () => print("Share Profile Clicked"),
                          icon: Bootstrap.share,
                          label: "Share Profile",
                        ),
                        const SizedBox(width: 15),
                        customProfileButton(
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfilePage()),
                            );
                            if (updated == true) {
                              fetchUserData(); // Auto-refresh
                            }
                          },

                          icon: Clarity.edit_line,
                          label: "Edit Profile",
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              // Navigation Tabs
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text("Thread",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(width: 20),
                      Text("Media",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(width: 20),
                      Text("Comment",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(width: 20),
                      Text("Liked",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(width: 20),
                      Text("Social",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
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

  Widget customProfileButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
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
            TextSpan(
              text: isExpanded ? bio : words.take(maxWords).join(' '),
            ),
            if (shouldTruncate)
              TextSpan(
                text: isExpanded ? " Show less" : " Show More ...",
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12, color: Colors.blueGrey),
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
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
