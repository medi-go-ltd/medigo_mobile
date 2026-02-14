import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';

class EarningsByTypeSection extends StatelessWidget {
  static const _chartPalette = [
    AppColors.primary,
    AppColors.accent,
    Color(0xFF26A69A),
    Color(0xFF00897B),
  ];

  const EarningsByTypeSection({super.key, required this.byDescription});

  final Map<String, double> byDescription;

  @override
  Widget build(BuildContext context) {
    final total = byDescription.values.fold(0.0, (a, b) => a + b);
    final entries = byDescription.entries.toList();
    if (total <= 0) return const SizedBox.shrink();

    final sections = entries.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final color = _chartPalette[i % _chartPalette.length];
      return PieChartSectionData(
        value: e.value,
        color: color,
        title: '',
        showTitle: false,
        radius: 60,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earnings by type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final color = _chartPalette[i % _chartPalette.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '£${e.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
