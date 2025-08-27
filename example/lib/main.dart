import 'package:example/chat_bubble.dart';
import 'package:example/hovered_slide_menu.dart';
import 'package:example/menu_builders.dart';
import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart'; // Your package export

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Action Menu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Action Menu Demo')),
      resizeToAvoidBottomInset: false,

      body: QuickActionMenu(
        // Wrap your main content with QuickActionMenu
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Test Case 1: Basic (Both Menus, Center Align) ---
            ChatBubble(
              tag: 'bubble_1',
              text: 'Long press me! (Basic: Top & Bottom menus, Center)',
              isSelf: true,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              // bottomMenuBuilder: buildActionBar,
              bottomMenuBuilder: (context) => SlideSelectMenu(),
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
            ),
            const SizedBox(height: 20),

            // --- Test Case 2: Only Top Menu (Right Align) ---
            ChatBubble(
              tag: 'bubble_2',
              text: 'Only reactions here (Right Align).',
              isSelf: false,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              topMenuAlignment: OverlayMenuHorizontalAlignment.right,
            ),
            const SizedBox(height: 20),

            // --- Test Case 3: Only Bottom Menu (Left Align) ---
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: ChatBubble(
                tag: 'bubble_3',
                text: 'Only actions here (Left Align).',
                isSelf: true,
                viewPadding: safeArea,
                bottomMenuBuilder: buildActionBar,
                bottomMenuAlignment: OverlayMenuHorizontalAlignment.left,
              ),
            ),
            const SizedBox(height: 20),

            // --- Test Case 4: Long Text (Guaranteed Vertical Overflow for Scrolling) ---
            ChatBubble(
              tag: 'bubble_4',
              text:
                  'This is a **very long message** that is specifically '
                      'designed to **force the menu to become scrollable**. \n'
                      'We need to verify that when its total content height '
                      'exceeds the available safe screen height, the menu '
                      'correctly detects the need for scrolling and displays '
                      'with a scrollbar, allowing all its content to be viewed.\n '
                      'This text should be long enough to push the boundaries '
                      'of most common device screens, ensuring the scrolling '
                      'mechanism is properly triggered. Scroll down to see '
                      'the rest of the actions. \n'
                      'Top menu center, bottom menu center. \n\n' *
                  3,
              isSelf: false,
              viewPadding: safeArea,

              topMenuBuilder: buildReactionMenu,
              bottomMenuBuilder: buildLongActionBar, // A taller action bar
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
            ),
            const SizedBox(height: 20),

            // --- Test Case 5: Wide Anchor (Guaranteed Horizontal Scaling) ---
            ChatBubble(
              tag: 'bubble_5',
              text:
                  'This content is designed to be **extremely wide**. '
                  'It should definitely **trigger the anchor scaling mechanism** '
                  'to ensure it fits within the horizontal safe area of the screen. '
                  'Observe how the anchor widget itself visually shrinks while '
                  'the menu components align relative to its new, scaled width.',
              isSelf: true,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              bottomMenuBuilder: buildActionBar,
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
              width:
                  MediaQuery.of(context).size.width *
                  0.95, // Make it almost screen-width
            ),
            const SizedBox(height: 20),

            // --- Test Case 6: Mixed Alignments (Top Left, Bottom Right) ---
            ChatBubble(
              tag: 'bubble_6',
              text: 'Mixed alignments: Top Left, Bottom Right.',
              isSelf: false,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              bottomMenuBuilder: buildActionBar,
              topMenuAlignment: OverlayMenuHorizontalAlignment.left,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.right,
            ),
            const SizedBox(height: 20),

            // --- Test Case 7: Anchor near top edge (Test vertical clamping) ---
            // Add significant space above to allow scrolling to this bubble,
            // then ensure its menu clamps to the top.
            const SizedBox(height: 300), // Push subsequent content down
            ChatBubble(
              tag: 'bubble_7',
              text:
                  'This bubble starts further down. When scrolled to the top '
                  'of the viewport, its menu should **clamp to the top padding** '
                  'of the screen, not go off-screen upwards.',
              isSelf: true,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              bottomMenuBuilder: buildActionBar,
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
            ),
            const SizedBox(height: 20), // Standard spacing
            // --- Test Case 8: Anchor near bottom edge (Test vertical clamping) ---
            // Ensure there's ample scrollable space after this bubble so it can
            // be positioned correctly near the bottom of the viewport.
            ChatBubble(
              tag: 'bubble_8',
              text:
                  'This bubble is placed near the bottom. Its menu should '
                  '**clamp to the bottom padding** of the screen if it '
                  'would otherwise overflow downwards.',
              isSelf: false,
              viewPadding: safeArea,
              topMenuBuilder: buildReactionMenu,
              bottomMenuBuilder: buildActionBar,
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
            ),
            SizedBox(
              height: screenSize.height * .7,
            ), // Ensures enough scrollable space below
          ],
        ),
      ),
    );
  }
}
