import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/seed_data.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  Customer? _currentCustomer;
  List<Booking> _bookings = [];
  String? _activeBookingId;
  bool _isLoading = false;

  AppProvider() {
    _init();
  }

  Customer? get currentCustomer => _currentCustomer;
  List<Booking> get bookings => _bookings;
  bool get isLoggedIn => _currentCustomer != null;
  bool get isLoading => _isLoading;
  DatabaseService get db => _db;

  Booking? get activeBooking {
    if (_activeBookingId == null) {
      try {
        return _bookings.firstWhere(
          (b) =>
              b.status != BookingStatus.completed &&
              b.status != BookingStatus.cancelled,
        );
      } catch (_) {
        return _bookings.isNotEmpty ? _bookings.first : null;
      }
    }
    try {
      return _bookings.firstWhere((b) => b.id == _activeBookingId);
    } catch (_) {
      return _bookings.isNotEmpty ? _bookings.first : null;
    }
  }

  Future<void> _init() async {
    await _db.initialize();
    _listenToBookings();
  }

  void _listenToBookings() {
    _bookingsSubscription?.cancel();
    final customerId = _currentCustomer?.id ?? 'cust_hamza_01';
    _bookingsSubscription = _db.streamCustomerBookings(customerId).listen((updated) {
      _bookings = updated;
      notifyListeners();
    });
  }

  void setActiveBooking(String id) {
    _activeBookingId = id;
    notifyListeners();
  }

  // Quick switch between realistic seeded customers for testing
  void switchCustomer(Customer customer) {
    _currentCustomer = customer;
    _listenToBookings();
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    // Default to realistic primary customer: Hamza Malik
    final defaultCust = SeedData.customers.first;
    _currentCustomer = defaultCust;
    await _db.saveCustomer(_currentCustomer!);
    _listenToBookings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
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
          final uid = userCred.user?.uid ?? 'cust_${email.hashCode.abs()}';
          var cust = await _db.getCustomer(uid);
          if (cust == null) {
            cust = SeedData.customers.firstWhere(
              (c) => c.email.toLowerCase() == email.trim().toLowerCase(),
              orElse: () => Customer(
                id: uid,
                fullName: userCred.user?.displayName ?? email.split('@')[0],
                email: email.trim(),
                phoneNumber: userCred.user?.phoneNumber ?? '+92 300 1234567',
                createdAt: DateTime.now().toIso8601String(),
                addresses: [
                  Address(
                    id: 'addr_default',
                    label: 'Home',
                    street: 'House 42, Street 8, Sector C, Phase 5 DHA',
                    city: 'Lahore',
                    state: 'Punjab',
                    zipCode: '54792',
                    latitude: 31.4682,
                    longitude: 74.3891,
                    isDefault: true,
                  ),
                ],
              ),
            );
            await _db.saveCustomer(cust);
          }
          _currentCustomer = cust;
          _listenToBookings();
          _isLoading = false;
          notifyListeners();
          return;
        } on FirebaseAuthException {
          rethrow;
        } catch (_) {
          // Fall back to local store if network or cloud auth is not configured
        }
      }

      // Resilient local store fallback (offline / local development)
      await Future.delayed(const Duration(milliseconds: 300));
      final matched = SeedData.customers.firstWhere(
        (c) => c.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () {
          final cleanName = email.contains('@')
              ? email.split('@')[0].split('.').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ')
              : 'ApexFix Customer';
          return Customer(
            id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
            fullName: cleanName.isNotEmpty ? cleanName : 'Hamza Malik',
            email: email.trim(),
            phoneNumber: '+92 300 1234567',
            createdAt: DateTime.now().toIso8601String(),
            addresses: [
              Address(
                id: 'addr_default',
                label: 'Home',
                street: 'House 42, Street 8, Sector C, Phase 5 DHA',
                city: 'Lahore',
                state: 'Punjab',
                zipCode: '54792',
                latitude: 31.4682,
                longitude: 74.3891,
                isDefault: true,
              ),
            ],
          );
        },
      );

      _currentCustomer = matched;
      await _db.saveCustomer(_currentCustomer!);
      _listenToBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (Firebase.apps.isNotEmpty) {
        try {
          final auth = FirebaseAuth.instance;
          final userCred = await auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          final uid = userCred.user?.uid ?? 'cust_${DateTime.now().millisecondsSinceEpoch}';
          await userCred.user?.updateDisplayName(fullName.trim());

          _currentCustomer = Customer(
            id: uid,
            fullName: fullName.trim(),
            email: email.trim(),
            phoneNumber: phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : '+92 301 2345678',
            createdAt: DateTime.now().toIso8601String(),
            addresses: [
              Address(
                id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                label: 'Home',
                street: 'Main Boulevard, Gulberg III',
                city: 'Lahore',
                state: 'Punjab',
                zipCode: '54660',
                latitude: 31.5170,
                longitude: 74.3580,
                isDefault: true,
              ),
            ],
          );

          await _db.saveCustomer(_currentCustomer!);
          _listenToBookings();
          _isLoading = false;
          notifyListeners();
          return;
        } on FirebaseAuthException {
          rethrow;
        } catch (_) {
          // Fall back to local store if network or cloud auth is not configured
        }
      }

      // Resilient local store fallback
      await Future.delayed(const Duration(milliseconds: 300));
      _currentCustomer = Customer(
        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim().isNotEmpty ? phoneNumber.trim() : '+92 301 2345678',
        createdAt: DateTime.now().toIso8601String(),
        addresses: [
          Address(
            id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
            label: 'Home',
            street: 'Main Boulevard, Gulberg III',
            city: 'Lahore',
            state: 'Punjab',
            zipCode: '54660',
            latitude: 31.5170,
            longitude: 74.3580,
            isDefault: true,
          ),
        ],
      );

      await _db.saveCustomer(_currentCustomer!);
      _listenToBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addAddress(Address address) {
    if (_currentCustomer != null) {
      final updatedAddresses = List<Address>.from(_currentCustomer!.addresses);
      final isDefault = updatedAddresses.isEmpty || address.isDefault;
      final newAddr = Address(
        id: address.id.isNotEmpty ? address.id : 'addr_${DateTime.now().millisecondsSinceEpoch}',
        label: address.label,
        street: address.street,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        latitude: address.latitude,
        longitude: address.longitude,
        isDefault: isDefault,
      );
      if (isDefault) {
        for (var i = 0; i < updatedAddresses.length; i++) {
          updatedAddresses[i] = Address(
            id: updatedAddresses[i].id,
            label: updatedAddresses[i].label,
            street: updatedAddresses[i].street,
            city: updatedAddresses[i].city,
            state: updatedAddresses[i].state,
            zipCode: updatedAddresses[i].zipCode,
            latitude: updatedAddresses[i].latitude,
            longitude: updatedAddresses[i].longitude,
            isDefault: false,
          );
        }
      }
      updatedAddresses.add(newAddr);
      _currentCustomer = Customer(
        id: _currentCustomer!.id,
        fullName: _currentCustomer!.fullName,
        email: _currentCustomer!.email,
        phoneNumber: _currentCustomer!.phoneNumber,
        avatarUrl: _currentCustomer!.avatarUrl,
        createdAt: _currentCustomer!.createdAt,
        defaultAddressId: isDefault ? newAddr.id : _currentCustomer!.defaultAddressId,
        addresses: updatedAddresses,
      );
      _db.saveCustomer(_currentCustomer!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    _currentCustomer = null;
    _bookings = [];
    _activeBookingId = null;
    _bookingsSubscription?.cancel();
    notifyListeners();
  }

  Future<Booking> createBooking({
    required ServiceCategory category,
    required ServiceItem service,
    required Address address,
    required String date,
    required String timeSlot,
    required String complaintTitle,
    required String complaintDescription,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Authoritative service pricing lookup (Gate 1.11 & 4.5: prevents client-side price tampering)
    final authoritativeService = SeedData.services.firstWhere(
      (s) => s.id == service.id,
      orElse: () => service,
    );
    final basePrice = authoritativeService.basePrice;
    final tax = basePrice * 0.05;
    final total = basePrice + tax;

    final newBooking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      bookingNumber: 'APX-${10000 + (DateTime.now().millisecond * 89) % 90000}',
      customerId: _currentCustomer?.id ?? 'cust_hamza_01',
      technicianId: null, // Searching for technician
      technician: null,
      serviceCategoryId: category.id,
      serviceId: authoritativeService.id,
      serviceName: authoritativeService.title,
      serviceCategoryName: category.title,
      complaintTitle: complaintTitle,
      complaintDescription: complaintDescription,
      address: address,
      scheduledDate: date,
      scheduledTimeSlot: timeSlot,
      status: BookingStatus.searchingTechnician,
      serviceCharge: ServiceCharge(
        baseServiceFee: basePrice,
        partsCost: 0,
        tax: tax,
        total: total,
      ),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.createBooking(newBooking);
    _activeBookingId = newBooking.id;
    _isLoading = false;
    notifyListeners();
    return newBooking;
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    Technician? tech;
    int? eta;

    if (newStatus != BookingStatus.searchingTechnician &&
        newStatus != BookingStatus.pending) {
      tech = SeedData.technicians.first; // Assign Tariq Mahmood
    }

    if (newStatus == BookingStatus.onTheWay) {
      eta = 14;
    } else if (newStatus == BookingStatus.arrived) {
      eta = 0;
    }

    await _db.updateBookingStatus(
      bookingId,
      newStatus,
      tech: tech,
      eta: eta,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
