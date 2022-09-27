import 'dart:io';

import 'package:settings_yaml/settings_yaml.dart';

class Config {
  static String _nodeUrlWs = '';
  static String _pillarName = '';
  static bool _enableRocketChat = true;
  static String _rocketChatUrl = '';
  static String _rocketChatUsername = '';
  static String _rocketChatPassword = '';
  static String _rocketChatDelegatorChannelName = '';
  static int _rocketChatMinimumDelegationWeight = 0;

  static String get nodeUrlWs {
    return _nodeUrlWs;
  }

  static String get pillarName {
    return _pillarName;
  }

  static bool get enableRocketChat {
    return _enableRocketChat;
  }

  static String get rocketChatUrl {
    return _rocketChatUrl;
  }

  static String get rocketChatUsername {
    return _rocketChatUsername;
  }

  static String get rocketChatPassword {
    return _rocketChatPassword;
  }

  static String get rocketChatDelegatorChannelName {
    return _rocketChatDelegatorChannelName;
  }

  static int get rocketChatMinimumDelegationWeight {
    return _rocketChatMinimumDelegationWeight;
  }

  static void load() {
    final settings = SettingsYaml.load(
        pathToSettings: '${Directory.current.path}/config.yaml');

    _nodeUrlWs = settings['node_url_ws'] as String;
    _pillarName = settings['pillar_name'] as String;
    _enableRocketChat = settings['enable_rocket_chat'] as bool;
    _rocketChatUrl = settings['rocket_chat_url'] as String;
    _rocketChatUsername = settings['rocket_chat_username'] as String;
    _rocketChatPassword = settings['rocket_chat_password'] as String;
    _rocketChatDelegatorChannelName =
        settings['rocket_chat_delegator_channel_name'] as String;
    _rocketChatMinimumDelegationWeight =
        settings['rocket_chat_minimum_delegation_weight'] as int;
  }
}
