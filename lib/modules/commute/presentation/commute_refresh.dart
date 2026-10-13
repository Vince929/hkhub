import 'dart:async';

import 'package:flutter/material.dart';

/// Refresh only while the app is resumed and this route is actually visible.
mixin CommuteRefresh<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  Timer? _timer;

  void refreshCommute();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true) {
        refreshCommute();
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && ModalRoute.of(context)?.isCurrent == true) {
      refreshCommute();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

}
