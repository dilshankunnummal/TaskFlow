sealed class DashboardEvent {
  const DashboardEvent();
}

final class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

final class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}
