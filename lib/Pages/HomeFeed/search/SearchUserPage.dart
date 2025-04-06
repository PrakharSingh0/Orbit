import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../MiscellaneousPage/threadBuilder.dart';
import '../Profile/ProfilePage.dart';
import 'PublicProfilePage.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> results = [];

  void searchUsers(String query) async {
    if (query.trim().isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userTag', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('userTag', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
        .get();

    setState(() {
      results = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: searchUsers,
              decoration: InputDecoration(
                hintText: "Search by @tag",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final user = results[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePictureUrl'] ?? ""),
                    ),
                    title: Text(user['userName'] ?? ''),
                    subtitle: Text("@${user['userTag']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(userId: results[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
