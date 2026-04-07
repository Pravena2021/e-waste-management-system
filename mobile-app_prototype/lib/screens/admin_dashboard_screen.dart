import 'package:flutter/material.dart';
import '../services/app_database.dart';
import '../models/device_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'All'; // 'All', 'Repairable', 'Non-Repairable', 'Rare/High-Value'

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.addListener(() {
      if (mounted) setState(() {});
    });
  }

  List<DeviceModel> get _filteredDevices {
    final all = AppDatabase.instance.devices;
    if (_filter == 'All') return all;
    return all.where((d) => d.conditionTag == _filter).toList();
  }

  Color _getTagColor(String tag) {
    if (tag == "Repairable") return Colors.green;
    if (tag == "Non-Repairable") return Colors.red;
    if (tag == "Rare/High-Value") return Colors.amber;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Metrics Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricBlock('Total Scanned', AppDatabase.instance.devices.length.toString(), Colors.blue),
                _buildMetricBlock('Resale Active', AppDatabase.instance.devices.where((d) => d.status.contains('Listed')).length.toString(), Colors.amber),
                _buildMetricBlock('Wiped/Recycled', AppDatabase.instance.devices.where((d) => d.status.contains('Recycled')).length.toString(), Colors.green),
              ],
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Filter by Tag: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _filter,
                    items: ['All', 'Repairable', 'Non-Repairable', 'Rare/High-Value']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _filter = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Device List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDevices.length,
              itemBuilder: (context, index) {
                final device = _filteredDevices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTagColor(device.conditionTag),
                      child: Icon(
                        device.conditionTag == 'Non-Repairable' ? Icons.delete : Icons.storefront,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(device.model, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('IMEI: ${device.imei}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(),
                            Text('Condition: ${device.conditionTag}', style: TextStyle(color: _getTagColor(device.conditionTag), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Status: ${device.status}'),
                            if (device.certificateId != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Text('Cert: ${device.certificateId}', style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.green)),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricBlock(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
