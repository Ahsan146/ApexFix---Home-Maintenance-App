import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'seed_data.dart';

class TechnicianDatabaseService {
  TechnicianDatabaseService._privateConstructor();
  static final TechnicianDatabaseService instance = TechnicianDatabaseService._privateConstructor();

  FirebaseFirestore? _firestore;
  bool _isFirebaseReady = false;

  final Map<String, TechJob> _incomingJobsCache = {};
  final Map<String, TechJob> _jobsHistoryCache = {};
  TechJob? _activeJob;

  final _incomingController = StreamController<List<TechJob>>.broadcast();
  final _activeJobController = StreamController<TechJob?>.broadcast();
  final _historyController = StreamController<List<TechJob>>.broadcast();

  bool get isFirebaseReady => _isFirebaseReady;
  TechJob? get activeJob => _activeJob;

  Future<void> initialize() async {
    // Populate cache with rich seed data
    for (var job in SeedData.initialIncomingJobs) {
      _incomingJobsCache[job.id] = job;
    }
    for (var hist in SeedData.initialJobsHistory) {
      _jobsHistoryCache[hist.id] = hist;
    }

    _emitIncoming();
    _emitHistory();

    // Check Cloud Firestore connection
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseReady = true;
        debugPrint('[TechnicianDatabaseService] Connected to Cloud Firestore.');
        await _listenToFirestoreBookings();
      } else {
        debugPrint('[TechnicianDatabaseService] Operating in local resilient store.');
      }
    } catch (e) {
      debugPrint('[TechnicianDatabaseService] Firestore connection notice: $e');
    }
  }

  Future<void> _listenToFirestoreBookings() async {
    if (!_isFirebaseReady || _firestore == null) return;

    try {
      // Listen to searching bookings
      _firestore!
          .collection('bookings')
          .where('status', isEqualTo: 'searchingTechnician')
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final job = TechJob.fromMap(data);
          _incomingJobsCache[job.id] = job;
        }
        _emitIncoming();
      }, onError: (err) {
        debugPrint('[TechnicianDatabaseService] Incoming bookings stream error: $err');
      });
    } catch (e) {
      debugPrint('[TechnicianDatabaseService] Error setting up stream: $e');
    }
  }

  void _emitIncoming() {
    final list = _incomingJobsCache.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _incomingController.add(list);
  }

  void _emitHistory() {
    final list = _jobsHistoryCache.values.toList()
      ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
    _historyController.add(list);
  }

  // -------------------------------------------------------------
  // Streams
  // -------------------------------------------------------------
  Stream<List<TechJob>> streamIncomingJobs() => _incomingController.stream;
  Stream<TechJob?> streamActiveJob() => _activeJobController.stream;
  Stream<List<TechJob>> streamJobsHistory() => _historyController.stream;

  List<TechJob> getIncomingJobs() => _incomingJobsCache.values.toList();
  List<TechJob> getJobsHistory() => _jobsHistoryCache.values.toList();

  // -------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------
  Future<void> acceptJob(TechJob job, Technician tech) async {
    _incomingJobsCache.remove(job.id);
    _emitIncoming();

    final acceptedJob = job.copyWith(
      status: BookingStatus.accepted,
      acceptedAt: DateTime.now().toIso8601String(),
    );

    _activeJob = acceptedJob;
    _activeJobController.add(_activeJob);

    if (_isFirebaseReady && _firestore != null) {
      try {
        await _firestore!.collection('bookings').doc(job.id).update({
          'status': 'accepted',
          'technicianId': tech.id,
          'technician': tech.toMap(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('[TechnicianDatabaseService] Error updating booking in Firestore: $e');
      }
    }
  }

  void declineJob(String jobId) {
    _incomingJobsCache.remove(jobId);
    _emitIncoming();
  }

  Future<void> updateActiveJobStatus(BookingStatus newStatus) async {
    if (_activeJob == null) return;

    final jobId = _activeJob!.id;

    if (newStatus == BookingStatus.completed) {
      final finished = _activeJob!.copyWith(
        status: BookingStatus.completed,
        completedAt: DateTime.now().toIso8601String(),
        customerRating: 5.0,
        customerReview: 'Excellent service! Quick diagnosis and very clean workmanship.',
      );

      _jobsHistoryCache[finished.id] = finished;
      _activeJob = null;
      _activeJobController.add(null);
      _emitHistory();

      if (_isFirebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('bookings').doc(jobId).update({
            'status': 'completed',
            'completedAt': finished.completedAt,
            'customerRating': finished.customerRating,
            'customerReview': finished.customerReview,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('[TechnicianDatabaseService] Error marking completed in Firestore: $e');
        }
      }
    } else {
      _activeJob = _activeJob!.copyWith(status: newStatus);
      _activeJobController.add(_activeJob);

      if (_isFirebaseReady && _firestore != null) {
        try {
          await _firestore!.collection('bookings').doc(jobId).update({
            'status': newStatus.name,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('[TechnicianDatabaseService] Error updating status in Firestore: $e');
        }
      }
    }
  }

  void addSimulatedIncomingJob(TechJob job) {
    _incomingJobsCache[job.id] = job;
    _emitIncoming();
  }
}

