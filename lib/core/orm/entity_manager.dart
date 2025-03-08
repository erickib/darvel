import 'package:darvel/core/orm/entity_metadata.dart';
import 'package:darvel/core/orm/sql_generator.dart';
import 'package:mysql1/mysql1.dart';

class EntityManager {
  final MySqlConnection connection;

  EntityManager(this.connection);

  Future<void> persist(Object entity) async {
    final metadata = EntityMetadata.fromEntity(entity);
    final sql = SqlGenerator.insert(metadata);
    final values = metadata.toValues();

    await connection.query(sql, values);
  }

  // Future<List<T>> findAll<T>() async {
  //   final metadata = EntityMetadata.fromType(T);
  //   final result =
  //       await connection.query('SELECT * FROM ${metadata.tableName}');
  //   return result.map((row) => metadata.fromRow(row) as T).toList();
  // }
}
