import 'package:flutter/material.dart';

// Windows风格卡片组件
class WindowsCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double elevation;
  final EdgeInsets margin;
  final EdgeInsets padding;
  
  const WindowsCard({
    super.key,
    required this.child,
    this.borderRadius = 4.0,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.elevation = 1.0,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16.0),
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1 * elevation),
            spreadRadius: 0,
            blurRadius: 2 * elevation,
            offset: Offset(0, 1 * elevation),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

// Windows风格列表项组件
class WindowsListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  
  const WindowsListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(3.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0078D4).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// Windows风格分隔线组件
class WindowsDivider extends StatelessWidget {
  final double thickness;
  final double height;
  final Color color;
  
  const WindowsDivider({
    super.key,
    this.thickness = 1.0,
    this.height = 16.0,
    this.color = const Color(0xFFE0E0E0),
  });
  
  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      height: height,
      color: color,
    );
  }
}
