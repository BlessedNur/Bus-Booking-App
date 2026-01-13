import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/bus_model.dart';
import '../models/booking_model.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await StorageService.getToken();
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    await StorageService.saveToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    await StorageService.removeToken();
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'An error occurred');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response from server. Status: ${response.statusCode}');
      }
      rethrow;
    }
  }

  // Helper to make HTTP requests with better error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    String? operation,
  }) async {
    try {
      final response = await request();
      return response;
    } on http.ClientException catch (e) {
      throw Exception(
        'Network error: ${e.message}\n'
        'Make sure the backend server is accessible at ${ApiConfig.baseUrl}'
      );
    } on SocketException {
      throw Exception(
        'Connection error: Cannot reach server\n'
        'Please ensure:\n'
        '1. Backend is running: cd backend && npm run dev\n'
        '2. Backend URL is correct: ${ApiConfig.baseUrl}\n'
        '3. No firewall is blocking port 3000'
      );
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('failed host lookup') || 
          errorMsg.contains('connection refused') ||
          errorMsg.contains('failed to fetch') ||
          errorMsg.contains('network is unreachable') ||
          errorMsg.contains('socketexception')) {
        throw Exception(
          'Cannot connect to backend server\n\n'
          'Troubleshooting:\n'
          '1. Start backend: cd backend && npm run dev\n'
          '2. Verify backend URL: ${ApiConfig.baseUrl}\n'
          '3. Test backend health: ${ApiConfig.baseUrl.replaceAll("/api", "/health")}\n'
          '4. Check firewall settings'
        );
      }
      rethrow;
    }
  }

  // Auth Methods
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? countryCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          if (countryCode != null) 'countryCode': countryCode,
        }),
      ),
      operation: 'register',
    );

    final data = await _handleResponse(response);
    return AuthResponse.fromJson(data['data']);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ),
      operation: 'login',
    );

    final data = await _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data['data']);
    await setToken(authResponse.token);
    return authResponse;
  }

  Future<AuthResponse> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtp}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      ),
      operation: 'verifyOTP',
    );

    final data = await _handleResponse(response);
    final authResponse = AuthResponse.fromJson(data['data']);
    await setToken(authResponse.token);
    return authResponse;
  }

  Future<void> resendOTP({
    required String email,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resendOtp}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
        }),
      ),
      operation: 'resendOTP',
    );

    await _handleResponse(response);
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.forgotPassword}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
        }),
      ),
      operation: 'forgotPassword',
    );

    await _handleResponse(response);
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPassword}');
    final response = await _makeRequest(
      () => http.put(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'token': token,
          'password': password,
        }),
      ),
      operation: 'resetPassword',
    );

    await _handleResponse(response);
  }

  Future<UserModel> getCurrentUser() async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMe}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(),
      ),
      operation: 'getCurrentUser',
    );

    final data = await _handleResponse(response);
    return UserModel.fromJson(data['data']['user']);
  }

  // Bus Methods
  Future<List<BusModel>> searchBuses({
    required String from,
    required String to,
    required String date,
    int? page,
    int? limit,
  }) async {
    final queryParams = {
      'from': from,
      'to': to,
      'date': date,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final baseUrl = '${ApiConfig.baseUrl}${ApiConfig.searchBuses}';
    final uri = queryParams.isEmpty 
        ? Uri.parse(baseUrl)
        : Uri.parse(baseUrl).replace(queryParameters: queryParams.map((k, v) => MapEntry(k.toString(), v.toString())));
    
    final response = await _makeRequest(
      () => http.get(
        uri,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'searchBuses',
    );

    final data = await _handleResponse(response);
    final buses = data['data'] as List;
    return buses.map((bus) => BusModel.fromJson(bus)).toList();
  }

  Future<BusModel> getBus(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBus(id)}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'getBus',
    );

    final data = await _handleResponse(response);
    return BusModel.fromJson(data['data']);
  }

  Future<List<SeatModel>> getBusSeats({
    required String busId,
    String? date,
  }) async {
    final queryParams = date != null ? <String, String>{'date': date} : <String, String>{};
    final baseUrl = '${ApiConfig.baseUrl}${ApiConfig.getBusSeats(busId)}';
    final uri = queryParams.isEmpty 
        ? Uri.parse(baseUrl)
        : Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final url = uri;
    
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'getBusSeats',
    );

    final data = await _handleResponse(response);
    final seats = data['data'] as List;
    return seats.map((seat) => SeatModel.fromJson(seat)).toList();
  }

  // Booking Methods
  Future<BookingModel> createBooking({
    required String busId,
    required List<String> seats,
    required List<Map<String, dynamic>> passengers,
    required Map<String, dynamic> route,
    String? paymentMethod,
  }) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createBooking}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'bus': busId,
          'seats': seats,
          'passengers': passengers,
          'route': route,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        }),
      ),
      operation: 'createBooking',
    );

    final data = await _handleResponse(response);
    return BookingModel.fromJson(data['data']);
  }

  Future<List<BookingModel>> getMyBookings({
    String? status,
    int? page,
    int? limit,
  }) async {
    await getToken(); // Ensure token is loaded
    final queryParams = <String, String>{
      if (status != null) 'status': status,
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final baseUrl = '${ApiConfig.baseUrl}${ApiConfig.bookings}';
    final uri = queryParams.isEmpty 
        ? Uri.parse(baseUrl)
        : Uri.parse(baseUrl).replace(queryParameters: queryParams);
    
    final response = await _makeRequest(
      () => http.get(
        uri,
        headers: _getHeaders(),
      ),
      operation: 'getMyBookings',
    );

    final data = await _handleResponse(response);
    final bookings = data['data'] as List;
    return bookings.map((booking) => BookingModel.fromJson(booking)).toList();
  }

  Future<BookingModel> getBooking(String id) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBooking(id)}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(),
      ),
      operation: 'getBooking',
    );

    final data = await _handleResponse(response);
    return BookingModel.fromJson(data['data']);
  }

  Future<BookingModel> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cancelBooking(bookingId)}');
    final response = await _makeRequest(
      () => http.put(
        url,
        headers: _getHeaders(),
        body: json.encode({
          if (reason != null) 'reason': reason,
        }),
      ),
      operation: 'cancelBooking',
    );

    final data = await _handleResponse(response);
    return BookingModel.fromJson(data['data']);
  }

  Future<Map<String, dynamic>> getBookingTicket(String id) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getBookingTicket(id)}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(),
      ),
      operation: 'getBookingTicket',
    );

    final data = await _handleResponse(response);
    return data['data'];
  }

  // User Methods
  Future<UserModel> getUserProfile() async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserProfile}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(),
      ),
      operation: 'getUserProfile',
    );

    final data = await _handleResponse(response);
    return UserModel.fromJson(data['data']['user']);
  }

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? countryCode,
  }) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateUserProfile}');
    final response = await _makeRequest(
      () => http.put(
        url,
        headers: _getHeaders(),
        body: json.encode({
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (countryCode != null) 'countryCode': countryCode,
        }),
      ),
      operation: 'updateUserProfile',
    );

    final data = await _handleResponse(response);
    return UserModel.fromJson(data['data']['user']);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await getToken(); // Ensure token is loaded
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.changePassword}');
    final response = await _makeRequest(
      () => http.put(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ),
      operation: 'changePassword',
    );

    await _handleResponse(response);
  }

  Future<void> logout() async {
    await clearToken();
    await StorageService.removeUser();
  }

  // Agency Methods
  Future<List<AgencyModel>> getAgencies() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.agencies}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'getAgencies',
    );

    final data = await _handleResponse(response);
    final List<dynamic> agenciesList = data['data'] ?? [];
    return agenciesList.map((json) => AgencyModel.fromJson(json)).toList();
  }

  Future<AgencyModel> getAgency(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAgency(id)}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'getAgency',
    );

    final data = await _handleResponse(response);
    return AgencyModel.fromJson(data['data']);
  }

  // Review Methods
  Future<List<Map<String, dynamic>>> getAgencyReviews(String agencyId) async {
    await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getAgencyReviews(agencyId)}');
    final response = await _makeRequest(
      () => http.get(
        url,
        headers: _getHeaders(includeAuth: false),
      ),
      operation: 'getAgencyReviews',
    );

    final data = await _handleResponse(response);
    final List<dynamic> reviewsList = data['data'] ?? [];
    return reviewsList.map((review) => review as Map<String, dynamic>).toList();
  }

  Future<bool> canUserReviewAgency(String agencyId) async {
    await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.checkCanReview(agencyId)}');
    try {
      final response = await _makeRequest(
        () => http.get(
          url,
          headers: _getHeaders(),
        ),
        operation: 'canUserReviewAgency',
      );

      final data = await _handleResponse(response);
      return data['data']['canReview'] ?? false;
    } catch (e) {
      // If endpoint doesn't exist, check bookings manually
      return await _checkUserHasBookedWithAgency(agencyId);
    }
  }

  Future<bool> _checkUserHasBookedWithAgency(String agencyId) async {
    try {
      final bookings = await getMyBookings();
      return bookings.any((booking) => 
        booking.bus?.agency?.id == agencyId && 
        (booking.status == 'Confirmed' || booking.status == 'Completed')
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> createAgencyReview({
    required String agencyId,
    required int rating,
    required String comment,
  }) async {
    await getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createAgencyReview(agencyId)}');
    final response = await _makeRequest(
      () => http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      ),
      operation: 'createAgencyReview',
    );

    final data = await _handleResponse(response);
    return data['data'];
  }
}
