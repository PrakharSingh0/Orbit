import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isExpanded = false; // Controls the bio expansion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.white,),
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: (){},icon: const Icon(BoxIcons.bx_menu_alt_right,color: Colors.white))],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo Section
            Stack(
              children: [
                Column(children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25)),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black54, // Subtle black shadow
                          spreadRadius:1, // How much it spreads
                          blurRadius: 20,  // Smooth blur
                          offset: Offset(0, 2), // Moves shadow downward
                        ),
                      ],
                      color: Colors.blueGrey[300],
                      image: const DecorationImage(
                        image: AssetImage("assets/back.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                            height: 15), // To align after profile image

                        const SizedBox(height: 10),

                        buildBio("""This is the user's bio. It can be very long or short, depending on what the user writes. Flutter is great for UI development, and making dynamic expandable text is very easy. The main goal is to make sure that long text does not clutter the UI while still allowing users to view the full content when they want. Clicking on this text will reveal more content, making it user-friendly."""),


                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Space columns evenly
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _profileDetail(Icons.work, "Game Developer"),
                                _profileDetail(Icons.cake, "Born: 02-11-2004"),
                              ],
                            ),
                            const SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _profileDetail(Icons.calendar_today, "Joined: 02-10-2024"),
                                _profileDetail(Icons.location_on, "Uttar Pradesh, India"),

                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customProfileButton(
                              onPressed: () {
                                print("Share Profile Clicked");
                              },
                              icon: Bootstrap.share,
                              label: "Share Profile",
                            ),
                            const SizedBox(width: 15), // Space between buttons
                            customProfileButton(
                              onPressed: () {
                                print("Edit Profile Clicked");
                              },
                              icon: Clarity.edit_line,
                              label: "Edit Profile",
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ]),
                Positioned(
                  right: 40,
                  top: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.surface,offset: const Offset(0, 1),blurRadius: 10)],
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : ThemeData.dark().colorScheme.surface,
                        width: 4,
                      ),

                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                      radius: 40,
                    ),
                  ),
                ),

                const Positioned(
                  left: 15,
                  top: 120,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("UserName",
                              style: TextStyle(fontSize: 26, color:Colors.white,fontWeight: FontWeight.bold,shadows: [Shadow(color: Colors.white,blurRadius: 5,offset: Offset(1, 1))])),
                          Text("@UserID",
                              style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
            const Divider(),

            // Threads ======================


            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemCount: 5, // Replace with actual post count
            //   itemBuilder: (context, index) {
            //     return threadPost(
            //       username: "UserName",
            //       content: "This is a sample post content for thread #$index. 🚀",
            //       timestamp: "2h ago",
            //     );
            //   },
            // ),


          ],
        ),
      ),
    );
  }

  // Custom Widget Builder -----------

  Widget profileStats(String count, String label,Icon icon) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget customProfileButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 0), // Better height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Icon(icon, size: 16,color: Theme.of(context).textTheme.bodyLarge?.color,),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color, // Correct placement
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _profileDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // Minimal spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align properly
        children: [
          Icon(icon, size: 14, color: Theme.of(context).disabledColor), // Gray icon
          const SizedBox(width: 8), // Small space
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor), // Gray text
          ),
        ],
      ),
    );
  }

  Widget buildBio(String bio) {
    const int maxWords = 20; // Word limit before truncating
    List<String> words = bio.split(' ');
    bool shouldTruncate = words.length > maxWords;

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Theme.of(context).hintColor,
          ),
          children: [
            TextSpan(
              text: isExpanded ? bio : words.take(maxWords).join(' '), // Show full or truncated text
            ),
            if (shouldTruncate)
              TextSpan(
                text: isExpanded ? " Show less" : " ...", // Toggle text
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget threadPost({
    required String username,
    required String content,
    required String timestamp,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  // Replace with actual image
                ),
                const SizedBox(width: 10),
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 5),
                Text(timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
              ],
            ),
          ],
        ),
      ),
    );
  }



}
