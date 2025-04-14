import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PublicProfilePage extends StatelessWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data['profilePictureUrl'] ?? ''),
                ),
                const SizedBox(height: 10),
                Text(data['userName'], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("@${data['userTag']}", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                if (data['bio'] != null)
                  Text(data['bio'], style: GoogleFonts.poppins(fontSize: 15), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      Text('${data['follower']?.length ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text("Followers"),
                    ]),
                    Column(children: [
                      Text('${data['following']?.length ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text("Following"),
                    ]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
