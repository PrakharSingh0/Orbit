import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/HomeFeed/AddPostPage.dart';
import 'package:orbit/Pages/HomeFeed/Chat.dart';
import 'package:orbit/Pages/HomeFeed/ExplorePage.dart';
import 'package:orbit/Pages/HomeFeed/FeedPage.dart';
import 'package:orbit/Pages/HomeFeed/InboxPage.dart';
import 'package:orbit/Pages/MiscellaneousPage/LeftDrawer.dart';
import 'package:orbit/Pages/MiscellaneousPage/RightDrawer.dart';

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key});

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  int _selectedIndex = 0;

  // Explicitly defining the list type as List<Widget>
  final List<Widget> pages = [
    const FeedPage(),
    const ExplorePage(),
    const AddPostPage(),
    const InboxPage(),
    const Chat()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const RightDrawer(),
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text("Orbit"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.search)),
          IconButton(
              onPressed: () {}, icon: const Icon(CupertinoIcons.heart_fill)),
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
          const SizedBox.square(
            dimension: 10,
          )
        ],
      ),
      body: pages[_selectedIndex], // No change needed here
      bottomNavigationBar: BottomNavigationBar(
        elevation: 5,
        selectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Bootstrap.globe2), label: "Explore"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus), label: "Post"),
          BottomNavigationBarItem(icon: Icon(Icons.all_inbox), label: "Inbox"),
          BottomNavigationBarItem(
              icon: Icon(LineAwesome.user_astronaut_solid), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
