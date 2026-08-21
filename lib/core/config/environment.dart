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
      mockDataAssetPath: 'mock_data/taskflow_mock_data.json',
    );
  }

  factory Environment.rest(String baseUrl) {
    return Environment._(
      dataSourceMode: DataSourceMode.restApi,
      mockDataAssetPath: 'mock_data/taskflow_mock_data.json',
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
