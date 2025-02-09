import 'package:flutter/material.dart';

class KYCDocumentsSection extends StatelessWidget {
  final String? kycImage1;
  final String? kycImage2;
  final bool isSubmitting;
  final void Function(String) onKYC1Selected;
  final void Function(String) onKYC2Selected;

  const KYCDocumentsSection({
    super.key,
    this.kycImage1,
    this.kycImage2,
    required this.isSubmitting,
    required this.onKYC1Selected,
    required this.onKYC2Selected,
  });

  Widget _buildDocumentSlot({
    required String title,
    required String? imagePath,
    required VoidCallback onUpload,
  }) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: imagePath != null
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Text('No document'),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : onUpload,
          icon: const Icon(Icons.upload_file),
          label: Text(title),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KYC Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDocumentSlot(
                title: 'ID Proof 1',
                imagePath: kycImage1,
                onUpload: () => onKYC1Selected('dummy_path'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDocumentSlot(
                title: 'ID Proof 2',
                imagePath: kycImage2,
                onUpload: () => onKYC2Selected('dummy_path'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Please upload any government issued ID proof',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
