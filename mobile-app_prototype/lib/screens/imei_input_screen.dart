import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'device_analysis_screen.dart';
import 'admin_dashboard_screen.dart';

class ImeiInputScreen extends StatefulWidget {
  const ImeiInputScreen({super.key});

  @override
  State<ImeiInputScreen> createState() => _ImeiInputScreenState();
}

class _ImeiInputScreenState extends State<ImeiInputScreen> {
  final TextEditingController _imeiController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    _imeiController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _imeiController.text = barcode.rawValue!;
          _isScanning = false;
        });
        _scannerController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('IMEI Detected!')),
        );
        break;
      }
    }
  }

  void _scanAgain() {
    setState(() {
      _imeiController.clear();
      _isScanning = true;
    });
    _scannerController.start();
  }

  void _submitImei() {
    final imei = _imeiController.text;
    if (imei.isEmpty || imei.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid IMEI')),
      );
      return;
    }
    // Proceed to device analysis
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceAnalysisScreen(imei: imei),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan or Enter IMEI'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            },
            tooltip: 'Admin Dashboard',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner View
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _isScanning
                      ? MobileScanner(
                          controller: _scannerController,
                          onDetect: _onDetect,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green, size: 64),
                              SizedBox(height: 16),
                              Text('Scan Completed', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Input Field
            TextField(
              controller: _imeiController,
              decoration: const InputDecoration(
                labelText: 'IMEI Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _isScanning ? null : _scanAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan Again'),
                ),
                ElevatedButton.icon(
                  onPressed: _submitImei,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
