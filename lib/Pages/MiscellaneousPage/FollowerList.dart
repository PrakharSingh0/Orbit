import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:orbit/Pages/HomeFeed/Profile/ProfilePage.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class FollowListPage extends StatefulWidget {
  final String userId;
  final String currentUserId;
  final int initialPageIndex;

  const FollowListPage({
    super.key,
    required this.userId,
    required this.currentUserId,
    this.initialPageIndex = 0,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialPageIndex.clamp(0, 1),
    );
    _tabController.addListener(_handleTabChange);
    _loadUsers();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() => _isLoading = true);
    _loadUsers();
  }

  void _loadUsers() async {
    final followersFuture = fetchUsers('followers');
    final followingFuture = fetchUsers('following');

    final results = await Future.wait([followersFuture, followingFuture]);

    setState(() {
      _followers = results[0];
      _following = results[1];
      _isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadUsers();
  }

  Future<List<Map<String, dynamic>>> fetchUsers(String type) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection(type)
        .get();

    List<Map<String, dynamic>> userList = [];

    for (var doc in snapshot.docs) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final isFollowingSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserId)
            .collection('following')
            .doc(doc.id)
            .get();

        final isFollowedBackSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('following')
            .doc(widget.currentUserId)
            .get();

        userList.add({
          ...userData,
          'uid': doc.id,
          'isFollowing': isFollowingSnapshot.exists,
          'followsYou': isFollowedBackSnapshot.exists,
        });
      }
    }

    return userList;
  }

  Route _createFadeSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, _, child) {
        const beginOffset = Offset(0.0, 0.1);
        const endOffset = Offset.zero;
        final offsetTween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.easeOut));

        final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
  }

  Widget buildUserTile(Map<String, dynamic> user) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        bool isFollowing = user['isFollowing'] ?? false;
        final bool followsYou = user['followsYou'] ?? false;
        final bool isInFollowingTab = _tabController.index == 1;
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        String buttonText = '';
        Color backgroundColor = Colors.transparent;
        Color textColor = colorScheme.onPrimary;

        if (isInFollowingTab) {
          buttonText = 'Unfollow';
          backgroundColor = colorScheme.surfaceVariant;
          textColor = Colors.red;
        } else if (followsYou && !isFollowing) {
          buttonText = 'Follow back';
          backgroundColor = Colors.blue;
          textColor = Colors.white;
        } else if (isFollowing) {
          buttonText = 'Following';
          backgroundColor = Colors.grey; // neutral background
          textColor = colorScheme.onSurface; // subtle text
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () {
            Navigator.of(context).push(
              _createFadeSlideRoute(ProfilePage(userId: user['uid'])),
            );
          },
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[300],
            backgroundImage: (user['profilePictureUrl'] != null &&
                user['profilePictureUrl'].toString().isNotEmpty)
                ? NetworkImage(user['profilePictureUrl'])
                : null,
            child: (user['profilePictureUrl'] == null ||
                user['profilePictureUrl'].toString().isEmpty)
                ? const Icon(Icons.person, size: 26, color: Colors.white)
                : null,
          ),
          title: Text(
            user['userName'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onBackground,
            ),
          ),
          subtitle: Text(
            '@${user['userTag'] ?? ''}',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: buttonText.isNotEmpty
              ? TextButton(
            onPressed: () async {
              final followRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserId)
                  .collection('following')
                  .doc(user['uid']);

              final followerRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user['uid'])
                  .collection('followers')
                  .doc(widget.currentUserId);

              if (isFollowing || isInFollowingTab) {
                await followRef.delete();
                await followerRef.delete();
                isFollowing = false;
              } else {
                await followRef.set({});
                await followerRef.set({});
                isFollowing = true;
              }

              setInnerState(() {
                user['isFollowing'] = isFollowing;
              });

              setState(() => _loadUsers());
            },
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              : null,
        );
      },
    );
  }



  Widget buildShimmerList() {
    final baseColor = Colors.grey.shade400;
    final highlightColor = Colors.blue.shade200;

    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: const CircleAvatar(radius: 26, backgroundColor: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildUserList(List<Map<String, dynamic>> users) {
    if (_isLoading) return buildShimmerList();
    if (users.isEmpty) {
      return const Center(child: Text("No users found"));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => buildUserTile(users[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Followers & Following"),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent.shade400, // 💠 Cool label color
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: Colors.blueAccent.shade400, // 💠 Cool indicator color
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Followers"),
            Tab(text: "Following"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          buildUserList(_followers),
          buildUserList(_following),
        ],
      ),
    );
  }
}
