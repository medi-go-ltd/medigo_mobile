import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class DoctorBottomNavBar extends StatelessWidget {
  const DoctorBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.pressedNavIndex,
    this.onPressedChange,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final int? pressedNavIndex;
  final ValueChanged<int?>? onPressedChange;

  static const _navItems = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.calendar_today_rounded, label: 'Bookings'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Payments'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _navItems.length; i++)
                _NavItem(
                  icon: _navItems[i].icon,
                  label: _navItems[i].label,
                  isSelected: currentIndex == i,
                  isPressed: pressedNavIndex == i,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPressedChange?.call(null);
                    onIndexChanged(i);
                  },
                  onTapDown: () => onPressedChange?.call(i),
                  onTapUp: () => onPressedChange?.call(null),
                  onTapCancel: () => onPressedChange?.call(null),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isPressed,
    required this.onTap,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isPressed;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;

  bool get _effectivePressed => isPressed;

  @override
  Widget build(BuildContext context) {
    final scale =
        (isSelected ? 1.05 : 1.0) * (_effectivePressed ? 0.97 : 1.0);

    return Expanded(
      child: Semantics(
        label: isSelected ? '$label, selected' : label,
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTapDown: (_) => onTapDown(),
          onTapUp: (_) => onTapUp(),
          onTapCancel: onTapCancel,
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
