import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingTopNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool hasServiceAlert;

  const FloatingTopNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.hasServiceAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 680),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.directions_car_filled_rounded,
                      label: 'Garage',
                      isSelected: currentIndex == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      icon: Icons.build_circle_rounded,
                      label: 'Service & Care',
                      isSelected: currentIndex == 1,
                      showBadge: hasServiceAlert,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      icon: Icons.local_gas_station_rounded,
                      label: 'Fuel & Odo',
                      isSelected: currentIndex == 2,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Toll Wallet',
                      isSelected: currentIndex == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool showBadge = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 110;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTabSelected(index),
            borderRadius: BorderRadius.circular(28),
            splashColor: AppColors.primary.withValues(alpha: 0.12),
            highlightColor: AppColors.primary.withValues(alpha: 0.06),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 6 : 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primaryGradient : null,
                color: isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: isCompact ? 17 : 19,
                        color: isSelected ? Colors.white : AppColors.secondary,
                      ),
                      if (!isCompact || isSelected) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isCompact ? 11 : 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (showBadge && !isSelected)
                    Positioned(
                      top: -2,
                      right: 4,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
