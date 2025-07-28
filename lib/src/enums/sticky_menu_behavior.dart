/// Defines which menu (top, bottom, or both) should stick during scrolling.
enum StickyMenuBehavior {
  /// Neither menu sticks.
  none,

  /// The top menu sticks to the anchor or top of the scroll view.
  top,

  /// The bottom menu sticks to the anchor or bottom of the scroll view.
  bottom,

  /// Both menus stick to their respective ends or the anchor.
  both,
}
