import 'package:darvel/app/models/User.dart';
import 'package:mysql1/mysql1.dart';

class EntityMetadata {
  final String tableName;
  final List<ColumnMetadata> columns;

  EntityMetadata(this.tableName, this.columns);

  static EntityMetadata fromEntity(Object entity) {
    // Usa mirrors (ou parser de annotations via builder no futuro)
    // Lê @Entity, @Column e outros
    return EntityMetadata('users', [
      ColumnMetadata('id', 'int', primaryKey: true),
      ColumnMetadata('name', 'VARCHAR'),
      ColumnMetadata('email', 'VARCHAR', nullable: true),
      ColumnMetadata('createdAt', 'TIMESTAMP',
          defaultValue: 'CURRENT_TIMESTAMP'),
    ]);
  }

  static EntityMetadata fromType(Type type) {
    // Mesmo que o fromEntity, mas pegando só pelo Type
    return fromEntity(type);
  }

  List<Object?> toValues() {
    // Extrai os valores da entidade para o insert
    return [];
  }

  // Object fromRow(ResultRow row) {
  //   // Constrói uma instância da entidade a partir de uma linha de banco
  //   return User(
  //     id: row['id'],
  //     name: row['name'],
  //     email: row['email'],
  //     createdAt: row['createdAt'],
  //   );
  // }
}

class ColumnMetadata {
  final String name;
  final String type;
  final bool nullable;
  final bool primaryKey;
  final String? defaultValue;

  ColumnMetadata(this.name, this.type,
      {this.nullable = false, this.primaryKey = false, this.defaultValue});
}
