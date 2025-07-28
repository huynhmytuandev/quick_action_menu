import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// The main widget for our slide-selectable menu.
/// It detects pointer movements across its children and manages the hover state.
class SlideSelectMenu extends StatefulWidget {
  const SlideSelectMenu({super.key});

  @override
  State<SlideSelectMenu> createState() => _SlideSelectMenuState();
}

class _SlideSelectMenuState extends State<SlideSelectMenu> {
  // ValueNotifier is used to efficiently notify individual menu items
  // about which item is currently being hovered over.
  // -1 indicates no item is currently hovered.
  final ValueNotifier<int> _hoveredIndexNotifier = ValueNotifier<int>(-1);

  // A list of GlobalKeys, one for each menu item.
  // These keys are essential for getting the RenderBox (size and position)
  // of each item, allowing us to determine if the pointer is over it.
  late List<GlobalKey> _itemKeys;

  // The list of menu items to display.
  late List<MenuItemData> _menuItems;

  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize our menu items with their text, icons, and actions.
    _menuItems = [
      MenuItemData(
        text: 'Add to Folder',
        icon: Icons.folder_open,
        onTap: () => _showMessage('Add to Folder'),
      ),
      MenuItemData(
        text: 'Mark as Unread',
        icon: Icons.chat_bubble_outline,
        onTap: () => _showMessage('Mark as Unread'),
      ),
      MenuItemData(
        text: 'Pin',
        icon: Icons.push_pin_outlined,
        onTap: () => _showMessage('Pin'),
      ),
      MenuItemData(
        text: 'Unmute',
        icon: Icons.notifications_off_outlined,
        onTap: () => _showMessage('Unmute'),
      ),
      MenuItemData(
        text: 'Delete',
        icon: Icons.delete_outline,
        onTap: () => _showMessage('Delete'),
        isDestructive: true,
      ),
    ];
    // Generate a unique GlobalKey for each menu item.
    _itemKeys = List.generate(_menuItems.length, (index) => GlobalKey());
  }

  /// Displays a SnackBar message when a menu item is selected.
  void _showMessage(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action selected!')));
    // After an action is performed, reset the hovered state.
    _hoveredIndexNotifier.value = -1;
  }

  /// Helper function to determine if a global point (e.g., finger position)
  /// is currently inside the bounds of a specific widget.
  bool _isPointInsideWidget(GlobalKey key, Offset globalPoint) {
    // Get the RenderBox of the widget associated with the given key.
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return false; // Widget not rendered yet or key is invalid.
    }

    // Convert the global point to the local coordinate system of the RenderBox.
    final Offset localPosition = renderBox.globalToLocal(globalPoint);

    // Perform a hit test to check if the localPosition is within the RenderBox's bounds.
    // BoxHitTestResult() is used to collect hit test results, but we only care about the boolean outcome here.
    return renderBox.hitTest(BoxHitTestResult(), position: localPosition);
  }

  /// Handles the initial pointer down event.
  /// It immediately updates the hovered item based on the pointer's starting position.
  void _onPointerDown(PointerDownEvent event) {
    _updateHoveredItem(event.position);
  }

  /// Handles pointer movement events.
  /// This is crucial for the "slide-to-select" functionality, as it continuously
  /// checks which item the pointer is currently over.
  void _onPointerMove(PointerMoveEvent event) {
    _updateHoveredItem(event.position);
  }

  /// Updates the `_hoveredIndexNotifier` based on the current global pointer position.
  /// This function iterates through all menu items to find which one (if any)
  /// the pointer is currently hovering over.
  void _updateHoveredItem(Offset globalPosition) {
    int newHoveredIndex = -1; // Default to no item hovered.
    for (int i = 0; i < _itemKeys.length; i++) {
      // Check if the current pointer position is inside the i-th menu item.
      if (_isPointInsideWidget(_itemKeys[i], globalPosition)) {
        newHoveredIndex = i; // Found the hovered item.
        break; // Exit loop as soon as an item is found.
      }
    }

    // If the hovered item has changed, update the notifier and provide haptic feedback.
    if (newHoveredIndex != _hoveredIndexNotifier.value) {
      _hoveredIndexNotifier.value = newHoveredIndex;
      if (newHoveredIndex != -1) {
        // Provide a light haptic feedback when a new item is hovered.
        HapticFeedback.lightImpact();
      }
    }
  }

  /// Handles the pointer up event (when the finger is lifted).
  /// If an item was hovered when the finger was lifted, its action is triggered.
  void _onPointerUp(PointerUpEvent event) {
    if (_hoveredIndexNotifier.value != -1) {
      // If an item was hovered, execute its associated onTap action.
      _menuItems[_hoveredIndexNotifier.value].onTap();
    }
    // Always reset the hovered state after the pointer is lifted.
    _hoveredIndexNotifier.value = -1;
  }

  @override
  Widget build(BuildContext context) {
    // The Listener widget wraps the entire menu. This allows it to capture
    // pointer events even if they originate outside the visual bounds of the menu
    // but then slide into it.
    return Listener(
      key: _globalKey,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Container(
        // Constraints to limit the maximum width of the menu.
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the menu.
          borderRadius: BorderRadius.circular(12.0), // Rounded corners.
          boxShadow: [
            // Adds a subtle shadow for a floating effect, similar to iOS.
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5), // Position of the shadow.
            ),
          ],
        ),
        // ClipRRect ensures that any content inside (like the Column)
        // respects the rounded corners of the Container.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            // Make the column only as tall as its children, ensuring it fits the content.
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_menuItems.length, (index) {
              final item = _menuItems[index];
              return Column(
                children: [
                  // Each _MenuItem widget represents a single row in the menu.
                  _MenuItem(
                    key: _itemKeys[index], // Assign the unique GlobalKey.
                    data: item,
                    index: index,
                    hoveredIndexNotifier: _hoveredIndexNotifier,
                  ),
                  // Add a Divider between menu items, but not after the last one.
                  if (index < _menuItems.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// A StatelessWidget that represents an individual menu item.
/// It listens to the `hoveredIndexNotifier` to update its visual state (highlighting).
class _MenuItem extends StatelessWidget {
  final MenuItemData data; // Data for this specific menu item.
  final int index; // The index of this item in the menu list.
  final ValueNotifier<int>
  hoveredIndexNotifier; // Notifier for global hover state.

  const _MenuItem({
    super.key, // Key is passed from the parent to allow GlobalKey assignment.
    required this.data,
    required this.index,
    required this.hoveredIndexNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder rebuilds only when the `hoveredIndexNotifier` changes,
    // making the hover effect efficient.
    return ValueListenableBuilder<int>(
      valueListenable: hoveredIndexNotifier,
      builder: (context, hoveredIndex, child) {
        // Determine if this specific item is currently being hovered over.
        final bool isHovered = hoveredIndex == index;
        return GestureDetector(
          // Allow direct tapping on the item as well.
          onTap: data.onTap,
          child: Container(
            // Change background color based on hover state and if it's a destructive action.
            color: isHovered
                ? (data.isDestructive
                      ? Colors.red.shade100
                      : Colors.blue.shade50)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // Expanded ensures the text takes available space, pushing the icon to the right.
                Expanded(
                  child: Text(
                    data.text,
                    style: TextStyle(
                      fontSize: 17,
                      // Destructive actions (like Delete) are red.
                      color: data.isDestructive ? Colors.red : Colors.black,
                      // Text becomes bold when hovered.
                      fontWeight: isHovered
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // The icon for the menu item.
                Icon(
                  data.icon,
                  color: data.isDestructive ? Colors.red : Colors.grey.shade600,
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A data model class to define each item in our menu.
/// It holds the text, an icon, the action to perform (onTap),
/// and a flag to indicate if it's a destructive action (like 'Delete').
class MenuItemData {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  MenuItemData({
    required this.text,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}
