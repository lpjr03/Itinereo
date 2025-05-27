/// Base exception for photo operations.
class PhotoException implements Exception {
  final String message;
  PhotoException(this.message);

  @override
  String toString() => 'PhotoException: $message';
}

/// Error while capturing a photo.
class PhotoCaptureException extends PhotoException {
  PhotoCaptureException(String message) : super(message);
}

/// Error while uploading a photo.
class PhotoUploadException extends PhotoException {
  PhotoUploadException(String message) : super(message);
}

/// Error while deleting a photo.
class PhotoDeleteException extends PhotoException {
  PhotoDeleteException(String message) : super(message);
}
