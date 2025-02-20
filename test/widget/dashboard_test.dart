import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../setup/test_setup.dart';

class TestDashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const TestDashboardCard({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Dashboard Widget Tests', () {
    testWidgets('should render dashboard grid layout', (WidgetTester tester) async {
      final dashboard = StaggeredGrid.count(
        crossAxisCount: 2,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: TestDashboardCard(
              title: 'Total Revenue',
              child: const Center(child: Text('\$5000')),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: TestDashboardCard(
              title: 'Occupancy Rate',
              child: const Center(child: Text('80%')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(dashboard));
      await tester.pumpAndSettle();

      expect(find.byType(StaggeredGrid), findsOneWidget);
      expect(find.byType(TestDashboardCard), findsNWidgets(2));
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(find.text('Occupancy Rate'), findsOneWidget);
    });

    testWidgets('should render line chart', (WidgetTester tester) async {
      final lineChart = SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(1, 1),
                  const FlSpot(2, 4),
                  const FlSpot(3, 2),
                ],
                isCurved: true,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(lineChart));
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('should render loading shimmer effect', (WidgetTester tester) async {
      final shimmerLoading = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
            ),
          ],
        ),
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(shimmerLoading));
      await tester.pump(); // Just pump once since we don't need to wait for animations

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('should render pie chart', (WidgetTester tester) async {
      final pieChart = SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: 40,
                color: Colors.blue,
                title: '40%',
              ),
              PieChartSectionData(
                value: 60,
                color: Colors.red,
                title: '60%',
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(pieChart));
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
    });
  });
}