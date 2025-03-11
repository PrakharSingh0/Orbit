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
        leading: const BackButton(color: Colors.white,),
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: (){},icon: Icon(BoxIcons.bx_menu_alt_right))],
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
                            height: 30), // To align after profile image
                        Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("UserName",
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                Text("@UserID",
                                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),

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
                            SizedBox(width: 10,),
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
                const Positioned(
                  left: 15,
                  top: 130,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/avatar.jpg"),
                    radius: 40,
                  ),
                ),
              ],
            ),
            const Divider(),
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


}
