import 'dart:math';

import 'package:taskflow/core/error/exceptions.dart';

final class SimulatedNetworkConfig {
  const SimulatedNetworkConfig({
    required this.minDelayMs,
    required this.maxDelayMs,
    required this.forceNotFoundId,
    required this.forceTimeoutId,
    required this.forceValidationErrorId,
  });

  factory SimulatedNetworkConfig.fromJson(Map<String, dynamic> json) {
    return SimulatedNetworkConfig(
      minDelayMs: json['min_delay_ms'] as int,
      maxDelayMs: json['max_delay_ms'] as int,
      forceNotFoundId: json['force_not_found_id'] as String,
      forceTimeoutId: json['force_timeout_id'] as String,
      forceValidationErrorId: json['force_validation_error_id'] as String,
    );
  }

  final int minDelayMs;
  final int maxDelayMs;
  final String forceNotFoundId;
  final String forceTimeoutId;
  final String forceValidationErrorId;
}

final class SimulatedNetwork {
  SimulatedNetwork(this._config);

  final SimulatedNetworkConfig _config;
  final Random _random = Random();

  Future<void> delay() async {
    final range = _config.maxDelayMs - _config.minDelayMs;
    final jitter = range <= 0 ? 0 : _random.nextInt(range);
    final durationMs = _config.minDelayMs + jitter;
    await Future<void>.delayed(Duration(milliseconds: durationMs));
  }

  void throwIfForced(String? id) {
    if (id == null) {
      return;
    }
    if (id == _config.forceNotFoundId) {
      throw const NotFoundException();
    }
    if (id == _config.forceTimeoutId) {
      throw const TimeoutException();
    }
    if (id == _config.forceValidationErrorId) {
      throw const ValidationException('The provided input failed validation.');
    }
  }

  Future<T> run<T>(T Function() body, {String? forceId}) async {
    await delay();
    throwIfForced(forceId);
    return body();
  }
}
