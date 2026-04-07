import 'package:flutter/material.dart';
import '../services/ai_analysis_service.dart';
import '../services/app_database.dart';
import '../models/device_model.dart';
import 'resale_path_screen.dart';
import 'data_wiping_screen.dart';

class DeviceAnalysisScreen extends StatefulWidget {
  final String imei;

  const DeviceAnalysisScreen({super.key, required this.imei});

  @override
  State<DeviceAnalysisScreen> createState() => _DeviceAnalysisScreenState();
}

class _DeviceAnalysisScreenState extends State<DeviceAnalysisScreen> with SingleTickerProviderStateMixin {
  final AiAnalysisService _aiService = AiAnalysisService();
  DeviceAnalysisResult? _result;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _startAnalysis();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final result = await _aiService.analyzeDevice(widget.imei);
    setState(() {
      _result = result;
      _isLoading = false;
    });

    // Register initial scan in the database
    AppDatabase.instance.addDeviceOrUpdate(DeviceModel(
      imei: widget.imei,
      model: result.deviceModel,
      conditionTag: result.conditionTag,
      status: 'Pending Routing',
    ));
  }

  Color _getConditionColor(String tag) {
    if (tag == "Repairable") return Colors.green;
    if (tag == "Non-Repairable") return Colors.red;
    if (tag == "Rare/High-Value") return Colors.amber;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Device Analysis'),
      ),
      body: Center(
        child: _isLoading ? _buildLoadingView() : _buildResultView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _animationController,
          child: const Icon(Icons.memory, size: 80, color: Colors.blueAccent),
        ),
        const SizedBox(height: 24),
        const Text(
          'Scanning logical sectors...',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
        const SizedBox(height: 12),
        const Text(
          'Evaluating Component Health',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final res = _result!;
    final color = _getConditionColor(res.conditionTag);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: color),
          const SizedBox(height: 16),
          Text(
            'Analysis Complete',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _buildInfoRow('Device Model', res.deviceModel),
          _buildInfoRow('Age (months)', '${res.ageMonths}'),
          _buildInfoRow('Market Value', '\$${res.marketValue.toStringAsFixed(2)}'),
          _buildInfoRow('Hardware Health', res.hardwareHealth),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'Condition Tag',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  res.conditionTag,
                  style: TextStyle(
                      color: color, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (res.conditionTag == 'Non-Repairable') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataWipingScreen(result: res, imei: widget.imei)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResalePathScreen(result: res, imei: widget.imei)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
