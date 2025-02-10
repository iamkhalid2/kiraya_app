import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../services/stats_service.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tenantProvider = Provider.of<TenantProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context).settings;

    if (!tenantProvider.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tenants = tenantProvider.tenants;
    final totalTenants = StatsService.getTotalTenants(tenants);
    final monthlyIncome = StatsService.getTotalMonthlyIncome(tenants);
    final collectionRate = StatsService.getCollectionRate(tenants);
    final vacancyRate = StatsService.getVacancyRate(tenants, userSettings.totalRooms);
    final paymentDistribution = StatsService.getPaymentStatusDistribution(tenants);
    final revenueHistory = StatsService.getRevenueHistory(tenants);

    final maxRevenue = revenueHistory.isEmpty
        ? 1000.0
        : revenueHistory.fold<double>(
            0,
            (max, item) => item.value > max ? item.value : max,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Total Tenants',
                    value: totalTenants.toDouble(),
                    icon: Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Monthly Income',
                    value: monthlyIncome,
                    icon: Icons.attach_money,
                    color: theme.colorScheme.secondary,
                    isCurrency: true,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Collection Rate',
                    value: collectionRate,
                    icon: Icons.timeline,
                    color: theme.colorScheme.tertiary,
                    isPercentage: true,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Vacancy Rate',
                    value: vacancyRate,
                    icon: Icons.meeting_room,
                    color: theme.colorScheme.primary.withBlue(180),
                    isPercentage: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue History',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minX: -0.5,
                          maxX: revenueHistory.length - 0.5,
                          minY: 0,
                          maxY: maxRevenue * 1.2,
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: false,
                            horizontalInterval:
                                maxRevenue / 4 < 1 ? 1 : maxRevenue / 4,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: theme.dividerColor,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(),
                            topTitles: const AxisTitles(),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >=
                                      revenueHistory.length) {
                                    return const Text('');
                                  }
                                  final date =
                                      revenueHistory[value.toInt()].key;
                                  return Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      '${date.month}/${date.year}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: maxRevenue / 4 < 1
                                    ? 1
                                    : maxRevenue / 4,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '₹${value.toInt()}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          theme.colorScheme.onSurface,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                revenueHistory.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  revenueHistory[index].value,
                                ),
                              ),
                              isCurved: true,
                              color: theme.colorScheme.primary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor:
                                        theme.colorScheme.primary,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: theme.colorScheme.primary
                                    .withAlpha(26),
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
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Status',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusIndicator(
                          'Paid',
                          paymentDistribution['paid'] ?? 0,
                          theme.colorScheme.secondary,
                        ),
                        _buildStatusIndicator(
                          'Pending',
                          paymentDistribution['pending'] ?? 0,
                          theme.colorScheme.error,
                        ),
                        _buildStatusIndicator(
                          'Partial',
                          paymentDistribution['partial'] ?? 0,
                          theme.colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
