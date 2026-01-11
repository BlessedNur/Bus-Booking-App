class BusModel {
  final String id;
  final AgencyModel? agency;
  final String busNumber;
  final String type;
  final RouteInfo route;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int duration;
  final int totalSeats;
  final int availableSeats;
  final double price;
  final double vipPrice;
  final bool isVIP;
  final List<String> amenities;
  final bool isActive;

  BusModel({
    required this.id,
    this.agency,
    required this.busNumber,
    required this.type,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.totalSeats,
    required this.availableSeats,
    required this.price,
    required this.vipPrice,
    this.isVIP = false,
    this.amenities = const [],
    this.isActive = true,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['_id'] ?? json['id'] ?? '',
      agency: json['agency'] != null
          ? AgencyModel.fromJson(
              json['agency'] is String ? {'id': json['agency']} : json['agency'])
          : null,
      busNumber: json['busNumber'] ?? '',
      type: json['type'] ?? 'Standard',
      route: RouteInfo.fromJson(json['route'] ?? {}),
      departureTime: json['departureTime'] != null
          ? DateTime.parse(json['departureTime'])
          : DateTime.now(),
      arrivalTime: json['arrivalTime'] != null
          ? DateTime.parse(json['arrivalTime'])
          : DateTime.now(),
      duration: json['duration'] ?? 0,
      totalSeats: json['totalSeats'] ?? 40,
      availableSeats: json['availableSeats'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      vipPrice: (json['vipPrice'] ?? json['price'] ?? 0).toDouble(),
      isVIP: json['isVIP'] ?? false,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'type': type,
      'route': route.toJson(),
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'duration': duration,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'price': price,
      'vipPrice': vipPrice,
      'isVIP': isVIP,
      'amenities': amenities,
    };
  }
}

class RouteInfo {
  final String from;
  final String to;

  RouteInfo({
    required this.from,
    required this.to,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

class AgencyModel {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final double rating;
  final List<String> amenities;

  AgencyModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.rating = 0.0,
    this.amenities = const [],
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'],
      description: json['description'],
      rating: (json['rating'] ?? 0).toDouble(),
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'rating': rating,
      'amenities': amenities,
    };
  }
}
