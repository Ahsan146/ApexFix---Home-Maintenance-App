// ApexFix Pro - Technician Data Models

enum BookingStatus {
  pending,
  searchingTechnician,
  technicianAssigned,
  accepted,
  onTheWay,
  arrived,
  workInProgress,
  completed,
  cancelled,
  rejected,
  disputed,
}

enum TechnicianAvailability {
  offline,
  online,
  busy,
  onBreak,
}

class Address {
  final String id;
  final String label;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };

  factory Address.fromMap(Map<String, dynamic> map) => Address(
        id: map['id'] ?? '',
        label: map['label'] ?? 'Home',
        street: map['street'] ?? '',
        city: map['city'] ?? '',
        state: map['state'] ?? '',
        zipCode: map['zipCode'] ?? '',
        latitude: (map['latitude'] as num?)?.toDouble() ?? 31.5204,
        longitude: (map['longitude'] as num?)?.toDouble() ?? 74.3587,
        isDefault: map['isDefault'] ?? false,
      );
}

class ServiceCharge {
  final double baseServiceFee;
  final double tax;
  final double total;
  final double partsFee;

  ServiceCharge({
    required this.baseServiceFee,
    required this.tax,
    required this.total,
    this.partsFee = 0,
  });

  Map<String, dynamic> toMap() => {
        'baseServiceFee': baseServiceFee,
        'tax': tax,
        'total': total,
        'partsFee': partsFee,
      };

  factory ServiceCharge.fromMap(Map<String, dynamic> map) => ServiceCharge(
        baseServiceFee: (map['baseServiceFee'] as num?)?.toDouble() ?? 0.0,
        tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        partsFee: (map['partsFee'] as num?)?.toDouble() ?? 0.0,
      );
}

class Technician {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final int completedJobsCount;
  final TechnicianAvailability availability;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? vehicleInfo;
  final String? bio;
  final double todayEarnings;
  final double totalWalletBalance;
  final bool isVerified;

  Technician({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.specialties,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.completedJobsCount = 0,
    this.availability = TechnicianAvailability.online,
    this.currentLatitude = 31.5204,
    this.currentLongitude = 74.3587,
    this.vehicleInfo,
    this.bio,
    this.todayEarnings = 0.0,
    this.totalWalletBalance = 0.0,
    this.isVerified = true,
  });

  Technician copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    List<String>? specialties,
    double? rating,
    int? reviewCount,
    int? completedJobsCount,
    TechnicianAvailability? availability,
    double? currentLatitude,
    double? currentLongitude,
    String? vehicleInfo,
    String? bio,
    double? todayEarnings,
    double? totalWalletBalance,
    bool? isVerified,
  }) =>
      Technician(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        specialties: specialties ?? this.specialties,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        completedJobsCount: completedJobsCount ?? this.completedJobsCount,
        availability: availability ?? this.availability,
        currentLatitude: currentLatitude ?? this.currentLatitude,
        currentLongitude: currentLongitude ?? this.currentLongitude,
        vehicleInfo: vehicleInfo ?? this.vehicleInfo,
        bio: bio ?? this.bio,
        todayEarnings: todayEarnings ?? this.todayEarnings,
        totalWalletBalance: totalWalletBalance ?? this.totalWalletBalance,
        isVerified: isVerified ?? this.isVerified,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'specialties': specialties,
        'rating': rating,
        'reviewCount': reviewCount,
        'completedJobsCount': completedJobsCount,
        'availability': availability.name,
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
        'vehicleInfo': vehicleInfo,
        'bio': bio,
        'todayEarnings': todayEarnings,
        'totalWalletBalance': totalWalletBalance,
        'isVerified': isVerified,
      };

  factory Technician.fromMap(Map<String, dynamic> map) => Technician(
        id: map['id'] ?? '',
        fullName: map['fullName'] ?? 'Verified Specialist',
        email: map['email'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '+92 321 7890123',
        avatarUrl: map['avatarUrl'],
        specialties: List<String>.from(map['specialties'] ?? []),
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
        completedJobsCount: (map['completedJobsCount'] as num?)?.toInt() ?? 0,
        availability: TechnicianAvailability.values.firstWhere(
          (a) => a.name == map['availability'],
          orElse: () => TechnicianAvailability.online,
        ),
        currentLatitude: (map['currentLatitude'] as num?)?.toDouble() ?? 31.5204,
        currentLongitude: (map['currentLongitude'] as num?)?.toDouble() ?? 74.3587,
        vehicleInfo: map['vehicleInfo'],
        bio: map['bio'],
        todayEarnings: (map['todayEarnings'] as num?)?.toDouble() ?? 0.0,
        totalWalletBalance: (map['totalWalletBalance'] as num?)?.toDouble() ?? 0.0,
        isVerified: map['isVerified'] ?? true,
      );
}

class TechJob {
  final String id;
  final String bookingNumber;
  final String customerName;
  final String customerPhone;
  final String serviceCategoryId;
  final String serviceCategoryName;
  final String serviceName;
  final String complaintTitle;
  final String complaintDescription;
  final Address address;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final BookingStatus status;
  final ServiceCharge serviceCharge;
  final double technicianPayout;
  final String createdAt;
  final String? acceptedAt;
  final String? completedAt;
  final double? customerRating;
  final String? customerReview;

  TechJob({
    required this.id,
    required this.bookingNumber,
    required this.customerName,
    required this.customerPhone,
    required this.serviceCategoryId,
    required this.serviceCategoryName,
    required this.serviceName,
    required this.complaintTitle,
    required this.complaintDescription,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.status,
    required this.serviceCharge,
    required this.technicianPayout,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.customerRating,
    this.customerReview,
  });

  TechJob copyWith({
    BookingStatus? status,
    String? acceptedAt,
    String? completedAt,
    double? customerRating,
    String? customerReview,
  }) =>
      TechJob(
        id: id,
        bookingNumber: bookingNumber,
        customerName: customerName,
        customerPhone: customerPhone,
        serviceCategoryId: serviceCategoryId,
        serviceCategoryName: serviceCategoryName,
        serviceName: serviceName,
        complaintTitle: complaintTitle,
        complaintDescription: complaintDescription,
        address: address,
        scheduledDate: scheduledDate,
        scheduledTimeSlot: scheduledTimeSlot,
        status: status ?? this.status,
        serviceCharge: serviceCharge,
        technicianPayout: technicianPayout,
        createdAt: createdAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        completedAt: completedAt ?? this.completedAt,
        customerRating: customerRating ?? this.customerRating,
        customerReview: customerReview ?? this.customerReview,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingNumber': bookingNumber,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'serviceCategoryId': serviceCategoryId,
        'serviceCategoryName': serviceCategoryName,
        'serviceName': serviceName,
        'complaintTitle': complaintTitle,
        'complaintDescription': complaintDescription,
        'address': address.toMap(),
        'scheduledDate': scheduledDate,
        'scheduledTimeSlot': scheduledTimeSlot,
        'status': status.name,
        'serviceCharge': serviceCharge.toMap(),
        'technicianPayout': technicianPayout,
        'createdAt': createdAt,
        'acceptedAt': acceptedAt,
        'completedAt': completedAt,
        'customerRating': customerRating,
        'customerReview': customerReview,
      };

  factory TechJob.fromMap(Map<String, dynamic> map) {
    final charge = ServiceCharge.fromMap(
      Map<String, dynamic>.from(map['serviceCharge'] ?? {}),
    );
    final payout = (map['technicianPayout'] as num?)?.toDouble() ?? (charge.total * 0.8);

    return TechJob(
      id: map['id'] ?? '',
      bookingNumber: map['bookingNumber'] ?? '',
      customerName: map['customerName'] ?? 'ApexFix Customer',
      customerPhone: map['customerPhone'] ?? '+92 300 1234567',
      serviceCategoryId: map['serviceCategoryId'] ?? '',
      serviceCategoryName: map['serviceCategoryName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      complaintTitle: map['complaintTitle'] ?? '',
      complaintDescription: map['complaintDescription'] ?? '',
      address: Address.fromMap(Map<String, dynamic>.from(map['address'] ?? {})),
      scheduledDate: map['scheduledDate'] ?? '',
      scheduledTimeSlot: map['scheduledTimeSlot'] ?? '',
      status: BookingStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (map['status'] ?? '').toString().toLowerCase(),
        orElse: () => BookingStatus.pending,
      ),
      serviceCharge: charge,
      technicianPayout: payout,
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
      acceptedAt: map['acceptedAt'],
      completedAt: map['completedAt'],
      customerRating: (map['customerRating'] as num?)?.toDouble(),
      customerReview: map['customerReview'],
    );
  }
}

