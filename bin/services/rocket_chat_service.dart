import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../config/config.dart';

class RocketChatService {
  static final RocketChatService _instance = RocketChatService._internal();

  factory RocketChatService() {
    return _instance;
  }

  RocketChatService._internal();

  final Map<String, String> _headers = {};
  final _log = Logger('RocketChatService');

  Future<bool> authenticate(String username, String password) async {
    final response = await http.post(
        Uri.parse('${Config.rocketChatUrl}/api/v1/login'),
        body: {'username': username, 'password': password});
    if (response.statusCode == 200) {
      _headers['X-Auth-Token'] = jsonDecode(response.body)['data']['authToken'];
      _headers['X-User-Id'] = jsonDecode(response.body)['data']['userId'];
      _log.info('Successfully authenticated with Rocket Chat.');
      return true;
    } else {
      _log.severe(
          'Failed to authenticate with Rocket Chat: ${response.statusCode}.');
      return false;
    }
  }

  Future<List> getUserList() async {
    final response = await http.get(
        Uri.parse('${Config.rocketChatUrl}/api/v1/users.list'),
        headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['users'] as List;
    } else {
      _log.severe(
          'getUserList(): Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  Future<Map<String, String>> getUserCustomFields(String userId) async {
    final response = await http.get(
        Uri.parse('${Config.rocketChatUrl}/api/v1/users.info?userId=${userId}'),
        headers: _headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)['user'];
      return json['customFields'] != null
          ? Map<String, String>.from(json['customFields'])
          : {};
    } else {
      _log.severe(
          'getUserCustomFields(): Request failed with status: ${response.statusCode}.');
      return {};
    }
  }

  Future<String> getGroupId(String groupName) async {
    final response = await http.get(
        Uri.parse(
            '${Config.rocketChatUrl}/api/v1/groups.info?roomName=${groupName}'),
        headers: _headers);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['group'] != null ? json['group']['_id'] : '';
    } else {
      _log.severe(
          'getGroupId(): Request failed with status: ${response.statusCode}.');
      return '';
    }
  }

  Future<List> getGroupUsers(String groupId) async {
    final response = await http.get(
        Uri.parse(
            '${Config.rocketChatUrl}/api/v1/groups.members?roomId=${groupId}'),
        headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['members'] as List;
    } else {
      _log.severe(
          'getGroupUsers(): Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  kickUserFromGroup(String userId, String roomId) async {
    final response = await http.post(
        Uri.parse('${Config.rocketChatUrl}/api/v1/groups.kick'),
        body: {'userId': userId, 'roomId': roomId},
        headers: _headers);
    if (response.statusCode == 200) {
      _log.info('User kicked from group: ${userId}.');
    } else {
      _log.info(
          'kickUserFromGroup(): Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  addUserToGroup(String userId, String roomId) async {
    final response = await http.post(
        Uri.parse('${Config.rocketChatUrl}/api/v1/groups.invite'),
        body: {'userId': userId, 'roomId': roomId},
        headers: _headers);
    if (response.statusCode == 200) {
      _log.info('User added to group: ${userId}.');
    } else {
      _log.info(
          'addUserToGroup(): Request failed with status: ${response.statusCode}.');
      return [];
    }
  }
}
