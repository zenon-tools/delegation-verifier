import 'dart:async';

import 'package:logging/logging.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

import 'config/config.dart';
import 'platform_handlers/rocket_chat_platform_handler.dart';

Future main() async {
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  Config.load();

  final node = Zenon();
  await node.wsClient.initialize(Config.nodeUrlWs);

  if (Config.enableRocketChat) {
    final rocketChatHandler = RocketChatPlatformHandler(node);
    rocketChatHandler.sync();
    _run(rocketChatHandler);
  }
}

_run(RocketChatPlatformHandler rocketChatHandler) async {
  Timer.periodic(Duration(seconds: 300), (Timer t) async {
    t.cancel();
    await rocketChatHandler.sync();
    _run(rocketChatHandler);
  });
}
