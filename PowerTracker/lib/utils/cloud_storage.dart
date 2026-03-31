import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyRecord {
  final String id;
  final String date;
  final double totalUsage; // kWh
  final double totalCost; // PHP
  final int activeDevices;
  final double peakUsage;
  final double averageUsage;
  final List<DeviceUsage> devices;

  EnergyRecord({
    required this.id,
    required this.date,
    required this.totalUsage,
    required this.totalCost,
    required this.activeDevices,
    required this.peakUsage,
    required this.averageUsage,
    required this.devices,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'totalUsage': totalUsage,
      'totalCost': totalCost,
      'activeDevices': activeDevices,
      'peakUsage': peakUsage,
      'averageUsage': averageUsage,
      'devices': devices.map((d) => d.toJson()).toList(),
    };
  }

  factory EnergyRecord.fromJson(Map<String, dynamic> json) {
    return EnergyRecord(
      id: json['id'],
      date: json['date'],
      totalUsage: (json['totalUsage'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      activeDevices: json['activeDevices'],
      peakUsage: (json['peakUsage'] as num).toDouble(),
      averageUsage: (json['averageUsage'] as num).toDouble(),
      devices: (json['devices'] as List)
          .map((d) => DeviceUsage.fromJson(d))
          .toList(),
    );
  }
}

class DeviceUsage {
  final String name;
  final double usage;
  final int hours;

  DeviceUsage({
    required this.name,
    required this.usage,
    required this.hours,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage': usage,
      'hours': hours,
    };
  }

  factory DeviceUsage.fromJson(Map<String, dynamic> json) {
    return DeviceUsage(
      name: json['name'],
      usage: (json['usage'] as num).toDouble(),
      hours: json['hours'],
    );
  }
}

class CloudStorage {
  static const String _storageKey = 'powertracker_history';

  // Save a new energy record to cloud
  static Future<bool> saveRecord(EnergyRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRecords = await getAllRecords();
      final updatedRecords = [record, ...existingRecords];
      final jsonData = json.encode(updatedRecords.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, jsonData);
      return true;
    } catch (e) {
      print('Failed to save record: $e');
      return false;
    }
  }

  // Save current day's data
  static Future<bool> saveDailySnapshot(
    List<Map<String, dynamic>> devices,
    double totalUsage,
  ) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final existingRecords = await getAllRecords();

      // Check if today's record already exists
      final existingIndex = existingRecords.indexWhere((r) => r.date == today);

      final activeDevicesList = devices.where((d) => d['active'] == true).toList();
      const totalHours = 24; // Full day

      final record = EnergyRecord(
        id: existingIndex >= 0
            ? existingRecords[existingIndex].id
            : 'record-${DateTime.now().millisecondsSinceEpoch}',
        date: today,
        totalUsage: (totalUsage / 1000 * totalHours), // Convert W to kWh for 24 hours
        totalCost: (totalUsage / 1000 * totalHours) * 12, // ₱12 per kWh
        activeDevices: activeDevicesList.length,
        peakUsage: (totalUsage / 1000 * 1.3), // Simulated peak
        averageUsage: (totalUsage / 1000),
        devices: activeDevicesList.map((d) {
          return DeviceUsage(
            name: d['name'],
            usage: (d['power'] / 1000) * totalHours,
            hours: totalHours,
          );
        }).toList(),
      );

      if (existingIndex >= 0) {
        // Update existing record
        existingRecords[existingIndex] = record;
        final prefs = await SharedPreferences.getInstance();
        final jsonData = json.encode(existingRecords.map((r) => r.toJson()).toList());
        await prefs.setString(_storageKey, jsonData);
      } else {
        // Add new record
        return await saveRecord(record);
      }

      return true;
    } catch (e) {
      print('Failed to save daily snapshot: $e');
      return false;
    }
  }

  // Get all records from cloud
  static Future<List<EnergyRecord>> getAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        return jsonList.map((json) => EnergyRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load records: $e');
      return [];
    }
  }

  // Get records by date range
  static Future<List<EnergyRecord>> getRecordsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final allRecords = await getAllRecords();
    return allRecords.where((record) {
      return record.date.compareTo(startDate) >= 0 &&
          record.date.compareTo(endDate) <= 0;
    }).toList();
  }

  // Delete a record
  static Future<bool> deleteRecord(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingRecords = await getAllRecords();
      final updatedRecords = existingRecords.where((r) => r.id != id).toList();
      final jsonData = json.encode(updatedRecords.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, jsonData);
      return true;
    } catch (e) {
      print('Failed to delete record: $e');
      return false;
    }
  }

  // Clear all records
  static Future<bool> clearAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      return true;
    } catch (e) {
      print('Failed to clear records: $e');
      return false;
    }
  }

  // Get storage status
  static Future<Map<String, dynamic>> getStorageStatus() async {
    try {
      final records = await getAllRecords();
      return {
        'synced': true,
        'recordCount': records.length,
      };
    } catch (e) {
      return {
        'synced': false,
        'recordCount': 0,
      };
    }
  }

  // Generate mock historical data
  static List<EnergyRecord> generateMockHistoricalData() {
    final List<EnergyRecord> data = [];
    final today = DateTime.now();

    // Generate last 90 days of data
    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));
      final totalUsage = (10 + (20 * (i % 30) / 30)).toDouble();
      final totalCost = totalUsage * 12;

      data.add(EnergyRecord(
        id: 'record-$i',
        date: date.toIso8601String().split('T')[0],
        totalUsage: double.parse(totalUsage.toStringAsFixed(2)),
        totalCost: double.parse(totalCost.toStringAsFixed(2)),
        activeDevices: 2 + (i % 3),
        peakUsage: double.parse((totalUsage / 24 * 1.5).toStringAsFixed(2)),
        averageUsage: double.parse((totalUsage / 24).toStringAsFixed(2)),
        devices: [
          DeviceUsage(
            name: 'Living Room AC',
            usage: double.parse((4 + (8 * (i % 10) / 10)).toStringAsFixed(2)),
            hours: 6 + (i % 12),
          ),
          DeviceUsage(
            name: 'Refrigerator',
            usage: double.parse((2 + (4 * (i % 8) / 8)).toStringAsFixed(2)),
            hours: 24,
          ),
          DeviceUsage(
            name: 'Smart TV',
            usage: double.parse((1 + (3 * (i % 6) / 6)).toStringAsFixed(2)),
            hours: 2 + (i % 8),
          ),
          DeviceUsage(
            name: 'LED Lights',
            usage: double.parse((0.5 + (2 * (i % 5) / 5)).toStringAsFixed(2)),
            hours: 4 + (i % 10),
          ),
        ],
      ));
    }

    return data;
  }

  // Initialize with mock data if empty
  static Future<void> initializeMockData() async {
    final existingRecords = await getAllRecords();
    if (existingRecords.isEmpty) {
      final mockData = generateMockHistoricalData();
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(mockData.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, jsonData);
    }
  }
}
