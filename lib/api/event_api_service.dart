import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/api/api_service.dart';

class EventApiService {
  /// Create a new event
  static Future<dynamic> createEvent(Map<String, dynamic> payload) async {
    try {
      final response = await ApiService.authenticatedRequest(
        ApiEndpoints.createEvent,
        method: 'POST',
        body: payload,
      );

      if (response != null && response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Create Event Failed: ${response?.statusCode} - ${response?.body}');
      }
    } catch (e) {
      debugPrint('Error creating event: $e');
    }
    return null;
  }

  /// Get all events
  static Future<dynamic> getAllEvents() async {
    try {
      final response = await ApiService.authenticatedRequest(
        ApiEndpoints.getAllEvents,
        method: 'GET',
      );

      if (response != null && response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Get All Events Failed: ${response?.statusCode} - ${response?.body}');
      }
    } catch (e) {
      debugPrint('Error getting all events: $e');
    }
    return null;
  }

  /// Get event categories
  static Future<dynamic> getEventCategories() async {
    try {
      final response = await ApiService.authenticatedRequest(
        ApiEndpoints.eventCategories,
        method: 'GET',
      );

      if (response != null && response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Get Categories Failed: ${response?.statusCode} - ${response?.body}');
      }
    } catch (e) {
      debugPrint('Error getting categories: $e');
    }
    return null;
  }
}
