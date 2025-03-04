class ViewException implements Exception {
  final String message;
  ViewException(this.message);

  @override
  String toString() => 'ViewException: $message';
}
