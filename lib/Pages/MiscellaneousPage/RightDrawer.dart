import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/ProfilePage.dart';
import 'package:orbit/Pages/MiscellaneousPage/FollowerList.dart';
import 'package:orbit/Pages/MiscellaneousPage/Premium.dart';
import 'package:orbit/Pages/MiscellaneousPage/UserHistory.dart';
import 'package:orbit/Pages/MiscellaneousPage/UserSavedPost.dart';
import 'SettingsPage/Settings.dart';

class RightDrawer extends StatefulWidget {
  const RightDrawer({super.key});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  bool _isOnline = true; // Track online status

  void _navigateFromDrawer(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Slide in from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad,
          ));

          final scaleAnimation = Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ));

          return SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _onStatusChanged() {
    setState(() {
      _isOnline = !_isOnline; // Toggle online status
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  1), // Outer padding for better spacing
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.onSurface,
                                // gradient: LinearGradient( // Instagram-like subtle gradient
                                //   colors: [Colors.lightBlueAccent, Colors.redAccent],
                                //   begin: Alignment.topLeft,
                                //   end: Alignment.bottomRight,
                                // ),
                                border: Border.all(
                                    color: theme.colorScheme.onSurface,
                                    width: 0.2), // White border for contrast
                              ),
                              child: CircleAvatar(
                                radius: 22, // Adjusted for better balance
                                backgroundColor:
                                    Colors.grey[300], // Placeholder color
                                backgroundImage:
                                    const AssetImage("assets/avatar.jpg"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "UserName",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "@UserID",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
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
                            onPressed: _onStatusChanged,
                            child: Text(
                              _isOnline
                                  ? " Online Status: ON "
                                  : " Online Status: OFF ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color:
                                      _isOnline ? Colors.green : Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Follower & Following Section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          bool isWideScreen = constraints.maxWidth > 180;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: isWideScreen
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatCard(
                                          "Follower",
                                          "0",
                                          const UserFollowerList(
                                              initialTabIndex: 0)),
                                      _buildStatCard(
                                          "Following",
                                          "0",
                                          const UserFollowerList(
                                              initialTabIndex: 1)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildStatCard(
                                          "Follower",
                                          "0",
                                          const UserFollowerList(
                                              initialTabIndex: 0)),
                                      const SizedBox(height: 8),
                                      _buildStatCard(
                                          "Following",
                                          "0",
                                          const UserFollowerList(
                                              initialTabIndex: 1)),
                                    ],
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      const Divider(indent: 10, endIndent: 10),

                      // Scrollable Menu Items
                      Column(
                        children: [
                          _buildDrawerItem(
                              Icons.person, "Profile", const Profile()),
                          _buildDrawerItem(
                              Icons.bookmark, "Saved", const UserSavedPost()),
                          _buildDrawerItem(
                              Icons.history, "History", const UserHistory()),
                          _buildDrawerItem(Icons.workspace_premium, "Premium",
                              const Premium()),
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
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  onTap: () => _showUserSwitchBottomSheet(context),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text(" Settings ",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  onTap: () => _navigateFromDrawer(context, const Settings()),
                ),
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
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
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
      sheetAnimationStyle: AnimationStyle(curve: Curves.ease,duration: Duration(milliseconds: 300)),
      context: context,
      shape: const RoundedRectangleBorder(

          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return
          const SizedBox(
            height: 200,
            child: Center(
              child: Text("User Switching Feature is Coming Soon ..."),
            ),
          );
      },
    );
  }
}
