import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart';

// --- Reaction Menu (Top) ---
Widget buildReactionMenu(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReactionButton(context, '👍'),
        _buildReactionButton(context, '❤️'),
        _buildReactionButton(context, '😂'),
        _buildReactionButton(context, '🎉'),
        _buildReactionButton(context, '🤔'),
      ],
    ),
  );
}

Widget _buildReactionButton(BuildContext context, String emoji) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: GestureDetector(
      onTap: () {
        debugPrint('Reaction: $emoji');
        QuickActionMenu.of(context).hideMenu(); // Hide menu on selection
      },
      child: Text(emoji, style: const TextStyle(fontSize: 28)),
    ),
  );
}

// --- Action Bar (Bottom) ---
Widget buildActionBar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(
      top: 10,
    ), // Space between top and bottom menus
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(context, Icons.reply, 'Reply'),
        const SizedBox(width: 10),
        _buildActionButton(context, Icons.forward, 'Forward'),
        const SizedBox(width: 10),
        _buildActionButton(context, Icons.delete, 'Delete'),
      ],
    ),
  );
}

// A taller action bar to help test scrolling
Widget buildLongActionBar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      // Use Column to make it taller
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(context, Icons.reply, 'Reply'),
        _buildActionButton(context, Icons.forward, 'Forward'),
        _buildActionButton(context, Icons.delete, 'Delete'),
        _buildActionButton(context, Icons.copy, 'Copy'),
        _buildActionButton(context, Icons.edit, 'Edit'),
        _buildActionButton(context, Icons.star, 'Star'),
        _buildActionButton(context, Icons.info, 'Info'),
      ],
    ),
  );
}

Widget _buildActionButton(BuildContext context, IconData icon, String label) {
  return InkWell(
    onTap: () {
      debugPrint('Action: $label');
      QuickActionMenu.of(context).hideMenu(); // Hide menu on selection
    },
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Icon(icon, size: 20),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
