// ignore_for_file: avoid_print

import 'dart:io';

import 'package:push_sender/push_sender.dart';

Future<void> main(List<String> arguments) async {
  final pushSender = PushSender();

  await pushSender.init();

  final messageId = await pushSender.send(
    token: arguments.first,
  );

  print('Message ID: $messageId');

  exit(0);
}
