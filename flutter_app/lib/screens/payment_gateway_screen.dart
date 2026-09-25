import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class PaymentGatewayScreen extends StatefulWidget {
  final double amount;
  final String itemTitle;
  final String itemSubtitle;
  final VoidCallback? onPaymentSuccess;

  const PaymentGatewayScreen({
    super.key,
    this.amount = 1000.0,
    this.itemTitle = 'FastTag Wallet Recharge',
    this.itemSubtitle = 'Vehicle: MH 12 RN 2024 (NETC-3416-8901-2290)',
    this.onPaymentSuccess,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  int _timeLeft = 598;
  Timer? _timer;
  String _selectedMethod = 'upi';
  bool _isProcessing = false;
  double _progress = 0.0;
  String _processingStep = 'Communicating with NPCI...';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        // Handle timeout
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int mins = _timeLeft ~/ 60;
    int secs = _timeLeft % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
      _progress = 0.25;
      _processingStep = 'NPCI Switch Handshake Verified...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _progress = 0.55;
      _processingStep = 'Authorizing debit...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _progress = 0.85;
      _processingStep = 'Updating NETC FastTag RFID balance...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _progress = 1.0;
      _processingStep = 'Payment Approved! Redirecting...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      widget.onPaymentSuccess?.call();
      Navigator.pop(context, true); // Return success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0b2222), Color(0xFF004c4b), Color(0xFF006a68)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Ambient orbs
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        _buildTransactionRecap(),
                        _buildMainBody(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF0f2e2d),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGlow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.toll, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'MOTORO',
                        style: TextStyle(
                          color: Color(0xFF7bf6f2),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'BBPS / NETC Gateway',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'NPCI Official FASTag Top-Up System',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expires in: $_formattedTime',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRecap() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.itemSubtitle, style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text('Payable Amount: ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: AppTheme.headlineStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 250, child: _buildPaymentMethodsList()),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPaymentForm()),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              SizedBox(height: 160, child: _buildPaymentMethodsList(horizontal: true)),
              const Divider(height: 1),
              _buildPaymentForm(),
            ],
          );
        }
      },
    );
  }

  Widget _buildPaymentMethodsList({bool horizontal = false}) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'CHOOSE PAYMENT MODE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: horizontal
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _buildMethodTabs(horizontal: true),
                  )
                : Column(
                    children: _buildMethodTabs(horizontal: false),
                  ),
          ),
          if (!horizontal) ...[
            const Spacer(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green[600], size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'PCI-DSS Level 1 & RBI Encrypted',
                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildMethodTabs({required bool horizontal}) {
    return [
      _buildMethodTab('upi', 'UPI / QR Code', 'GPay, PhonePe, Paytm, CRED', Icons.qr_code_2, Colors.green[100]!, Colors.green[800]!, horizontal),
      _buildMethodTab('card', 'Debit / Credit Card', 'RuPay, Visa, Mastercard', Icons.credit_card, Colors.blue[100]!, Colors.blue[800]!, horizontal),
      _buildMethodTab('netbanking', 'Net Banking', 'All Indian Banks Supported', Icons.account_balance, Colors.purple[100]!, Colors.purple[800]!, horizontal),
      _buildMethodTab('bbps', 'FastTag Wallet Direct', 'Auto-Debit & Linked Bank', Icons.account_balance_wallet, Colors.orange[100]!, Colors.orange[800]!, horizontal),
    ];
  }

  Widget _buildMethodTab(String id, String title, String subtitle, IconData icon, Color bgColor, Color iconColor, bool horizontal) {
    bool isSelected = _selectedMethod == id;
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: horizontal
            ? Border(bottom: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 3))
            : Border(left: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 4)),
      ),
      child: Row(
        mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          if (!horizontal)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = id;
        });
      },
      child: horizontal ? content : content,
    );
  }

  Widget _buildPaymentForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSelectedMethodForm()),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processPayment,
              icon: const Icon(Icons.verified_user, size: 20),
              label: Text('Pay ₹${widget.amount.toStringAsFixed(2)} & Credit FastTag'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 14),
                label: const Text('Cancel and Return'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              TextButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.bolt, size: 14),
                label: const Text('Quick Demo Success'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMethodForm() {
    switch (_selectedMethod) {
      case 'upi':
        return _buildUpiForm();
      case 'card':
        return _buildCardForm();
      case 'netbanking':
        return const Center(child: Text('Net Banking Content'));
      case 'bbps':
        return const Center(child: Text('BBPS Content'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUpiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Scan UPI QR or Enter VPA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('Scan with any UPI app on your mobile phone to approve instantly.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 2),
                ),
                child: Center(
                  child: Icon(Icons.qr_code_2, size: 80, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Supported UPI Apps:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['GPay', 'PhonePe', 'Paytm', 'CRED'].map((app) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(app, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Or Enter Virtual Payment Address (VPA)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: 'driver.fleet@okhdfcbank'),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        suffixIcon: TextButton(
                          onPressed: () {},
                          child: Text('Verify', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Debit or Credit Card', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Text('RuPay, Visa, Mastercard, and Corporate fleet cards accepted.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        _buildTextField('Card Number', '5241 8900 1234 5678', icon: Icons.credit_card),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Valid Thru', '08/29')),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('CVV / CVC', '782', isPassword: true)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField('Name on Card', 'VIKRAM SHARMA'),
      ],
    );
  }

  Widget _buildTextField(String label, String value, {IconData? icon, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          obscureText: isPassword,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: const Color(0xFF0f2e2d).withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    strokeWidth: 4,
                  ),
                ),
                const Icon(Icons.toll, color: Color(0xFF7bf6f2), size: 32),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing NETC Payment...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _processingStep,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 250,
              height: 6,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7bf6f2)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Do not close this window or press back.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
