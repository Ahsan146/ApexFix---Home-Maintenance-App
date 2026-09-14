import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'seed_data.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  FirebaseFirestore? _firestore;
  bool _isFirebaseReady = false;

  // Local reactive cache for instant responsiveness & offline resilience
  final Map<String, ServiceCategory> _categoriesCache = {};
  final Map<String, ServiceItem> _servicesCache = {};
  final Map<String, Technician> _techniciansCache = {};
  final Map<String, Customer> _customersCache = {};
  final Map<String, Booking> _bookingsCache = {};

  final _bookingsController = StreamController<List<Booking>>.broadcast();
  final _categoriesController = StreamController<List<ServiceCategory>>.broadcast();

  bool get isFirebaseReady => _isFirebaseReady;

  Future<void> initialize() async {
    // Populate local cache from SeedData first
    for (var cat in SeedData.categories) {
      _categoriesCache[cat.id] = cat;
    }
    for (var srv in SeedData.services) {
      _servicesCache[srv.id] = srv;
    }
    for (var tech in SeedData.technicians) {
      _techniciansCache[tech.id] = tech;
    }
    for (var cust in SeedData.customers) {
      _customersCache[cust.id] = cust;
    }
    for (var bk in SeedData.initialBookings) {
      _bookingsCache[bk.id] = bk;
    }

    _emitBookings();
    _categoriesController.add(_categoriesCache.values.toList());

    // Try connecting to Cloud Firestore
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseReady = true;
        debugPrint('[DatabaseService] Connected to Cloud Firestore successfully.');
        await _syncWithFirestore();
      } else {
        debugPrint('[DatabaseService] Firebase not initialized. Running on local resilient store.');
      }
    } catch (e) {
      debugPrint('[DatabaseService] Cloud Firestore connection notice: $e. Operating in local store.');
    }
  }

  Future<void> _syncWithFirestore() async {
    if (!_isFirebaseReady || _firestore == null) return;

    try {
      // 1. Seed categories if empty
      final catSnap = await _firestore!.collection('categories').limit(1).get();
      if (catSnap.docs.isEmpty) {
        debugPrint('[DatabaseService] Seeding initial categories into Cloud Firestore...');
        final batch = _firestore!.batch();
        for (var cat in SeedData.categories) {
          batch.set(_firestore!.collection('categories').doc(cat.id), cat.toMap());
        }
        for (var srv in SeedData.services) {
          batch.set(_firestore!.collection('services').doc(srv.id), srv.toMap());
        }
        for (var tech in SeedData.technicians) {
          batch.set(_firestore!.collection('technicians').doc(tech.id), tech.toMap());
        }
        for (var cust in SeedData.customers) {
          batch.set(_firestore!.collection('customers').doc(cust.id), cust.toMap());
        }
        for (var bk in SeedData.initialBookings) {
          batch.set(_firestore!.collection('bookings').doc(bk.id), bk.toMap());
        }
        await batch.commit();
        debugPrint('[DatabaseService] Cloud Firestore seeded successfully!');
      }

      // Listen to Firestore bookings updates in real-time
      _firestore!.collection('bookings').snapshots().listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          final bk = Booking.fromMap(data);
          _bookingsCache[bk.id] = bk;
        }
        _emitBookings();
      }, onError: (err) {
        debugPrint('[DatabaseService] Firestore bookings stream error: $err');
      });
    } catch (e) {
      debugPrint('[DatabaseService] Firestore sync error: $e');
    }
  }

  void _emitBookings() {
    final list = _bookingsCache.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _bookingsController.add(list);
  }

  // -------------------------------------------------------------
  // Stream & Query Methods
  // -------------------------------------------------------------
  Stream<List<ServiceCategory>> streamCategories() {
    return _categoriesController.stream;
  }

  List<ServiceCategory> getCategories() {
    return _categoriesCache.values.toList();
  }

  List<ServiceItem> getServicesForCategory(String categoryId) {
    return _servicesCache.values.where((s) => s.categoryId == categoryId).toList();
  }

  Stream<List<Booking>> streamCustomerBookings(String customerId) {
    return _bookingsController.stream.map(
      (list) => list.where((b) => b.customerId == customerId || b.customerId.startsWith('cust_')).toList(),
    );
  }

  Stream<Booking?> streamBooking(String bookingId) {
    return _bookingsController.stream.map(
      (list) => list.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => _bookingsCache[bookingId] ?? SeedData.initialBookings.first,
      ),
    );
  }

  List<Booking> getBookingsForCustomer(String customerId) {
    return _bookingsCache.values
        .where((b) => b.customerId == customerId || b.customerId.startsWith('cust_'))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // -------------------------------------------------------------
  // Write Methods
  // -------------------------------------------------------------
  Future<Booking> createBooking(Booking booking) async {
    _bookingsCache[booking.id] = booking;
    _emitBookings();

    if (_isFirebaseReady && _firestore != null) {
      try {
        await _firestore!.collection('bookings').doc(booking.id).set(booking.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Error saving booking to Firestore: $e');
      }
    }
    return booking;
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    Technician? tech,
    int? eta,
  }) async {
    final existing = _bookingsCache[bookingId];
    if (existing == null) return;

    final updated = existing.copyWith(
      status: status,
      technician: tech ?? existing.technician,
      technicianId: tech?.id ?? existing.technicianId,
      estimatedArrivalMinutes: eta ?? existing.estimatedArrivalMinutes,
      updatedAt: DateTime.now().toIso8601String(),
    );

    _bookingsCache[bookingId] = updated;
    _emitBookings();

    if (_isFirebaseReady && _firestore != null) {
      try {
        await _firestore!.collection('bookings').doc(bookingId).update({
          'status': status.name,
          if (tech != null) 'technician': tech.toMap(),
          if (tech != null) 'technicianId': tech.id,
          if (eta != null) 'estimatedArrivalMinutes': eta,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('[DatabaseService] Error updating booking in Firestore: $e');
      }
    }
  }

  Future<Customer?> getCustomer(String customerId) async {
    if (_customersCache.containsKey(customerId)) {
      return _customersCache[customerId];
    }
    if (_isFirebaseReady && _firestore != null) {
      try {
        final doc = await _firestore!.collection('customers').doc(customerId).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['id'] = doc.id;
          final cust = Customer.fromMap(data);
          _customersCache[cust.id] = cust;
          return cust;
        }
      } catch (e) {
        debugPrint('[DatabaseService] Error getting customer: $e');
      }
    }
    return null;
  }

  Future<void> saveCustomer(Customer customer) async {
    _customersCache[customer.id] = customer;
    if (_isFirebaseReady && _firestore != null) {
      try {
        await _firestore!.collection('customers').doc(customer.id).set(customer.toMap());
      } catch (e) {
        debugPrint('[DatabaseService] Error saving customer: $e');
      }
    }
  }

  List<Technician> getTechnicians() => _techniciansCache.values.toList();
}

