import 'package:flutter/material.dart';
import 'package:orbit/Pages/Cards/ThreadCard.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: Column(
      children: [
        // const Divider(
        //   thickness: 0.1,
        // ),
        ThreadCard(),
        Divider(
          thickness: 0.1,
        ),
        // const ThreadCard(),
        // const Divider(
        //   thickness: 0.1,
        // ),
        // const ThreadCard(),
        // const Divider(
        //   thickness: 0.1,
        // ),
        // const ThreadCard(),
        // const Divider(
        //   thickness: 0.1,
        // ),
        // const ThreadCard(),
        // const Divider(
        //   thickness: 0.1,
        // ),
      ],
    ));
  }
}
