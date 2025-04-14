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
  String _searchQuery = '';
  bool _isLoading = true;

  final Map<String, dynamic> _userCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialPageIndex.clamp(0, 1),
    );
    _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final followersFuture = _fetchUsers('followers');
    final followingFuture = _fetchUsers('following');

    final results = await Future.wait([followersFuture, followingFuture]);

    setState(() {
      _followers = results[0];
      _following = results[1];
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchUsers(String type) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection(type)
        .get();

    List<Map<String, dynamic>> userList = [];

    for (var doc in snapshot.docs) {
      final uid = doc.id;

      if (_userCache.containsKey(uid)) {
        userList.add(_userCache[uid]);
        continue;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) continue;

      final userData = userDoc.data()!;
      final isFollowingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('following')
          .doc(uid)
          .get();

      final followsYouSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('following')
          .doc(widget.currentUserId)
          .get();

      final userMap = {
        ...userData,
        'uid': uid,
        'isFollowing': isFollowingSnapshot.exists,
        'followsYou': followsYouSnapshot.exists,
      };

      _userCache[uid] = userMap;
      userList.add(userMap);
    }

    return userList;
  }

  void _handleUnfollow(String uid) async {
    final user = _userCache[uid];
    if (user == null) return;

    final confirm = await showDialog(
      context: context,
      builder: (_) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Theme.of(context).colorScheme.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24), // Reduced width
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 34,
                  backgroundImage: (user['profilePictureUrl'] != null &&
                      user['profilePictureUrl'].toString().isNotEmpty)
                      ? NetworkImage(user['profilePictureUrl'])
                      : null,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: (user['profilePictureUrl'] == null ||
                      user['profilePictureUrl'].toString().isEmpty)
                      ? Icon(Icons.person, size: 38, color: Theme.of(context).colorScheme.onBackground)
                      : null,
                ),
                const SizedBox(height: 12),

                // Name & Tag
                Text(
                  user['userName'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${user['userTag']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 12),

                // Info Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'You won’t see their posts anymore',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Unfollow Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.person_remove_rounded, size: 18),
                  label: const Text('Unfollow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),

                const SizedBox(height: 8),

                // Cancel Button
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancel'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(40),
                    textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );


      },
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('following')
        .doc(uid)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(widget.currentUserId)
        .delete();

    setState(() {
      _userCache[uid]?['isFollowing'] = false;
    });

    await _loadUsers();
  }


  Future<void> _followBack(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('following')
        .doc(uid)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(widget.currentUserId)
        .set({});

    setState(() {
      _userCache[uid]?['isFollowing'] = true;
    });

    await _loadUsers();
  }

  Widget _buildUserTile(Map<String, dynamic> user, bool isFollowerTab) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFollowing = user['isFollowing'] ?? false;
    final followsYou = user['followsYou'] ?? false;
    final uid = user['uid'];

    String? buttonText;
    VoidCallback? onPressed;

    if (isFollowerTab && !isFollowing && followsYou) {
      buttonText = 'Follow back';
      onPressed = () => _followBack(uid);
    } else if (isFollowing) {
      buttonText = 'Unfollow';
      onPressed = () => _handleUnfollow(uid);
    } else {
      buttonText = null;
    }

    return ListTile(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ProfilePage(userId: uid),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: (user['profilePictureUrl'] != null && user['profilePictureUrl'].toString().isNotEmpty)
            ? NetworkImage(user['profilePictureUrl'])
            : null,
        child: (user['profilePictureUrl'] == null || user['profilePictureUrl'].toString().isEmpty)
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(user['userName'] ?? '', style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.bold)),
      subtitle: Text('@${user['userTag'] ?? ''}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
      trailing: buttonText != null
          ? TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: buttonText == 'Unfollow' ? colorScheme.surfaceVariant : Colors.blueAccent,
          foregroundColor: buttonText == 'Unfollow' ? Colors.red : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w600)),
      )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, bool isFollowerTab) {
    if (_isLoading) return _buildShimmerList();

    final filtered = users.where((user) {
      final name = user['userName']?.toLowerCase() ?? '';
      final tag = user['userTag']?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || tag.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildSearchBar();
        return _buildUserTile(filtered[index - 1], isFollowerTab);
      },
    );
  }

  Widget _buildShimmerList() {
    final baseColor = Colors.grey.shade400;
    final highlightColor = Colors.blue.shade200;

    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connections"),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
          indicatorColor: Colors.blueAccent,
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
          _buildUserList(_followers, true),
          _buildUserList(_following, false),
        ],
      ),
    );
  }
}
