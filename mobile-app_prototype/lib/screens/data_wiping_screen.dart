import 'package:flutter/material.dart';
import '../services/ai_analysis_service.dart';
import '../services/encryption_service.dart';
import '../services/app_database.dart';

class DataWipingScreen extends StatefulWidget {
  final DeviceAnalysisResult result;
  final String imei;

  const DataWipingScreen({super.key, required this.result, required this.imei});

  @override
  State<DataWipingScreen> createState() => _DataWipingScreenState();
}

class _DataWipingScreenState extends State<DataWipingScreen> {
  int _wipingPhase = 0; // 0: Pending, 1: Phase 1, 2: Phase 2, 3: Phase 3, 4: Done
  bool _isToolVerified = false;
  bool _isAuditorVerified = false;
  String? _certificateId;

  void _startTripleStageWipe() async {
    for (int i = 1; i <= 4; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _wipingPhase = i;
      });
    }
    setState(() {
      _isToolVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Triple-Stage Wiping & Tool Verification Complete')),
    );
  }

  void _generateCertificate() async {
    if (!_isToolVerified || !_isAuditorVerified) return;
    
    // Simulate Blockchain transaction
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // remove loader

      final certHash = EncryptionService.generateImmutableCertificate(
        widget.imei, 
        "ZTEP_TRIPLE_WIPE", 
        "AUDITOR_77A"
      );

      setState(() {
        _certificateId = certHash;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Immutable Blockchain Certificate Generated!')),
      );
    }
  }

  void _scheduleTransfer() {
    AppDatabase.instance.updateDeviceStatus(widget.imei, 'Wiped & Recycled', certId: _certificateId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer to Recycling Partner Scheduled!')),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Wiping & Recycling'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.recycling, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Secure Recycling Path',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Device Info
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.grey),
                title: Text(widget.result.deviceModel, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Condition: Non-Repairable\nRequires secure wipe before dismantling.'),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 24),

            // Wiping Progress
            Text('Triple-Stage Wiping Protocol', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_wipingPhase == 0)
              ElevatedButton.icon(
                onPressed: _startTripleStageWipe,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Wiping Process'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              )
            else ...[
              LinearProgressIndicator(
                value: _wipingPhase / 4.0,
                backgroundColor: Colors.grey.shade300,
                color: Colors.redAccent,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 8),
              Text(_getWipingStatusText(), style: TextStyle(color: _wipingPhase == 4 ? Colors.green : Colors.black87)),
            ],

            const Divider(height: 48),

            // Verification
            Text('Dual Verification', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_isToolVerified ? Icons.check_circle : Icons.pending, color: _isToolVerified ? Colors.green : Colors.grey),
              title: const Text('Diagnostic Tool Verification'),
              subtitle: const Text('Automated partition inspection'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auditor Verification'),
              subtitle: const Text('Manual confirmation of successful wipe'),
              value: _isAuditorVerified,
              activeColor: Colors.redAccent,
              onChanged: _isToolVerified && _certificateId == null ? (val) {
                setState(() {
                  _isAuditorVerified = val ?? false;
                });
              } : null,
            ),

            const SizedBox(height: 16),
            
            // Certificate Area
            if (_certificateId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.security, color: Colors.green),
                    const SizedBox(height: 8),
                    const Text('Blockchain Wipe Certificate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text(_certificateId!, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, letterSpacing: 1.2)),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: (_isToolVerified && _isAuditorVerified) ? _generateCertificate : null,
                icon: const Icon(Icons.verified),
                label: const Text('Generate Blockchain Certificate'),
              ),

            const SizedBox(height: 32),

            // Final Action
            ElevatedButton.icon(
              onPressed: _certificateId != null ? _scheduleTransfer : null,
              icon: const Icon(Icons.local_shipping),
              label: const Text('Schedule Transfer to Recycling Partner'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWipingStatusText() {
    switch (_wipingPhase) {
      case 0: return "Pending initialization...";
      case 1: return "Stage 1: Overwriting with zeroes...";
      case 2: return "Stage 2: Overwriting with random data...";
      case 3: return "Stage 3: Verifying sector integrity...";
      case 4: return "Data Wiping Complete.";
      default: return "";
    }
  }
}
