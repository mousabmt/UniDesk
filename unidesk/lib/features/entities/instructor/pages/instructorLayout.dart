import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_layout.dart';

class InstructorLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final GlobalKey<NavigatorState> navigatorKey;

  const InstructorLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.navigatorKey,
  });

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentIndex: widget.currentIndex,
      child: widget.child,
      navigatorKey: widget.navigatorKey,
    );
  }
}
