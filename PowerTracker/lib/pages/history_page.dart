import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/cloud_storage.dart';

enum CloudSyncStatus { synced, syncing, error }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<EnergyRecord> _records = [];
  List<EnergyRecord> _filteredRecords = [];
  CloudSyncStatus _cloudSyncStatus = CloudSyncStatus.synced;
  String _searchQuery = '';
  String _filterMonth = 'all';
  EnergyRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _loadCloudData();
  }

  Future<void> _loadCloudData() async {
    setState(() {
      _cloudSyncStatus = CloudSyncStatus.syncing;
    });

    try {
      await CloudStorage.initializeMockData();
      final records = await CloudStorage.getAllRecords();

      setState(() {
        _records = records;
        _filteredRecords = records;
        _cloudSyncStatus = CloudSyncStatus.synced;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _cloudSyncStatus = CloudSyncStatus.error;
      });
    }
  }

  void _applyFilters() {
    List<EnergyRecord> filtered = _records;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        return record.date.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_filterMonth != 'all') {
      final monthIndex = int.parse(_filterMonth);
      filtered = filtered.where((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.month - 1 == monthIndex;
      }).toList();
    }

    setState(() {
      _filteredRecords = filtered;
    });
  }

  void _viewReceipt(EnergyRecord record) {
    setState(() {
      _selectedRecord = record;
    });
    _showReceiptDialog();
  }

  Future<void> _downloadReceipt(EnergyRecord record) async {
    final receiptContent = _generateReceiptText(record);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/PowerTracker-Receipt-${record.date}.txt');
      await file.writeAsString(receiptContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'PowerTracker Receipt - ${record.date}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download receipt: $e')),
        );
      }
    }
  }

  String _generateReceiptText(EnergyRecord record) {
    final date = DateTime.parse(record.date);
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

    final deviceBreakdown = record.devices
        .map((device) =>
            '${device.name.padRight(20)} ${device.usage.toStringAsFixed(2)} kWh (${device.hours}h)')
        .join('\n');

    return '''
═══════════════════════════════════════
          POWERTRACKER RECEIPT
═══════════════════════════════════════

Date: $formattedDate

───────────────────────────────────────
ENERGY CONSUMPTION SUMMARY
───────────────────────────────────────

Total Usage:        ${record.totalUsage.toStringAsFixed(2)} kWh
Peak Usage:         ${record.peakUsage.toStringAsFixed(2)} kWh/h
Average Usage:      ${record.averageUsage.toStringAsFixed(2)} kWh/h
Active Devices:     ${record.activeDevices}

───────────────────────────────────────
DEVICE BREAKDOWN
───────────────────────────────────────

$deviceBreakdown

───────────────────────────────────────
BILLING DETAILS
───────────────────────────────────────

Rate:               ₱12.00 per kWh
Subtotal:           ₱${record.totalCost.toStringAsFixed(2)}
Tax (0%):           ₱0.00

───────────────────────────────────────
TOTAL AMOUNT:       ₱${record.totalCost.toStringAsFixed(2)}
───────────────────────────────────────

Thank you for using PowerTracker!
Energy monitoring made simple.

═══════════════════════════════════════
''';
  }

  void _showReceiptDialog() {
    if (_selectedRecord == null) return;

    final record = _selectedRecord!;
    final date = DateTime.parse(record.date);
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(date);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Energy Receipt',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Cost Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Cost',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${record.totalCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${record.totalUsage.toStringAsFixed(2)} kWh consumed',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Usage Stats
                      const Text(
                        'Usage Statistics',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peak Usage',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${record.peakUsage.toStringAsFixed(1)} kWh/h',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Average Usage',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${record.averageUsage.toStringAsFixed(1)} kWh/h',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Device Breakdown
                      const Text(
                        'Device Breakdown',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...record.devices.map((device) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${device.hours} hours',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${device.usage.toStringAsFixed(2)} kWh',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₱${(device.usage * 12).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Billing
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBillingRow('Rate per kWh', '₱12.00'),
                            const SizedBox(height: 8),
                            _buildBillingRow(
                              'Subtotal',
                              '₱${record.totalCost.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            _buildBillingRow('Tax (0%)', '₱0.00'),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₱${record.totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Download Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadReceipt(record);
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Download Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
    );
  }

  Widget _buildBillingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHistoricalUsage = _records.fold<double>(
      0.0,
      (sum, r) => sum + r.totalUsage,
    );
    final totalHistoricalCost = _records.fold<double>(
      0.0,
      (sum, r) => sum + r.totalCost,
    );
    final avgDailyUsage = _records.isNotEmpty ? totalHistoricalUsage / _records.length : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadCloudData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cloud Sync Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cloudSyncStatus == CloudSyncStatus.synced
                      ? Colors.green[50]
                      : _cloudSyncStatus == CloudSyncStatus.syncing
                          ? Colors.blue[50]
                          : Colors.red[50],
                  border: Border.all(
                    color: _cloudSyncStatus == CloudSyncStatus.synced
                        ? Colors.green[200]!
                        : _cloudSyncStatus == CloudSyncStatus.syncing
                            ? Colors.blue[200]!
                            : Colors.red[200]!,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cloudSyncStatus == CloudSyncStatus.synced
                          ? Icons.check_circle
                          : _cloudSyncStatus == CloudSyncStatus.syncing
                              ? Icons.cloud
                              : Icons.error,
                      color: _cloudSyncStatus == CloudSyncStatus.synced
                          ? Colors.green[600]
                          : _cloudSyncStatus == CloudSyncStatus.syncing
                              ? Colors.blue[600]
                              : Colors.red[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _cloudSyncStatus == CloudSyncStatus.synced
                                ? 'Cloud Synced'
                                : _cloudSyncStatus == CloudSyncStatus.syncing
                                    ? 'Syncing...'
                                    : 'Sync Failed',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _cloudSyncStatus == CloudSyncStatus.synced
                                ? '${_records.length} records backed up'
                                : _cloudSyncStatus == CloudSyncStatus.syncing
                                    ? 'Please wait...'
                                    : 'Unable to sync data',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _cloudSyncStatus == CloudSyncStatus.syncing
                          ? null
                          : _loadCloudData,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.cloud, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Records',
                      _records.length.toString(),
                      '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Daily',
                      avgDailyUsage.toStringAsFixed(1),
                      'kWh',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Cost',
                      '₱${totalHistoricalCost.toStringAsFixed(0)}',
                      '',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: 'Search by date...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterMonth,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _filterMonth = value!;
                            });
                            _applyFilters();
                          },
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Months')),
                            DropdownMenuItem(value: '0', child: Text('January')),
                            DropdownMenuItem(value: '1', child: Text('February')),
                            DropdownMenuItem(value: '2', child: Text('March')),
                            DropdownMenuItem(value: '3', child: Text('April')),
                            DropdownMenuItem(value: '4', child: Text('May')),
                            DropdownMenuItem(value: '5', child: Text('June')),
                            DropdownMenuItem(value: '6', child: Text('July')),
                            DropdownMenuItem(value: '7', child: Text('August')),
                            DropdownMenuItem(value: '8', child: Text('September')),
                            DropdownMenuItem(value: '9', child: Text('October')),
                            DropdownMenuItem(value: '10', child: Text('November')),
                            DropdownMenuItem(value: '11', child: Text('December')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Records List
              Row(
                children: [
                  const Icon(Icons.description, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Energy History (${_filteredRecords.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_filteredRecords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      _searchQuery.isNotEmpty || _filterMonth != 'all'
                          ? 'No records found'
                          : 'No history data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ...(_filteredRecords.map((record) {
                  final date = DateTime.parse(record.date);
                  final formattedDate = DateFormat('MMM d, y').format(date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _viewReceipt(record),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF6366F1),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${record.activeDevices} devices active',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${record.totalCost.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${record.totalUsage.toStringAsFixed(2)} kWh',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Peak',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${record.peakUsage.toStringAsFixed(1)} kWh',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Average',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${record.averageUsage.toStringAsFixed(1)} kWh',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Devices',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${record.devices.length}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _viewReceipt(record),
                                      icon: const Icon(Icons.description, size: 16),
                                      label: const Text('View Receipt'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _downloadReceipt(record),
                                      icon: const Icon(Icons.download, size: 16),
                                      label: const Text('Download'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String suffix) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (suffix.isNotEmpty)
            Text(
              suffix,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }
}
