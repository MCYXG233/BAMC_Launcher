import 'package:flutter/material.dart';

// Windows风格按钮组件
class WindowsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDisabled;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double height;
  
  const WindowsButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isDisabled = false,
    this.borderRadius = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.leadingIcon,
    this.trailingIcon,
    this.height = 32.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final bool isDisabled = this.isDisabled || onPressed == null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SizedBox(
      height: height,
      child: isPrimary ? ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: colorScheme.onPrimary,
          ),
        ),
        child: _buildButtonContent(),
      ) : OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          side: BorderSide(
            color: isDisabled ? colorScheme.onSurface.withOpacity(0.12) : colorScheme.primary,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: colorScheme.primary,
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }
  
  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: 6),
        ],
        Text(
          text,
          textAlign: TextAlign.center,
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 6),
          trailingIcon!,
        ],
      ],
    );
  }
}

// Windows风格图标按钮组件
class WindowsIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final String? tooltip;
  final Color? color;
  
  const WindowsIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.size = 24.0,
    this.tooltip,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: size,
      tooltip: tooltip,
      padding: const EdgeInsets.all(4),
      constraints: BoxConstraints(minHeight: size + 8, minWidth: size + 8),
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: color ?? theme.colorScheme.onSurface,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
