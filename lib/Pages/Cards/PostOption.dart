import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class PostOptions {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        final theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _dragHandle(),
            _buildOption(context, Bootstrap.bookmark, "Save", theme, () {}),
            _buildOption(context, Bootstrap.person_x, "Block Account", theme, () {}),
            _buildOption(context, Bootstrap.flag, "Report Post", theme, () {}),
            _buildOption(context, Bootstrap.eye_slash, "Hide", theme, () {}),
            _buildOption(context, Bootstrap.share, "Share", theme, () {}),
            _buildOption(context, Bootstrap.repeat, "Repost", theme, () {}),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  static Widget _buildOption(BuildContext context, IconData icon, String title, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dragHandle() {
    return Container(
      width: 90,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    );
  }
}
