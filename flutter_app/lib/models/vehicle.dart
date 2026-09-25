class VehicleItem {
  final String vin;
  final String name;
  final String edition;
  final String typeLabel;
  final String fuelType;
  String status;
  final bool isOnline;
  double fuelLevelPercent;
  double fuelCapacityLitres;
  int rangeKm;
  int odometerKm;
  final String? serviceAlert;
  int? serviceDueKm;
  final String? driverInfo;
  final String locationName;
  final String imageUrl;
  bool isSelected;

  // Detailed Telemetry & Specs
  double tirePressureFl;
  double tirePressureFr;
  double tirePressureRl;
  double tirePressureRr;
  double batteryVoltage;
  String fastTagId;
  String insuranceExpiry;
  String pucExpiry;
  String registrationPlate;

  VehicleItem({
    required this.vin,
    required this.name,
    required this.edition,
    required this.typeLabel,
    this.fuelType = 'Petrol',
    required this.status,
    required this.isOnline,
    required this.fuelLevelPercent,
    required this.fuelCapacityLitres,
    required this.rangeKm,
    required this.odometerKm,
    this.serviceAlert,
    this.serviceDueKm,
    this.driverInfo,
    required this.locationName,
    required this.imageUrl,
    required this.isSelected,
    this.tirePressureFl = 33.0,
    this.tirePressureFr = 33.0,
    this.tirePressureRl = 35.0,
    this.tirePressureRr = 35.0,
    this.batteryVoltage = 12.8,
    this.fastTagId = '607418-NETC-4091',
    this.insuranceExpiry = '18 Dec 2026',
    this.pucExpiry = '14 Nov 2026',
    this.registrationPlate = 'MH 12 RN 2024',
  });

  factory VehicleItem.fromJson(Map<String, dynamic> json) {
    return VehicleItem(
      vin: json['vin'] as String? ?? '',
      name: json['name'] as String? ?? 'Vehicle',
      edition: json['edition'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? 'Coupe',
      fuelType: json['fuel_type'] as String? ?? 'Petrol',
      status: json['status'] as String? ?? 'In Garage',
      isOnline: json['is_online'] as bool? ?? true,
      fuelLevelPercent: (json['fuel_level_percent'] as num?)?.toDouble() ??
          (json['energy_level_percent'] as num?)?.toDouble() ??
          75.0,
      fuelCapacityLitres: (json['fuel_capacity_litres'] as num?)?.toDouble() ?? 64.0,
      rangeKm: (json['range_km'] as num?)?.toInt() ?? 450,
      odometerKm: (json['odometer_km'] as num?)?.toInt() ?? 12450,
      serviceAlert: json['service_alert'] as String?,
      serviceDueKm: (json['service_due_km'] as num?)?.toInt(),
      driverInfo: json['driver_info'] as String?,
      locationName: json['location_name'] as String? ?? 'Home Garage',
      imageUrl: resolveImageUrl(json['image_url'] as String?),
      isSelected: json['is_selected'] as bool? ?? false,
      tirePressureFl: (json['tire_fl'] as num?)?.toDouble() ?? 33.0,
      tirePressureFr: (json['tire_fr'] as num?)?.toDouble() ?? 33.0,
      tirePressureRl: (json['tire_rl'] as num?)?.toDouble() ?? 35.0,
      tirePressureRr: (json['tire_rr'] as num?)?.toDouble() ?? 35.0,
      batteryVoltage: (json['battery_voltage'] as num?)?.toDouble() ?? 12.8,
      fastTagId: json['fasttag_id'] as String? ?? '607418-NETC-${json['vin']?.hashCode.abs().toString().substring(0, 4) ?? '9118'}',
      insuranceExpiry: json['insurance_expiry'] as String? ?? '18 Dec 2026',
      pucExpiry: json['puc_expiry'] as String? ?? '14 Nov 2026',
      registrationPlate: json['registration_plate'] as String? ?? (json['edition']?.toString().contains('•') == true ? json['edition'].toString().split('•').last.trim() : 'MH 12 RN 2024'),
    );
  }

  static String resolveImageUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80';
    }
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final clean = trimmed.replaceFirst(RegExp(r'^(file:///|file://|/+)'), '');
    return 'http://10.0.2.2:3000/$clean';
  }

  Map<String, dynamic> toJson() {
    return {
      'vin': vin,
      'name': name,
      'edition': edition,
      'type_label': typeLabel,
      'fuel_type': fuelType,
      'status': status,
      'is_online': isOnline,
      'fuel_level_percent': fuelLevelPercent,
      'fuel_capacity_litres': fuelCapacityLitres,
      'range_km': rangeKm,
      'odometer_km': odometerKm,
      'service_alert': serviceAlert,
      'service_due_km': serviceDueKm,
      'driver_info': driverInfo,
      'location_name': locationName,
      'image_url': imageUrl,
      'is_selected': isSelected,
      'tire_fl': tirePressureFl,
      'tire_fr': tirePressureFr,
      'tire_rl': tirePressureRl,
      'tire_rr': tirePressureRr,
      'battery_voltage': batteryVoltage,
      'fasttag_id': fastTagId,
      'insurance_expiry': insuranceExpiry,
      'puc_expiry': pucExpiry,
      'registration_plate': registrationPlate,
    };
  }
}

class FleetSummary {
  final int totalVehicles;
  final int activeCount;
  final int parkedCount;
  final int fleetMileageKm;
  final String avgEfficiency;
  final int nextServiceDays;
  final double tollWalletBalance;
  final String selectedVin;

  FleetSummary({
    required this.totalVehicles,
    required this.activeCount,
    required this.parkedCount,
    required this.fleetMileageKm,
    required this.avgEfficiency,
    required this.nextServiceDays,
    required this.tollWalletBalance,
    required this.selectedVin,
  });

  factory FleetSummary.fromJson(Map<String, dynamic> json) {
    return FleetSummary(
      totalVehicles: (json['total_vehicles'] as num?)?.toInt() ?? 3,
      activeCount: (json['active_count'] as num?)?.toInt() ?? 2,
      parkedCount: (json['parked_count'] as num?)?.toInt() ?? 1,
      fleetMileageKm: (json['fleet_mileage_km'] as num?)?.toInt() ?? 48210,
      avgEfficiency: json['avg_efficiency'] as String? ?? '14.8 km/L',
      nextServiceDays: (json['next_service_days'] as num?)?.toInt() ?? 12,
      tollWalletBalance: (json['toll_wallet_balance'] as num?)?.toDouble() ?? 124.50,
      selectedVin: json['selected_vin'] as String? ?? 'MOTORO-911-GT3',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_vehicles': totalVehicles,
      'active_count': activeCount,
      'parked_count': parkedCount,
      'fleet_mileage_km': fleetMileageKm,
      'avg_efficiency': avgEfficiency,
      'next_service_days': nextServiceDays,
      'toll_wallet_balance': tollWalletBalance,
      'selected_vin': selectedVin,
    };
  }
}
