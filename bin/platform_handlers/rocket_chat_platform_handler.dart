import 'package:hex/hex.dart';
import 'package:logging/logging.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';
import 'package:collection/collection.dart';

import '../config/config.dart';
import '../models/rocket_chat/delegator_channel.dart';
import '../services/rocket_chat_service.dart';
import '../utils/utils.dart';

class RocketChatPlatformHandler {
  late final Zenon _node;
  final _log = Logger('RocketChatPlatformHandler');

  RocketChatPlatformHandler(this._node);

  sync() async {
    _log.info('Starting Rocket Chat handler');
    await RocketChatService()
        .authenticate(Config.rocketChatUsername, Config.rocketChatPassword);
    final chatUsers = await _getChatUsers();
    final validSignatureUsers = await _getValidSignatureUsers(chatUsers);
    final verifiedDelegatorIds =
        await _getVerifiedDelegatorIds(validSignatureUsers);
    final channel = await _getDelegatorChannelInfo();
    if (channel != null) {
      final adminIds = _parseChatAdminIds(chatUsers);
      await _kickNonDelegatingUsersFromChannel(
          verifiedDelegatorIds, adminIds, channel);
      await _addDelegatingUsersToChannel(
          verifiedDelegatorIds, adminIds, channel);
    }
    _log.info('Rocket Chat handler complete\n');
  }

  _getChatUsers() async {
    final users = (await RocketChatService().getUserList())
        .where((e) =>
            (e['roles'].contains('user') || e['roles'].contains('admin')))
        .toList();
    _log.info('Rocket Chat users: ${users.length}');
    return users;
  }

  _getValidSignatureUsers(chatUsers) async {
    final users = [];
    for (final user in chatUsers) {
      if (user['roles'].contains('admin')) continue;
      final fields =
          (await RocketChatService().getUserCustomFields(user['_id']));
      if (fields.length == 0) continue;
      final isValid = await Utils.verifySignature(
          fields['Signed Message']!,
          fields['Delegation Address']!,
          fields['Public Key']!,
          fields['Signature']!);

      if (isValid) {
        users.add({'_id': user['_id'], ...fields});
      }
    }
    _log.info('Users with valid signature: ${users.length}');
    return users;
  }

  Future<List<String>> _getVerifiedDelegatorIds(validSignatureUsers) async {
    final List<String> ids = [];
    for (final user in validSignatureUsers) {
      final delegation = await _node.embedded.pillar.getDelegatedPillar(
          Address.fromPublicKey(HEX.decode(user['Public Key'])));
      if (delegation != null &&
          delegation.name.toLowerCase() == Config.pillarName.toLowerCase() &&
          (delegation.weight / 100000000) >=
              Config.rocketChatMinimumDelegationWeight) {
        ids.add(user['_id']);
      }
    }
    _log.info('Users with valid delegation and signature: ${ids.length}');
    return ids;
  }

  List<String> _parseChatAdminIds(List chatUsers) {
    return chatUsers
        .where((e) => (e['roles'].contains('admin')))
        .toList()
        .map((e) => e['_id'] as String)
        .toList();
  }

  Future<DelegatorChannel?> _getDelegatorChannelInfo() async {
    final id = await RocketChatService()
        .getGroupId(Config.rocketChatDelegatorChannelName);
    if (id.isNotEmpty) {
      final users = await RocketChatService().getGroupUsers(id);
      if (users.isNotEmpty) {
        return DelegatorChannel(id, users);
      }
    }
    return null;
  }

  _kickNonDelegatingUsersFromChannel(List<String> verifiedDelegatorIds,
      List<String> adminIds, DelegatorChannel channel) async {
    for (final user in channel.users) {
      if (!verifiedDelegatorIds.contains(user['_id']) &&
          !adminIds.contains(user['_id'])) {
        await RocketChatService().kickUserFromGroup(user['_id'], channel.id);
      }
    }
  }

  _addDelegatingUsersToChannel(List<String> verifiedDelegatorIds,
      List<String> adminIds, DelegatorChannel channel) async {
    for (final userId in verifiedDelegatorIds) {
      if (channel.users.firstWhereOrNull((item) => item['_id'] == userId) ==
              null &&
          !adminIds.contains(userId)) {
        await RocketChatService().addUserToGroup(userId, channel.id);
      }
    }
  }
}
