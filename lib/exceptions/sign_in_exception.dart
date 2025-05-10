/// Exception thrown when a sign-in process fails.
class SignInException implements Exception {
  /// The error message describing the sign-in failure.
  final String message;

  /// Creates a [SignInException] with a given [message].
  SignInException(this.message);

  @override
  String toString() => 'SignInException: $message';
}