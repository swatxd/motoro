import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'garage_screen.dart';

/// Unified HomeScreen for MOTORO:
/// Seamlessly renders GarageScreen as the centralized Indian Fleet Hub.
class HomeScreen extends StatelessWidget {
  final String? operatorName;
  final String? operatorEmail;
  final String? initialVin;
  final VehicleItem? initialVehicle;

  const HomeScreen({
    super.key,
    this.operatorName,
    this.operatorEmail,
    this.initialVin,
    this.initialVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GarageScreen(
      initialVehicle: initialVehicle,
    );
  }
}
