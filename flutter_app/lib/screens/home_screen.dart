import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_top_nav_bar.dart';
import 'service_screen.dart';
import 'fuel_odo_screen.dart';
import 'fasttag_screen.dart';
import 'qr_contact_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';

class GarageScreen extends StatefulWidget {
  final VehicleItem? initialVehicle;
  final String? initialVin;

  const GarageScreen({
    super.key,
    this.initialVehicle,
    this.initialVin,
  });

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> with SingleTickerProviderStateMixin {
  VehicleItem? _selectedVehicle;
  List<VehicleItem> _vehicles = [];
  bool _isLoading = true;

  // Animation controller for pulsing indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Indian States Mapping for HSRP live detection
  static const Map<String, String> indianStates = {
    'AN': 'Andaman & Nicobar', 'AP': 'Andhra Pradesh', 'AR': 'Arunachal Pradesh', 'AS': 'Assam',
    'BR': 'Bihar', 'CG': 'Chhattisgarh', 'CH': 'Chandigarh', 'DD': 'Daman & Diu', 'DL': 'Delhi NCR',
    'DN': 'Dadra & Nagar', 'GA': 'Goa', 'GJ': 'Gujarat', 'HP': 'Himachal Pradesh', 'HR': 'Haryana',
    'JH': 'Jharkhand', 'JK': 'Jammu & Kashmir', 'KA': 'Karnataka', 'KL': 'Kerala', 'LA': 'Ladakh',
    'LD': 'Lakshadweep', 'MH': 'Maharashtra', 'ML': 'Meghalaya', 'MN': 'Manipur', 'MP': 'Madhya Pradesh',
    'MZ': 'Mizoram', 'NL': 'Nagaland', 'OD': 'Odisha', 'PB': 'Punjab', 'PY': 'Puducherry',
    'RJ': 'Rajasthan', 'SK': 'Sikkim', 'TN': 'Tamil Nadu', 'TR': 'Tripura', 'TS': 'Telangana',
    'UK': 'Uttarakhand', 'UP': 'Uttar Pradesh', 'WB': 'West Bengal'
  };

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

    _selectedVehicle = widget.initialVehicle;
    _loadGarageData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadGarageData() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getVehicles();
    if (mounted) {
      setState(() {
        _vehicles = list;
        if (_selectedVehicle == null && list.isNotEmpty) {
          if (widget.initialVin != null) {
            _selectedVehicle = list.firstWhere(
              (v) => v.vin == widget.initialVin,
              orElse: () => list.firstWhere((v) => v.isSelected, orElse: () => list.first),
            );
          } else {
            _selectedVehicle = list.firstWhere((v) => v.isSelected, orElse: () => list.first);
          }
        } else if (_selectedVehicle != null) {
          _selectedVehicle = list.firstWhere((v) => v.vin == _selectedVehicle!.vin, orElse: () => list.first);
        }
        _isLoading = false;
      });
    }
  }

  void _selectVehicle(VehicleItem vehicle) async {
    setState(() {
      _selectedVehicle = vehicle;
      for (var v in _vehicles) {
        v.isSelected = (v.vin == vehicle.vin);
      }
    });
    await ApiService.selectVehicle(vehicle.vin);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1800),
        content: Text('Switched garage fleet to ${vehicle.name} (${vehicle.registrationPlate})'),
      ),
    );
  }

  void _showNotificationsModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Fleet & Garage Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              title: 'HSRP & FASTag Synchronized',
              subtitle: 'ICICI FASTag connected to MH 12 RN 2024. Toll pass verified.',
              time: '10 mins ago',
              color: Colors.teal,
              icon: Icons.toll_rounded,
            ),
            const SizedBox(height: 10),
            _buildNotificationItem(
              title: 'Scheduled Service Due Soon',
              subtitle: 'Mahindra XUV700 Bay A scheduled in 680 km at Pothens Hub.',
              time: '1 hour ago',
              color: AppColors.warning,
              icon: Icons.build_circle_rounded,
            ),
            const SizedBox(height: 10),
            _buildNotificationItem(
              title: 'Insurance Policy Active',
              subtitle: 'Comprehensive cover active till Dec 2026. Zero claims logged.',
              time: '1 day ago',
              color: AppColors.success,
              icon: Icons.verified_user_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEnrollVehicleModal() {
    final modelCtrl = TextEditingController(text: 'Mahindra Scorpio-N Z8 L');
    final plateCtrl = TextEditingController(text: 'MH 14 JM 8899');
    final capCtrl = TextEditingController(text: '57');
    final odoCtrl = TextEditingController(text: '2400');
    String fuelType = 'Diesel';
    String fastagBank = 'ICICI Bank FASTag';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final rawPlate = plateCtrl.text.toUpperCase().trim();
          final statePrefix = rawPlate.length >= 2 ? rawPlate.substring(0, 2) : '';
          final detectedState = indianStates[statePrefix] != null
              ? '${indianStates[statePrefix]} ($statePrefix)'
              : 'Bharat HSRP (MoRTH)';

          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Modal Handle
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),

                // Modal Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryContainer],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Enroll Indian Car',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: AppColors.emerald,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'MoRTH VAHAN 4.0',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.emerald),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Instant HSRP plate verification & FASTag linking',
                                style: TextStyle(fontSize: 11, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.secondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),

                // Modal Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live HSRP Preview Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'LIVE HSRP EMBOSSED PREVIEW',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 0.8),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                detectedState,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // High Security Registration Plate (HSRP) Metal Simulation
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey.shade100, Colors.grey.shade200],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blueGrey.shade800, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Left Blue IND Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF003399), Color(0xFF002266)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 10),
                                    SizedBox(height: 2),
                                    Text('IND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Plate Number
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      rawPlate.isEmpty ? 'MH 14 JM 8899' : rawPlate,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                        letterSpacing: 3.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'HSRP 2026-BHARAT • IN90827341',
                                      style: TextStyle(fontSize: 8, fontFamily: 'monospace', color: Colors.black45, letterSpacing: 1.2),
                                    ),
                                  ],
                                ),
                              ),

                              // Security Screw Icon
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade600, width: 1),
                                ),
                                child: const Center(
                                  child: Text('+', style: TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Popular Indian Models (1-Tap Quick Select Presets)
                        const Text(
                          'POPULAR INDIAN MODELS (1-TAP SELECT)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPresetChip(
                              title: 'Scorpio-N Z8 L',
                              subtitle: 'Diesel 4XPLOR • 57L',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Mahindra Scorpio-N Z8 L';
                                  fuelType = 'Diesel';
                                  capCtrl.text = '57';
                                });
                              },
                            ),
                            _buildPresetChip(
                              title: 'Tata Safari Dark',
                              subtitle: 'Kryotec 2.0L • 50L',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Tata Safari Dark Edition';
                                  fuelType = 'Diesel';
                                  capCtrl.text = '50';
                                });
                              },
                            ),
                            _buildPresetChip(
                              title: 'Tata Harrier',
                              subtitle: 'Fearless+ • 50L',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Tata Harrier Fearless+';
                                  fuelType = 'Diesel';
                                  capCtrl.text = '50';
                                });
                              },
                            ),
                            _buildPresetChip(
                              title: 'Hyundai Creta',
                              subtitle: '1.5L Turbo • 50L',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Hyundai Creta SX(O)';
                                  fuelType = 'Petrol';
                                  capCtrl.text = '50';
                                });
                              },
                            ),
                            _buildPresetChip(
                              title: 'Fortuner Legender',
                              subtitle: 'Diesel 4x4 • 80L',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Toyota Fortuner Legender';
                                  fuelType = 'Diesel';
                                  capCtrl.text = '80';
                                });
                              },
                            ),
                            _buildPresetChip(
                              title: 'Nexon EV Empowered',
                              subtitle: 'Electric • 40.5 kWh',
                              onTap: () {
                                setModalState(() {
                                  modelCtrl.text = 'Tata Nexon EV Empowered';
                                  fuelType = 'Electric';
                                  capCtrl.text = '40.5';
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Form Inputs
                        TextField(
                          controller: modelCtrl,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Car Make & Model',
                            prefixIcon: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Registration plate input
                        TextField(
                          controller: plateCtrl,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setModalState(() {}),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5),
                          decoration: InputDecoration(
                            labelText: 'Registration Plate (HSRP)',
                            prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Fuel & Capacity Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: fuelType,
                                decoration: InputDecoration(
                                  labelText: 'Powertrain',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel mHawk')),
                                  DropdownMenuItem(value: 'Petrol', child: Text('Petrol Turbo')),
                                  DropdownMenuItem(value: 'Electric', child: Text('Electric (EV)')),
                                  DropdownMenuItem(value: 'CNG', child: Text('CNG Bi-Fuel')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() {
                                      fuelType = val;
                                      if (val == 'Electric') {
                                        capCtrl.text = '40.5';
                                      } else if (val == 'CNG') {
                                        capCtrl.text = '60';
                                      } else {
                                        capCtrl.text = '57';
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: capCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: fuelType == 'Electric' ? 'Battery (kWh)' : 'Tank (Litres)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // FASTag Provider & Odometer
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: fastagBank,
                                decoration: InputDecoration(
                                  labelText: 'FASTag Provider',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'ICICI Bank FASTag', child: Text('ICICI Bank')),
                                  DropdownMenuItem(value: 'HDFC Bank FASTag', child: Text('HDFC Bank')),
                                  DropdownMenuItem(value: 'SBI FASTag', child: Text('SBI FASTag')),
                                  DropdownMenuItem(value: 'Paytm FASTag', child: Text('Paytm Bank')),
                                  DropdownMenuItem(value: 'Axis Bank FASTag', child: Text('Axis Bank')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setModalState(() => fastagBank = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: odoCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                decoration: InputDecoration(
                                  labelText: 'Odo (km)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setModalState(() => isSubmitting = true);
                                    await Future.delayed(const Duration(milliseconds: 1000));

                                    final name = modelCtrl.text.trim().isNotEmpty ? modelCtrl.text.trim() : 'Mahindra Scorpio-N';
                                    final plate = rawPlate.isNotEmpty ? rawPlate : 'MH 14 JM 8899';
                                    final vin = 'IND-${plate.replaceAll(' ', '-')}';
                                    final cap = double.tryParse(capCtrl.text) ?? 57.0;
                                    final odo = int.tryParse(odoCtrl.text) ?? 2400;

                                    final newVehicle = VehicleItem(
                                      vin: vin,
                                      name: name,
                                      edition: '$fuelType • VAHAN Enrolled',
                                      typeLabel: 'Indian Fleet Vehicle',
                                      fuelType: fuelType,
                                      status: 'In Garage • Ready',
                                      isOnline: true,
                                      fuelLevelPercent: 82.0,
                                      fuelCapacityLitres: cap,
                                      rangeKm: (cap * 14.2).toInt(),
                                      odometerKm: odo,
                                      locationName: 'Home Bay',
                                      imageUrl: fuelType == 'Electric'
                                          ? 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80'
                                          : 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80',
                                      isSelected: true,
                                      registrationPlate: plate,
                                      fastTagId: fastagBank,
                                    );

                                    setState(() {
                                      for (var v in _vehicles) {
                                        v.isSelected = false;
                                      }
                                      _vehicles.add(newVehicle);
                                      _selectedVehicle = newVehicle;
                                    });

                                    if (!modalCtx.mounted) return;
                                    Navigator.pop(modalCtx);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        content: Row(
                                          children: [
                                            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text('🎉 $name ($plate) enrolled via MoRTH VAHAN 4.0!')),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isSubmitting
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                      SizedBox(width: 12),
                                      Text('Verifying VAHAN & Enrolling...', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.verified_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Verify VAHAN & Add to Garage Fleet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.onSurface)),
            Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.secondary)),
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

            // SECONDARY 5-PILL DOCK
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
                          // PAGE TITLE & ACTION BANNER
                          _buildHeaderBanner(),
                          const SizedBox(height: 16),

                          // FLEET DOSSIER VEHICLE CARDS
                          ..._vehicles.map((car) => _buildFleetVehicleCard(car)),
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
          // Brand Logo with Tricolor Bharat Badge
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(initialVin: _selectedVehicle?.vin)),
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
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
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

          // Right Controls: Vehicle Switcher Pill, Notification, Profile
          Row(
            children: [
              // Vehicle Switcher Pill
              PopupMenuButton<VehicleItem>(
                initialValue: _selectedVehicle,
                tooltip: 'Switch Fleet Vehicle',
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (veh) => _selectVehicle(veh),
                itemBuilder: (ctx) => _vehicles.map((v) {
                  final isCurr = v.vin == _selectedVehicle?.vin;
                  return PopupMenuItem<VehicleItem>(
                    value: v,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(
                              '${v.registrationPlate} • ${v.fuelType}',
                              style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        if (isCurr)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedVehicle?.registrationPlate ?? 'MH 12 RN 2024',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Notifications
              IconButton(
                icon: const Stack(
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.secondary),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
                onPressed: _showNotificationsModal,
              ),

              // Profile Avatar "VS" -> AccountScreen
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
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

              // Logout Icon -> LoginScreen
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.secondary),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SECONDARY ICON-ONLY NAVIGATION DOCK (CENTRALIZED ACTIVE SLIDE)
  Widget _buildSecondaryNavDock() {
    return FloatingTopNavBar(
      currentIndex: 0,
      currentVehicle: _selectedVehicle,
    );
  }

  // 3. PAGE HEADER & TITLE BANNER
  Widget _buildHeaderBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Indian Garage Fleet',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '${_vehicles.length} Enrolled',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Manage VAHAN registration, insurance, FASTag & telemetry.',
              style: TextStyle(fontSize: 11, color: AppColors.secondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showEnrollVehicleModal,
          icon: const Icon(Icons.add_circle_rounded, size: 16),
          label: const Text('Enroll Car', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  // 4. FLEET DOSSIER VEHICLE CARD
  Widget _buildFleetVehicleCard(VehicleItem car) {
    final isSelected = car.vin == _selectedVehicle?.vin;
    final isElectric = car.fuelType.toLowerCase().contains('electric') || car.fuelType.toLowerCase().contains('ev');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image Container with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.network(
                    car.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.directions_car_rounded, size: 48, color: AppColors.secondary),
                      ),
                    ),
                  ),
                ),
              ),

              // Top Status Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.success
                              : (isElectric ? Colors.cyanAccent : Colors.amberAccent),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSelected
                            ? 'ACTIVE IN FLEET'
                            : (isElectric ? 'STANDBY EV' : 'STANDBY FLEET'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom-Right HSRP Plate Tag
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    car.registrationPlate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: AppColors.primaryFixed,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Powertrain Chips
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isElectric
                            ? Colors.teal.shade50
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isElectric
                            ? 'Electric • ${car.fuelCapacityLitres} kWh'
                            : '${car.fuelType} • ${car.fuelCapacityLitres.toInt()}L Tank',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isElectric ? Colors.teal.shade800 : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isElectric ? 'ZConnect Telemetry' : 'MoRTH VAHAN Active',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Vehicle Model Title & Subtitle
                Text(
                  car.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'RTO Verified • Odometer: ${car.odometerKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
                const SizedBox(height: 14),

                // Document Validity Checklist Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildChecklistRow(
                        icon: Icons.verified_user_rounded,
                        iconColor: AppColors.emerald,
                        label: 'Insurance Policy:',
                        value: car.insuranceExpiry,
                        valueColor: AppColors.emerald,
                      ),
                      const SizedBox(height: 8),
                      _buildChecklistRow(
                        icon: isElectric ? Icons.battery_charging_full_rounded : Icons.air_rounded,
                        iconColor: AppColors.emerald,
                        label: isElectric ? 'Battery Health:' : 'PUC Certificate:',
                        value: isElectric ? '98% SoC State of Health' : car.pucExpiry,
                        valueColor: AppColors.emerald,
                      ),
                      const SizedBox(height: 8),
                      _buildChecklistRow(
                        icon: Icons.toll_rounded,
                        iconColor: AppColors.primary,
                        label: 'FASTag RFID Tag:',
                        value: car.fastTagId,
                        isMono: true,
                        valueColor: AppColors.onSurface,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1),
                      ),
                      _buildChecklistRow(
                        icon: Icons.build_circle_rounded,
                        iconColor: Colors.amber.shade700,
                        label: 'Next Service Due:',
                        value: car.serviceDueKm != null ? 'In ${car.serviceDueKm} km' : 'In 680 km (Bay A)',
                        valueColor: Colors.amber.shade800,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  children: [
                    if (isSelected) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen(initialVin: car.vin)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('View Telemetry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => ServiceScreen(initialVehicle: car)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _selectVehicle(car),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Set as Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => FastTagScreen(initialVehicle: car)),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Toll Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = AppColors.onSurface,
    bool isMono = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontFamily: isMono ? 'monospace' : null,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}


/// Compatibility wrapper: Any existing route or navigation targeting HomeScreen
/// will now seamlessly render the GarageScreen.
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
      initialVin: initialVin,
    );
  }
}
