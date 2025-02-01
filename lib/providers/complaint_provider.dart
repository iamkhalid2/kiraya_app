import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint.dart';
import '../services/firestore_service.dart';

class ComplaintProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Complaint> _complaints = [];
  String _searchQuery = '';
  bool _isLoading = false;
  Stream<List<Complaint>>? _complaintsStream;

  List<Complaint> get complaints => _searchQuery.isEmpty
      ? _complaints
      : _complaints
          .where((complaint) =>
              complaint.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              complaint.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  List<Complaint> getTenantComplaints(String tenantId) {
    return _complaints.where((complaint) => complaint.tenantId == tenantId).toList();
  }

  bool get isLoading => _isLoading;
  Stream<List<Complaint>>? get complaintsStream => _complaintsStream;

  ComplaintProvider() {
    // Initialize the stream
    _complaintsStream = _firestoreService.complaintsStream.map((snapshot) {
      return snapshot.docs.map((doc) {
        return Complaint.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    // Listen to stream updates
    _complaintsStream?.listen((complaints) {
      _complaints = complaints;
      notifyListeners();
    });
  }

  Future<void> addComplaint(Complaint complaint) async {
    try {
      await _firestoreService.addComplaint(complaint.toMap());
    } catch (e) {
      debugPrint('Error adding complaint: $e');
      rethrow;
    }
  }

  Future<void> updateComplaint(Complaint complaint) async {
    try {
      if (complaint.id == null) throw Exception('Complaint ID cannot be null');
      await _firestoreService.updateComplaint(complaint.id!, complaint.toMap());
    } catch (e) {
      debugPrint('Error updating complaint: $e');
      rethrow;
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await _firestoreService.deleteComplaint(id);
    } catch (e) {
      debugPrint('Error deleting complaint: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
