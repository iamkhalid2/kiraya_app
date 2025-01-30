import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../providers/tenant_provider.dart';
import '../../services/stats_service.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TenantProvider>(
      builder: (context, tenantProvider, child) {
        final tenants = tenantProvider.tenants;
        final totalRooms = 20; // This should come from settings/configuration

        final totalTenants = StatsService.getTotalTenants(tenants);
        final monthlyIncome = StatsService.getTotalMonthlyIncome(tenants);
        final collectionRate = StatsService.getCollectionRate(tenants);
        final vacancyRate = StatsService.getVacancyRate(tenants, totalRooms);
        final currentMonthCollection = StatsService.getCurrentMonthCollection(tenants);
        final paymentDistribution = StatsService.getPaymentStatusDistribution(tenants);
        final revenueHistory = StatsService.getRevenueHistory(tenants);

        // Calculate max revenue for chart Y-axis
        final maxRevenue = revenueHistory.isEmpty
            ? 1000.0 // Default value when no data
            : revenueHistory.fold<double>(
                0,
                (max, item) => item.value > max ? item.value : max,
              );

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => tenantProvider.loadTenants(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: [
                      StaggeredGridTile.fit(
                        crossAxisCellCount: 1,
                        child: StatCard(
                          title: 'Total Tenants',
                          value: totalTenants.toDouble(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),
                      StaggeredGridTile.fit(
                        crossAxisCellCount: 1,
                        child: StatCard(
                          title: 'Monthly Income',
                          value: monthlyIncome,
                          icon: Icons.attach_money,
                          color: Colors.green,
                          isCurrency: true,
                        ),
                      ),
                      StaggeredGridTile.fit(
                        crossAxisCellCount: 1,
                        child: StatCard(
                          title: 'Collection Rate',
                          value: collectionRate,
                          icon: Icons.timeline,
                          color: Colors.orange,
                          isPercentage: true,
                        ),
                      ),
                      StaggeredGridTile.fit(
                        crossAxisCellCount: 1,
                        child: StatCard(
                          title: 'Vacancy Rate',
                          value: vacancyRate,
                          icon: Icons.home_work,
                          color: Colors.purple,
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 24,
                              top: 8,
                              bottom: 12,
                            ),
                            child: SizedBox(
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
                                    horizontalInterval: maxRevenue / 4 < 1 ? 1 : maxRevenue / 4,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300],
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
                                          if (value.toInt() >= revenueHistory.length) {
                                            return const Text('');
                                          }
                                          final date = revenueHistory[value.toInt()].key;
                                          return Transform.rotate(
                                            angle: -0.5,
                                            child: SizedBox(
                                              width: 40,
                                              child: Text(
                                                '${date.month}/${date.year}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
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
                                        interval: maxRevenue / 4 < 1 ? 1 : maxRevenue / 4,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              '₹${value.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                      color: Theme.of(context).primaryColor,
                                      barWidth: 3,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: Colors.white,
                                            strokeWidth: 2,
                                            strokeColor: Theme.of(context).primaryColor,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                      ),
                                    ),
                                  ],
                                ),
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusIndicator(
                                'Paid',
                                paymentDistribution['paid'] ?? 0,
                                Colors.green,
                              ),
                              _buildStatusIndicator(
                                'Pending',
                                paymentDistribution['pending'] ?? 0,
                                Colors.red,
                              ),
                              _buildStatusIndicator(
                                'Partial',
                                paymentDistribution['partial'] ?? 0,
                                Colors.orange,
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
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
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
