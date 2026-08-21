import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:taskflow/core/config/environment.dart';
import 'package:taskflow/core/error/exceptions.dart';

final class MockJsonLoader {
  MockJsonLoader(this._environment);

  final Environment _environment;
  Map<String, dynamic>? _cache;

  Future<Map<String, dynamic>> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }
    try {
      final raw = await rootBundle.loadString(_environment.mockDataAssetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = decoded;
      return decoded;
    } catch (_) {
      throw const CacheException('Unable to load bundled mock data.');
    }
  }

  Future<List<Map<String, dynamic>>> section(String key) async {
    final data = await load();
    final value = data[key];
    if (value is! List) {
      return const [];
    }
    return value.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> object(String key) async {
    final data = await load();
    final value = data[key];
    if (value is! Map<String, dynamic>) {
      throw CacheException('Missing "$key" section in mock data.');
    }
    return value;
  }

  void invalidate() {
    _cache = null;
  }
}
