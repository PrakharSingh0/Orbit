import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import '../../ThemeData/theme_provider.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  bool _showAllFollowers = false; // Track expanded state

  final List<String> _followers = List.generate(15, (index) => "Follower ${index + 1}"); // Dummy follower list

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Column(
          children: [
            SizedBox(height: 50,),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Favorite Followers Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Favorite Followers",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                      itemCount: _showAllFollowers ? _followers.length : (_followers.length > 4 ? 4 : _followers.length),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(radius: 18), // Placeholder avatar
                          title: Text(_followers[index]),
                          onTap: () {
                            // Handle follower tap
                          },
                        );
                      },
                    ),

                    if (_followers.length > 5)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllFollowers = !_showAllFollowers;
                          });
                        },
                        child: Text(_showAllFollowers ? "Show Less" : "Show More"),
                      ),

                  ],
                ),
              ),
            ),

            // Dark Mode & Logout at the bottom
            Column(
              children: [
                const Divider(),

                SwitchListTile(
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: RotationTransition(
                          turns: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      themeProvider.themeMode == ThemeMode.dark ? Icons.bedtime : Icons.wb_sunny_rounded,
                      key: ValueKey<bool>(themeProvider.themeMode == ThemeMode.dark),
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.grey.shade800,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

                ListTile(
                  leading: const Icon(AntDesign.logout_outline),
                  title: const Text("Log Out"),
                  onTap: () {
                    // Handle log out
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
