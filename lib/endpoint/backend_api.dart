import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // Used for handling JSON

Future<void> createUser(String email) async {
  final url = Uri.parse('http://140.116.247.117:13080/user/create_user/');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'account_type': 'email',
      'email': email
    }),
  );

  if (response.statusCode == 201) {
    // If the server returns an OK response, parse the JSON
    debugPrint('User created: ${response.body}');
  } else {
    // If the response is not successful, throw an exception
    // throw Exception('Failed to create user: ${response.body}');
    debugPrint('Failed to create user: ${response.body}');
  }
}

Future<int?> searchUserDetail(String email) async {
  final url = Uri.parse('http://140.116.247.117:13080/user/search_by_email/$email');
  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // If the server returns an OK response, parse the JSON
    debugPrint('User detail: ${response.body}');
    Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody['user_id'] as int?;
  } else {
    // If the response is not successful, throw an exception
    // throw Exception('Failed to retrieve user detail: ${response.body}');
    debugPrint('Failed to retrieve user detail: ${response.body}');
    return null;
  }
}

Future<int?> createMusicSelection(int userId, String activityType) async {
  final url = Uri.parse('http://140.116.247.117:13080/music/create_music_selection/');

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'user_id': userId,
      'activity_type': activityType,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, you can parse the JSON.
    debugPrint('MusicSelection detail: ${response.body}');
    Map<String, dynamic> responseBody = json.decode(response.body);
    return responseBody['music_selection_id'] as int?;
  } else {
    // If the server did not return a 200 OK response, throw an exception.
    // throw Exception('Failed to create music selection: ${response.body}');
    debugPrint('Failed to create music selection: ${response.body}');
  }
}

Future<http.Response?> createRealTimeData({
  required int musicSelectionId,
  required String currentPlaybackPosition,
  required int stepBpm,
  required List<double?> gps,
  int? musicBpm,
  int? heartRate,
  String? weatherCondition,
  int? sunlightIntensity,
  String? airQuality,
  String? dayNightCycle,
}) async {
  final url = Uri.parse('http://140.116.247.117:13080/real_time/create_data/');

  final data = {
    'music_selection_id': musicSelectionId,
    'current_playback_position': currentPlaybackPosition,
    'step_bpm': stepBpm,
    'gps': gps,
    if (musicBpm != null) 'music_bpm': musicBpm,
    if (heartRate != null) 'heart_rate': heartRate,
    if (weatherCondition != null) 'weather_condition': weatherCondition,
    if (sunlightIntensity != null) 'sunlight_intensity': sunlightIntensity,
    if (airQuality != null) 'air_quality': airQuality,
    if (dayNightCycle != null) 'day_night_cycle': dayNightCycle,
  };
  debugPrint('RealTimeData: ${json.encode(data)}');
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, you can parse the JSON.
    debugPrint('RealTimeData detail: ${response.body}');
    return response;
  } else {
    // If the server did not return a 200 OK response, throw an exception.
    // throw Exception('Failed to create real-time data: ${response.body}');
    debugPrint('Failed to create real-time data: ${response.body}');
  }
}
