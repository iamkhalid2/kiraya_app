import 'package:flutter/material.dart';
import '../../../models/room.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with room number and type
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
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      room.type.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sections with dynamic layout
            Expanded(
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
    final availableSize = constraints.maxWidth;
    final itemSize = (availableSize - 24) / 2; // 24 for padding between items

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(12),
      children: room.sections.map((section) {
        final color = section.isOccupied ? Colors.orange : Colors.green;
        return Container(
          width: itemSize,
          height: itemSize,
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTripleLayout(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth;
    final availableHeight = constraints.maxHeight;
    final bottomPadding = availableHeight * 0.1; // 10% bottom padding
    final topPadding = availableHeight * 0.05; // 5% top padding
    final horizontalPadding = availableWidth * 0.1; // 10% side padding
    
    final circleSize = (availableWidth - (horizontalPadding * 2)) * 0.45; // 45% of available width

    return Stack(
      children: [
        // Top circle
        Positioned(
          top: topPadding,
          left: (availableWidth - circleSize) / 2,
          child: _buildSectionCircle(room.sections[0], circleSize),
        ),
        // Bottom left circle
        Positioned(
          bottom: bottomPadding,
          left: horizontalPadding,
          child: _buildSectionCircle(room.sections[1], circleSize),
        ),
        // Bottom right circle
        Positioned(
          bottom: bottomPadding,
          right: horizontalPadding,
          child: _buildSectionCircle(room.sections[2], circleSize),
        ),
      ],
    );
  }

  Widget _buildDefaultLayout(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth;
    final spacing = 8.0;
    final itemWidth = (availableWidth - (spacing * (room.sections.length - 1) + 24)) / room.sections.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: room.sections.map((section) => _buildSectionCircle(section, itemWidth)).toList(),
    );
  }

  Widget _buildSectionCircle(Section section, double size) {
    final color = section.isOccupied ? Colors.orange : Colors.green;
    return Container(
      width: size,
      height: size,
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
            fontSize: size > 40 ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color.shade700,
          ),
        ),
      ),
    );
  }
}
