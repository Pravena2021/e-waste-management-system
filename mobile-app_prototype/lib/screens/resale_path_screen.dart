import 'package:flutter/material.dart';
import '../services/ai_analysis_service.dart';
import '../services/app_database.dart';

class ResalePathScreen extends StatefulWidget {
  final DeviceAnalysisResult result;
  final String imei;

  const ResalePathScreen({super.key, required this.result, required this.imei});

  @override
  State<ResalePathScreen> createState() => _ResalePathScreenState();
}

class _ResalePathScreenState extends State<ResalePathScreen> {
  bool _isWipingConfirmed = false;
  bool _isPassportUpdated = false;

  final List<String> _mockRepairHistory = [
    "Battery replaced (OEM) - 2024-10-12",
    "Screen refurbished - 2025-01-05"
  ];

  void _updateDigitalPassport() async {
    // Simulate Blockchain/Ledger Digital Passport update
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); // remove loader
      setState(() {
        _isPassportUpdated = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digital Passport Updated Successfully!')),
      );
    }
  }

  void _listOnMarketplace() {
    AppDatabase.instance.updateDeviceStatus(widget.imei, 'Listed on Marketplace');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device successfully listed on Marketplace!')),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resale Verification'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.storefront, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Pre-Marketplace Checklist',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Device Details & Repair History Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Device Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(res.deviceModel),
                      subtitle: Text('Condition: ${res.hardwareHealth}'),
                      trailing: Text('\$${res.marketValue.toStringAsFixed(2)}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                    ),
                    const SizedBox(height: 8),
                    Text('Repair History:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ..._mockRepairHistory.map((repair) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.build_circle, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(child: Text(repair, style: const TextStyle(fontSize: 14))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Checklist Actions
            Text('Processing Checklist', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            CheckboxListTile(
              title: const Text('Confirm Light Wiping (ZTEP protocol) completion'),
              value: _isWipingConfirmed,
              activeColor: Colors.amber,
              onChanged: (val) {
                setState(() {
                  _isWipingConfirmed = val ?? false;
                });
              },
            ),

            ListTile(
              title: const Text('Update Digital Passport with condition and repair info'),
              trailing: _isPassportUpdated
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: _updateDigitalPassport,
                      child: const Text('Update'),
                    ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: (_isWipingConfirmed && _isPassportUpdated) ? _listOnMarketplace : null,
              icon: const Icon(Icons.publish),
              label: const Text('List Device on Marketplace'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
