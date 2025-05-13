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

String? Function(String?)? passwordValidator = (String? value) {
  if (value == null || value.isEmpty) {
    return 'Please Enter Password';
  }
  return null;
};

String? Function(String?)? nameValidator = (String? value) {
  if (value == null || value.isEmpty) {
    return 'Please Enter Name';
  }
  return null;
};
