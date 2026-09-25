import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'fuel_odo_screen.dart';
import 'fasttag_screen.dart';
import 'qr_contact_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';
import 'payment_gateway_screen.dart';

class ServiceScreen extends StatefulWidget {
  final VehicleItem? initialVehicle;

  const ServiceScreen({super.key, this.initialVehicle});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> with SingleTickerProviderStateMixin {
  VehicleItem? _vehicle;
  List<VehicleItem> _allVehicles = [];
  bool _isLoading = true;
  String _selectedBrandFilter = 'Mahindra';
  String _currentGpsCity = 'Kozhikode, Kerala';
  bool _isGpsRefreshing = false;

  // Animation controller for pulsing indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Recommended Services Data
  final List<Map<String, dynamic>> _recommendedServices = [
    {
      'id': 'oil',
      'title': 'Synthetic Oil & Filter Service',
      'subtitle': '5W-40 Synthetic with OEM filter',
      'badge': 'Scheduled',
      'badgeColor': AppColors.primary,
      'duration': '~45m',
      'cost': 2850.0,
      'icon': Icons.oil_barrel_rounded,
      'minutes': 45,
    },
    {
      'id': 'brakes',
      'title': 'Brake Pads & Rotors',
      'subtitle': 'Sensor threshold reached • Thickness check',
      'badge': 'Due',
      'badgeColor': AppColors.error,
      'duration': '~60m',
      'cost': 1850.0,
      'icon': Icons.disc_full_rounded,
      'minutes': 60,
    },
    {
      'id': 'alignment',
      'title': 'Wheel Alignment & Balancing',
      'subtitle': 'Laser camber, toe & dynamic balancing',
      'badge': 'Routine',
      'badgeColor': AppColors.secondary,
      'duration': '~30m',
      'cost': 950.0,
      'icon': Icons.tire_repair_rounded,
      'minutes': 30,
    },
    {
      'id': 'filter',
      'title': 'Cabin Air & Microfilter',
      'subtitle': 'Activated carbon filter sanitize',
      'badge': 'Routine',
      'badgeColor': AppColors.secondary,
      'duration': '~20m',
      'cost': 750.0,
      'icon': Icons.air_rounded,
      'minutes': 20,
    },
    {
      'id': 'diag',
      'title': 'Comprehensive Diagnostic Scan',
      'subtitle': '52-point mechanical and safety report',
      'badge': 'Care+',
      'badgeColor': AppColors.primaryContainer,
      'duration': '~45m',
      'cost': 1200.0,
      'icon': Icons.troubleshoot_rounded,
      'minutes': 45,
    },
  ];

  // Authorized Service Centers in Kozhikode & Mumbai
  final List<Map<String, dynamic>> _serviceCenters = [
    {
      'name': 'Pothens Mahindra Authorized Hub',
      'brand': 'Mahindra',
      'distance': '1.4 km',
      'location': 'Thondayad Bypass, Kozhikode 673014',
      'rating': 4.9,
      'reviews': 428,
      'bays': 6,
      'phone': '+91 495 243 8900',
      'isOpen': true,
      'features': 'OEM Parts • 24/7 Roadside • Fast Bay',
    },
    {
      'name': 'ITL Motors Mahindra Service Station',
      'brand': 'Mahindra',
      'distance': '2.9 km',
      'location': 'Mini Bypass, Govindapuram, Kozhikode',
      'rating': 4.8,
      'reviews': 312,
      'bays': 4,
      'phone': '+91 495 274 1122',
      'isOpen': true,
      'features': 'Certified Master Techs • Quick Bay',
    },
    {
      'name': 'Malayalam Tata Motors & EV Care Hub',
      'brand': 'Tata',
      'distance': '1.8 km',
      'location': 'Arayidathupalam, Kozhikode 673016',
      'rating': 4.9,
      'reviews': 512,
      'bays': 8,
      'phone': '+91 495 890 1234',
      'isOpen': true,
      'features': '60kW EV Fast Charge • High-Voltage Bay',
    },
    {
      'name': 'Marina Motors Tata Authorized Workshop',
      'brand': 'Tata',
      'distance': '3.4 km',
      'location': 'Eranhipalam, Kozhikode 673006',
      'rating': 4.7,
      'reviews': 280,
      'bays': 5,
      'phone': '+91 495 276 4400',
      'isOpen': true,
      'features': 'Express Routine Maintenance • Body Shop',
    },
    {
      'name': 'MOTORO Multi-Brand Tech Hub',
      'brand': 'All',
      'distance': '5.2 km',
      'location': 'Cyberpark Industrial Area, Palazhi, Kerala',
      'rating': 4.9,
      'reviews': 650,
      'bays': 8,
      'phone': '+91 495 332 9900',
      'isOpen': true,
      'features': 'All Indian Fleets • EV Battery Diagnostic',
    },
  ];

  // Service Records History
  final List<Map<String, dynamic>> _serviceHistory = [
    {
      'date': 'OCT 15, 2025',
      'badge': 'Certified Hub',
      'badgeColor': AppColors.success,
      'odometer': '10,240 km',
      'title': '10,000 km Scheduled Factory Inspection',
      'subtitle': 'Pothens Mahindra Hub • Kozhikode',
      'code': 'SRV-88219',
      'details': '52/52 Safety Points Passed',
      'cost': '₹4,850',
    },
    {
      'date': 'JUL 22, 2025',
      'badge': 'Alignment',
      'badgeColor': AppColors.primary,
      'odometer': '7,890 km',
      'title': 'Wheel Alignment & Dynamic Balancing',
      'subtitle': 'MOTORO Downtown Hub • Worli Bay',
      'code': 'SRV-77142',
      'details': 'Laser tolerances <0.02° calibrated',
      'cost': '₹1,200',
    },
    {
      'date': 'MAR 10, 2025',
      'badge': 'Delivery',
      'badgeColor': AppColors.secondary,
      'odometer': '25 km',
      'title': 'Factory Handover & Delivery Inspection',
      'subtitle': 'Pre-Delivery Inspection Certified',
      'code': 'SRV-60012',
      'details': 'PDI Approved by Master Tech #4912',
      'cost': '₹0 (Warranty)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _vehicle = widget.initialVehicle;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadVehicles();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    if (mounted) {
      setState(() {
        _allVehicles = vehicles;
        if (_vehicle == null && vehicles.isNotEmpty) {
          _vehicle = vehicles.firstWhere(
            (v) => v.isSelected,
            orElse: () => vehicles.first,
          );
        } else if (_vehicle != null) {
          _vehicle = vehicles.firstWhere(
            (v) => v.vin == _vehicle!.vin,
            orElse: () => _vehicle!,
          );
        }
        // Align brand filter with selected vehicle if known
        if (_vehicle?.name.toLowerCase().contains('tata') == true) {
          _selectedBrandFilter = 'Tata';
        } else {
          _selectedBrandFilter = 'Mahindra';
        }
        _isLoading = false;
      });
    }
  }

  void _switchVehicle(VehicleItem v) {
    setState(() {
      _vehicle = v;
      if (v.name.toLowerCase().contains('tata')) {
        _selectedBrandFilter = 'Tata';
      } else {
        _selectedBrandFilter = 'Mahindra';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${v.name} (${v.registrationPlate})'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refreshGpsLocation() async {
    setState(() => _isGpsRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _isGpsRefreshing = false;
        _currentGpsCity = 'Kozhikode, Kerala (11.2588° N, 75.7804° E)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.my_location, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('GPS Synced: Kozhikode Hub (0.8s lock)'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onNavigationTabSelected(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(initialVin: _vehicle?.vin)),
      );
    } else if (index == 1) {
      // Already on ServiceScreen
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FuelOdoScreen(initialVehicle: _vehicle)),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FastTagScreen(initialVehicle: _vehicle)),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QrContactScreen(initialVehicle: _vehicle)),
      );
    }
  }

  void _openBookingModal({String? preselectedServiceTitle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ServiceBookingBottomSheet(
        vehicle: _vehicle ??
            VehicleItem(
              vin: 'MH12RN2024',
              name: 'Mahindra XUV700 AX7 L',
              edition: 'Diesel mHawk 2.2L • AX7 AWD',
              typeLabel: 'SUV',
              status: 'Optimal',
              isOnline: true,
              fuelLevelPercent: 75.0,
              fuelCapacityLitres: 60.0,
              rangeKm: 580,
              odometerKm: 12450,
              locationName: 'Kozhikode, Kerala',
              imageUrl: '',
              isSelected: true,
              registrationPlate: 'MH 12 RN 2024',
            ),
        allServices: _recommendedServices,
        serviceCenters: _serviceCenters,
        preselectedServiceTitle: preselectedServiceTitle,
        onBookingConfirmed: (ticketData) {
          _showBookingConfirmedDialog(ticketData);
        },
      ),
    );
  }

  void _showBookingConfirmedDialog(Map<String, dynamic> ticketData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Appointment Confirmed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Digital service pass generated for your vehicle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking Code',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ticketData['code'] ?? 'SRV-77189',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildTicketRow('Vehicle', ticketData['vehicleName'] ?? 'Mahindra XUV700'),
                    const SizedBox(height: 8),
                    _buildTicketRow('Slot', '${ticketData['date']} • ${ticketData['time']}'),
                    const SizedBox(height: 8),
                    _buildTicketRow('Center', ticketData['center'] ?? 'Pothens Mahindra Hub'),
                    const SizedBox(height: 8),
                    _buildTicketRow('Total Preserved', ticketData['price'] ?? '₹4,700 (Care+ Included)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Done & Add to Calendar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _vehicle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Decorative Mesh
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electric.withValues(alpha: 0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Screen Scrollable
          SafeArea(
            child: Column(
              children: [
                _buildTopAppBar(),
                _buildSecondaryNavDock(),
                Expanded(
                  child: _isLoading || vehicle == null
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: _loadVehicles,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 960),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDiagnosticsStatusBanner(vehicle),
                                    const SizedBox(height: 18),
                                    _buildHeaderAndBookHero(),
                                    const SizedBox(height: 20),
                                    _buildServiceCentersSection(),
                                    const SizedBox(height: 24),
                                    _buildRecommendedAndHistoryGrid(),
                                    const SizedBox(height: 48),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Master Top App Bar matching service.html
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo: MOTORO BHARAT
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(initialVin: _vehicle?.vin)),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.toll_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'MOTORO',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'BHARAT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(1),
                                child: Container(
                                  width: 12,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF9933), Colors.white, Color(0xFF138808)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Controls: Vehicle Switcher & Profile
          Row(
            children: [
              // Vehicle Dropdown Pill
              if (_allVehicles.isNotEmpty)
                PopupMenuButton<VehicleItem>(
                  tooltip: 'Switch Fleet Vehicle',
                  initialValue: _vehicle,
                  onSelected: _switchVehicle,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _vehicle?.registrationPlate ?? 'MH 12 RN 2024',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.secondary),
                      ],
                    ),
                  ),
                  itemBuilder: (ctx) => _allVehicles.map((v) {
                    final isSel = v.vin == _vehicle?.vin;
                    return PopupMenuItem<VehicleItem>(
                      value: v,
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSel ? AppColors.primary : AppColors.outline,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: TextStyle(
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${v.registrationPlate} • ${v.fuelType}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(width: 8),

              // Profile Avatar -> Account Screen
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Logout
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, size: 16, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Secondary Navigation Dock matching service.html & FloatingTopNavBar
  Widget _buildSecondaryNavDock() {
    final navItems = [
      {'label': 'Garage', 'icon': Icons.directions_car_rounded},
      {'label': 'Services', 'icon': Icons.build_circle_rounded},
      {'label': 'Fuel & Odo', 'icon': Icons.local_gas_station_rounded},
      {'label': 'FastTag', 'icon': Icons.toll_rounded},
      {'label': 'QR Tag', 'icon': Icons.qr_code_scanner_rounded},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(navItems.length, (idx) {
            final isSelected = idx == 1; // Service is index 1
            final item = navItems[idx];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: InkWell(
                onTap: () => _onNavigationTabSelected(idx),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 3. Vehicle Health Diagnostics Status Banner matching service.html
  Widget _buildDiagnosticsStatusBanner(VehicleItem vehicle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Vehicle Health Diagnostics',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '96% Optimal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All electronic sensors online • Next inspection at ${(vehicle.odometerKm + 2550)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol('ODOMETER', '${vehicle.odometerKm}', 'km', AppColors.onSurface),
                Container(width: 1, height: 28, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                _buildMetricCol('FUEL LEVEL', '${vehicle.fuelLevelPercent.toInt()}%', '(${vehicle.fuelCapacityLitres.toInt()} L)', AppColors.primary),
                Container(width: 1, height: 28, color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                _buildMetricCol('SERVICE DUE', 'In 480', 'km', AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, String unit, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: valColor,
                  fontFamily: 'sans-serif',
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Header & Book Service Hero Button matching service.html
  Widget _buildHeaderAndBookHero() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Service & Maintenance',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Book certified service centers with genuine OEM parts warranty.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _openBookingModal(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          icon: const Icon(Icons.calendar_month_rounded, size: 18),
          label: Row(
            children: const [
              Text(
                'Book Service',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Authorized Service Centers with Brand Filters & Interactive Canvas Map
  Widget _buildServiceCentersSection() {
    final filteredCenters = _serviceCenters.where((c) {
      if (_selectedBrandFilter == 'ALL') return true;
      if (_selectedBrandFilter == 'Mahindra') return c['brand'] == 'Mahindra' || c['brand'] == 'All';
      if (_selectedBrandFilter == 'Tata') return c['brand'] == 'Tata' || c['brand'] == 'All';
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & GPS Trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.near_me_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Authorized Centers',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _selectedBrandFilter == 'ALL'
                                  ? 'ALL FLEETS'
                                  : '$_selectedBrandFilter OEM',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Nearest centers in Kozhikode, Kerala',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),

              // GPS Refresh Button
              InkWell(
                onTap: _refreshGpsLocation,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isGpsRefreshing ? 'Syncing...' : '📍 GPS Active',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.refresh_rounded,
                        size: 13,
                        color: _isGpsRefreshing ? AppColors.primary : AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stylized Interactive Visual Map Canvas
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Stylized Vector Map Road Grid
                CustomPaint(
                  size: const Size(double.infinity, 160),
                  painter: _ServiceMapCanvasPainter(),
                ),

                // Floating Brand Filter Pills Overlay on Top Right
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['ALL', 'Mahindra', 'Tata'].map((brand) {
                        final isSel = _selectedBrandFilter == brand;
                        return InkWell(
                          onTap: () => setState(() => _selectedBrandFilter = brand),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              brand == 'Tata' ? 'Tata EV' : brand,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.secondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Bottom Left Coordinates Tag
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location_rounded, size: 12, color: AppColors.primaryFixed),
                        const SizedBox(width: 5),
                        Text(
                          _currentGpsCity,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Carousel of Service Center Cards
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredCenters.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 12),
              itemBuilder: (ctx, idx) {
                final center = filteredCenters[idx];
                return _buildCenterCard(center);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(Map<String, dynamic> center) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      center['distance'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFEAB308)),
                      const SizedBox(width: 2),
                      Text(
                        '${center['rating']} (${center['reviews']})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                center['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                center['location'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${center['bays']} Bays • Open',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              ElevatedButton(
                onPressed: () => _openBookingModal(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(60, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Select Bay',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. Two-Column Layout: Recommended Maintenance & Service Records Timeline
  Widget _buildRecommendedAndHistoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _buildRecommendedServicesColumn(),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 6,
                child: _buildServiceRecordsTimelineColumn(),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecommendedServicesColumn(),
              const SizedBox(height: 24),
              _buildServiceRecordsTimelineColumn(),
            ],
          );
        }
      },
    );
  }

  Widget _buildRecommendedServicesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.build_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 6),
                Text(
                  'Recommended Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '3 Due',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recommendedServices.length,
          separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
          itemBuilder: (ctx, idx) {
            final s = _recommendedServices[idx];
            return _buildServiceActionCard(s);
          },
        ),
      ],
    );
  }

  Widget _buildServiceActionCard(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (s['badgeColor'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s['icon'] as IconData, color: s['badgeColor'] as Color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (s['badgeColor'] as Color).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s['badge'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: s['badgeColor'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s['subtitle'] as String,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹${(s['cost'] as double).toInt()} ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                      TextSpan(
                        text: '· ${s['duration']}',
                        style: const TextStyle(fontSize: 10, color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _openBookingModal(preselectedServiceTitle: s['title'] as String),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: const [
                        Text(
                          'Book',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRecordsTimelineColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 6),
            Text(
              'Service Records History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _serviceHistory.length,
          itemBuilder: (ctx, idx) {
            final rec = _serviceHistory[idx];
            return _buildTimelineItem(rec, isLast: idx == _serviceHistory.length - 1);
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> rec, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Line with Circle Marker
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: rec['badgeColor'] as Color, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              rec['date'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: (rec['badgeColor'] as Color).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rec['badge'] as String,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: rec['badgeColor'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          rec['odometer'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rec['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rec['subtitle'] as String,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                rec['details'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            rec['code'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Map Canvas Painter for realistic futuristic blueprint aesthetic
class _ServiceMapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    // Draw subtle grid lines
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Road highway paths
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.65);
    path1.quadraticBezierTo(size.width * 0.4, size.height * 0.55, size.width, size.height * 0.35);
    canvas.drawPath(path1, roadPaint);

    final roadPaint2 = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(size.width * 0.25, 0);
    path2.lineTo(size.width * 0.35, size.height);
    canvas.drawPath(path2, roadPaint2);

    // Connecting route line (electric teal)
    final routePaint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final routePath = Path();
    routePath.moveTo(size.width * 0.28, size.height * 0.62);
    routePath.lineTo(size.width * 0.52, size.height * 0.48);
    routePath.lineTo(size.width * 0.76, size.height * 0.38);
    canvas.drawPath(routePath, routePaint);

    // Center pins
    final pinPaint = Paint()..color = const Color(0xFF2BB5B2);
    final pinPaintMahindra = Paint()..color = const Color(0xFF006A68);
    final userPin = Paint()..color = const Color(0xFF00E5C9);

    // User Location Pulse
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.62), 10, Paint()..color = const Color(0x3300E5C9));
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.62), 5, userPin);

    // Pin 1 (Pothens Mahindra Hub)
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.48), 6, pinPaintMahindra);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.48), 2.5, Paint()..color = Colors.white);

    // Pin 2 (Malayalam Tata EV Hub)
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.38), 6, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.38), 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 7. Multi-Service Booking Bottom Sheet Modal matching service.html
class _ServiceBookingBottomSheet extends StatefulWidget {
  final VehicleItem vehicle;
  final List<Map<String, dynamic>> allServices;
  final List<Map<String, dynamic>> serviceCenters;
  final String? preselectedServiceTitle;
  final ValueChanged<Map<String, dynamic>> onBookingConfirmed;

  const _ServiceBookingBottomSheet({
    required this.vehicle,
    required this.allServices,
    required this.serviceCenters,
    this.preselectedServiceTitle,
    required this.onBookingConfirmed,
  });

  @override
  State<_ServiceBookingBottomSheet> createState() => _ServiceBookingBottomSheetState();
}

class _ServiceBookingBottomSheetState extends State<_ServiceBookingBottomSheet> {
  final Set<String> _selectedServiceIds = {};
  int _selectedDayIndex = 5; // Sep 05
  String _selectedTimeSlot = '11:30 AM';
  late String _selectedCenter;
  bool _doorstepPickup = false;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _timeSlots = ['09:00 AM', '11:30 AM', '02:00 PM', '04:30 PM'];

  @override
  void initState() {
    super.initState();
    _selectedCenter = widget.serviceCenters.first['name'] as String;

    // Default select services
    _selectedServiceIds.add('oil');
    _selectedServiceIds.add('brakes');

    if (widget.preselectedServiceTitle != null) {
      final match = widget.allServices.firstWhere(
        (s) => s['title'] == widget.preselectedServiceTitle,
        orElse: () => widget.allServices.first,
      );
      _selectedServiceIds.add(match['id'] as String);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalEstimate {
    double sum = 0;
    for (final s in widget.allServices) {
      if (_selectedServiceIds.contains(s['id'])) {
        sum += (s['cost'] as double);
      }
    }
    if (_doorstepPickup) sum += 350;
    return sum;
  }

  int get _totalMinutes {
    int sum = 0;
    for (final s in widget.allServices) {
      if (_selectedServiceIds.contains(s['id'])) {
        sum += (s['minutes'] as int);
      }
    }
    return sum;
  }

  void _proceedToCheckoutOrConfirm() {
    final ticketData = {
      'code': 'SRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'vehicleName': widget.vehicle.name,
      'date': 'Sep 0$_selectedDayIndex, 2026',
      'time': _selectedTimeSlot,
      'center': _selectedCenter,
      'price': '₹${_totalEstimate.toInt()}',
      'pickup': _doorstepPickup,
    };

    Navigator.pop(context); // Close bottom sheet

    // Offer advance token payment option via PaymentGatewayScreen or direct booking
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Confirm Booking Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Total Estimated Service: ₹${_totalEstimate.toInt()}\n'
          'Slot: Sep 0$_selectedDayIndex • $_selectedTimeSlot\n'
          'Center: $_selectedCenter\n\n'
          'Would you like to pay an advance deposit of ₹500 via UPI/Card, or pay at the center upon delivery?',
          style: const TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onBookingConfirmed(ticketData);
            },
            child: const Text('Pay at Center'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentGatewayScreen(
                    itemTitle: 'Service Bay Advance Deposit',
                    itemSubtitle: 'Bay Slot at $_selectedCenter • Sep 0$_selectedDayIndex',
                    amount: 500.0,
                    onPaymentSuccess: () {
                      widget.onBookingConfirmed(ticketData);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay ₹500 Advance'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Book Service Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Select services, date and preferred center',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardPadding + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Confirmation Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vehicle.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.vehicle.registrationPlate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Care+ Covered',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 1. Multi-Service Checklist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SELECT SERVICES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_selectedServiceIds.length} Selected • ~${_totalMinutes ~/ 60}h ${_totalMinutes % 60}m',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...widget.allServices.map((s) {
                    final isChecked = _selectedServiceIds.contains(s['id']);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              if (_selectedServiceIds.length > 1) {
                                _selectedServiceIds.remove(s['id']);
                              }
                            } else {
                              _selectedServiceIds.add(s['id'] as String);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isChecked ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surfaceContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isChecked ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedServiceIds.add(s['id'] as String);
                                    } else if (_selectedServiceIds.length > 1) {
                                      _selectedServiceIds.remove(s['id']);
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['title'] as String,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      s['subtitle'] as String,
                                      style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${(s['cost'] as double).toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // 2. Interactive Calendar Date Picker
                  const Text(
                    'APPOINTMENT DATE & SLOT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'September 2026',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Mon - Sun',
                              style: TextStyle(fontSize: 10, color: AppColors.outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Calendar days row for current week
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final dayNum = i + 1;
                            final isSel = _selectedDayIndex == dayNum;
                            final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return InkWell(
                              onTap: () => setState(() => _selectedDayIndex = dayNum),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 36,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSel ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                  boxShadow: isSel
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayLabels[i],
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white.withValues(alpha: 0.8) : AppColors.outline,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '0$dayNum',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white : AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Time Slots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _timeSlots.map((slot) {
                      final isSel = _selectedTimeSlot == slot;
                      return InkWell(
                        onTap: () => setState(() => _selectedTimeSlot = slot),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSel ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 3. Service Center Picker Dropdown
                  const Text(
                    'SERVICE CENTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCenter,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCenter = val);
                        },
                        items: widget.serviceCenters.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['name'] as String,
                            child: Text(
                              '${c['name']} (${c['distance']})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Doorstep Valet Pickup Toggle (+₹350)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doorstep Valet Pickup & Drop',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Driver will collect vehicle from home/office (+₹350)',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _doorstepPickup,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _doorstepPickup = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 5. Notes
                  const Text(
                    'NOTES (OPTIONAL)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g. Check slight steering vibration above 80 km/h...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer Checkout Summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ESTIMATED TOTAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₹${_totalEstimate.toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _proceedToCheckoutOrConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
