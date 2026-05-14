import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final double? width;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon!, const SizedBox(width: 8), Text(label)],
              )
            : Text(label);

    final button = outlined
        ? OutlinedButton(onPressed: loading ? null : onPressed, child: content)
        : ElevatedButton(onPressed: loading ? null : onPressed, child: content);

    return SizedBox(
      width: width ?? double.infinity,
      child: button,
    );
  }
}
