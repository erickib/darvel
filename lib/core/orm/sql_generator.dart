import 'package:darvel/core/orm/entity_metadata.dart';

class SqlGenerator {
  static String insert(EntityMetadata metadata) {
    final columns = metadata.columns.map((c) => c.name).join(', ');
    final placeholders = metadata.columns.map((_) => '?').join(', ');

    return 'INSERT INTO ${metadata.tableName} ($columns) VALUES ($placeholders)';
  }

  static String update(EntityMetadata metadata) {
    final setClause = metadata.columns
        .where((c) => !c.primaryKey)
        .map((c) => '${c.name} = ?')
        .join(', ');

    final primaryKeyColumn = metadata.columns.firstWhere((c) => c.primaryKey);

    return 'UPDATE ${metadata.tableName} SET $setClause WHERE ${primaryKeyColumn.name} = ?';
  }
}
