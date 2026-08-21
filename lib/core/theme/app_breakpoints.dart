abstract final class AppBreakpoints {
  static const double phone = 600;
  static const double tablet = 1024;

  static bool isPhone(double width) => width < phone;

  static bool isTablet(double width) => width >= phone && width < tablet;

  static bool isDesktop(double width) => width >= tablet;
}
