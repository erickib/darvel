class Route {
  final String method;
  final String path;

  const Route(this.method, this.path);

  const factory Route.get(String path) = GetRoute;
  const factory Route.post(String path) = PostRoute;
}

class GetRoute extends Route {
  const GetRoute(String path) : super('GET', path);
}

class PostRoute extends Route {
  const PostRoute(String path) : super('POST', path);
}
