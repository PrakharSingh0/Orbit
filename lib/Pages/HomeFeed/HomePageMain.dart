import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/AddPostPage.dart';

import 'package:orbit/Pages/HomeFeed/ExplorePage.dart';
import 'package:orbit/Pages/HomeFeed/FeedPage.dart';
import 'package:orbit/Pages/HomeFeed/InboxPage.dart';
import 'package:orbit/Pages/HomeFeed/ProfilePage.dart';
import 'package:orbit/Pages/MiscellaneousPage/LeftDrawer.dart';
import 'package:orbit/Pages/MiscellaneousPage/RightDrawer.dart';


class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key});

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  int _selectedIndex = 0;
  int unreadMessages = 0;
  final List<Widget> pages = [
    const FeedPage(),
    const ExplorePage(),
    const AddPostPage(),
    const InboxPage(),
    const Profile()
  ];

  final List<String> appBarTitles = [
    "Orbit",
    "Explore",
    "Create Post",
    "Inbox",
    "Profile"
  ];


  void _navigateWithCoolAnimation(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide from bottom
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.2), // Start slightly below
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic, // ✅ Smooth & natural transition
          ));

          // Scale (zoom) effect
          final scaleAnimation = Tween<double>(
            begin: 0.95, // Slightly smaller
            end: 1.0,    // Full size
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack, // ✅ Adds a nice "pop" effect
          ));

          // Fade animation
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // ✅ Smooth fade-in
          ));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }





  void _onItemTapped(int index) {
    if (index == 4) { // Profile Button Clicked
      _navigateWithCoolAnimation(context, const Profile()); // ✅ Open with animation
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      endDrawer: const RightDrawer(),
      drawer: const LeftDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          appBarTitles[_selectedIndex], // Dynamic Title
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            // color: Colors.white,
          ),
        ),
        // backgroundColor: theme.colorScheme.primary,
        // elevation: 4,
        shadowColor: Colors.black26,
        titleSpacing: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.search)),
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.heart_fill)),
          Builder(
            builder: (context) => InkWell(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/avatar.jpg"),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ✅ Smooth Page Transition
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: pages[_selectedIndex],
      ),

      // ✅ Modern Bottom Navigation Bar (Labels Appear Only When Selected)
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: theme.colorScheme.surface.withAlpha((0.9 * 255).toInt()),
        indicatorColor: Colors.transparent, // ✅ Removes default highlight
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22),
            selectedIcon: Icon(Icons.home, color: Colors.blueGrey, size: 24),
            label: "Home",
          ),
          const NavigationDestination(
            icon: Icon(Bootstrap.globe2, size: 22),
            selectedIcon: Icon(Bootstrap.globe, color: Colors.blueGrey, size: 24),
            label: "Explore",
          ),
          const NavigationDestination(
            icon: Icon(CupertinoIcons.add_circled, size: 26),
            selectedIcon: Icon(CupertinoIcons.add_circled_solid, color: Colors.blueGrey, size: 28),
            label: "Post",
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.all_inbox_outlined, size: 22),
                if (unreadMessages > 0) // ✅ Show badge only when there are unread messages
                  Positioned(
                    right: -5,
                    top: -5,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        unreadMessages.toString(),
                        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            selectedIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.all_inbox, size: 24),
                if (unreadMessages > 0) // ✅ Show badge only when there are unread messages
                  Positioned(
                    right: -5,
                    top: -5,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        unreadMessages.toString(),
                        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Inbox",
          ),
          const NavigationDestination(
            icon: Icon(LineAwesome.user_astronaut_solid, size: 22),
            selectedIcon: Icon(FontAwesome.user, color: Colors.blueGrey, size: 24),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}