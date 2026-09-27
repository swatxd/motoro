import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Redesigned Enroll Vehicle Modal:
/// - Fits smartphone screens perfectly (auto-align, keyboard safe, zero overflow).
/// - Minimalist text, icon-forward telemetry UI.
/// - Live HSRP metallic embossed plate simulation.
/// - 4-powertrain quick icon selector (Diesel, Petrol, EV, CNG).
/// - 1-tap popular Indian car presets.
/// - Instant VAHAN verification & FASTag linking.
class EnrollVehicleModal extends StatefulWidget {
  final Function(VehicleItem newVehicle) onVehicleEnrolled;

  const EnrollVehicleModal({
    super.key,
    required this.onVehicleEnrolled,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(VehicleItem newVehicle) onVehicleEnrolled,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EnrollVehicleModal(
        onVehicleEnrolled: onVehicleEnrolled,
      ),
    );
  }

  @override
  State<EnrollVehicleModal> createState() => _EnrollVehicleModalState();
}

class _EnrollVehicleModalState extends State<EnrollVehicleModal> {
  final TextEditingController _modelCtrl =
      TextEditingController(text: 'Mahindra Scorpio-N Z8 L');
  final TextEditingController _plateCtrl =
      TextEditingController(text: 'MH 14 JM 8899');
  final TextEditingController _capCtrl = TextEditingController(text: '57');
  final TextEditingController _odoCtrl = TextEditingController(text: '2400');

  String _fuelType = 'Diesel';
  String _fastagBank = 'ICICI Bank FASTag';
  bool _isSubmitting = false;

  static const Map<String, String> indianStates = {
    'AN': 'Andaman & Nicobar',
    'AP': 'Andhra Pradesh',
    'AR': 'Arunachal Pradesh',
    'AS': 'Assam',
    'BR': 'Bihar',
    'CG': 'Chhattisgarh',
    'CH': 'Chandigarh',
    'DD': 'Daman & Diu',
    'DL': 'Delhi NCR',
    'DN': 'Dadra & Nagar',
    'GA': 'Goa',
    'GJ': 'Gujarat',
    'HP': 'Himachal Pradesh',
    'HR': 'Haryana',
    'JH': 'Jharkhand',
    'JK': 'Jammu & Kashmir',
    'KA': 'Karnataka',
    'KL': 'Kerala',
    'LA': 'Ladakh',
    'LD': 'Lakshadweep',
    'MH': 'Maharashtra',
    'ML': 'Meghalaya',
    'MN': 'Manipur',
    'MP': 'Madhya Pradesh',
    'MZ': 'Mizoram',
    'NL': 'Nagaland',
    'OD': 'Odisha',
    'PB': 'Punjab',
    'PY': 'Puducherry',
    'RJ': 'Rajasthan',
    'SK': 'Sikkim',
    'TN': 'Tamil Nadu',
    'TR': 'Tripura',
    'TS': 'Telangana',
    'UK': 'Uttarakhand',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal'
  };

  @override
  void dispose() {
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _capCtrl.dispose();
    _odoCtrl.dispose();
    super.dispose();
  }

  void _applyPreset({
    required String model,
    required String fuel,
    required String capacity,
  }) {
    setState(() {
      _modelCtrl.text = model;
      _fuelType = fuel;
      _capCtrl.text = capacity;
    });
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final rawPlate = _plateCtrl.text.toUpperCase().trim();
    final name =
        _modelCtrl.text.trim().isNotEmpty ? _modelCtrl.text.trim() : 'Mahindra Scorpio-N';
    final plate = rawPlate.isNotEmpty ? rawPlate : 'MH 14 JM 8899';
    final vin = 'IND-${plate.replaceAll(' ', '-')}';
    final cap = double.tryParse(_capCtrl.text) ?? 57.0;
    final odo = int.tryParse(_odoCtrl.text) ?? 2400;

    final newVehicle = VehicleItem(
      vin: vin,
      name: name,
      edition: '$_fuelType • VAHAN 4.0',
      typeLabel: 'Indian Fleet',
      fuelType: _fuelType,
      status: 'In Garage • Ready',
      isOnline: true,
      fuelLevelPercent: 85.0,
      fuelCapacityLitres: cap,
      rangeKm: (cap * 14.5).toInt(),
      odometerKm: odo,
      locationName: 'Home Bay',
      imageUrl: _fuelType == 'Electric'
          ? 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80'
          : 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80',
      isSelected: true,
      registrationPlate: plate,
      fastTagId: _fastagBank,
    );

    widget.onVehicleEnrolled(newVehicle);
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Enrolled $name ($plate) via VAHAN 4.0')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final rawPlate = _plateCtrl.text.toUpperCase().trim();
    final statePrefix = rawPlate.length >= 2 ? rawPlate.substring(0, 2) : '';
    final stateName = indianStates[statePrefix] ?? 'Bharat HSRP';

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.90,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),

          // Header: Icon + Title + Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enroll Vehicle',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'MoRTH VAHAN 4.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.secondary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Embossed HSRP Plate Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade100, Colors.grey.shade200],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade800, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Blue IND strip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003399),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 9),
                              SizedBox(height: 1),
                              Text(
                                'IND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 8.5,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Center Plate Text
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rawPlate.isEmpty ? 'MH 14 JM 8899' : rawPlate,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                    letterSpacing: 3.0,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '$stateName • HSRP SECURED',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: Colors.black45,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Security Bolt
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade600, width: 0.8),
                          ),
                          child: const Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 7,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. 1-Tap Preset Chips (Horizontal Scrollable)
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildPresetPill('Scorpio-N', 'Diesel', '57'),
                        _buildPresetPill('Safari Dark', 'Diesel', '50'),
                        _buildPresetPill('Harrier', 'Diesel', '50'),
                        _buildPresetPill('Creta Turbo', 'Petrol', '50'),
                        _buildPresetPill('Fortuner', 'Diesel', '80'),
                        _buildPresetPill('Nexon EV', 'Electric', '40.5'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Powertrain 4-Icon Selector
                  Row(
                    children: [
                      _buildPowertrainOption(
                        label: 'Diesel',
                        icon: Icons.local_gas_station_rounded,
                        defaultCapacity: '57',
                      ),
                      const SizedBox(width: 8),
                      _buildPowertrainOption(
                        label: 'Petrol',
                        icon: Icons.local_gas_station_outlined,
                        defaultCapacity: '50',
                      ),
                      const SizedBox(width: 8),
                      _buildPowertrainOption(
                        label: 'Electric',
                        icon: Icons.bolt_rounded,
                        defaultCapacity: '40.5',
                      ),
                      const SizedBox(width: 8),
                      _buildPowertrainOption(
                        label: 'CNG',
                        icon: Icons.eco_rounded,
                        defaultCapacity: '60',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Input: Make & Model
                  TextField(
                    controller: _modelCtrl,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Vehicle Model',
                      prefixIcon: const Icon(Icons.directions_car_rounded, size: 19),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 5. Input: Plate (HSRP)
                  TextField(
                    controller: _plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Registration (Plate)',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 19),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 6. Dual Columns: Capacity & Odometer
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _capCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: _fuelType == 'Electric' ? 'Battery (kWh)' : 'Tank (L)',
                            prefixIcon: Icon(
                              _fuelType == 'Electric'
                                  ? Icons.battery_charging_full_rounded
                                  : Icons.local_gas_station_rounded,
                              size: 19,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _odoCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Odometer (km)',
                            prefixIcon: const Icon(Icons.speed_rounded, size: 19),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 7. FASTag Provider Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _fastagBank,
                    decoration: InputDecoration(
                      labelText: 'FASTag Bank',
                      prefixIcon: const Icon(Icons.toll_rounded, size: 19),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'ICICI Bank FASTag', child: Text('ICICI FASTag')),
                      DropdownMenuItem(
                          value: 'HDFC Bank FASTag', child: Text('HDFC FASTag')),
                      DropdownMenuItem(
                          value: 'SBI FASTag', child: Text('SBI FASTag')),
                      DropdownMenuItem(
                          value: 'Paytm FASTag', child: Text('Paytm FASTag')),
                      DropdownMenuItem(
                          value: 'Axis Bank FASTag', child: Text('Axis FASTag')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _fastagBank = val);
                    },
                  ),
                  const SizedBox(height: 18),

                  // 8. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Add Vehicle to Fleet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPill(String title, String fuel, String cap) {
    final isSel = _modelCtrl.text.contains(title);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? AppColors.primary : AppColors.onSurface,
          ),
        ),
        backgroundColor:
            isSel ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceContainer,
        side: BorderSide(
          color: isSel ? AppColors.primary : Colors.grey.shade300,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        onPressed: () => _applyPreset(model: title, fuel: fuel, capacity: cap),
      ),
    );
  }

  Widget _buildPowertrainOption({
    required String label,
    required IconData icon,
    required String defaultCapacity,
  }) {
    final isSel = _fuelType == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _fuelType = label;
            _capCtrl.text = defaultCapacity;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSel ? Colors.white : AppColors.secondary,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                  color: isSel ? Colors.white : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
