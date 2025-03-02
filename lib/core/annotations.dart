// lib/core/annotations.dart
class Route {
  final String method;
  final String path;

  const Route.get(this.path) : method = 'GET';
  const Route.post(this.path) : method = 'POST';
}
