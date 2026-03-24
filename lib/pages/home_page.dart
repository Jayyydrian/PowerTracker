import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, dynamic>> devices;
  final void Function(int index) onToggle;
  final void Function(Map<String, dynamic> device) onAdd;
  final void Function(int index) onRemove;

  const HomePage({
    Key? key,
    required this.devices,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isRemoveMode = false;

  // Philippine average rate: ₱10.00 per kWh (Meralco approx.)
  static const double _ratePerKwh = 10.00;
  // Assume all active devices run 24h/day for 30 days
  static const double _hoursPerMonth = 24 * 30;

  int get _totalUsage => widget.devices.fold(
        0,
        (sum, d) => sum + ((d['isOn'] as bool) ? (d['power'] as int) : 0),
      );

  // kWh = (totalWatts / 1000) * hours
  double get _monthlyKwh => (_totalUsage / 1000) * _hoursPerMonth;

  // Estimated bill = kWh * rate
  double get _estimatedBill => _monthlyKwh * _ratePerKwh;

  void _showBillBreakdown() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bill Breakdown'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assumes devices run 24 hrs/day for 30 days at ₱${_ratePerKwh.toStringAsFixed(2)}/kWh.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // Per-device breakdown
              ...widget.devices
                  .where((d) => d['isOn'] as bool)
                  .map((d) {
                final watts = d['power'] as int;
                final kwh = (watts / 1000) * _hoursPerMonth;
                final cost = kwh * _ratePerKwh;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          d['name'] as String,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₱${cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total kWh',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('${_monthlyKwh.toStringAsFixed(2)} kWh',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Bill',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    '₱${_estimatedBill.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _AddDeviceDialog(
        onDeviceAdded: (device) => widget.onAdd(device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devices = widget.devices;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Current Usage Card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.white, size: 32),
                    Text(
                      'Real-time',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${_totalUsage}W',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Usage',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Estimated Bill Card ─────────────────────────────────────────
          GestureDetector(
            onTap: _showBillBreakdown,
            child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.attach_money,
                        color: Colors.white, size: 32),
                    Row(
                      children: [
                        Text(
                          'Monthly Est.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9), fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.info_outline,
                            color: Colors.white.withOpacity(0.8), size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '₱${_estimatedBill.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_monthlyKwh.toStringAsFixed(2)} kWh · tap for breakdown',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimated Bill',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
          ),

          const SizedBox(height: 24),

          // ── Quick Controls Header ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Controls',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => _isRemoveMode = !_isRemoveMode),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Text(_isRemoveMode ? 'Done' : 'Remove'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRemoveMode ? Colors.red : Colors.grey[300],
                      foregroundColor:
                          _isRemoveMode ? Colors.white : Colors.grey[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddDeviceDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Device Grid ─────────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isOn = device['isOn'] as bool;
              final color = device['color'] as Color;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap:
                        _isRemoveMode ? null : () => widget.onToggle(index),
                    child: Opacity(
                      opacity: _isRemoveMode ? 0.75 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isOn ? Colors.white : Colors.grey[50],
                          border: Border.all(
                            color: isOn
                                ? const Color(0xFF6366F1)
                                : Colors.grey[200]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(isOn ? 0.2 : 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                device['icon'] as IconData,
                                color: isOn ? color : Colors.grey[400],
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              device['name'] as String,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOn
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isOn ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isOn
                                          ? Colors.green[700]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOn ? '${device['power']}W' : '0W',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isRemoveMode)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => widget.onRemove(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Add Device Dialog ────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _availableIcons = [
  {'icon': Icons.ac_unit,               'color': Colors.blue},
  {'icon': Icons.kitchen,               'color': Colors.green},
  {'icon': Icons.tv,                    'color': Colors.purple},
  {'icon': Icons.lightbulb,             'color': Colors.amber},
  {'icon': Icons.microwave,             'color': Colors.orange},
  {'icon': Icons.water_drop,            'color': Colors.cyan},
  {'icon': Icons.computer,              'color': Colors.indigo},
  {'icon': Icons.speaker,               'color': Colors.pink},
  {'icon': Icons.iron,                  'color': Colors.teal},
  {'icon': Icons.heat_pump,             'color': Colors.red},
  {'icon': Icons.router,                'color': Colors.blueGrey},
  {'icon': Icons.local_laundry_service, 'color': Colors.teal},
];

class _AddDeviceDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onDeviceAdded;
  const _AddDeviceDialog({required this.onDeviceAdded});

  @override
  State<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<_AddDeviceDialog> {
  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  final _roomController = TextEditingController();
  int _selectedIconIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _powerController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _powerController.text.isEmpty ||
        _roomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red),
      );
      return;
    }
    final selected = _availableIcons[_selectedIconIndex];
    widget.onDeviceAdded({
      'name': _nameController.text.trim(),
      'room': _roomController.text.trim(),
      'power': int.tryParse(_powerController.text) ?? 0,
      'icon': selected['icon'],
      'color': selected['color'],
      'isOn': false,
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add New Device'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Device Name',
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Bedroom Fan',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Room',
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _roomController,
                decoration: InputDecoration(
                  hintText: 'e.g., Bedroom',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Power Consumption (Watts)',
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _powerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 75',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Icon',
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final option = _availableIcons[index];
                  final isSelected = _selectedIconIndex == index;
                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedIconIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? const Color(0xFFEEF2FF)
                            : Colors.white,
                      ),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: option['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(option['icon'] as IconData,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              Text('Cancel', style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Add Device'),
        ),
      ],
    );
  }
}