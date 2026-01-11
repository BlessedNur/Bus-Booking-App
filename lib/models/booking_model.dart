import 'bus_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final BusModel? bus;
  final List<PassengerModel> passengers;
  final BookingRoute route;
  final double totalPrice;
  final String status;
  final String bookingId;
  final String qrCode;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;

  BookingModel({
    required this.id,
    required this.userId,
    this.bus,
    required this.passengers,
    required this.route,
    required this.totalPrice,
    required this.status,
    required this.bookingId,
    this.qrCode = '',
    this.paymentMethod = 'Cash',
    this.paymentStatus = 'Pending',
    this.createdAt,
    this.cancelledAt,
    this.cancelledReason,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] is String
          ? json['user']
          : json['user']?['_id'] ?? json['user']?['id'] ?? '',
      bus: json['bus'] != null
          ? BusModel.fromJson(json['bus'] is String
              ? {'id': json['bus']}
              : json['bus'])
          : null,
      passengers: json['passengers'] != null
          ? (json['passengers'] as List)
              .map((p) => PassengerModel.fromJson(p))
              .toList()
          : [],
      route: BookingRoute.fromJson(json['route'] ?? {}),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Confirmed',
      bookingId: json['bookingId'] ?? '',
      qrCode: json['qrCode'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancelledReason: json['cancelledReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'route': route.toJson(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'qrCode': qrCode,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
    };
  }
}

class PassengerModel {
  final String name;
  final int age;
  final String seatNumber;
  final String? gender;

  PassengerModel({
    required this.name,
    required this.age,
    required this.seatNumber,
    this.gender,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      seatNumber: json['seatNumber'] ?? '',
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'seatNumber': seatNumber,
      'gender': gender,
    };
  }
}

class BookingRoute {
  final String from;
  final String to;
  final DateTime date;
  final String departureTime;
  final String arrivalTime;

  BookingRoute({
    required this.from,
    required this.to,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory BookingRoute.fromJson(Map<String, dynamic> json) {
    return BookingRoute(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'date': date.toIso8601String(),
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
    };
  }
}

class SeatModel {
  final String id;
  final String busId;
  final String seatNumber;
  final String type;
  final bool isAvailable;
  final bool isBooked;
  final DateTime? bookingDate;

  SeatModel({
    required this.id,
    required this.busId,
    required this.seatNumber,
    this.type = 'Standard',
    this.isAvailable = true,
    this.isBooked = false,
    this.bookingDate,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['_id'] ?? json['id'] ?? '',
      busId: json['bus'] is String ? json['bus'] : json['bus']?['_id'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      type: json['type'] ?? 'Standard',
      isAvailable: json['isAvailable'] ?? true,
      isBooked: json['isBooked'] ?? false,
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : null,
    );
  }
}
