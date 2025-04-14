/// Utility class for form validation
class FormValidators {
  /// Validates that a field is not empty
  static String? Function(String?) required(String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validates that a field is a valid email
  static String? Function(String?) email(String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Email is required';
      }
      
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      );
      
      if (!emailRegex.hasMatch(value)) {
        return errorMessage;
      }
      
      return null;
    };
  }

  /// Validates that a field has a minimum length
  static String? Function(String?) minLength(int length, String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      
      if (value.length < length) {
        return errorMessage;
      }
      
      return null;
    };
  }

  /// Validates that a field is a valid number
  static String? Function(String?) number(String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      
      if (double.tryParse(value) == null) {
        return errorMessage;
      }
      
      return null;
    };
  }

  /// Validates that a field is a valid phone number
  static String? Function(String?) phone(String errorMessage) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null; // Phone can be optional
      }
      
      final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
      
      if (!phoneRegex.hasMatch(value)) {
        return errorMessage;
      }
      
      return null;
    };
  }

  /// Validates that a field matches another field (e.g., password confirmation)
  static String? Function(String?) matches(String other, String errorMessage) {
    return (value) {
      if (value != other) {
        return errorMessage;
      }
      
      return null;
    };
  }
}
