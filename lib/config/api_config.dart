import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Production backend URL
  static const String _productionBaseUrl = 'https://bus-booking-backend-c7s8.onrender.com';
  
  // Local development URL (for testing with local backend)
  static const String _localBaseUrl = 'http://localhost:3000';
  
  // Use production URL by default, set to false for local development
  static const bool _useProduction = true;
  
  // Get base URL based on environment
  static String get baseUrl {
    if (_useProduction) {
      return '$_productionBaseUrl/api';
    }
    
    // Local development URLs
    if (kIsWeb) {
      return '$_localBaseUrl/api';
    }
    
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:3000/api';
    }
    
    if (Platform.isIOS) {
      // iOS simulator uses localhost
      return '$_localBaseUrl/api';
    }
    
    // Default fallback
    return '$_localBaseUrl/api';
  }
  
  // API Endpoints
  static const String auth = '/auth';
  static const String buses = '/buses';
  static const String bookings = '/bookings';
  static const String agencies = '/agencies';
  static const String users = '/users';
  
  // Auth endpoints
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String verifyOtp = '$auth/verify-otp';
  static const String resendOtp = '$auth/resend-otp';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String getMe = '$auth/me';
  
  // Bus endpoints
  static const String searchBuses = '$buses/search';
  static String getBus(String id) => '$buses/$id';
  static String getBusSeats(String id) => '$buses/$id/seats';
  
  // Booking endpoints
  static const String createBooking = bookings;
  static String getBooking(String id) => '$bookings/$id';
  static String cancelBooking(String id) => '$bookings/$id/cancel';
  static String getBookingTicket(String id) => '$bookings/$id/ticket';
  
  // User endpoints
  static const String getUserProfile = '$users/profile';
  static const String updateUserProfile = '$users/profile';
  static const String changePassword = '$users/password';
  static const String getUserBookings = '$users/bookings';
  
  // Agency endpoints
  static const String getAgencies = agencies;
  static String getAgency(String id) => '$agencies/$id';
  static String getAgencyBuses(String id) => '$agencies/$id/buses';
}
