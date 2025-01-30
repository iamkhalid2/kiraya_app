import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/complaint_provider.dart';
import '../../models/complaint.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
        if (complaintProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final complaints = complaintProvider.complaints;

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No complaints found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => complaintProvider.loadComplaints(),
          child: ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return _buildComplaintCard(context, complaint, complaintProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    Complaint complaint,
    ComplaintProvider provider,
  ) {
    Color statusColor;
    switch (complaint.status.toLowerCase()) {
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'pending':
      default:
        statusColor = Colors.red;
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          if (complaint.status.toLowerCase() != 'resolved')
            SlidableAction(
              onPressed: (_) async {
                final updatedComplaint = complaint.copyWith(
                  status: 'Resolved',
                );
                await provider.updateComplaint(updatedComplaint);
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.check,
              label: 'Resolve',
            ),
          SlidableAction(
            onPressed: (_) async {
              // Show confirmation dialog
              final delete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Complaint'),
                  content: const Text(
                    'Are you sure you want to delete this complaint?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (delete == true && complaint.id != null) {
                await provider.deleteComplaint(complaint.id!);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(complaint.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                complaint.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                timeago.format(complaint.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              complaint.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
