import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/room_provider.dart';
import '../../services/stats_service.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tenantProvider = Provider.of<TenantProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    if (!tenantProvider.isInitialized || !roomProvider.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tenants = tenantProvider.tenants;
    final rooms = roomProvider.rooms;
    final totalTenants = StatsService.getTotalTenants(tenants);
    final monthlyIncome = StatsService.getTotalMonthlyIncome(tenants);
    final collectionRate = StatsService.getCollectionRate(tenants);
    final vacancyRate = StatsService.getVacancyRate(tenants, rooms);
    final paymentDistribution = StatsService.getPaymentStatusDistribution(tenants);
    final revenueHistory = StatsService.getRevenueHistory(tenants);

    final maxRevenue = revenueHistory.isEmpty
        ? 1000.0
        : revenueHistory.fold<double>(
            0,
            (max, item) => item.value > max ? item.value : max,
          );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Dashboard',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Analytics & Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
                    title: 'Tenants',
                    value: totalTenants.toDouble(),
                    icon: Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Income',
                    value: monthlyIncome,
                    icon: Icons.attach_money,
                    color: theme.colorScheme.secondary,
                    isCurrency: true,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Collection %',
                    value: collectionRate,
                    icon: Icons.timeline,
                    color: theme.colorScheme.tertiary,
                    isPercentage: true,
                  ),
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 1,
                  child: StatCard(
                    title: 'Vacancy %',
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
                        _PaymentStatusIndicator(
                          label: 'Paid',
                          value: paymentDistribution['paid'] ?? 0,
                          color: Colors.green,
                        ),
                        _PaymentStatusIndicator(
                          label: 'Pending',
                          value: paymentDistribution['pending'] ?? 0,
                          color: Colors.red,
                        ),
                        _PaymentStatusIndicator(
                          label: 'Partial',
                          value: paymentDistribution['partial'] ?? 0,
                          color: Colors.orange,
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
}

class _PaymentStatusIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _PaymentStatusIndicator({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
