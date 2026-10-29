import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:app_ui/src/toast/app_toast.dart';
import 'package:app_ui/src/toast/app_toast_service.dart';
import 'package:app_ui/src/widgets/glass_panel.dart';
import 'package:app_ui/src/widgets/glow_dot.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Over the whole window: paints the toast the service says is current,
/// sliding in above the status bar.
class AppToastLayerComponent extends StatelessWidget {
  const AppToastLayerComponent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final service = injector<AppToastService>();
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: Space.xl + Space.md,
          child: Center(
            child: ListenableBuilder(
              listenable: service,
              builder: (context, _) => AnimatedSwitcher(
                duration: Motion.normal,
                switchInCurve: Motion.curve,
                switchOutCurve: Motion.curve,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (service.current) {
                  final AppToast toast => _ToastWidget(
                    key: ValueKey(toast),
                    toast: toast,
                    onTap: service.dismiss,
                  ),
                  null => const SizedBox.shrink(),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.toast, required this.onTap, super.key});

  final AppToast toast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: GestureDetector(
        onTap: onTap,
        child: GlassPanel(
          strong: true,
          shadow: true,
          radius: Radii.xs,
          padding: const EdgeInsets.symmetric(
            horizontal: Space.md,
            vertical: Space.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlowDot(color: toast.isFailure ? tokens.danger : tokens.success),
              const SizedBox(width: Space.sm),
              Flexible(
                child: Text(
                  toast.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
