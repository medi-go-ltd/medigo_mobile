import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medigo_mobile/theme/app_theme.dart';
import 'package:medigo_mobile/view_models/doctor_home_view_model.dart';
import 'package:medigo_mobile/widgets/scale_on_tap.dart';

class EarningsChartSection extends StatelessWidget {
  const EarningsChartSection({
    super.key,
    required this.chartData,
    required this.chartDays,
    required this.onChartDaysChanged,
  });

  final List<DayEarnings> chartData;
  final int chartDays;
  final ValueChanged<int> onChartDaysChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Earnings over time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _ChartPeriodChip(
                    label: '7D',
                    days: 7,
                    selected: chartDays == 7,
                    onTap: () => onChartDaysChanged(7),
                  ),
                  _ChartPeriodChip(
                    label: '30D',
                    days: 30,
                    selected: chartDays == 30,
                    onTap: () => onChartDaysChanged(30),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: chartData.isEmpty
              ? const Center(
                  child: Text(
                    'No earnings in this period',
                    style: AppTypography.bodySecondary,
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (chartData
                                .map((e) => e.amount)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2)
                        .clamp(10, double.infinity),
                    barTouchData: const BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => Text(
                            '£${value.toInt()}',
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= chartData.length) {
                              return const SizedBox.shrink();
                            }
                            final count = chartData.length;
                            final step = count > 10 ? (count / 5).ceil() : 1;
                            if (step > 1 && i % step != 0) {
                              return const SizedBox.shrink();
                            }
                            final d = chartData[i].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${d.day}/${d.month}',
                                style: AppTypography.bodySecondary.copyWith(
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppColors.border,
                        strokeWidth: 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: chartData.asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.amount,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.7),
                                AppColors.primary,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      );
                    }).toList(),
                  ),
                  duration: const Duration(milliseconds: 200),
                ),
        ),
      ],
    );
  }
}

class _ChartPeriodChip extends StatelessWidget {
  const _ChartPeriodChip({
    required this.label,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int days;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
