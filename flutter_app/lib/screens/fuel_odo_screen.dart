import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'garage_screen.dart';
import 'service_screen.dart';
import 'fasttag_screen.dart';
import 'qr_contact_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';

class FuelOdoScreen extends StatefulWidget {
  final VehicleItem? initialVehicle;

  const FuelOdoScreen({
    super.key,
    this.initialVehicle,
  });

  @override
  State<FuelOdoScreen> createState() => _FuelOdoScreenState();
}

class _FuelOdoScreenState extends State<FuelOdoScreen> with SingleTickerProviderStateMixin {
  VehicleItem? _vehicle;
  List<VehicleItem> _allVehicles = [];
  bool _isLoading = false;

  // Pulse animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Fuel telemetry state
  double _fuelPercent = 78.0;
  double _fuelLitres = 46.8;
  double _tankCapacity = 60.0;
  int _estRangeKm = 620;
  int _currentOdo = 14820;

  // Fuel Form Controllers
  final _fuelLitresCtrl = TextEditingController(text: '35.0');
  final _fuelPriceCtrl = TextEditingController(text: '94.20');
  String _selectedStation = 'Shell Express V-Power Station';
  String _selectedGrade = 'Diesel BS-VI Ultra Low Sulphur';
  bool _isFullTankCalibrated = true;

  // Odometer Form Controllers
  final _odoReadingCtrl = TextEditingController(text: '15290');
  final _odoNotesCtrl = TextEditingController(text: 'Mumbai to Pune Expressway return trip');
  String _selectedTripType = 'Highway Cruise';

  // Demo Ledger Entries
  late List<Map<String, dynamic>> _logs;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _vehicle = widget.initialVehicle;
    _initLogs();
    _loadData();
  }

  void _initLogs() {
    _logs = [
      {
        'date': 'Today, 04:30 PM',
        'type': 'Fuel Fill-Up',
        'odo': 14820,
        'qty': '35.0 L',
        'station': 'Shell Express V-Power',
        'cost': '₹ 3,297.00',
        'mileage': '14.8 km/L',
        'isFuel': true,
      },
      {
        'date': '29 Aug, 09:15 AM',
        'type': 'Odo Checkpoint',
        'odo': 14350,
        'qty': '+470 km',
        'station': 'Highway Cruise',
        'cost': '-',
        'mileage': '16.8 km/L',
        'isFuel': false,
      },
      {
        'date': '24 Aug, 07:45 PM',
        'type': 'Fuel Fill-Up',
        'odo': 13880,
        'qty': '40.2 L',
        'station': 'IndianOil Swarna Pump',
        'cost': '₹ 3,786.80',
        'mileage': '14.2 km/L',
        'isFuel': true,
      },
      {
        'date': '18 Aug, 02:10 PM',
        'type': 'Fuel Fill-Up',
        'odo': 13310,
        'qty': '37.0 L',
        'station': 'BPCL Speed Bay',
        'cost': '₹ 3,485.40',
        'mileage': '15.4 km/L',
        'isFuel': true,
      },
      {
        'date': '12 Aug, 11:30 AM',
        'type': 'Fuel Fill-Up',
        'odo': 12750,
        'qty': '42.0 L',
        'station': 'HP AutoCare Depot',
        'cost': '₹ 3,956.40',
        'mileage': '13.9 km/L',
        'isFuel': true,
      },
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fuelLitresCtrl.dispose();
    _fuelPriceCtrl.dispose();
    _odoReadingCtrl.dispose();
    _odoNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final vehicles = await ApiService.getVehicles();
    if (mounted) {
      setState(() {
        _allVehicles = vehicles;
        if (_vehicle == null && vehicles.isNotEmpty) {
          _vehicle = vehicles.firstWhere((v) => v.isSelected, orElse: () => vehicles.first);
        } else if (_vehicle != null) {
          _vehicle = vehicles.firstWhere((v) => v.vin == _vehicle!.vin, orElse: () => _vehicle!);
        }

        if (_vehicle != null) {
          _fuelPercent = _vehicle!.fuelLevelPercent;
          _tankCapacity = _vehicle!.fuelCapacityLitres > 0 ? _vehicle!.fuelCapacityLitres : 60.0;
          _fuelLitres = (_fuelPercent / 100.0) * _tankCapacity;
          _estRangeKm = _vehicle!.rangeKm > 0 ? _vehicle!.rangeKm : 620;
          _currentOdo = _vehicle!.odometerKm > 0 ? _vehicle!.odometerKm : 14820;
          _odoReadingCtrl.text = (_currentOdo + 470).toString();
        }
        _isLoading = false;
      });
    }
  }

  void _switchVehicle(VehicleItem v) async {
    setState(() {
      _vehicle = v;
      for (var car in _allVehicles) {
        car.isSelected = (car.vin == v.vin);
      }
      _fuelPercent = v.fuelLevelPercent;
      _tankCapacity = v.fuelCapacityLitres > 0 ? v.fuelCapacityLitres : 60.0;
      _fuelLitres = (_fuelPercent / 100.0) * _tankCapacity;
      _estRangeKm = v.rangeKm > 0 ? v.rangeKm : 620;
      _currentOdo = v.odometerKm > 0 ? v.odometerKm : 14820;
      _odoReadingCtrl.text = (_currentOdo + 470).toString();
    });
    await ApiService.selectVehicle(v.vin);
  }

  double get _computedFuelCost {
    final litres = double.tryParse(_fuelLitresCtrl.text) ?? 0.0;
    final price = double.tryParse(_fuelPriceCtrl.text) ?? 0.0;
    return litres * price;
  }

  int get _computedOdoDelta {
    final entered = int.tryParse(_odoReadingCtrl.text) ?? _currentOdo;
    return (entered - _currentOdo) > 0 ? (entered - _currentOdo) : 0;
  }

  double get _computedEstimatedBurn {
    return _computedOdoDelta > 0 ? (_computedOdoDelta / 14.8) : 0.0;
  }

  void _handleFuelSubmit() {
    final litres = double.tryParse(_fuelLitresCtrl.text) ?? 35.0;
    final cost = _computedFuelCost;

    setState(() {
      _fuelLitres = math.min(_tankCapacity, _fuelLitres + litres);
      _fuelPercent = math.min(100.0, (_fuelLitres / _tankCapacity) * 100.0);
      _estRangeKm = (_fuelLitres * 14.8).round();

      _logs.insert(0, {
        'date': 'Just Now',
        'type': 'Fuel Fill-Up',
        'odo': _currentOdo,
        'qty': '${litres.toStringAsFixed(1)} L',
        'station': '${_selectedStation.split(' ')[0]} ${_selectedStation.split(' ')[1]}',
        'cost': '₹ ${cost.toStringAsFixed(2)}',
        'mileage': '14.8 km/L',
        'isFuel': true,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Logged ${litres.toStringAsFixed(1)}L refill at $_selectedStation!')),
          ],
        ),
      ),
    );
  }

  void _handleOdoSubmit() {
    final newOdo = int.tryParse(_odoReadingCtrl.text) ?? (_currentOdo + 470);
    final delta = newOdo - _currentOdo;

    setState(() {
      _currentOdo = newOdo;
      _fuelLitres = math.max(5.0, _fuelLitres - (delta / 14.8));
      _fuelPercent = (_fuelLitres / _tankCapacity) * 100.0;
      _estRangeKm = (_fuelLitres * 14.8).round();

      _logs.insert(0, {
        'date': 'Just Now',
        'type': 'Odo Checkpoint',
        'odo': newOdo,
        'qty': '+$delta km',
        'station': _selectedTripType,
        'cost': '-',
        'mileage': _selectedTripType == 'Highway Cruise' ? '17.2 km/L' : '14.8 km/L',
        'isFuel': false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.speed_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Odometer updated to $newOdo km (+$delta km logged)')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // MASTER TOP APP BAR
            _buildMasterTopAppBar(),

            // SECONDARY 5-PILL NAVIGATION DOCK
            _buildSecondaryNavDock(),

            // MAIN SCROLLABLE CONTENT
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: HERO TANK RADIAL GAUGE & ESTIMATED KM RANGE
                          _buildSection1HeroGauge(),
                          const SizedBox(height: 18),

                          // SECTION 2: DUAL MANUAL LOGGING PODS (FUEL & ODOMETER)
                          _buildSection2DualLoggingPods(),
                          const SizedBox(height: 18),

                          // SECTION 3: MILEAGE MONITOR & EFFICIENCY INTELLIGENCE
                          _buildSection3MileageMonitor(),
                          const SizedBox(height: 18),

                          // SECTION 4: APPROXIMATE ENGINE HEALTH INDEX
                          _buildSection4EngineHealth(),
                          const SizedBox(height: 18),

                          // SECTION 5: VERIFIED DRIVER LOG LEDGER
                          _buildSection5DriverLogLedger(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. MASTER TOP APP BAR
  Widget _buildMasterTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(initialVin: _vehicle?.vin)),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.toll_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MOTORO',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 12,
                          height: 8,
                          child: Column(
                            children: [
                              Container(height: 2.66, color: const Color(0xFFFF9933)),
                              Container(height: 2.66, color: Colors.white),
                              Container(height: 2.66, color: const Color(0xFF138808)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Controls
          Row(
            children: [
              PopupMenuButton<VehicleItem>(
                initialValue: _vehicle,
                tooltip: 'Switch Fleet Tag',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (veh) => _switchVehicle(veh),
                itemBuilder: (ctx) => _allVehicles.map((v) {
                  final isCurr = v.vin == _vehicle?.vin;
                  return PopupMenuItem<VehicleItem>(
                    value: v,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('${v.registrationPlate} • ${v.fuelType}', style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontFamily: 'monospace')),
                          ],
                        ),
                        if (isCurr)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                            child: Text('Active', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      FadeTransition(
                        opacity: _pulseAnimation,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _vehicle?.registrationPlate ?? 'MH 12 RN 2024',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.onSurface),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Profile "VS"
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text('VS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Logout
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.secondary),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SECONDARY 5-PILL DOCK
  Widget _buildSecondaryNavDock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildNavDockPill(
              title: 'Garage',
              icon: Icons.garage_rounded,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GarageScreen(initialVehicle: _vehicle)));
              },
            ),
            _buildNavDockPill(
              title: 'Services',
              icon: Icons.build_circle_rounded,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServiceScreen(initialVehicle: _vehicle)));
              },
            ),
            _buildNavDockPill(
              title: 'Fuel & Odo',
              icon: Icons.local_gas_station_rounded,
              isActive: true,
              onTap: () {},
            ),
            _buildNavDockPill(
              title: 'FastTag',
              icon: Icons.toll_rounded,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FastTagScreen(initialVehicle: _vehicle)));
              },
            ),
            _buildNavDockPill(
              title: 'QR Tag',
              icon: Icons.qr_code_scanner_rounded,
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QrContactScreen(initialVehicle: _vehicle)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavDockPill({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isActive ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]) : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? Colors.white : AppColors.secondary),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 1: HERO TANK RADIAL GAUGE & RANGE
  Widget _buildSection1HeroGauge() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radial Gauge
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _RadialGaugePainter(percent: _fuelPercent / 100.0),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_gas_station_rounded, size: 20, color: AppColors.primary),
                        Text(
                          '${_fuelPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        Text(
                          '${_fuelLitres.toStringAsFixed(1)} / ${_tankCapacity.toInt()}L',
                          style: const TextStyle(fontSize: 9, color: AppColors.secondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // DTE Hero Readout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DISTANCE TO EMPTY (DTE)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 0.8),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('+35 km Refill', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_estRangeKm',
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, fontFamily: 'Outfit', color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Text('km', style: TextStyle(fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Text(
                      'AI Dynamic Projection based on throttle profile',
                      style: TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 3 Macro Telemetry Cards
          Row(
            children: [
              Expanded(
                child: _buildMacroTelemetryCard(
                  label: 'CLUSTER ODOMETER',
                  value: '${_currentOdo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                  note: '+470 km logged',
                  noteColor: AppColors.emerald,
                  icon: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroTelemetryCard(
                  label: 'BLENDED MILEAGE',
                  value: '14.8 km/L',
                  note: '₹ 6.54 / km cost',
                  noteColor: AppColors.primary,
                  icon: Icons.eco_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMacroTelemetryCard(
                  label: 'APPROX HEALTH',
                  value: '96% Prime',
                  note: 'Service in 680 km',
                  noteColor: Colors.amber.shade800,
                  icon: Icons.health_and_safety_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTelemetryCard({
    required String label,
    required String value,
    required String note,
    required Color noteColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.secondary)),
              Icon(icon, size: 12, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit', color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(note, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: noteColor)),
        ],
      ),
    );
  }

  // SECTION 2: DUAL MANUAL LOGGING PODS
  Widget _buildSection2DualLoggingPods() {
    return Column(
      children: [
        // Pod A: Manual Fuel Fill-Up Log
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_gas_station_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Manual Fuel Fill-Up Log', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('QUICK LOG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Litres Input with Quick Chips
              TextField(
                controller: _fuelLitresCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Fuel Pumped (Litres)',
                  suffixText: 'LTR',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildQuickLitreChip('+10 L', () => setState(() => _fuelLitresCtrl.text = '10.0')),
                  const SizedBox(width: 6),
                  _buildQuickLitreChip('+20 L', () => setState(() => _fuelLitresCtrl.text = '20.0')),
                  const SizedBox(width: 6),
                  _buildQuickLitreChip('+35 L', () => setState(() => _fuelLitresCtrl.text = '35.0')),
                  const SizedBox(width: 6),
                  _buildQuickLitreChip('Full Tank', () => setState(() => _fuelLitresCtrl.text = (_tankCapacity - _fuelLitres).clamp(5.0, _tankCapacity).toStringAsFixed(1))),
                ],
              ),
              const SizedBox(height: 12),

              // Price & Total Cost Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fuelPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        labelText: 'Price / Litre',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Total', style: TextStyle(fontSize: 9, color: AppColors.secondary)),
                          Text(
                            '₹ ${_computedFuelCost.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Station Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedStation,
                decoration: InputDecoration(
                  labelText: 'Fuel Station / Vendor',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Shell Express V-Power Station', child: Text('Shell Express Station')),
                  DropdownMenuItem(value: 'IndianOil Swarna Pump', child: Text('IndianOil (IOCL)')),
                  DropdownMenuItem(value: 'HP AutoCare Fuel Depot', child: Text('Hindustan Petroleum (HP)')),
                  DropdownMenuItem(value: 'Bharat Petroleum Speed Bay', child: Text('Bharat Petroleum (BPCL)')),
                  DropdownMenuItem(value: 'Reliance Petroleum Terminal', child: Text('Reliance Petroleum')),
                  DropdownMenuItem(value: 'Nayara Energy Station', child: Text('Nayara Energy')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStation = val);
                },
              ),
              const SizedBox(height: 12),

              // Fuel Grade Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedGrade,
                decoration: InputDecoration(
                  labelText: 'Fuel Grade / Quality',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Diesel BS-VI Ultra Low Sulphur', child: Text('Diesel BS-VI Ultra Low')),
                  DropdownMenuItem(value: 'Premium V-Power Diesel', child: Text('Premium Cetane Diesel')),
                  DropdownMenuItem(value: 'High Octane XP95 Petrol', child: Text('High Octane XP95')),
                  DropdownMenuItem(value: 'Regular Unleaded 91', child: Text('Regular Unleaded')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGrade = val);
                },
              ),
              const SizedBox(height: 12),

              // Full Tank Calibration Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Tank Calibration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Calculates exact delta km/L between shut-offs', style: TextStyle(fontSize: 10, color: AppColors.secondary)),
                    ],
                  ),
                  Switch(
                    value: _isFullTankCalibrated,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isFullTankCalibrated = val),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleFuelSubmit,
                  icon: const Icon(Icons.ev_station_rounded, size: 18),
                  label: const Text('Log Fuel Fill-Up & Recalibrate Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pod B: Manual Odometer & Trip Checkpoint
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.speed_rounded, color: AppColors.primaryContainer, size: 20),
                      SizedBox(width: 8),
                      Text('Manual Odometer & Trip Checkpoint', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('LIVE SYNC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Odometer Reading Input
              TextField(
                controller: _odoReadingCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: 'Verified Odometer Reading (km)',
                  suffixText: 'KM',
                  helperText: 'Last logged: $_currentOdo km',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),

              // Delta Traveled & Estimated Burn Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DISTANCE DELTA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          const SizedBox(height: 2),
                          Text('+$_computedOdoDelta km', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Text('Since last refill', style: TextStyle(fontSize: 8, color: AppColors.emerald, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ESTIMATED BURN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          const SizedBox(height: 2),
                          Text('~${_computedEstimatedBurn.toStringAsFixed(1)} L', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                          const Text('At 14.8 km/L blended', style: TextStyle(fontSize: 8, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Trip Driving Environment Selector
              const Text('Trip Driving Environment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTripEnvRadio('Highway Cruise', 'Highway', '17.2 km/L', Icons.add_road_rounded)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTripEnvRadio('City Commute', 'City Rush', '12.1 km/L', Icons.traffic_rounded)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTripEnvRadio('Off-Road Trail', 'Off-Road', '10.5 km/L', Icons.terrain_rounded)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTripEnvRadio('Mixed City & Highway', 'Mixed', '14.8 km/L', Icons.alt_route_rounded)),
                ],
              ),
              const SizedBox(height: 12),

              // Trip Notes
              TextField(
                controller: _odoNotesCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Trip Notes & Route Details (Optional)',
                  hintText: 'e.g. Mumbai to Pune Expressway return journey',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Commit Odo Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleOdoSubmit,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Commit Odometer Log & Refresh Engine Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLitreChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
      ),
    );
  }

  Widget _buildTripEnvRadio(String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedTripType == value;
    return InkWell(
      onTap: () => setState(() => _selectedTripType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.secondary),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.onSurface)),
            Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  // SECTION 3: MILEAGE MONITOR & FUEL EFFICIENCY INTELLIGENCE
  Widget _buildSection3MileageMonitor() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('Fuel Efficiency & Mileage Monitor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 14, color: AppColors.emerald),
                    const SizedBox(width: 4),
                    Text('A+ Eco Performer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Metric Pillars
          Row(
            children: [
              Expanded(child: _buildMetricPillar('BLENDED LIFETIME', '14.8', 'km/L', '+4.2% factory', AppColors.emerald)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPillar('COST / KM', '₹ 6.54', '/ km', 'At ₹94.20/L', AppColors.secondary)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPillar('HIGHWAY CRUISE', '17.2', 'km/L', 'Peak: 18.4', AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPillar('CITY RUSH', '12.1', 'km/L', 'Peak traffic', Colors.amber.shade800)),
            ],
          ),
          const SizedBox(height: 18),

          // 5-Bar Trajectory Chart
          const Text('RECENT REFUEL MILEAGE TRAJECTORY (LAST 5 LOGS)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarItem('13.9', '12 Aug', 0.72, false),
                _buildBarItem('15.4', '18 Aug', 0.85, false),
                _buildBarItem('14.2', '24 Aug', 0.76, false),
                _buildBarItem('16.8', '29 Aug', 0.94, true), // Peak
                _buildBarItem('14.8', 'Current', 0.80, false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target: 15.0 km/L', style: TextStyle(fontSize: 10, color: AppColors.secondary)),
              Text('Highest Recorded Run: 16.8 km/L', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPillar(String label, String value, String unit, String note, Color noteColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(fontSize: 8, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 2),
          Text(note, style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.bold, color: noteColor)),
        ],
      ),
    );
  }

  Widget _buildBarItem(String val, String label, double fraction, bool isPeak) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: isPeak ? AppColors.emerald : AppColors.onSurface)),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 100 * fraction,
          decoration: BoxDecoration(
            gradient: isPeak
                ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.emerald, AppColors.electric])
                : const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.primary, AppColors.primaryContainer]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.secondary)),
      ],
    );
  }

  // SECTION 4: APPROXIMATE ENGINE HEALTH INDEX
  Widget _buildSection4EngineHealth() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: AppColors.emerald, size: 20),
                  SizedBox(width: 8),
                  Text('Approximate Engine Health Index', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('High Confidence', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Health Score and 4 Subsystems
          Row(
            children: [
              // Radial Health
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('96%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.emerald, fontFamily: 'Outfit')),
                      Text('Prime', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 4 Subsystems Progress Bars
              Expanded(
                child: Column(
                  children: [
                    _buildSubsystemProgress('Oil Viscosity', '92%', 0.92, Colors.amber.shade700),
                    const SizedBox(height: 6),
                    _buildSubsystemProgress('Combustion Stability', '98%', 0.98, AppColors.emerald),
                    const SizedBox(height: 6),
                    _buildSubsystemProgress('Injector Flow', '95%', 0.95, AppColors.primary),
                    const SizedBox(height: 6),
                    _buildSubsystemProgress('Thermal Index', '97%', 0.97, Colors.teal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Diagnostic Recommendation Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mechanical Integrity Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                      Text('Logging regularly prevents catastrophic faults.', style: TextStyle(fontSize: 9, color: AppColors.secondary)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServiceScreen(initialVehicle: _vehicle)));
                  },
                  icon: const Icon(Icons.calendar_month_rounded, size: 14),
                  label: const Text('Book Bay', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsystemProgress(String label, String percent, double frac, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            Text(percent, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: frac, backgroundColor: Colors.grey.shade200, color: color, minHeight: 5),
        ),
      ],
    );
  }

  // SECTION 5: VERIFIED DRIVER LOG LEDGER
  Widget _buildSection5DriverLogLedger() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verified Driver Log Ledger', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  Text('Chronological audit trail of refuels and odometer checkpoints', style: TextStyle(fontSize: 10, color: AppColors.secondary)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: const Text('Exported telemetry audit log to motoro_fuel_odo_ledger.csv'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 14),
                label: const Text('CSV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ledger Items
          ..._logs.map((item) => _buildLedgerTile(item)),
        ],
      ),
    );
  }

  Widget _buildLedgerTile(Map<String, dynamic> item) {
    final bool isFuel = item['isFuel'] as bool;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isFuel ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isFuel ? Icons.local_gas_station_rounded : Icons.speed_rounded,
                  color: isFuel ? AppColors.primary : AppColors.primaryContainer,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['type'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  Text('${item['station']} • ${item['date']}', style: const TextStyle(fontSize: 9, color: AppColors.secondary)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['qty']} (${item['odo']} km)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.onSurface),
              ),
              Text(
                item['cost'] != '-' ? '${item['cost']} • ${item['mileage']}' : '${item['mileage']}',
                style: TextStyle(fontSize: 9, color: AppColors.emerald, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for circular gauge arc
class _RadialGaugePainter extends CustomPainter {
  final double percent;

  _RadialGaugePainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Active fill arc
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.electric, AppColors.primaryContainer, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percent.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) => oldDelegate.percent != percent;
}
