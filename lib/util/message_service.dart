import 'package:flutter/services.dart';

class MessageService {
  static const _eventChannel = EventChannel('app/native-code');

  void startListening() {
    _eventChannel.receiveBroadcastStream().listen(
      (message) {
        print("New message from native code: $message");
      },
      onError: (error) {
        print("Error: $error");
      },
    );
  }
}
