// ApexFix Data Models in Dart/Flutter

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
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
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

class Customer {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final String createdAt;
  final String role;
  final List<Address> addresses;
  final String? defaultAddressId;

  Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    required this.createdAt,
    this.role = 'customer',
    this.addresses = const [],
    this.defaultAddressId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt,
    'role': role,
    'defaultAddressId': defaultAddressId,
    'addresses': addresses.map((a) => a.toMap()).toList(),
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'] ?? '',
    fullName: map['fullName'] ?? 'ApexFix User',
    email: map['email'] ?? '',
    phoneNumber: map['phoneNumber'] ?? '+92 300 1234567',
    avatarUrl: map['avatarUrl'],
    createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    role: map['role'] ?? 'customer',
    defaultAddressId: map['defaultAddressId'],
    addresses: (map['addresses'] as List<dynamic>?)
            ?.map((a) => Address.fromMap(Map<String, dynamic>.from(a)))
            .toList() ??
        [],
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

  Technician({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.specialties = const [],
    this.rating = 4.9,
    this.reviewCount = 50,
    this.completedJobsCount = 120,
    this.availability = TechnicianAvailability.online,
    this.currentLatitude,
    this.currentLongitude,
    this.vehicleInfo,
    this.bio,
  });

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
    'currentLatitude': currentLatitude,
    'currentLongitude': currentLongitude,
    'vehicleInfo': vehicleInfo,
    'bio': bio,
  };

  factory Technician.fromMap(Map<String, dynamic> map) => Technician(
    id: map['id'] ?? '',
    fullName: map['fullName'] ?? 'Verified Specialist',
    email: map['email'] ?? '',
    phoneNumber: map['phoneNumber'] ?? '+92 321 7890123',
    avatarUrl: map['avatarUrl'],
    specialties: List<String>.from(map['specialties'] ?? []),
    rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
    reviewCount: map['reviewCount'] ?? 0,
    completedJobsCount: map['completedJobsCount'] ?? 0,
    currentLatitude: (map['currentLatitude'] as num?)?.toDouble(),
    currentLongitude: (map['currentLongitude'] as num?)?.toDouble(),
    vehicleInfo: map['vehicleInfo'],
    bio: map['bio'],
  );
}

class ServiceCategory {
  final String id;
  final String title;
  final String iconName;
  final String colorBg;
  final String colorText;
  final String description;
  final double startingPrice;
  final String? bannerImage;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorBg,
    required this.colorText,
    required this.description,
    required this.startingPrice,
    this.bannerImage,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'iconName': iconName,
    'colorBg': colorBg,
    'colorText': colorText,
    'description': description,
    'startingPrice': startingPrice,
    'bannerImage': bannerImage,
  };

  factory ServiceCategory.fromMap(Map<String, dynamic> map) => ServiceCategory(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    iconName: map['iconName'] ?? 'wrench',
    colorBg: map['colorBg'] ?? '#EFF6FF',
    colorText: map['colorText'] ?? '#1D4ED8',
    description: map['description'] ?? '',
    startingPrice: (map['startingPrice'] as num?)?.toDouble() ?? 0.0,
    bannerImage: map['bannerImage'],
  );
}

class ServiceItem {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final double basePrice;
  final int durationMinutes;
  final List<String> features;

  ServiceItem({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.basePrice,
    required this.durationMinutes,
    this.features = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'description': description,
    'basePrice': basePrice,
    'durationMinutes': durationMinutes,
    'features': features,
  };

  factory ServiceItem.fromMap(Map<String, dynamic> map) => ServiceItem(
    id: map['id'] ?? '',
    categoryId: map['categoryId'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0.0,
    durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
    features: List<String>.from(map['features'] ?? []),
  );
}

class ServiceCharge {
  final double baseServiceFee;
  final double? partsCost;
  final double tax;
  final double? discount;
  final double total;

  ServiceCharge({
    required this.baseServiceFee,
    this.partsCost,
    required this.tax,
    this.discount,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'baseServiceFee': baseServiceFee,
    'partsCost': partsCost,
    'tax': tax,
    'discount': discount,
    'total': total,
  };

  factory ServiceCharge.fromMap(Map<String, dynamic> map) => ServiceCharge(
    baseServiceFee: (map['baseServiceFee'] as num?)?.toDouble() ?? 0.0,
    partsCost: (map['partsCost'] as num?)?.toDouble(),
    tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
    discount: (map['discount'] as num?)?.toDouble(),
    total: (map['total'] as num?)?.toDouble() ?? 0.0,
  );
}

class Booking {
  final String id;
  final String bookingNumber;
  final String customerId;
  final String? technicianId;
  final Technician? technician;
  final String serviceCategoryId;
  final String serviceId;
  final String serviceName;
  final String serviceCategoryName;
  final String complaintTitle;
  final String complaintDescription;
  final Address address;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final BookingStatus status;
  final ServiceCharge serviceCharge;
  final String createdAt;
  final String updatedAt;
  final int? estimatedArrivalMinutes;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    this.technicianId,
    this.technician,
    required this.serviceCategoryId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategoryName,
    required this.complaintTitle,
    required this.complaintDescription,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.status,
    required this.serviceCharge,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedArrivalMinutes,
  });

  static BookingStatus parseStatus(String? str) {
    if (str == null) return BookingStatus.pending;
    return BookingStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == str.toLowerCase(),
      orElse: () => BookingStatus.pending,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'bookingNumber': bookingNumber,
    'customerId': customerId,
    'technicianId': technicianId,
    'technician': technician?.toMap(),
    'serviceCategoryId': serviceCategoryId,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'serviceCategoryName': serviceCategoryName,
    'complaintTitle': complaintTitle,
    'complaintDescription': complaintDescription,
    'address': address.toMap(),
    'scheduledDate': scheduledDate,
    'scheduledTimeSlot': scheduledTimeSlot,
    'status': status.name,
    'serviceCharge': serviceCharge.toMap(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'estimatedArrivalMinutes': estimatedArrivalMinutes,
  };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
    id: map['id'] ?? '',
    bookingNumber: map['bookingNumber'] ?? '',
    customerId: map['customerId'] ?? '',
    technicianId: map['technicianId'],
    technician: map['technician'] != null
        ? Technician.fromMap(Map<String, dynamic>.from(map['technician']))
        : null,
    serviceCategoryId: map['serviceCategoryId'] ?? '',
    serviceId: map['serviceId'] ?? '',
    serviceName: map['serviceName'] ?? '',
    serviceCategoryName: map['serviceCategoryName'] ?? '',
    complaintTitle: map['complaintTitle'] ?? '',
    complaintDescription: map['complaintDescription'] ?? '',
    address: Address.fromMap(
        Map<String, dynamic>.from(map['address'] ?? {})),
    scheduledDate: map['scheduledDate'] ?? '',
    scheduledTimeSlot: map['scheduledTimeSlot'] ?? '',
    status: parseStatus(map['status']),
    serviceCharge: ServiceCharge.fromMap(
        Map<String, dynamic>.from(map['serviceCharge'] ?? {})),
    createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    updatedAt: map['updatedAt'] ?? DateTime.now().toIso8601String(),
    estimatedArrivalMinutes: map['estimatedArrivalMinutes'] as int?,
  );

  Booking copyWith({
    String? id,
    String? bookingNumber,
    String? customerId,
    String? technicianId,
    Technician? technician,
    String? serviceCategoryId,
    String? serviceId,
    String? serviceName,
    String? serviceCategoryName,
    String? complaintTitle,
    String? complaintDescription,
    Address? address,
    String? scheduledDate,
    String? scheduledTimeSlot,
    BookingStatus? status,
    ServiceCharge? serviceCharge,
    String? createdAt,
    String? updatedAt,
    int? estimatedArrivalMinutes,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      customerId: customerId ?? this.customerId,
      technicianId: technicianId ?? this.technicianId,
      technician: technician ?? this.technician,
      serviceCategoryId: serviceCategoryId ?? this.serviceCategoryId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceCategoryName: serviceCategoryName ?? this.serviceCategoryName,
      complaintTitle: complaintTitle ?? this.complaintTitle,
      complaintDescription: complaintDescription ?? this.complaintDescription,
      address: address ?? this.address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      status: status ?? this.status,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedArrivalMinutes:
          estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
    );
  }
}
