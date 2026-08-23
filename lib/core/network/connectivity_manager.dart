import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/network/mock_network.dart';

@lazySingleton
class ConnectivityManager {
  final MockNetwork _mockNetwork = MockNetwork.instance;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool get isOnline => _mockNetwork.isOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  void setOnline(bool value) {
    if (_mockNetwork.isOnline == value) return;
    _mockNetwork.setOnline(value);
    _controller.add(value);
  }
}
