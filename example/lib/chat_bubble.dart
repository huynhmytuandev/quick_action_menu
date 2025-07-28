import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart';

class ChatBubble extends StatefulWidget {
  final Object tag;
  final String text;
  final bool isSelf;
  final EdgeInsets viewPadding;
  final WidgetBuilder? topMenuBuilder;
  final WidgetBuilder? bottomMenuBuilder;
  final OverlayMenuHorizontalAlignment topMenuAlignment;
  final OverlayMenuHorizontalAlignment bottomMenuAlignment;
  final double? width; // For testing wide bubbles

  const ChatBubble({
    required this.tag,
    required this.text,
    required this.viewPadding,
    this.isSelf = false,
    this.topMenuBuilder,
    this.bottomMenuBuilder,
    this.topMenuAlignment = OverlayMenuHorizontalAlignment.center,
    this.bottomMenuAlignment = OverlayMenuHorizontalAlignment.center,
    this.width,
    super.key,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Adjust duration as needed
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      // Scale up slightly
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLongPress(BuildContext context) async {
    // Scale up the bubble
    // await _animationController.forward();
    if (context.mounted) {
      final topMenuWidget = widget.topMenuBuilder?.call(context);
      final bottomMenuWidget = widget.bottomMenuBuilder?.call(context);
      QuickActionMenu.of(context).showMenu(
        tag: widget.tag,
        topMenuWidget: topMenuWidget,
        bottomMenuWidget: bottomMenuWidget,
        topMenuAlignment: widget.topMenuAlignment,
        bottomMenuAlignment: widget.bottomMenuAlignment,
        reverseScroll: true,
        padding: widget.viewPadding + EdgeInsets.only(left: 20, right: 20),
        stickyMenuBehavior: StickyMenuBehavior.both,
      );
    }

    // Scale down the bubble after the menu is dismissed
    // await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSelf ? Alignment.centerRight : Alignment.centerLeft,
      child: QuickActionAnchor(
        tag: widget.tag,
        child: GestureDetector(
          onLongPress: () => _handleLongPress(context),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.width, // Apply optional width for testing scaling
              constraints: widget.width == null
                  ? const BoxConstraints(maxWidth: 250) // Default max width
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelf ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.isSelf ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
