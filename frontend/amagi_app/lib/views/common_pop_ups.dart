import 'package:flutter/material.dart';

/// Este archivo contiene funciones para mostrar mensajes emergentes comunes,
/// como mensajes de error de conexión a Internet y mensajes de tiempo de espera agotado.

void _dismissActivePopups(BuildContext context) {
  try {
    final rootNav = Navigator.of(context, rootNavigator: true);
    rootNav.popUntil((route) => route is! PopupRoute);

    final localNav = Navigator.of(context);
    if (localNav != rootNav) {
      localNav.popUntil((route) => route is! PopupRoute);
    }
    debugPrint('[Popups] Dismissed active popups (if any)');
  } catch (e) {
    debugPrint('[Popups] Error dismissing popups: $e');
  }
}

void showNoInternetMessage(BuildContext context) {
  debugPrint('[Popups] showNoInternetMessage()');
  if (!context.mounted) {
    debugPrint('[Popups] Context not mounted, aborting dialog.');
    return;
  }
  Color defaultTextButtonColor =
      TextButton.styleFrom().foregroundColor?.resolve({}) ??
          Theme.of(context).primaryColor;

  _dismissActivePopups(context);
  debugPrint('[Popups] Opening NoInternet AlertDialog');

  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Column(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Sin conexión a Internet'),
          ],
        ),
        content: const Text(
            'Por favor, verifique su conexión a Internet e intente de nuevo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('Aceptar',
                style: TextStyle(color: defaultTextButtonColor)),
          ),
        ],
      );
    },
  );
}

void showTimeoutMessage(BuildContext context) {
  debugPrint('[Popups] showTimeoutMessage()');
  if (!context.mounted) {
    debugPrint('[Popups] Context not mounted, aborting dialog.');
    return;
  }
  Color defaultTextButtonColor =
      TextButton.styleFrom().foregroundColor?.resolve({}) ??
          Theme.of(context).primaryColor;

  _dismissActivePopups(context);
  debugPrint('[Popups] Opening Timeout AlertDialog');

  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Column(
          children: [
            Icon(Icons.timer_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Tiempo de espera agotado'),
          ],
        ),
        content: const Text(
            'La solicitud ha tardado demasiado. Por favor, intente de nuevo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('Aceptar',
                style: TextStyle(color: defaultTextButtonColor)),
          ),
        ],
      );
    },
  );
}

// Control único para overlays activos (evita duplicados)
OverlayEntry? _activeOverlay;

void _dismissActiveOverlay() {
  if (_activeOverlay != null) {
    try {
      _activeOverlay?.remove();
    } catch (_) {}
    _activeOverlay = null;
    debugPrint('[Popups] Dismissed active overlay');
  }
}

// Banner overlay genérico (fallback cuando showDialog no es posible)
void _showOverlayBanner(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) {
    debugPrint('[Popups] Context not mounted for overlay.');
    return;
  }
  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) {
    debugPrint('[Popups] No overlay found.');
    return;
  }

  _dismissActiveOverlay();
  final theme = Theme.of(context);
  _activeOverlay = OverlayEntry(
    builder: (_) => SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 4),
                          Text(message, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _dismissActiveOverlay,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  overlay.insert(_activeOverlay!);
  debugPrint('[Popups] Overlay banner shown: $title');

  Future.delayed(duration, () {
    _dismissActiveOverlay();
  });
}

// Fallbacks públicos: Overlay para No Internet / Timeout
void showNoInternetOverlayMessage(BuildContext context) {
  _showOverlayBanner(
    context,
    icon: Icons.wifi_off,
    title: 'Sin conexión a Internet',
    message: 'Por favor, verifique su conexión e intente de nuevo.',
  );
}

void showTimeoutOverlayMessage(BuildContext context) {
  _showOverlayBanner(
    context,
    icon: Icons.timer_off,
    title: 'Tiempo de espera agotado',
    message: 'La solicitud tardó demasiado. Intente de nuevo.',
  );
}
