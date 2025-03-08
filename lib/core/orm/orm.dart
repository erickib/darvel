class ORM {
  final String table;
  //final String path;

  const ORM(this.table);

  const factory ORM.table(String tableName) = Table;
  //const factory Route.post(String path) = PostRoute;
}

class Table extends ORM {
  const Table(String tableName) : super(tableName);
}

// class PostRoute extends Route {
//   const PostRoute(String path) : super('POST', path);
// }
