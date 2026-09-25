import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_top_nav_bar.dart';
import 'login_screen.dart';
import 'service_screen.dart';

class HomeScreen extends StatefulWidget {
  final String operatorName;
  final String operatorEmail;
  final String? initialVin;

  const HomeScreen({
    super.key,
    this.operatorName = 'Alex Mercer',
    this.operatorEmail = 'driver@motoro.io',
    this.initialVin,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  FleetSummary? _fleetSummary;
  List<VehicleItem> _vehicles = [];
  VehicleItem? _selectedVehicle;

  // Notification alerts
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Service Due Soon',
      'time': '1 hour ago',
      'desc': 'Audi RS6 Avant: Oil & Filter replacement recommended in 350 km.',
      'icon': 'warning',
    },
    {
      'title': 'Fuel Fill-Up Logged',
      'time': '3 hours ago',
      'desc': 'Porsche 911 GT3 RS: 45.0 L logged at Shell Express Station.',
      'icon': 'gas',
    },
    {
      'title': 'Toll Deducted',
      'time': 'Yesterday',
      'desc': 'FastTag debited \$4.20 on Express Highway 101.',
      'icon': 'toll',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFleetData();
  }

  Future<void> _loadFleetData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await ApiService.getFleetSummary();
      final vehicles = await ApiService.getVehicles();

      VehicleItem? activeCar;
      if (widget.initialVin != null) {
        activeCar = vehicles.firstWhere(
          (v) => v.vin == widget.initialVin,
          orElse: () => vehicles.firstWhere((v) => v.isSelected, orElse: () => vehicles.first),
        );
      } else {
        activeCar = vehicles.firstWhere((v) => v.isSelected, orElse: () => vehicles.first);
      }

      if (mounted) {
        setState(() {
          _fleetSummary = summary;
          _vehicles = vehicles;
          _selectedVehicle = activeCar;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNotificationToast(String message, {IconData icon = Icons.check_circle_outline}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E2828),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 2600),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryFixedDim, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSwitchVehicle(VehicleItem vehicle) async {
    if (vehicle.vin == _selectedVehicle?.vin) return;
    setState(() => _isLoading = true);

    await ApiService.selectVehicle(vehicle.vin);

    setState(() {
      for (var v in _vehicles) {
        v.isSelected = (v.vin == vehicle.vin);
      }
      _selectedVehicle = vehicle;
      _isLoading = false;
    });

    _showNotificationToast(
      'Switched active vehicle to ${vehicle.name}',
      icon: Icons.swap_horiz,
    );
  }

  void _onTopNavTabSelected(int index) {
    if (index == 0) {
      // Already on Garage Hub
      _loadFleetData();
    } else if (index == 1) {
      // Navigate to Service & Care screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceScreen(initialVehicle: _selectedVehicle),
        ),
      ).then((_) => _loadFleetData());
    } else if (index == 2) {
      // Open Fuel & Odometer logs sheet
      _showDriverLogSheet(initialTab: 0);
    } else if (index == 3) {
      // Open Toll Wallet sheet
      _showWalletRechargeSheet();
    }
  }

  // --- Driver Logging Sheet (Fuel & Odometer) ---

  void _showDriverLogSheet({int initialTab = 0}) {
    final vehicle = _selectedVehicle;
    if (vehicle == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DriverLogModalSheet(
        vehicle: vehicle,
        initialTab: initialTab,
        onLogSaved: (msg) {
          _loadFleetData();
          _showNotificationToast(msg, icon: Icons.check_circle);
        },
      ),
    );
  }

  void _showWalletRechargeSheet() {
    final controller = TextEditingController(text: '50.00');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.toll, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recharge FastTag Wallet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current Balance: \$${(_fleetSummary?.tollWalletBalance ?? 124.50).toStringAsFixed(2)} • Auto-Reload Active',
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [25, 50, 100].map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text('\$$amt'),
                    backgroundColor: AppColors.surfaceContainerLow,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    onPressed: () {
                      controller.text = amt.toStringAsFixed(2);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Recharge Amount (\$)',
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(controller.text);
                  if (amt != null && amt > 0) {
                    Navigator.pop(ctx);
                    final msg = await ApiService.rechargeWallet(amt);
                    setState(() {
                      if (_fleetSummary != null) {
                        _fleetSummary = FleetSummary(
                          totalVehicles: _fleetSummary!.totalVehicles,
                          activeCount: _fleetSummary!.activeCount,
                          parkedCount: _fleetSummary!.parkedCount,
                          fleetMileageKm: _fleetSummary!.fleetMileageKm,
                          avgEfficiency: _fleetSummary!.avgEfficiency,
                          nextServiceDays: _fleetSummary!.nextServiceDays,
                          tollWalletBalance: _fleetSummary!.tollWalletBalance + amt,
                          selectedVin: _fleetSummary!.selectedVin,
                        );
                      }
                    });
                    _showNotificationToast(msg, icon: Icons.credit_card);
                  }
                },
                child: const Text('Complete Instant Recharge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPairVehicleModal() {
    final nameCtrl = TextEditingController();
    final vinCtrl = TextEditingController();
    String selectedFuel = 'Petrol';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Enroll Vehicle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a combustion or hybrid vehicle to your MOTORO fleet management account.',
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Vehicle Model / Nickname',
                  hintText: 'e.g. Porsche 911 GT3 RS',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vinCtrl,
                decoration: InputDecoration(
                  labelText: 'Vehicle VIN',
                  hintText: 'e.g. MOTORO-911-GT3',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedFuel,
                decoration: InputDecoration(
                  labelText: 'Engine & Fuel Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Petrol', child: Text('Petrol (95/98 Octane)')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Turbo Diesel')),
                  DropdownMenuItem(value: 'Hybrid', child: Text('Plug-in / Mild Hybrid')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedFuel = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final newName = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'New Vehicle';
                final newVin = vinCtrl.text.trim().isNotEmpty ? vinCtrl.text.trim().toUpperCase() : 'MOTORO-${DateTime.now().millisecond}';

                final newCar = VehicleItem(
                  vin: newVin,
                  name: newName,
                  edition: 'Enrolled • Driver-Logged',
                  typeLabel: 'Fleet Vehicle',
                  fuelType: selectedFuel,
                  status: 'In Garage • Ready',
                  isOnline: true,
                  fuelLevelPercent: 80.0,
                  fuelCapacityLitres: 60.0,
                  rangeKm: 460,
                  odometerKm: 5000,
                  serviceDueKm: 1500,
                  locationName: 'Home Garage',
                  imageUrl: 'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=1200&q=80',
                  isSelected: true,
                );

                setState(() {
                  for (var v in _vehicles) {
                    v.isSelected = false;
                  }
                  _vehicles.add(newCar);
                  _selectedVehicle = newCar;
                });

                _showNotificationToast('$newName enrolled & active in fleet!', icon: Icons.check_circle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enroll Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Fleet Alerts & Notices',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _notifications.clear());
                    Navigator.pop(ctx);
                  },
                  child: const Text('Clear All', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No active notifications or alerts.', style: TextStyle(color: AppColors.secondary)),
                ),
              )
            else
              ..._notifications.map((n) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          n['icon'] == 'warning' ? Icons.warning_amber_rounded : Icons.notifications,
                          color: n['icon'] == 'warning' ? AppColors.error : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    n['title']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                                  ),
                                  Text(
                                    n['time']!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['desc']!,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.operatorName.isNotEmpty ? widget.operatorName[0].toUpperCase() : 'M',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.operatorName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    Text(
                      widget.operatorEmail,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_car, color: AppColors.primary),
              title: const Text('Managed Vehicles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: Text('${_vehicles.length} cars', style: const TextStyle(color: AppColors.outline, fontSize: 13)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.build_circle_outlined, color: AppColors.primary),
              title: const Text('Service & Care Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceScreen(initialVehicle: _selectedVehicle),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAlert = _vehicles.any((v) => v.serviceAlert != null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Atmospheric Ambient Glow Blobs
          Positioned(
            top: -60,
            left: -80,
            child: _buildAtmosphericGlow(
              color: AppColors.primaryFixedDim.withValues(alpha: 0.25),
              diameter: 280,
            ),
          ),
          Positioned(
            top: 360,
            right: -100,
            child: _buildAtmosphericGlow(
              color: AppColors.primaryContainer.withValues(alpha: 0.16),
              diameter: 320,
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: _buildAtmosphericGlow(
              color: AppColors.tertiaryFixedDim.withValues(alpha: 0.2),
              diameter: 360,
            ),
          ),

          // Main View Body
          Column(
            children: [
              _buildTopHeader(),
              // Floating Top Navigation Bar
              FloatingTopNavBar(
                currentIndex: 0,
                hasServiceAlert: hasAlert,
                onTabSelected: _onTopNavTabSelected,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _loadFleetData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 820),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSection1FleetMacroPulse(),
                                  const SizedBox(height: 20),
                                  _buildSection2HeroVehiclePod(),
                                  const SizedBox(height: 16),
                                  _buildOtherVehiclesPod(),
                                  const SizedBox(height: 14),
                                  _buildPairNewVehicleTile(),
                                  const SizedBox(height: 24),
                                  _buildSection3ManualActionPods(),
                                  const SizedBox(height: 24),
                                  _buildSection4FleetShortcuts(),
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
        ],
      ),
    );
  }

  Widget _buildAtmosphericGlow({required Color color, required double diameter}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // --- Top Header ---

  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'MOTORO',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Driver-Logged Telemetry Hub',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions (Notifications & Profile)
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: _showNotificationsSheet,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
                    ),
                    icon: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                  if (_notifications.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showProfileMenu,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 1: Fleet Macro Pulse ---

  Widget _buildSection1FleetMacroPulse() {
    final summary = _fleetSummary;
    final totalVehicles = summary?.totalVehicles ?? _vehicles.length;
    final mileage = summary?.fleetMileageKm ?? 48210;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Fleet Overview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalVehicles Cars Managed',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Manual driver logs, fuel tracking, and lifecycle service schedules',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Refresh Button
            IconButton(
              onPressed: _loadFleetData,
              icon: const Icon(Icons.refresh, color: AppColors.primary, size: 20),
              tooltip: 'Sync Fleet Data',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Macro Pill Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMacroPill(
                icon: Icons.speed,
                iconColor: AppColors.primary,
                label: 'Combined Odometer',
                value: '${mileage.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} km',
              ),
              const SizedBox(width: 8),
              _buildMacroPill(
                icon: Icons.local_gas_station_rounded,
                iconColor: AppColors.tertiary,
                label: 'Fleet Efficiency',
                value: summary?.avgEfficiency ?? '14.8 km/L',
              ),
              const SizedBox(width: 8),
              _buildMacroPill(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primaryContainer,
                label: 'Toll Wallet',
                value: '\$${(summary?.tollWalletBalance ?? 124.50).toStringAsFixed(2)}',
                valueColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildMacroPill(
                icon: Icons.event_available_outlined,
                iconColor: AppColors.secondary,
                label: 'Next Maintenance',
                value: 'In ${summary?.nextServiceDays ?? 14} days',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: valueColor ?? AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Section 2: Primary Selected Vehicle (Hero Pod) ---

  Widget _buildSection2HeroVehiclePod() {
    final vehicle = _selectedVehicle ?? (_vehicles.isNotEmpty ? _vehicles.first : null);
    if (vehicle == null) return const SizedBox.shrink();

    final remainingLitres = (vehicle.fuelCapacityLitres * vehicle.fuelLevelPercent / 100.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, size: 8, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Active Profile',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onPrimaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vehicle.fuelType,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      vehicle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      vehicle.edition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Fuel Tank Gauge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_gas_station_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${vehicle.fuelLevelPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${remainingLitres.toStringAsFixed(1)} / ${vehicle.fuelCapacityLitres.toStringAsFixed(0)} L',
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    '${vehicle.rangeKm} km est. range',
                    style: const TextStyle(fontSize: 10, color: AppColors.outline),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Vehicle Visual Display
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  height: 175,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    image: DecorationImage(
                      image: NetworkImage(vehicle.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient Scrim
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Status Overlay: In Garage / Location
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_outlined, color: AppColors.primary, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          vehicle.locationName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Odometer Overlay
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: AppColors.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.odometerKm.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Driver Action Quick Buttons (Fuel Log, Odometer, Service)
          Row(
            children: [
              Expanded(
                child: _buildDriverActionButton(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Log Fuel',
                  color: AppColors.primary,
                  onTap: () => _showDriverLogSheet(initialTab: 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDriverActionButton(
                  icon: Icons.speed_rounded,
                  label: 'Log Odometer',
                  color: AppColors.tertiary,
                  onTap: () => _showDriverLogSheet(initialTab: 1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDriverActionButton(
                  icon: Icons.build_circle_rounded,
                  label: 'Book Service',
                  color: AppColors.primaryContainer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceScreen(initialVehicle: vehicle),
                      ),
                    ).then((_) => _loadFleetData());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Section 2b: Other Vehicles In Garage Pod ---

  Widget _buildOtherVehiclesPod() {
    final otherCars = _vehicles.where((v) => v.vin != _selectedVehicle?.vin).toList();
    if (otherCars.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTHER FLEET VEHICLES',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ...otherCars.map((car) {
          final isWarning = car.serviceAlert != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          car.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    car.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isWarning ? AppColors.errorContainer : AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isWarning ? 'Service Due' : car.fuelType,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isWarning ? AppColors.error : AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isWarning ? (car.serviceAlert ?? '') : (car.driverInfo ?? car.edition),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isWarning ? AppColors.error : AppColors.onSurfaceVariant,
                                fontWeight: isWarning ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleSwitchVehicle(car),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWarning ? AppColors.surfaceContainerHigh : AppColors.secondary,
                          foregroundColor: isWarning ? AppColors.onSurface : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Switch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Quick info pills
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_gas_station_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${car.fuelLevelPercent.toInt()}% (${car.rangeKm} km)',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.speed, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${car.odometerKm} km',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.build_outlined, size: 14, color: AppColors.tertiary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  car.serviceDueKm != null ? '${car.serviceDueKm} km due' : 'Inspected',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPairNewVehicleTile() {
    return InkWell(
      onTap: _showPairVehicleModal,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_circle, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enroll Another Vehicle',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                  ),
                  Text(
                    'Add Petrol, Diesel, or Hybrid car to your driver management list',
                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // --- Section 3: Driver Manual Telemetry Pods (2x2 Grid) ---

  Widget _buildSection3ManualActionPods() {
    final vehicle = _selectedVehicle;
    if (vehicle == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${vehicle.name} • Driver Pods',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            IconButton(
              onPressed: () => _showDriverLogSheet(initialTab: 0),
              icon: const Icon(Icons.post_add_rounded, color: AppColors.primary, size: 22),
              tooltip: 'Open Logbook',
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            // Pod 1: Quick Fuel Log
            _buildTelemetryTile(
              title: 'Fuel Tank Level',
              icon: Icons.local_gas_station_rounded,
              iconColor: AppColors.primary,
              value: '${vehicle.fuelLevelPercent.toStringAsFixed(0)}%',
              unit: '${vehicle.fuelCapacityLitres.toStringAsFixed(0)} L Tank Capacity',
              actionLabel: '+ Fuel Fill-Up',
              actionColor: AppColors.primary,
              onAction: () => _showDriverLogSheet(initialTab: 0),
            ),
            // Pod 2: Quick Odometer Log
            _buildTelemetryTile(
              title: 'Odometer Reading',
              icon: Icons.speed_rounded,
              iconColor: AppColors.tertiary,
              value: vehicle.odometerKm.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},"),
              unit: 'km verified reading',
              actionLabel: '+ Log Reading',
              actionColor: AppColors.tertiary,
              onAction: () => _showDriverLogSheet(initialTab: 1),
            ),
            // Pod 3: Fuel Economy / Mileage
            _buildTelemetryTile(
              title: 'Calculated Mileage',
              icon: Icons.eco_rounded,
              iconColor: AppColors.primaryContainer,
              value: _fleetSummary?.avgEfficiency ?? '14.8 km/L',
              unit: 'Driver log estimate',
              actionLabel: 'View Logbook',
              actionColor: AppColors.primary,
              onAction: () => _showDriverLogSheet(initialTab: 0),
            ),
            // Pod 4: Maintenance Countdown
            _buildTelemetryTile(
              title: 'Service Countdown',
              icon: Icons.build_circle_outlined,
              iconColor: vehicle.serviceAlert != null ? AppColors.error : AppColors.secondary,
              value: vehicle.serviceDueKm != null ? '${vehicle.serviceDueKm} km' : 'Scheduled',
              unit: vehicle.serviceAlert != null ? 'Action Due' : 'All Clear',
              actionLabel: 'Book Care',
              actionColor: vehicle.serviceAlert != null ? AppColors.error : AppColors.secondary,
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceScreen(initialVehicle: vehicle),
                  ),
                ).then((_) => _loadFleetData());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.onSurface),
              ),
              Text(
                unit,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.secondary),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: actionColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: actionColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Section 4: Fleet Hub Shortcuts ---

  Widget _buildSection4FleetShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FLEET SHORTCUTS',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildShortcutCard(
                icon: Icons.local_gas_station_outlined,
                color: AppColors.primary,
                title: 'Fuel Logbook',
                subtitle: 'Pump receipts & km/L',
                onTap: () => _showDriverLogSheet(initialTab: 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShortcutCard(
                icon: Icons.build_circle_outlined,
                color: AppColors.tertiary,
                title: 'Service & Care',
                subtitle: 'Multi-service booking',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceScreen(initialVehicle: _selectedVehicle),
                    ),
                  ).then((_) => _loadFleetData());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildShortcutCard(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primaryContainer,
                title: 'Toll Wallet',
                subtitle: '\$${(_fleetSummary?.tollWalletBalance ?? 124.50).toStringAsFixed(2)} balance',
                onTap: _showWalletRechargeSheet,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildShortcutCard(
                icon: Icons.speed_outlined,
                color: AppColors.secondary,
                title: 'Odometer Entry',
                subtitle: 'Log current mileage',
                onTap: () => _showDriverLogSheet(initialTab: 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.onSurface),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Stateful Driver Log Modal Sheet with Fuel & Odometer Tabs ---

class _DriverLogModalSheet extends StatefulWidget {
  final VehicleItem vehicle;
  final int initialTab;
  final Function(String) onLogSaved;

  const _DriverLogModalSheet({
    required this.vehicle,
    this.initialTab = 0,
    required this.onLogSaved,
  });

  @override
  State<_DriverLogModalSheet> createState() => _DriverLogModalSheetState();
}

class _DriverLogModalSheetState extends State<_DriverLogModalSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fuelLitresCtrl = TextEditingController(text: '35.0');
  final _fuelCostCtrl = TextEditingController(text: '68.50');
  String _selectedStation = 'Shell Express';

  late TextEditingController _odometerCtrl;
  int _odometerDelta = 0;
  bool _isSubmitting = false;

  final List<String> _stationPresets = [
    'Shell Express',
    'BP Connect',
    'Chevron',
    'ExxonMobil',
    'IndianOil Hub',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _odometerCtrl = TextEditingController(text: (widget.vehicle.odometerKm + 45).toString());
    _odometerDelta = 45;

    _odometerCtrl.addListener(() {
      final val = int.tryParse(_odometerCtrl.text);
      if (val != null) {
        setState(() {
          _odometerDelta = val - widget.vehicle.odometerKm;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fuelLitresCtrl.dispose();
    _fuelCostCtrl.dispose();
    _odometerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitFuelLog() async {
    final litres = double.tryParse(_fuelLitresCtrl.text);
    if (litres == null || litres <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fuel volume in Litres.')),
      );
      return;
    }

    final cost = double.tryParse(_fuelCostCtrl.text) ?? 0.0;
    setState(() => _isSubmitting = true);

    try {
      final msg = await ApiService.logFuel(
        vin: widget.vehicle.vin,
        amountLitres: litres,
        costTotal: cost,
        fuelStation: _selectedStation,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onLogSaved(msg);
      }
    } catch (_) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitOdometerLog() async {
    final newKm = int.tryParse(_odometerCtrl.text);
    if (newKm == null || newKm < widget.vehicle.odometerKm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New odometer reading must be at least ${widget.vehicle.odometerKm} km.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final msg = await ApiService.logOdometer(widget.vehicle.vin, newKm);
      if (mounted) {
        Navigator.pop(context);
        widget.onLogSaved(msg);
      }
    } catch (_) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle & Close
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Logbook',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      widget.vehicle.name,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.secondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.local_gas_station_rounded, size: 18), text: 'Fuel Fill-Up'),
                  Tab(icon: Icon(Icons.speed_rounded, size: 18), text: 'Odometer Update'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Views
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Fuel
                  _buildFuelTab(),
                  // Tab 2: Odometer
                  _buildOdometerTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fuelLitresCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Volume Pumped',
                  suffixText: 'Litres',
                  prefixIcon: const Icon(Icons.local_gas_station, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _fuelCostCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Cost',
                  prefixText: '\$ ',
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text(
          'Station / Brand',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _stationPresets.map((st) {
            final isSel = _selectedStation == st;
            return ChoiceChip(
              label: Text(st),
              selected: isSel,
              selectedColor: AppColors.primaryContainer.withValues(alpha: 0.25),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                color: isSel ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedStation = st);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tank Capacity: ${widget.vehicle.fuelCapacityLitres.toStringAsFixed(0)} L • Current: ${widget.vehicle.fuelLevelPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitFuelLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Fuel Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildOdometerTab() {
    final nextService = widget.vehicle.serviceDueKm ?? 500;
    final remainingServiceAfter = (_odometerDelta > 0) ? (nextService - _odometerDelta).clamp(0, 999999) : nextService;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Stored Odometer:', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
              Text(
                '${widget.vehicle.odometerKm.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} km',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _odometerCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Odometer (km)',
            prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
            suffixText: 'km',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),

        // Live Delta & Service Impact
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _odometerDelta >= 0 ? AppColors.surfaceContainerHigh : AppColors.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Distance Logged This Session:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  Text(
                    '+$_odometerDelta km',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _odometerDelta >= 0 ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Next Service Interval Countdown:', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  Text(
                    '$remainingServiceAfter km',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitOdometerLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Update Odometer Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
