import 'dart:math';

class MockNetwork {
  MockNetwork._internal();

  static final MockNetwork instance = MockNetwork._internal();

  bool isOnline = true;

  final Random _random = Random();

  Future<void> simulateDelay({int minMs = 300, int maxMs = 800}) async {
    final duration = minMs + _random.nextInt(maxMs - minMs + 1);
    await Future.delayed(Duration(milliseconds: duration));
  }

  void setOnline(bool value) {
    isOnline = value;
  }
}