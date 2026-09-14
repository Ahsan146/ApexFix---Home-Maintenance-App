import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/seed_data.dart';
import '../services/technician_database_service.dart';

class TechnicianProvider extends ChangeNotifier {
  final TechnicianDatabaseService _db = TechnicianDatabaseService.instance;

  StreamSubscription<List<TechJob>>? _incomingSub;
  StreamSubscription<TechJob?>? _activeSub;
  StreamSubscription<List<TechJob>>? _historySub;

  Technician? _currentTechnician;
  bool _isLoading = false;

  List<TechJob> _incomingRequests = [];
  TechJob? _activeJob;
  List<TechJob> _jobsHistory = [];

  TechnicianProvider() {
    _init();
  }

  Technician? get currentTechnician => _currentTechnician;
  bool get isLoggedIn => _currentTechnician != null;
  bool get isLoading => _isLoading;
  bool get isOnline => _currentTechnician?.availability == TechnicianAvailability.online;

  List<TechJob> get incomingRequests => _incomingRequests;
  TechJob? get activeJob => _activeJob;
  List<TechJob> get jobsHistory => _jobsHistory;
  TechnicianDatabaseService get db => _db;

  Future<void> _init() async {
    await _db.initialize();

    _incomingSub = _db.streamIncomingJobs().listen((jobs) {
      if (isOnline) {
        _incomingRequests = jobs;
      } else {
        _incomingRequests = [];
      }
      notifyListeners();
    });

    _activeSub = _db.streamActiveJob().listen((job) {
      _activeJob = job;
      notifyListeners();
    });

    _historySub = _db.streamJobsHistory().listen((history) {
      _jobsHistory = history;
      notifyListeners();
    });

    // Populate initial views from local cache
    _incomingRequests = isOnline ? _db.getIncomingJobs() : [];
    _jobsHistory = _db.getJobsHistory();
  }

  void switchTechnician(Technician tech) {
    _currentTechnician = tech;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (Firebase.apps.isNotEmpty) {
        try {
          final auth = FirebaseAuth.instance;
          final userCred = await auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          final uid = userCred.user?.uid ?? 'tech_${email.hashCode.abs()}';
          final matched = SeedData.technicians.firstWhere(
            (t) => t.email.toLowerCase() == email.trim().toLowerCase(),
            orElse: () => SeedData.technicians.first.copyWith(id: uid, email: email.trim()),
          );
          _currentTechnician = matched;
          _incomingRequests = isOnline ? _db.getIncomingJobs() : [];
          _jobsHistory = _db.getJobsHistory();
          _isLoading = false;
          notifyListeners();
          return;
        } on FirebaseAuthException {
          rethrow;
        } catch (_) {
          // Fall back to local store
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));
      final matched = SeedData.technicians.firstWhere(
        (t) => t.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => SeedData.technicians.first,
      );

      _currentTechnician = matched;
      _incomingRequests = isOnline ? _db.getIncomingJobs() : [];
      _jobsHistory = _db.getJobsHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required List<String> specialties,
    required String vehicleInfo,
    required String bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String uid = 'tech_${DateTime.now().millisecondsSinceEpoch}';
      if (Firebase.apps.isNotEmpty) {
        try {
          final auth = FirebaseAuth.instance;
          final userCred = await auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: 'password123',
          );
          uid = userCred.user?.uid ?? uid;
          await userCred.user?.updateDisplayName(fullName.trim());
        } catch (_) {}
      }

      _currentTechnician = Technician(
        id: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : '+92 300 4567891',
        specialties: specialties.isNotEmpty ? specialties : ['AC & Cooling', 'HVAC Diagnostics'],
        rating: 5.0,
        reviewCount: 0,
        completedJobsCount: 0,
        availability: TechnicianAvailability.online,
        vehicleInfo: vehicleInfo.trim().isNotEmpty ? vehicleInfo.trim() : 'Honda CD 70',
        bio: bio.trim().isNotEmpty ? bio.trim() : 'Certified ApexFix Specialist',
        todayEarnings: 0.0,
        totalWalletBalance: 0.0,
        isVerified: true,
      );

      _incomingRequests = _db.getIncomingJobs();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleAvailability() {
    if (_currentTechnician == null) return;
    final newAvailability = isOnline
        ? TechnicianAvailability.offline
        : TechnicianAvailability.online;

    _currentTechnician = _currentTechnician!.copyWith(availability: newAvailability);
    if (!isOnline) {
      _incomingRequests = [];
    } else {
      _incomingRequests = _db.getIncomingJobs();
    }
    notifyListeners();
  }

  void simulateIncomingJob() {
    if (!isOnline || _activeJob != null) return;

    final id = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    final job = TechJob(
      id: id,
      bookingNumber: 'APX-${80000 + (_incomingRequests.length * 137) % 9999}',
      customerName: 'Ayesha Khan',
      customerPhone: '+92 322 8765432',
      serviceCategoryId: 'cat_hvac',
      serviceCategoryName: 'AC & Cooling',
      serviceName: 'Inverter AC Deep Jet Wash & Coil Cleaning',
      complaintTitle: 'AC cooling weak & water dripping',
      complaintDescription: 'Indoor split unit dripping water from right side casing; coils and filters need high-pressure jet wash.',
      address: Address(
        id: 'addr_ayesha',
        label: 'Apartment',
        street: 'Apt 304, Gulberg Heights, Main Boulevard Gulberg II',
        city: 'Lahore',
        state: 'Punjab',
        zipCode: '54660',
        latitude: 31.5170,
        longitude: 74.3580,
      ),
      scheduledDate: 'Today',
      scheduledTimeSlot: 'Immediate (Rapid Dispatch)',
      status: BookingStatus.searchingTechnician,
      serviceCharge: ServiceCharge(
        baseServiceFee: 2500,
        tax: 125,
        total: 2625,
      ),
      technicianPayout: 2100.0,
      createdAt: DateTime.now().toIso8601String(),
    );

    _db.addSimulatedIncomingJob(job);
  }

  Future<void> acceptJob(TechJob job) async {
    if (_currentTechnician == null) return;
    await _db.acceptJob(job, _currentTechnician!);
  }

  void declineJob(String jobId) {
    _db.declineJob(jobId);
  }

  Future<void> updateActiveJobStatus(BookingStatus newStatus) async {
    if (_activeJob == null) return;

    final payout = _activeJob!.technicianPayout;

    await _db.updateActiveJobStatus(newStatus);

    if (newStatus == BookingStatus.completed && _currentTechnician != null) {
      _currentTechnician = _currentTechnician!.copyWith(
        todayEarnings: _currentTechnician!.todayEarnings + payout,
        totalWalletBalance: _currentTechnician!.totalWalletBalance + payout,
        completedJobsCount: _currentTechnician!.completedJobsCount + 1,
      );
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _currentTechnician = null;
    _activeJob = null;
    _incomingRequests.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    _activeSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
