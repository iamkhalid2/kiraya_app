import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../room_details_screen.dart';

class RoomTile extends StatelessWidget {
  final Room room;
  
  const RoomTile({
    super.key,
    required this.room,
  });

  Color _getSectionColor(Section section) {
    if (!section.isOccupied) {
      return Colors.grey.shade200;  // Vacant
    }
    return Colors.green.shade100;
  }

  double _getSectionSize(BuildContext context, BoxConstraints constraints, RoomType type) {
    final baseSize = constraints.maxWidth / 2 - 12;
    return switch (type) {
      RoomType.single || RoomType.double => baseSize,
      RoomType.triple || RoomType.quad => baseSize * 0.65, // Reduced to 65% for better fit
    };
  }

  EdgeInsetsGeometry _getSectionPadding(RoomType type) {
    return switch (type) {
      RoomType.single || RoomType.double => const EdgeInsets.all(16),
      RoomType.triple || RoomType.quad => const EdgeInsets.all(8), // Less padding for triple and quad
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(room: room),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.primaryColor.withOpacity(0.1),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
            Expanded(
              child: Padding(
                padding: _getSectionPadding(room.type),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = _getSectionSize(context, constraints, room.type);
                    
                    return Wrap(
                      spacing: room.type == RoomType.triple || room.type == RoomType.quad ? 4 : 8,
                      runSpacing: room.type == RoomType.triple || room.type == RoomType.quad ? 4 : 8,
                      alignment: WrapAlignment.center,
                      children: room.sections.map((section) {
                        return SizedBox(
                          width: size,
                          height: size,
                          child: Material(
                            color: _getSectionColor(section),
                            shape: const CircleBorder(),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    section.id,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: room.type == RoomType.triple || room.type == RoomType.quad 
                                          ? 16 // Even smaller font for triple and quad
                                          : null,
                                    ),
                                  ),
                                  if (section.isOccupied && section.tenantName != null)
                                    Text(
                                      section.tenantName!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.black45,
                                        fontSize: room.type == RoomType.triple || room.type == RoomType.quad 
                                            ? 9 // Even smaller font for triple and quad
                                            : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.primaryColor.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${room.occupiedCount}/${room.occupantLimit} Occupied',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (room.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Vacant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (room.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Full',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
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
}
