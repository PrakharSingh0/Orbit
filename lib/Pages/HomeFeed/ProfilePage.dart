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
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(BoxIcons.bx_menu_alt_right, color: Colors.white),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo Section
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Cover Image
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54, // Subtle black shadow
                        spreadRadius:1, // How much it spreads
                        blurRadius: 8,  // Smooth blur
                        offset: Offset(0, 1), // Moves shadow downward
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage("assets/back.webp"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Frosted Glass Effect Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(25)),
                      color: Colors.black.withAlpha((0.3 * 255).toInt())
                    ),
                  ),
                ),

                // Profile Picture
                Positioned(
                  right: 30,
                  top: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color:Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Colors.black54,
                         width: 4),
                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage("assets/avatar.jpg"),
                      radius: 45,
                    ),
                  ),
                ),
              ],
            ),

            // User Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username and ID
                  Text(
                    "UserName",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor),
                  ),
                  Text(
                    "@UserID",
                    style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color),
                  ),

                  const SizedBox(height: 10),

                  // Bio Section
                  buildBio(
                    "This is the user's bio. It can be very long or short, depending on what the user writes. "
                        "Flutter is great for UI development, and making dynamic expandable text is very easy. "
                        "The main goal is to make sure that long text does not clutter the UI while still allowing "
                        "users to view the full content when they want. Clicking on this text will reveal more content.",
                  ),

                  const SizedBox(height: 10),

                  // Profile Details (Job, Birthdate, Location, etc.)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileDetail(Icons.work, "Game Developer"),
                          _profileDetail(Icons.cake, "Born: 02-11-2004"),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _profileDetail(Icons.calendar_today, "Joined: 02-10-2024"),
                          _profileDetail(Icons.location_on, "Uttar Pradesh, India"),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Action Buttons (Share & Edit Profile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customProfileButton(
                        onPressed: () => print("Share Profile Clicked"),
                        icon: Bootstrap.share,
                        label: "Share Profile",
                      ),
                      const SizedBox(width: 15),
                      customProfileButton(
                        onPressed: () => print("Edit Profile Clicked"),
                        icon: Clarity.edit_line,
                        label: "Edit Profile",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: const Row(
                  children: [
                    Text("Thread",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),SizedBox(width: 20,),
                    Text("Media",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),SizedBox(width: 20,),
                    Text("Comment",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),SizedBox(width: 20,),
                    Text("Liked",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),SizedBox(width: 20,),
                    Text("Social",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),SizedBox(width: 20,),
                  ],
                ),
              ),
            ),
            const Divider()
          ],
        ),
      ),
    );
  }

  // Profile Details Widget
  Widget _profileDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // Custom Profile Button
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

  // Expandable Bio Section
  Widget buildBio(String bio) {
    const int maxWords = 20;
    List<String> words = bio.split(' ');
    bool shouldTruncate = words.length > maxWords;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[700]),
          children: [
            TextSpan(
              text: isExpanded ? bio : words.take(maxWords).join(' '),
            ),
            if (shouldTruncate)
              TextSpan(
                text: isExpanded ? " Show less" : " ...",
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }
}
