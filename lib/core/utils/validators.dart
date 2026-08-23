abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[\w\-\.]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = 'This field'}) {
    if (value != null && value.length > max) {
      return '$fieldName must be $max characters or fewer.';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required.';
    }
    if (value.trim().length < 3) {
      return 'Full name must be at least 3 characters.';
    }
    return null;
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number.';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\]/\\;]'))) {
      return 'Password must contain a special character.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? projectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project name is required.';
    }
    if (value.trim().length < 3) {
      return 'Project name must be at least 3 characters.';
    }
    if (value.trim().length > 120) {
      return 'Project name must be 120 characters or fewer.';
    }
    return null;
  }

  static String? projectDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project description is required.';
    }
    return null;
  }
}
