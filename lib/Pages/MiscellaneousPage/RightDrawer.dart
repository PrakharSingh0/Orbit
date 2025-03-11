import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/ProfilePage.dart';

import 'Settings.dart';

class RightDrawer extends StatefulWidget {
  const RightDrawer({super.key});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  bool _isOnline = true; // Track online status

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
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "@UserID",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
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
                                color: _isOnline ? Colors.green : Colors.red,
                              ),
                            ),
                            onPressed: _onStatusChanged,
                            child: Text(
                              _isOnline
                                  ? " Online Status: On "
                                  : " Online Status: Off ",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _isOnline ? Colors.green : Colors.red,
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
                              title: const Text(" Profile ",overflow: TextOverflow.ellipsis,),
                              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> const Profile()));}
                            ),
                            ListTile(
                              leading: const Icon(FontAwesome.bookmark),
                              title: const Text(" Saved ",overflow: TextOverflow.ellipsis,),
                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> const Profile()));},
                            ),
                            ListTile(
                              leading: const Icon(OctIcons.history),
                              title: const Text(" History ",overflow: TextOverflow.ellipsis,),
                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> const Profile()));},
                            ),
                            ListTile(
                              leading: const Icon(Icons.workspace_premium),
                              title: const Text(" Premium ",overflow: TextOverflow.ellipsis,),
                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> const Profile()));},
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
                  title: const Text(" Switch User ",overflow: TextOverflow.ellipsis,),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text(" Settings ",overflow: TextOverflow.ellipsis,),
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> const Settings()));},
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
