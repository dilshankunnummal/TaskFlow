enum DataSourceMode { mockJson, restApi }

final class Environment {
  const Environment._({
    required this.dataSourceMode,
    required this.mockDataAssetPath,
    this.apiBaseUrl,
  });

  factory Environment.mock() {
    return const Environment._(
      dataSourceMode: DataSourceMode.mockJson,
      mockDataAssetPath: 'assets/mock_data/mock-data.json',
    );
  }

  factory Environment.rest(String baseUrl) {
    return Environment._(
      dataSourceMode: DataSourceMode.restApi,
      mockDataAssetPath: 'assets/mock_data/mock-data.json',
      apiBaseUrl: baseUrl,
    );
  }

  final DataSourceMode dataSourceMode;
  final String mockDataAssetPath;
  final String? apiBaseUrl;

  bool get isMock => dataSourceMode == DataSourceMode.mockJson;
}

final class AppEnvironment {
  const AppEnvironment._();

  static Environment current = Environment.mock();
}
