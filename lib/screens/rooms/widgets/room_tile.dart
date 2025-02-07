import 'package:flutter/material.dart';
import '../../../models/room.dart';

class RoomTile extends StatelessWidget {
  final Room room;

  const RoomTile({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Room sections
            CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: RoomSectionPainter(room: room),
            ),
            // Room info overlay
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Room number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Room ${room.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Room type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getRoomTypeText(room.occupantLimit),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
    );
  }

  String _getRoomTypeText(int occupantLimit) {
    switch (occupantLimit) {
      case 1:
        return 'Single Room';
      case 2:
        return 'Double Sharing';
      case 3:
        return 'Triple Sharing';
      case 4:
        return 'Four Sharing';
      default:
        return 'Unknown';
    }
  }
}

class RoomSectionPainter extends CustomPainter {
  final Room room;

  RoomSectionPainter({required this.room});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Calculate section dimensions based on occupant limit
    double sectionWidth = size.width;
    double sectionHeight = size.height;

    if (room.occupantLimit == 2) {
      sectionHeight = size.height / 2;
    } else if (room.occupantLimit == 3) {
      if (size.width > size.height) {
        sectionWidth = size.width / 3;
      } else {
        sectionHeight = size.height / 3;
      }
    } else if (room.occupantLimit == 4) {
      sectionWidth = size.width / 2;
      sectionHeight = size.height / 2;
    }

    // Draw sections
    for (int i = 0; i < room.occupantLimit; i++) {
      final section = room.sections[i];
      double left = 0;
      double top = 0;

      // Calculate position based on index and occupant limit
      if (room.occupantLimit == 2) {
        top = i * sectionHeight;
      } else if (room.occupantLimit == 3) {
        if (size.width > size.height) {
          left = i * sectionWidth;
        } else {
          top = i * sectionHeight;
        }
      } else if (room.occupantLimit == 4) {
        left = (i % 2) * sectionWidth;
        top = (i ~/ 2) * sectionHeight;
      }

      // Determine section color
      Color sectionColor;
      if (!section.isOccupied) {
        sectionColor = Colors.white;
      } else if (section.tenantId != null) {
        // TODO: Check actual tenant payment status
        sectionColor = Colors.green;
      } else {
        sectionColor = Colors.red;
      }

      // Draw section
      canvas.drawRect(
        Rect.fromLTWH(left, top, sectionWidth, sectionHeight),
        paint..color = sectionColor,
      );

      // Draw border
      canvas.drawRect(
        Rect.fromLTWH(left, top, sectionWidth, sectionHeight),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.grey[300]!
          ..strokeWidth = 1,
      );

      // Draw section label
      final textPainter = TextPainter(
        text: TextSpan(
          text: section.id,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          left + (sectionWidth - textPainter.width) / 2,
          top + (sectionHeight - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoomSectionPainter oldDelegate) {
    return oldDelegate.room != room;
  }
}
