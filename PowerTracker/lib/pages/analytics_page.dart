import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'week';

  final Map<String, List<Map<String, dynamic>>> _dataMap = {
    'day': [
      {'label': '00:00', 'value': 3.0},
      {'label': '04:00', 'value': 2.3},
      {'label': '08:00', 'value': 9.8},
      {'label': '12:00', 'value': 12.8},
      {'label': '16:00', 'value': 13.5},
      {'label': '20:00', 'value': 11.3},
    ],
    'week': [
      {'label': 'Mon', 'value': 12.8},
      {'label': 'Tue', 'value': 10.8},
      {'label': 'Wed', 'value': 13.5},
      {'label': 'Thu', 'value': 10.2},
      {'label': 'Fri', 'value': 14.3},
      {'label': 'Sat', 'value': 6.8},
      {'label': 'Sun', 'value': 9.0},
    ],
    'month': [
      {'label': 'Week 1', 'value': 85.4},
      {'label': 'Week 2', 'value': 89.6},
      {'label': 'Week 3', 'value': 82.1},
      {'label': 'Week 4', 'value': 96.2},
    ],
    'year': [
      {'label': 'Jan', 'value': 280.0},
      {'label': 'Feb', 'value': 260.0},
      {'label': 'Mar', 'value': 300.0},
      {'label': 'Apr', 'value': 320.0},
      {'label': 'May', 'value': 340.0},
      {'label': 'Jun', 'value': 360.0},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentData = _dataMap[_selectedPeriod]!;
    final totalUsage = currentData.fold<double>(
      0.0,
      (sum, item) => sum + (item['value'] as num).toDouble(),
    );
    final avgUsage = totalUsage / currentData.length;
    final maxUsage = currentData.map((d) => d['value'] as num).reduce((a, b) => a > b ? a : b).toDouble();
    final minUsage = currentData.map((d) => d['value'] as num).reduce((a, b) => a < b ? a : b).toDouble();
    final estimatedCost = totalUsage * 12;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                _buildPeriodButton('Day', 'day'),
                const SizedBox(width: 8),
                _buildPeriodButton('Week', 'week'),
                const SizedBox(width: 8),
                _buildPeriodButton('Month', 'month'),
                const SizedBox(width: 8),
                _buildPeriodButton('Year', 'year'),
              ],
            ),

            const SizedBox(height: 16),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    avgUsage.toStringAsFixed(1),
                    'kWh',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Peak',
                    maxUsage.toStringAsFixed(1),
                    'kWh',
                    Icons.flash_on,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Lowest',
                    minUsage.toStringAsFixed(1),
                    'kWh',
                    Icons.trending_down,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cost',
                    '₱${estimatedCost.toStringAsFixed(0)}',
                    'Estimated',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Energy Usage Graph
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Energy Usage Trend',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 5,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[200],
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey[200],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < currentData.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      currentData[index]['label'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: (currentData.length - 1).toDouble(),
                        minY: 0,
                        maxY: (maxUsage * 1.2),
                        lineBarsData: [
                          LineChartBarData(
                            spots: currentData.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                (entry.value['value'] as num).toDouble(),
                              );
                            }).toList(),
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.3),
                                  const Color(0xFF6366F1).withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
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

            const SizedBox(height: 20),

            // Energy Saving Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Energy Saving Tip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your peak usage is during mid-day. Consider reducing high-power devices during this time to save on your bill.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String suffix,
    IconData icon,
    Color color,
  ) {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
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
