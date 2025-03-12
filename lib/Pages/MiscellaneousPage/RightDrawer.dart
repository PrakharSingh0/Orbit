import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/ProfilePage.dart';

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
          // Slide from left (Drawer-like effect)
          final slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Start from left
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad, // ✅ Smooth & natural feel
          ));

          // Scale effect (subtle zoom-in)
          final scaleAnimation = Tween<double>(
            begin: 0.9, // Slightly smaller
            end: 1.0,   // Full size
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // ✅ Adds a slight "pop" effect
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Expanded(
              child: Center(
                // Center everything except bottom items
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Profile Section
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 25,backgroundImage: AssetImage("assets/avatar.jpg"),),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "UserName",
                                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "@UserID",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
                            onPressed: _onStatusChanged,
                            child: Text(
                              _isOnline
                                  ? " Online Status: ON "
                                  : " Online Status: OFF ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,
                                color: _isOnline ? Colors.green : Colors.grey,
                              ),
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
                                      _buildStatCard("Follower", "0"),
                                      _buildStatCard("Following", "0"),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildStatCard("Follower", "0"),
                                      const SizedBox(height: 8),
                                      _buildStatCard("Following", "0"),
                                    ],
                                  ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                      const Divider(indent: 10, endIndent: 10),

                      // Scrollable & Centered Menu Items
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(FontAwesome.user),
                              title: const Text(" Profile ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                              onTap: (){_navigateFromDrawer(context, const Profile());}
                            ),
                            ListTile(
                              leading: const Icon(FontAwesome.bookmark),
                              title: const Text(" Saved ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                              onTap: () {_navigateFromDrawer(context, const Profile());},
                            ),
                            ListTile(
                              leading: const Icon(OctIcons.history),
                              title: const Text(" History ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                              onTap: () {_navigateFromDrawer(context, const Profile());},
                            ),
                            ListTile(
                              leading: const Icon(Icons.workspace_premium),
                              title: const Text(" Premium ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                              onTap: () {_navigateFromDrawer(context, const Profile());},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(indent: 10, endIndent: 10),

            // Bottom Actions (Always at Bottom)
            Column(
              children: [
                ListTile(
                  leading: const Icon(AntDesign.user_switch_outline),
                  title: const Text(" Switch User ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text(" Settings ",style:TextStyle(fontWeight: FontWeight.w600,fontSize: 16),overflow: TextOverflow.ellipsis,),
                  onTap: () {_navigateFromDrawer(context, const Settings());},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Follower & Following
  Widget _buildStatCard(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Bootstrap.people, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,)),
            Text(value,
                style: const TextStyle(fontSize: 10, color: Colors.grey,overflow: TextOverflow.ellipsis,)),
          ],
        ),
      ],
    );
  }
}
