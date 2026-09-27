import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_top_nav_bar.dart';
import '../widgets/master_top_app_bar.dart';

class QrContactScreen extends StatefulWidget {
  final VehicleItem? initialVehicle;

  const QrContactScreen({super.key, this.initialVehicle});

  @override
  State<QrContactScreen> createState() => _QrContactScreenState();
}

class _QrContactScreenState extends State<QrContactScreen> with SingleTickerProviderStateMixin {
  VehicleItem? _vehicle;
  List<VehicleItem> _allVehicles = [];
  bool _isLoading = true;

  // Active Main Sub-Tab: 0: Live Scanner, 1: My Windshield Tag, 2: Alerts Log, 3: Order Decal
  int _activeSubTab = 0;

  // Scanner UI States
  bool _isSoundFxOn = true;
  bool _isTorchOn = false;
  double _zoomLevel = 1.0;
  bool _isTargetAcquired = false;

  // Privacy & Safety Toggles
  bool _allowVoipRelay = true;
  bool _instantSmsAlert = true;
  bool _chimeOnScan = true;

  // Order Form States
  String _selectedStickerFinish = 'Reflective Night-Glow';
  final TextEditingController _nameController = TextEditingController(text: 'Vikramaditya Sharma');
  final TextEditingController _mobileController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _plateController = TextEditingController(text: 'MH 12 RN 2024');
  final TextEditingController _addressController = TextEditingController(text: 'Flat 4B, Emerald Heights, Senapati Bapat Road');
  final TextEditingController _cityPinController = TextEditingController(text: 'Pune, Maharashtra - 411016');

  // Laser Scan Animation Controller
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  // Parking Shield Alerts Log Data
  final List<Map<String, dynamic>> _alertsLog = [
    {
      'title': 'Vehicle Blocking Gate Access',
      'location': 'Phoenix Mall Lower Parel • Gate 3',
      'time': '14 mins ago',
      'plate': 'MH 12 RN 2024',
      'status': 'Active',
      'type': 'gate',
      'desc': 'Scanned at Phoenix Mall • Caller sent quick preset: "Can you please move car?"',
    },
    {
      'title': 'Headlights / Foglamps Left On',
      'location': 'Tech Park Basement Bay 4',
      'time': '2 hrs ago',
      'plate': 'KA 01 EQ 4050',
      'status': 'Addressed',
      'type': 'lights',
      'desc': 'Parking attendant noticed fog lamps active. Risk of 12V battery discharge.',
    },
    {
      'title': 'Minor Parking Scratch Notice',
      'location': 'Worli Service Bay 12',
      'time': 'Yesterday',
      'plate': 'MH 12 RN 2024',
      'status': 'Resolved',
      'type': 'scratch',
      'desc': 'Neighbouring car driver notified of slight door contact while reversing.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _vehicle = widget.initialVehicle;
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
    _loadVehicles();
  }

  @override
  void dispose() {
    _laserController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _plateController.dispose();
    _addressController.dispose();
    _cityPinController.dispose();
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
        if (_vehicle != null) {
          _plateController.text = _vehicle!.registrationPlate;
        }
        _isLoading = false;
      });
    }
  }

  void _switchVehicle(VehicleItem v) {
    setState(() {
      _vehicle = v;
      _plateController.text = v.registrationPlate;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched QR Shield to ${v.name} (${v.registrationPlate})'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  void _triggerSimulatedScan({
    String? plate,
    String? vehicleName,
    String? location,
  }) {
    setState(() => _isTargetAcquired = true);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _isTargetAcquired = false);
        _openContactDrawer(
          plate: plate ?? _vehicle?.registrationPlate ?? 'MH 12 RN 2024',
          name: vehicleName ?? _vehicle?.name ?? 'Mahindra XUV700 AX7 L',
          location: location ?? 'Phoenix Mall Lower Parel • Shield Relay Active',
        );
      }
    });
  }

  void _openContactDrawer({
    required String plate,
    required String name,
    required String location,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnonymousContactDrawerModal(
        plate: plate,
        vehicleName: name,
        location: location,
        onMessageSent: (msg) {
          setState(() {
            _alertsLog.insert(0, {
              'title': 'Driver Notified: $msg',
              'location': location,
              'time': 'Just now',
              'plate': plate,
              'status': 'Active',
              'type': 'notification',
              'desc': 'Bystander sent masked message: "$msg"',
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Message delivered to driver of $plate via masked relay!')),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onInitiateVoipCall: () {
          _openVoipCallModal(plate);
        },
      ),
    );
  }

  void _openVoipCallModal(String plate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SimulatedVoipCallDialog(plate: plate),
    );
  }

  void _openPrintPreviewModal() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '1-Page PDF Sheet Preview',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Standard A4 Portrait Cut-Out Sheet (90 × 125 mm)',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    _buildPrintableStickerCard(isThumbnail: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sticker PDF document ready for printing!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Print / Save 1-Page PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitDecalOrder() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.done_all_rounded, color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ORDER DISPATCHED',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Weatherproof Tag Confirmed!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your reflective 3M windshield tag has been queued for BlueDart express delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    _buildOrderReceiptRow('Tracking ID:', 'BLUEDART-IND-98214', isPrimary: true),
                    const Divider(height: 16),
                    _buildOrderReceiptRow('Vehicle Plate:', _plateController.text),
                    const SizedBox(height: 6),
                    _buildOrderReceiptRow('Finish:', _selectedStickerFinish),
                    const SizedBox(height: 6),
                    _buildOrderReceiptRow('Destination:', _cityPinController.text),
                    const Divider(height: 16),
                    _buildOrderReceiptRow('Order Total:', '₹0.00 (FREE FOR FLEET)', isSuccess: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Return to QR Manager', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderReceiptRow(String label, String value, {bool isPrimary = false, bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? AppColors.primary
                  : isSuccess
                      ? AppColors.success
                      : AppColors.onSurface,
              fontFamily: isPrimary ? 'monospace' : 'sans-serif',
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
          // Background Aesthetic Mesh Blobs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
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

          // Main Column
          SafeArea(
            child: Column(
              children: [
                MasterTopAppBar(
                  currentVehicle: vehicle,
                  vehicles: _allVehicles,
                  onVehicleChanged: _switchVehicle,
                ),
                _buildSecondaryNavDock(),
                Expanded(
                  child: _isLoading || vehicle == null
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 960),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeroBannerAndTabPills(),
                                  const SizedBox(height: 18),
                                  if (_activeSubTab == 0) _buildTab1LiveScanner(vehicle),
                                  if (_activeSubTab == 1) _buildTab2PrintableWindshieldTag(vehicle),
                                  if (_activeSubTab == 2) _buildTab3AlertsLog(),
                                  if (_activeSubTab == 3) _buildTab4OrderDecal(),
                                  const SizedBox(height: 48),
                                ],
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

  // 2. Secondary Navigation Dock matching FloatingTopNavBar
  Widget _buildSecondaryNavDock() {
    return FloatingTopNavBar(
      currentIndex: 4, // QR Tag tab
      currentVehicle: _vehicle,
    );
  }

  // 3. Hero Ribbon & Sub-Nav Pills matching qr_contact.html
  Widget _buildHeroBannerAndTabPills() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Zero-Exposure VoIP & Anonymous QR Relay',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Smart Vehicle QR Scanner & Parking Shield',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan any parked vehicle\'s Motoro Shield QR to notify the driver or place an encrypted 2-way masked VoIP call. No personal mobile numbers are ever revealed to either party.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Sub-Nav Tabs Pills (Live Scanner, My Windshield Tag, Alerts Log, Order Decal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildSubTabPill(0, 'Live Scanner', Icons.center_focus_strong_rounded),
                  _buildSubTabPill(1, 'My Windshield Tag', Icons.badge_rounded),
                  _buildSubTabPill(2, 'Alerts Log', Icons.notifications_active_rounded, hasDot: true),
                  _buildSubTabPill(3, 'Order Decal', Icons.local_shipping_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabPill(int index, String label, IconData icon, {bool hasDot = false}) {
    final isSel = _activeSubTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: () => setState(() => _activeSubTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSel ? Colors.white : AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
              if (hasDot && !isSel) ...[
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: DEDICATED LIVE CYBER SCANNER
  // -------------------------------------------------------------
  Widget _buildTab1LiveScanner(VehicleItem vehicle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildScannerViewfinderCard(vehicle)),
              const SizedBox(width: 18),
              Expanded(flex: 5, child: _buildScannerSidePanel(vehicle)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildScannerViewfinderCard(vehicle),
              const SizedBox(height: 18),
              _buildScannerSidePanel(vehicle),
            ],
          );
        }
      },
    );
  }

  Widget _buildScannerViewfinderCard(VehicleItem vehicle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'High-Precision Optical Scanner',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Auto-detects Motoro Shield QR & NETC Barcodes',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isSoundFxOn = !_isSoundFxOn),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSoundFxOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isSoundFxOn ? 'FX ON' : 'FX OFF',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Authentic Smartphone Camera Scanner Viewfinder Box
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0E12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isTargetAcquired ? AppColors.success : const Color(0xFF1E293B),
                width: _isTargetAcquired ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isTargetAcquired ? AppColors.success.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top Status Bar: 60 FPS 1080P
                Positioned(
                  top: 12,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
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
                            const Text(
                              'OPTICAL SCANNER • 60 FPS • 1080P',
                              style: TextStyle(
                                fontSize: 9,
                                fontFamily: 'monospace',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flip_camera_android_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),

                // Top Instruction Text
                const Positioned(
                  top: 48,
                  child: Text(
                    'Align QR code/barcode within the frame',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Focus Reticle Box with 4 Sharp L-Bracket Corners
                GestureDetector(
                  onTap: () => _triggerSimulatedScan(),
                  child: SizedBox(
                    width: 210,
                    height: 210,
                    child: Stack(
                      children: [
                        // Custom Painter for the 4 Sharp L-Corner Brackets
                        CustomPaint(
                          size: const Size(210, 210),
                          painter: _ScannerBracketPainter(
                            isTargetAcquired: _isTargetAcquired,
                          ),
                        ),

                        // Center QR Code Canvas Card
                        Center(
                          child: Container(
                            width: 170,
                            height: 170,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              size: const Size(150, 150),
                              painter: _MotoroQrVectorPainter(),
                            ),
                          ),
                        ),

                        // Sweeping Animated Laser Scan Line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 210 * _laserAnimation.value,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primaryContainer,
                                      Colors.white,
                                      AppColors.primaryFixed,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryContainer,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Dark Pill Capsule (Gallery | Flashlight Torch)
                Positioned(
                  bottom: 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gallery Button
                        InkWell(
                          onTap: () => _triggerSimulatedScan(),
                          child: Row(
                            children: const [
                              Icon(Icons.photo_library_rounded, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Gallery',
                                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          color: Colors.white.withValues(alpha: 0.2),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        // Torch Toggle Button
                        InkWell(
                          onTap: () {
                            setState(() => _isTorchOn = !_isTorchOn);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isTorchOn ? 'Torch Flashlight Activated' : 'Torch Deactivated'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.flashlight_on_rounded,
                                color: _isTorchOn ? const Color(0xFFFACC15) : const Color(0xFFA855F7),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isTorchOn ? 'Torch ON' : 'Torch',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isTorchOn ? const Color(0xFFFACC15) : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Island Telemetry Strip
                Positioned(
                  bottom: 10,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.primaryFixed),
                            SizedBox(width: 4),
                            Text(
                              'Motoro Shield Protocol • Active Standby',
                              style: TextStyle(
                                fontSize: 9,
                                fontFamily: 'monospace',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'QR & OCR',
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'monospace',
                            color: AppColors.primaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Zoom & Control Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Zoom: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ...[1.0, 1.5, 2.0].map((z) {
                    final isSel = _zoomLevel == z;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: InkWell(
                        onTap: () => setState(() => _zoomLevel = z),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${z.toStringAsFixed(1)}x',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _triggerSimulatedScan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                label: const Text('Simulate Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSidePanel(VehicleItem vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instant Demo Vehicle Scans matching qr_contact.html
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
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
                    children: const [
                      Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Instant Demo Vehicle Scans',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ONE-TAP TEST',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Simulate scanning parked Indian vehicles in real parking situations:',
                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              // Scenario 1: Mahindra XUV700
              _buildDemoScanTile(
                name: 'Mahindra XUV700 AX7 AWD',
                plate: 'MH 12 RN 2024',
                location: 'Mumbai Worli Bay 4 • Diesel mHawk',
                tag: 'AX7 AWD',
                tagColor: AppColors.primary,
                icon: Icons.directions_car_rounded,
              ),
              const SizedBox(height: 8),

              // Scenario 2: Tata Nexon EV
              _buildDemoScanTile(
                name: 'Tata Nexon EV Empowered+',
                plate: 'KA 01 EQ 4050',
                location: 'Whitefield Depot • Electric 40.5 kWh',
                tag: 'Empowered+',
                tagColor: AppColors.success,
                icon: Icons.electric_car_rounded,
              ),
              const SizedBox(height: 8),

              // Scenario 3: Mahindra Thar 4x4
              _buildDemoScanTile(
                name: 'Mahindra Thar 4x4 MT',
                plate: 'DL 08 CA 7788',
                location: 'Delhi NCR Fleet Terminal • Diesel 130',
                tag: 'Earth Ed.',
                tagColor: const Color(0xFFD97706),
                icon: Icons.terrain_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Privacy Architecture Guarantee Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFF0FDF4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_user_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Motoro 2-Way Privacy Architecture',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('🔒 100% Masked VoIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3),
                          Text(
                            'Calls routed via cloud telephony bridge without caller ID exposure.',
                            style: TextStyle(fontSize: 9.5, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('🛡️ Anti-Spam Relay', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 3),
                          Text(
                            '3-alert rate limiter per hour with instant driver block switch.',
                            style: TextStyle(fontSize: 9.5, color: AppColors.onSurfaceVariant),
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
      ],
    );
  }

  Widget _buildDemoScanTile({
    required String name,
    required String plate,
    required String location,
    required String tag,
    required Color tagColor,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _triggerSimulatedScan(
        plate: plate,
        vehicleName: name,
        location: location,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: tagColor, size: 20),
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
                          name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: tagColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$plate • $location',
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                Text(
                  'Scan',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: PRINTABLE "CALL ME" WINDSHIELD TAG & SHEET
  // -------------------------------------------------------------
  Widget _buildTab2PrintableWindshieldTag(VehicleItem vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 16,
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
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.badge_rounded, color: Color(0xFFD97706), size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Printable "CALL ME" Windshield Tag',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'MoRTH Standard',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Place this high-contrast sticker on your windshield glass behind the rear-view mirror.',
                            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _openPrintPreviewModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Print / Save PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Layout: The Printable Sticker on Left, Settings on Right
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: Center(child: _buildPrintableStickerCard())),
                        const SizedBox(width: 24),
                        Expanded(flex: 6, child: _buildTagConfigPanel(vehicle)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Center(child: _buildPrintableStickerCard()),
                        const SizedBox(height: 24),
                        _buildTagConfigPanel(vehicle),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // The High-Contrast Printable Sticker Node (Black-bordered, CALL ME title, vector QR)
  Widget _buildPrintableStickerCard({bool isThumbnail = false}) {
    final scale = isThumbnail ? 0.78 : 1.0;
    final width = 290.0 * scale;

    return Container(
      width: width,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Header: MOTORO SHIELD • SMART PARKING TAG
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_rounded, size: 12 * scale, color: AppColors.primary),
                  SizedBox(width: 4 * scale),
                  Text(
                    'MOTORO SHIELD',
                    style: TextStyle(
                      fontSize: 8.5 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                'PARKING TAG',
                style: TextStyle(
                  fontSize: 8.5 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Divider(color: Colors.black, thickness: 2 * scale, height: 16 * scale),

          // Big Bold "CALL ME"
          Text(
            'CALL ME',
            style: TextStyle(
              fontSize: 34 * scale,
              fontWeight: FontWeight.w900,
              fontFamily: 'sans-serif',
              letterSpacing: -1.5 * scale,
              color: Colors.black,
              height: 1.0,
            ),
          ),
          SizedBox(height: 3 * scale),
          Text(
            'WRONG PARKING? SCAN TO CONTACT OWNER',
            style: TextStyle(
              fontSize: 8.5 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 12 * scale),

          // Crisp QR Matrix Card
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: Colors.black, width: 2 * scale),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 140 * scale,
                  height: 140 * scale,
                  child: CustomPaint(
                    painter: _MotoroQrVectorPainter(),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'motoro.app/c/${_plateController.text.replaceAll(' ', '')}',
                  style: TextStyle(
                    fontSize: 8.5 * scale,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          // Vehicle Plate Strip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IND BHARAT',
                      style: TextStyle(
                        fontSize: 7.5 * scale,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                    Text(
                      _plateController.text,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryFixed,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _vehicle?.name ?? 'Mahindra XUV700',
                      style: TextStyle(
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '100% Zero Spam',
                      style: TextStyle(
                        fontSize: 7.5 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),

          Text(
            'Scanning this code opens an anonymous web dialer. No app download needed by caller.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 7.5 * scale,
              color: Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagConfigPanel(VehicleItem vehicle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tag Configuration & Safety Options',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Toggles
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow Masked VoIP Call Relay', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                subtitle: const Text('Caller can connect via cloud telephony bridge', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                value: _allowVoipRelay,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _allowVoipRelay = val),
              ),
              const Divider(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Instant SMS Alert to Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                subtitle: const Text('Receive push notification & SMS on every QR scan', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                value: _instantSmsAlert,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _instantSmsAlert = val),
              ),
              const Divider(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Chime Tone on QR Scan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                subtitle: const Text('Plays emergency audio chime on driver phone', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                value: _chimeOnScan,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _chimeOnScan = val),
              ),

              const SizedBox(height: 10),
              // Emergency Medical Info (ICE)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Blood Group: B+',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ICE: Family (+91 94470 XXXXX)',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // High Gloss Printing Advice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '★ High-Gloss Printing Advice',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
              ),
              SizedBox(height: 3),
              Text(
                'Print on 300 GSM cardstock or glossy sticker paper. Fits standard transparent Indian FASTag/toll windshield pouches (90mm x 120mm) right behind the interior rear-view mirror.',
                style: TextStyle(fontSize: 11, color: Color(0xFF047857), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: INCOMING & OUTGOING PARKING ALERTS LOG
  // -------------------------------------------------------------
  Widget _buildTab3AlertsLog() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFD97706), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Live Parking Shield Alerts',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Real-time log of scans and notifications received on your vehicles',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alert queue synchronized with cloud relay.'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.sync_rounded, color: AppColors.primary),
                tooltip: 'Sync Log',
              ),
            ],
          ),

          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alertsLog.length,
            separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final alert = _alertsLog[idx];
              final isActive = alert['status'] == 'Active';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFFFEE2E2)
                                    : AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                                color: isActive ? const Color(0xFFDC2626) : AppColors.success,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['title'] as String,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  alert['location'] as String,
                                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert['status'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive ? const Color(0xFFB91C1C) : const Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert['desc'] as String,
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vehicle: ${alert['plate']} • ${alert['time']}',
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.outline),
                        ),
                        if (isActive)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Quick reply "Coming in 2 mins!" sent to bystander.'),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Reply "Coming (2m)"', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => alert['status'] = 'Resolved');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  foregroundColor: AppColors.onSurface,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Resolved', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: ORDER PHYSICAL 3M WEATHERPROOF QR DECAL
  // -------------------------------------------------------------
  Widget _buildTab4OrderDecal() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Book Weatherproof 3M QR Decal',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Order high-grade 3M micro-prismatic night-reflective decals',
                        style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '₹0 Free Express Delivery',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Choose Sticker Finish
          const Text(
            '1. CHOOSE STICKER FINISH',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFinishCard(
                  title: 'Reflective Night-Glow',
                  subtitle: 'High-visibility 3M vinyl. Glows under headlights.',
                  tag: '★ Most Popular',
                  value: 'Reflective Night-Glow',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFinishCard(
                  title: 'Static Cling',
                  subtitle: 'Electrostatic adhesion. Zero sticky residue on glass.',
                  tag: 'Removable',
                  value: 'Static Cling',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFinishCard(
                  title: 'Matte Stealth',
                  subtitle: 'Textured finish with laser-etched contrast.',
                  tag: 'UV Shield',
                  value: 'Matte Stealth',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Delivery Address Form
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. DELIVERY ADDRESS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.secondary),
              ),
              Row(
                children: const [
                  Icon(Icons.local_shipping_rounded, size: 14, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'BlueDart Express (2-Day Guaranteed)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('Full Name', _nameController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField('Courier Mobile', _mobileController),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildFormField('Vehicle Plate to Print', _plateController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _buildFormField('Street Address / Apartment', _addressController),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFormField('City, State & PIN', _cityPinController),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm and Dispatch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Dispatched from Motoro Central Logistics Depot',
                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _submitDecalOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text(
                  'Confirm & Dispatch Free Tag',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinishCard({
    required String title,
    required String subtitle,
    required String tag,
    required String value,
  }) {
    final isSel = _selectedStickerFinish == value;
    return InkWell(
      onTap: () => setState(() => _selectedStickerFinish = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: isSel ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSel ? AppColors.primary : AppColors.outline,
                  size: 20,
                ),
              ],
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// CUSTOM PAINTER: Sharp L-Corner Brackets matching camera scanner screenshot
// -----------------------------------------------------------------
class _ScannerBracketPainter extends CustomPainter {
  final bool isTargetAcquired;

  _ScannerBracketPainter({this.isTargetAcquired = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isTargetAcquired ? const Color(0xFF10B981) : Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const cornerLen = 24.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLen, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLen), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLen, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLen), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLen, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLen), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLen, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerBracketPainter oldDelegate) =>
      oldDelegate.isTargetAcquired != isTargetAcquired;
}

// -----------------------------------------------------------------
// CUSTOM PAINTER: Crisp High-Contrast QR Code Vector with Center Shield
// -----------------------------------------------------------------
class _MotoroQrVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blackPaint = Paint()..color = Colors.black;
    final whitePaint = Paint()..color = Colors.white;

    // Helper for Finder Patterns
    void drawFinderPattern(double x, double y, double s) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, s, s), const Radius.circular(4)),
        blackPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + s * 0.15, y + s * 0.15, s * 0.7, s * 0.7), const Radius.circular(3)),
        whitePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x + s * 0.3, y + s * 0.3, s * 0.4, s * 0.4), const Radius.circular(2)),
        blackPaint,
      );
    }

    final finderSize = size.width * 0.28;
    // 3 Finder patterns
    drawFinderPattern(0, 0, finderSize);
    drawFinderPattern(size.width - finderSize, 0, finderSize);
    drawFinderPattern(0, size.height - finderSize, finderSize);

    // Data matrix blocks
    final dotSize = size.width * 0.055;
    final matrixOffsets = [
      Offset(size.width * 0.35, size.height * 0.08),
      Offset(size.width * 0.45, size.height * 0.08),
      Offset(size.width * 0.55, size.height * 0.08),
      Offset(size.width * 0.35, size.height * 0.18),
      Offset(size.width * 0.55, size.height * 0.18),
      Offset(size.width * 0.08, size.height * 0.35),
      Offset(size.width * 0.18, size.height * 0.35),
      Offset(size.width * 0.08, size.height * 0.45),
      Offset(size.width * 0.08, size.height * 0.55),
      // Bottom Right cluster
      Offset(size.width * 0.38, size.height * 0.65),
      Offset(size.width * 0.48, size.height * 0.65),
      Offset(size.width * 0.60, size.height * 0.65),
      Offset(size.width * 0.72, size.height * 0.65),
      Offset(size.width * 0.85, size.height * 0.65),
      Offset(size.width * 0.65, size.height * 0.78),
      Offset(size.width * 0.76, size.height * 0.78),
      Offset(size.width * 0.88, size.height * 0.78),
      Offset(size.width * 0.42, size.height * 0.88),
      Offset(size.width * 0.56, size.height * 0.88),
    ];

    for (final off in matrixOffsets) {
      canvas.drawRect(Rect.fromLTWH(off.dx, off.dy, dotSize, dotSize), blackPaint);
    }

    // Center Shield Motif
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, size.width * 0.14, whitePaint);
    canvas.drawCircle(center, size.width * 0.12, Paint()..color = AppColors.primary);

    // Mini shield path
    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - size.width * 0.06);
    shieldPath.lineTo(center.dx + size.width * 0.05, center.dy - size.width * 0.03);
    shieldPath.lineTo(center.dx + size.width * 0.05, center.dy + size.width * 0.02);
    shieldPath.lineTo(center.dx, center.dy + size.width * 0.06);
    shieldPath.lineTo(center.dx - size.width * 0.05, center.dy + size.width * 0.02);
    shieldPath.lineTo(center.dx - size.width * 0.05, center.dy - size.width * 0.03);
    shieldPath.close();
    canvas.drawPath(shieldPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------
// MODAL 1: Anonymous Contact Drawer (Triggered on QR Scan)
// -----------------------------------------------------------------
class _AnonymousContactDrawerModal extends StatefulWidget {
  final String plate;
  final String vehicleName;
  final String location;
  final ValueChanged<String> onMessageSent;
  final VoidCallback onInitiateVoipCall;

  const _AnonymousContactDrawerModal({
    required this.plate,
    required this.vehicleName,
    required this.location,
    required this.onMessageSent,
    required this.onInitiateVoipCall,
  });

  @override
  State<_AnonymousContactDrawerModal> createState() => _AnonymousContactDrawerModalState();
}

class _AnonymousContactDrawerModalState extends State<_AnonymousContactDrawerModal> {
  final TextEditingController _customMsgController = TextEditingController();

  final List<String> _presets = [
    '🚗 Can you please move your car? It is blocking driveway / gate access.',
    '⚠️ Headlights / Foglamps left on (Battery drain risk).',
    '💥 Minor bump or scratch occurred in parking area.',
    '⛔ Vehicle parked in tow-away zone (Traffic police nearby).',
    '🛞 Low tyre pressure / flat tyre observed on rear wheel.',
  ];

  @override
  void dispose() {
    _customMsgController.dispose();
    super.dispose();
  }

  void _sendPreset(String text) {
    Navigator.pop(context);
    widget.onMessageSent(text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Vehicle Owner Connect', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Your personal phone number is 100% masked', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
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

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scanned Vehicle Profile Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.plate,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Verified Owner',
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.success),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(widget.vehicleName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(widget.location, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'ONE-TAP QUICK MESSAGES TO DRIVER:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),

                  ..._presets.map((msg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () => _sendPreset(msg),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  msg,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_rounded, size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Custom Message Input
                  const Text(
                    'OR TYPE A CUSTOM NOTE:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customMsgController,
                          maxLength: 140,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'e.g. Parked behind you at lower basement bay...',
                            hintStyle: const TextStyle(fontSize: 11, color: AppColors.outline),
                            counterText: '',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_customMsgController.text.trim().isNotEmpty) {
                            _sendPreset(_customMsgController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: const Text('Send', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Masked Anonymous Call Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onInitiateVoipCall();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text(
                        '📞 Call Owner (Masked VoIP Relay)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Zero exposure: Neither party will see the other\'s real phone number.',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
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
}

// -----------------------------------------------------------------
// MODAL 2: Simulated Masked VoIP Call with Animated Equalizer Bars
// -----------------------------------------------------------------
class _SimulatedVoipCallDialog extends StatefulWidget {
  final String plate;

  const _SimulatedVoipCallDialog({required this.plate});

  @override
  State<_SimulatedVoipCallDialog> createState() => _SimulatedVoipCallDialogState();
}

class _SimulatedVoipCallDialogState extends State<_SimulatedVoipCallDialog> with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  int _callSeconds = 0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _startCallTimer();
  }

  void _startCallTimer() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _callSeconds++);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatTimer() {
    final m = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF34D399), width: 2),
              ),
              child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF34D399), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              widget.plate,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                color: AppColors.primaryFixed,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Motoro 256-bit Encrypted VoIP Bridge',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),

            // Animated Equalizer Waveform Bars
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final h = 10.0 + (18.0 * ((_waveController.value + (i * 0.2)) % 1.0));
                    return Container(
                      width: 4,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 12),
            Text(
              'Connected to driver • ${_formatTimer()}',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Color(0xFF34D399),
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🛡️ Audio relay connected via AWS/Airtel SIP Trunk',
                style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1)),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons: Mute, Hangup, Speaker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => setState(() => _isMuted = !_isMuted),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _isMuted ? const Color(0xFFDC2626) : const Color(0xFF334155),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Audio routed to speakerphone.'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF334155),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
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
