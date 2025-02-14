import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../models/room.dart';
import '../../../providers/tenant_provider.dart';
import '../room_details_screen.dart';

class RoomTile extends StatelessWidget {
  final Room room;

  const RoomTile({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoomDetailsScreen(room: room)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Room ${room.number}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      room.type.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed height container for sections
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) => _buildSections(constraints),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSections(BoxConstraints constraints) {
    switch (room.type) {
      case RoomType.quad:
        return _buildQuadLayout(constraints);
      case RoomType.triple:
        return _buildTripleLayout(constraints);
      default:
        return _buildDefaultLayout(constraints);
    }
  }

  Widget _buildQuadLayout(BoxConstraints constraints) {
    final availableSize = math.min(constraints.maxWidth, constraints.maxHeight) - 16;
    final itemSize = availableSize / 2.5; // Reduced from 2 to 2.5 for better spacing

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: room.sections.map((section) {
          return _buildSectionCircle(
            section,
            itemSize,
            scaleFactor: 1.0,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripleLayout(BoxConstraints constraints) {
  final width = constraints.maxWidth;
  final height = constraints.maxHeight;
  final circleSize = math.min(width, height) / 2.5; // Slightly smaller circles

  return Center(
    child: SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top circle
          Positioned(
            top: 0,
            child: _buildSectionCircle(room.sections[0], circleSize, scaleFactor: 0.9),
          ),
          // Bottom left circle
          Positioned(
            bottom: 4,
            left: width * 0.2, // Moved more to the left
            child: _buildSectionCircle(room.sections[1], circleSize, scaleFactor: 0.9),
          ),
          // Bottom right circle
          Positioned(
            bottom: 4,
            right: width * 0.2, // Moved more to the right
            child: _buildSectionCircle(room.sections[2], circleSize, scaleFactor: 0.9),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDefaultLayout(BoxConstraints constraints) {
    final itemCount = room.sections.length;
    final spacing = 16.0;
    final totalSpacing = spacing * (itemCount - 1);
    final itemWidth = (constraints.maxWidth - totalSpacing - 32) / itemCount;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: room.sections.map((section) {
          final widget = _buildSectionCircle(
            section,
            itemWidth,
            scaleFactor: 0.9,
          );
          
          if (section == room.sections.last) return widget;
          
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: widget,
          );
        }).toList(),
      ),
    );
  }

  Color _getSectionColor(BuildContext context, Section section) {
    if (!section.isOccupied) return Colors.grey;

    final tenant = Provider.of<TenantProvider>(context)
        .tenants
        .firstWhere((t) => t.id == section.tenantId);

    return switch (tenant.paymentStatus.toLowerCase()) {
      'paid' => Colors.green,
      'pending' => Colors.red,
      'partial' => Colors.orange,
      _ => Colors.grey,
    };
  }

  Widget _buildSectionCircle(
    Section section,
    double size,
    {double scaleFactor = 1.0}
  ) {
    return Consumer<TenantProvider>(
      builder: (context, provider, _) {
        final color = _getSectionColor(context, section);
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Container(
              width: size * scaleFactor,
              height: size * scaleFactor,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  section.id,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: math.min(size * 0.3, 14),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}