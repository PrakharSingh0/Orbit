import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:orbit/Pages/MiscellaneousPage/LeftDrawer.dart';
import 'package:orbit/Pages/MiscellaneousPage/RightDrawer.dart';
import 'package:provider/provider.dart';

import '../../ThemeData/theme_provider.dart';

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key});

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  int _selectedIndex = 0;
  final pages = [];

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
              child: const CircleAvatar(),
            ),
          ),
          const SizedBox.square(
            dimension: 10,
          )
        ],
      ),
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
              icon: Icon(Bootstrap.chat), label: "Chat"),
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
