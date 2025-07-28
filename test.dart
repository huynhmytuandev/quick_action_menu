// // overlay_menu_widget.dart
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:quick_action_menu/src/models/menu_position_result.dart';
// import 'package:quick_action_menu/src/utils/menu_overlay_calculator.dart';
// import 'menu_position_calculator.dart';

// /// ------------------ MeasureSize ------------------
// typedef OnWidgetSizeChange = void Function(Size size);

// class MeasureSize extends StatefulWidget {
//   const MeasureSize({
//     required this.onChange,
//     required this.child,
//     super.key,
//   });

//   final Widget child;
//   final OnWidgetSizeChange onChange;

//   @override
//   State<MeasureSize> createState() => _MeasureSizeState();
// }

// class _MeasureSizeState extends State<MeasureSize> {
//   Size? _oldSize;

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final contextSize = context.size;
//       if (contextSize != null && contextSize != _oldSize) {
//         _oldSize = contextSize;
//         widget.onChange(contextSize);
//       }
//     });

//     return widget.child;
//   }
// }

// /// ------------------ OverlayMenuConfig ------------------
// class OverlayMenuConfig {
//   const OverlayMenuConfig({
//     required this.anchorKey,
//     required this.anchorAlignment,
//     required this.onDismissed,
//     this.topWidget,
//     this.bottomWidget,
//   });
//   final GlobalKey anchorKey;
//   final Widget? topWidget;
//   final Widget? bottomWidget;
//   final Alignment anchorAlignment;
//   final VoidCallback onDismissed;
// }

// /// ------------------ OverlayMenuWidget ------------------
// class OverlayMenuWidget extends StatefulWidget {
//   const OverlayMenuWidget({required this.config, super.key});
//   final OverlayMenuConfig config;

//   @override
//   State<OverlayMenuWidget> createState() => _OverlayMenuWidgetState();
// }

// class _OverlayMenuWidgetState extends State<OverlayMenuWidget>
//     with TickerProviderStateMixin {
//   Size? _topSize;
//   Size? _bottomSize;
//   Offset? _anchorOffset;
//   Size? _anchorSize;
//   MenuPositionResult? _position;

//   late final AnimationController _overlayController;
//   late final AnimationController _anchorMoveController;

//   late final Animation<double> _fadeAnimation;
//   late final Animation<double> _scaleAnimation;
//   late Animation<Offset> _anchorOffsetAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _overlayController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//     );

//     _anchorMoveController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _overlayController,
//       curve: Curves.easeOut,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
//       CurvedAnimation(parent: _overlayController, curve: Curves.easeOutBack),
//     );

//     SchedulerBinding.instance.addPostFrameCallback((_) => _calculatePosition());
//   }

//   @override
//   void dispose() {
//     _overlayController.dispose();
//     _anchorMoveController.dispose();
//     super.dispose();
//   }

//   void _calculatePosition() {
//     final renderBox =
//         widget.config.anchorKey.currentContext?.findRenderObject()
//             as RenderBox?;
//     if (renderBox == null || !renderBox.attached) return;

//     final anchorOffset = renderBox.localToGlobal(Offset.zero);
//     final anchorSize = renderBox.size;

//     setState(() {
//       _anchorOffset = anchorOffset;
//       _anchorSize = anchorSize;
//     });
//   }

//   void _onTopMeasured(Size size) {
//     setState(() => _topSize = size);
//     _tryComputeLayout();
//   }

//   void _onBottomMeasured(Size size) {
//     setState(() => _bottomSize = size);
//     _tryComputeLayout();
//   }

//   void _tryComputeLayout() {
//     if (_anchorOffset == null || _anchorSize == null) return;

//     final screenSize = MediaQuery.of(context).size;
//     final padding = MediaQuery.of(context).padding;

//     final calculator = MenuPositionCalculator(
//       screenSize: screenSize,
//       padding: padding,
//     );

//     final position = calculator.calculate(
//       anchorOffset: _anchorOffset!,
//       anchorSize: _anchorSize!,
//       topWidgetSize: _topSize,
//       bottomWidgetSize: _bottomSize,
//     );

//     setState(() {
//       _position = position;

//       _anchorOffsetAnimation =
//           Tween<Offset>(
//             begin: _anchorOffset,
//             end: position.overlayOrigin,
//           ).animate(
//             CurvedAnimation(
//               parent: _anchorMoveController,
//               curve: Curves.easeOut,
//             ),
//           );

//       _overlayController.forward();
//       _anchorMoveController.forward();
//     });
//   }

//   Future<void> _dismissOverlay() async {
//     await Future.wait([
//       _overlayController.reverse(),
//       _anchorMoveController.reverse(),
//     ]);
//     widget.config.onDismissed();
//   }

//   Widget _buildOverlayContent() {
//     final content = Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (widget.config.topWidget != null) widget.config.topWidget!,
//         _buildAnchorGhost(),
//         if (widget.config.bottomWidget != null) widget.config.bottomWidget!,
//       ],
//     );

//     if (_position?.needsScroll == true) {
//       return ConstrainedBox(
//         constraints: BoxConstraints(maxHeight: _position!.maxHeight),
//         child: SingleChildScrollView(child: content),
//       );
//     }

//     return content;
//   }

//   Widget _buildAnchorGhost() {
//     return SizedBox(
//       width: _anchorSize?.width,
//       height: _anchorSize?.height,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: _dismissOverlay,
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               color: Colors.black.withOpacity(0.2),
//             ),
//           ),
//         ),
//         Offstage(
//           child: Column(
//             children: [
//               if (widget.config.topWidget != null)
//                 MeasureSize(
//                   onChange: _onTopMeasured,
//                   child: widget.config.topWidget!,
//                 ),
//               if (widget.config.bottomWidget != null)
//                 MeasureSize(
//                   onChange: _onBottomMeasured,
//                   child: widget.config.bottomWidget!,
//                 ),
//             ],
//           ),
//         ),
//         if (_position != null)
//           AnimatedBuilder(
//             animation: _anchorOffsetAnimation,
//             builder: (context, child) {
//               return Positioned(
//                 left: _anchorOffsetAnimation.value.dx,
//                 top: _anchorOffsetAnimation.value.dy,
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     alignment: widget.config.anchorAlignment,
//                     child: _buildOverlayContent(),
//                   ),
//                 ),
//               );
//             },
//           ),
//       ],
//     );
//   }
// }

// /// ------------------ MenuController ------------------
// class MenuController {
//   MenuController._(this.context)
//     : _overlayState = Overlay.of(context, rootOverlay: true);
//   final BuildContext context;
//   final OverlayState _overlayState;
//   OverlayEntry? _entry;

//   static final Map<String, GlobalKey> _anchorRegistry = {};

//   static MenuController of(BuildContext context) => MenuController._(context);

//   static void registerAnchor(String tag, GlobalKey key) {
//     _anchorRegistry[tag] = key;
//   }

//   static void unregisterAnchor(String tag) {
//     _anchorRegistry.remove(tag);
//   }

//   void showByTag(
//     String tag, {
//     Widget? topWidget,
//     Widget? bottomWidget,
//     Alignment anchorAlignment = Alignment.center,
//   }) {
//     final anchorKey = _anchorRegistry[tag];
//     if (anchorKey == null) return;

//     show(
//       anchorKey: anchorKey,
//       topWidget: topWidget,
//       bottomWidget: bottomWidget,
//       anchorAlignment: anchorAlignment,
//     );
//   }

//   void show({
//     required GlobalKey anchorKey,
//     Widget? topWidget,
//     Widget? bottomWidget,
//     Alignment anchorAlignment = Alignment.center,
//   }) {
//     dismiss();

//     _entry = OverlayEntry(
//       builder: (_) => OverlayMenuWidget(
//         config: OverlayMenuConfig(
//           anchorKey: anchorKey,
//           topWidget: topWidget,
//           bottomWidget: bottomWidget,
//           anchorAlignment: anchorAlignment,
//           onDismissed: dismiss,
//         ),
//       ),
//     );

//     _overlayState.insert(_entry!);
//   }

//   void dismiss() {
//     _entry?.remove();
//     _entry = null;
//   }
// }

// /// ------------------ QuickActionMenu ------------------
// class QuickActionMenu extends InheritedWidget {
//   const QuickActionMenu({
//     required super.child,
//     required this.controller,
//     super.key,
//   });
//   final MenuController controller;

//   static MenuController of(BuildContext context) {
//     final widget = context
//         .dependOnInheritedWidgetOfExactType<QuickActionMenu>();
//     assert(widget != null, 'QuickActionMenu not found in context');
//     return widget!.controller;
//   }

//   @override
//   bool updateShouldNotify(covariant QuickActionMenu oldWidget) => false;
// }

// /// ------------------ QuickActionAnchor ------------------
// class QuickActionAnchor extends StatefulWidget {
//   const QuickActionAnchor({required this.child, required this.tag, super.key});
//   final Widget child;
//   final String tag;

//   @override
//   State<QuickActionAnchor> createState() => _QuickActionAnchorState();
// }

// class _QuickActionAnchorState extends State<QuickActionAnchor> {
//   final GlobalKey _key = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     MenuController.registerAnchor(widget.tag, _key);
//   }

//   @override
//   void dispose() {
//     MenuController.unregisterAnchor(widget.tag);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyedSubtree(
//       key: _key,
//       child: widget.child,
//     );
//   }
// }
