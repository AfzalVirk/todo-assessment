import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PriorityChip extends StatelessWidget {
  final String priority;
  final bool small;

  const PriorityChip({
    super.key,
    required this.priority,
    this.small = false,
  });

  Color get _color {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.priorityMedium;
    }
  }

  IconData get _icon {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.keyboard_double_arrow_up;
      case 'low':
        return Icons.keyboard_double_arrow_down;
      default:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: small ? 10 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            priority[0].toUpperCase() + priority.substring(1),
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
