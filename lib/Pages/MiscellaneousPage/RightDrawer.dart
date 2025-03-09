import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class RightDrawer extends StatelessWidget {
  const RightDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Column(
          children: [
            const Spacer(),

            // Online Status Button
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: OutlinedButton(
                      style:OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                      onPressed: () {},
                      child: const Text(" Online Status : On ",style: TextStyle(color: Colors.green),),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Responsive Follower & Following Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWideScreen = constraints.maxWidth > 180;
                      return isWideScreen
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard("Follower", "40"),
                          _buildStatCard("Following", "25"),
                        ],
                      )
                          : Column(
                        children: [
                          _buildStatCard("Follower", "40"),
                          const SizedBox(height: 8),
                          _buildStatCard("Following", "25"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const FractionallySizedBox(widthFactor: 0.9, child: Divider()),

            // Menu Items
            ListTile(
              leading: const Icon(FontAwesome.user),
              title: const Text(" Profile "),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(FontAwesome.bookmark),
              title: const Text(" Saved "),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(OctIcons.history),
              title: const Text(" History "),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text(" Premium "),
              onTap: () {},
            ),

            const Spacer(),
            const FractionallySizedBox(widthFactor: 0.9, child: Divider()),

            // Bottom Actions
            ListTile(
              leading: const Icon(Iconsax.profile_2user_outline),
              title: const Text(" Switch User "),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text(" Settings "),
              onTap: () {},
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
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
