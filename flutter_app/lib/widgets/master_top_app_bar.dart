import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../screens/account_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

/// Unified Master Top App Bar for MOTORO.
/// Features:
/// - Brand logo with Outfit typography (clean, modern, no Bharat badge).
/// - Responsive vehicle switcher dropdown pill with live telemetry status dot.
/// - Profile avatar (VS) leading to AccountScreen.
/// - Logout icon button leading to LoginScreen.
/// - Auto-aligned for smartphone screens with zero overflow.
class MasterTopAppBar extends StatelessWidget {
  final VehicleItem? currentVehicle;
  final List<VehicleItem> vehicles;
  final ValueChanged<VehicleItem>? onVehicleChanged;
  final VoidCallback? onLogoTap;

  const MasterTopAppBar({
    super.key,
    this.currentVehicle,
    this.vehicles = const [],
    this.onVehicleChanged,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Brand Logo & Title (without Bharat badge)
            InkWell(
              onTap: onLogoTap ??
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(initialVin: currentVehicle?.vin),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.toll_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MOTORO',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Vehicle Switcher Pill, Profile Avatar & Logout
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Vehicle Switcher Pill
                if (vehicles.isNotEmpty)
                  PopupMenuButton<VehicleItem>(
                    tooltip: 'Switch Vehicle',
                    initialValue: currentVehicle,
                    onSelected: onVehicleChanged,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 105),
                            child: Text(
                              currentVehicle?.registrationPlate ?? 'MH 12 RN 2024',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.expand_more_rounded,
                            size: 15,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (ctx) => vehicles.map((v) {
                      final isSel = v.vin == currentVehicle?.vin;
                      return PopupMenuItem<VehicleItem>(
                        value: v,
                        child: Row(
                          children: [
                            Icon(
                              isSel
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSel ? AppColors.primary : AppColors.outline,
                              size: 15,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '${v.registrationPlate} • ${v.fuelType}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.outline,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(width: 6),

                // Profile Avatar (VS)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // Logout Icon Button
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
