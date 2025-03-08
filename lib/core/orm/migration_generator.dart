import 'package:darvel/core/orm/entity_metadata.dart';

class MigrationGenerator {
  static String createTable(EntityMetadata metadata) {
    final columnsSql = metadata.columns.map((c) {
      final nullable = c.nullable ? '' : 'NOT NULL';
      final defaultClause =
          c.defaultValue != null ? "DEFAULT ${c.defaultValue}" : '';
      final type = (c.type == 'VARCHAR' && c.defaultValue == null)
          ? '${c.type}(255)'
          : c.type;
      final primary = c.primaryKey ? 'PRIMARY KEY' : '';

      return '${c.name} $type $nullable $defaultClause $primary';
    }).join(',\n');

    return 'CREATE TABLE ${metadata.tableName} (\n$columnsSql\n)';
  }
}
