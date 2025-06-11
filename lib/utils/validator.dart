/// Validates an email input field.
///
/// Returns an error message if:
/// - The input is empty or null.
/// - The input does not match a valid email pattern.
/// 
/// Returns `null` if the input is valid.
String? Function(String?)? emailValidator = (String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }

  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
};

/// Validates a password input field.
///
/// Returns an error message if the input is empty or null.
/// 
/// Returns `null` if the input is valid.
String? Function(String?)? passwordValidator = (String? value) {
  if (value == null || value.isEmpty) {
    return 'Please Enter Password';
  }
  if (value.length < 6) return 'Password must be at least 6 characters long';
  return null;
};

/// Validates a name input field.
///
/// Returns an error message if the input is empty or null.
/// 
/// Returns `null` if the input is valid.
String? Function(String?)? nameValidator = (String? value) {
  if (value == null || value.isEmpty) {
    return 'Please Enter Name';
  }
  if (value.length < 2) return 'Name must be at least 2 characters long';

  return null;
};
