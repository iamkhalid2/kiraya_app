import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/hive_database.dart';

class ComplaintProvider with ChangeNotifier {
  List<Complaint> _complaints = [];
  String _searchQuery = '';
  bool _isLoading = false;

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

  Future<void> loadComplaints() async {
    _isLoading = true;
    notifyListeners();

    try {
      _complaints = await HiveDatabase.instance.getAllComplaints();
      _complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading complaints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComplaint(Complaint complaint) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newComplaint = await HiveDatabase.instance.createComplaint(complaint);
      _complaints.insert(0, newComplaint);
    } catch (e) {
      debugPrint('Error adding complaint: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComplaint(Complaint complaint) async {
    _isLoading = true;
    notifyListeners();

    try {
      await HiveDatabase.instance.updateComplaint(complaint);
      final index = _complaints.indexWhere((c) => c.id == complaint.id);
      if (index != -1) {
        _complaints[index] = complaint;
      }
    } catch (e) {
      debugPrint('Error updating complaint: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComplaint(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _complaints.removeWhere((complaint) => complaint.id == id);
      notifyListeners();
      
      await HiveDatabase.instance.deleteComplaint(id);
    } catch (e) {
      debugPrint('Error deleting complaint: $e');
      await loadComplaints();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
