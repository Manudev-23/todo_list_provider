import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';

class DefaultListenerNotifier {
  final DefaultChangeNotifier changeNotifier;
  final BuildContext context;

  final VoidCallback? onSuccess;
  final Function(String)? onError;

  OverlayEntry? _overlayEntry;
  bool _successShown = false;

  DefaultListenerNotifier({
    required this.changeNotifier,
    required this.context,
    this.onSuccess,
    this.onError,
  }) {
    changeNotifier.addListener(_listener);
  }

  void _listener() {
    // ========================
    // 🔵 LOADING COM OVERLAY
    // ========================
    if (changeNotifier.loading && _overlayEntry == null) {
      _showOverlayLoading();
      _successShown = false;
    } else if (!changeNotifier.loading && _overlayEntry != null) {
      _removeOverlay();
    }

    // ========================
    // 🔴 ERRO
    // ========================
    if (changeNotifier.hasError && !changeNotifier.loading) {
      final msg = changeNotifier.error!;
      _showSnackBar(msg, Colors.red);

      onError?.call(msg);

      changeNotifier.setError(null);
    }

    // ========================
    // 🟢 SUCESSO
    // ========================
    if (changeNotifier.success && !_successShown && !changeNotifier.loading) {
      _successShown = true;

      _showSnackBar(
        'Operação realizada com sucesso!',
        Colors.green,
      );

      onSuccess?.call();
    }
  }

  // ========================
  // ⚙️ Overlay do Loading
  // ========================
  void _showOverlayLoading() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ========================
  // ⚙️ Snackbar
  // ========================
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ========================
  // ⚙️ Dispose
  // ========================
  void dispose() {
    changeNotifier.removeListener(_listener);
    _removeOverlay();
  }
}
