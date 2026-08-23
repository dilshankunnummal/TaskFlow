import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:injectable/injectable.dart';

@lazySingleton
class MockJsonDataSource {
  Map<String, dynamic>? _cache;

  static const _assetPath = 'assets/mock_data/mock-data.json';

  Future<Map<String, dynamic>> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    _cache = jsonDecode(raw) as Map<String, dynamic>;
    return _cache!;
  }

  Future<List<Map<String, dynamic>>> section(String key) async {
    final data = await load();
    final list = data[key] as List<dynamic>? ?? <dynamic>[];
    return list.cast<Map<String, dynamic>>();
  }

  void clearCache() {
    _cache = null;
  }
}