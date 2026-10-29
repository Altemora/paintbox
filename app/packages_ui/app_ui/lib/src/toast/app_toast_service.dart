import 'dart:async';

import 'package:app_ui/src/toast/app_toast.dart';
import 'package:flutter/foundation.dart';

/// One toast at a time, the others queue; one about the same thing
/// ([AppToast.key]) replaces it. The layer over the app paints [current].
class AppToastService extends ChangeNotifier {
  AppToastService({this.duration = const Duration(seconds: 4)});

  final Duration duration;
  final List<AppToast> _queue = [];
  AppToast? _current;
  Timer? _timer;

  AppToast? get current => _current;

  void show(AppToast toast) {
    if (toast.key != null && _current?.key == toast.key) {
      _current = toast;
      _restart();
      notifyListeners();
      return;
    }
    _queue.removeWhere((t) => t.key != null && t.key == toast.key);
    _queue.add(toast);
    if (_current == null) {
      _next();
    }
  }

  void dismiss() {
    _timer?.cancel();
    _current = null;
    notifyListeners();
    _next();
  }

  void _next() {
    if (_current != null || _queue.isEmpty) {
      return;
    }
    _current = _queue.removeAt(0);
    _restart();
    notifyListeners();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer(duration, dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
