import 'dart:io';
import 'package:mustache_template/mustache.dart';

void main() async {
  final entitiesDir = Directory('entities');
  final files = entitiesDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    processEntityFile(file);
  }
}

void processEntityFile(File file) {
  final content = file.readAsStringSync();
  final tableName = _extractTableName(content);
  final columns = _extractColumns(content);
  final relations = _extractRelations(content);

  // Generate SQL
  final tableTemplate =
      Template(File('table_template.mustache').readAsStringSync());
  final sql = tableTemplate.renderString({
    'tableName': tableName,
    'columns': columns,
  });

  File('${file.path.replaceFirst('.dart', '.sql')}').writeAsStringSync(sql);

  // Generate Relationships JSON
  if (relations.isNotEmpty) {
    final relationsTemplate =
        Template(File('relationships_template.mustache').readAsStringSync());
    final relationshipsJson = relationsTemplate.renderString({
      'tableName': tableName,
      'relations': relations,
    });

    File('${file.path.replaceFirst('.dart', '.relationships.json')}')
        .writeAsStringSync(relationshipsJson);
  }
}

/// Extracts the table name from @Table annotation.
String _extractTableName(String content) {
  final tableMatch =
      RegExp('''r'@Table\(name:\s*\'([^\']+)\'\)''').firstMatch(content);
  if (tableMatch == null) {
    throw Exception('Missing @Table annotation');
  }
  return tableMatch.group(1)!;
}

/// Extracts all @Column fields.
List<Map<String, dynamic>> _extractColumns(String content) {
  final columnMatches = RegExp(
          '''r'@Column\(name:\s*\'([^\']+)\'(?:,\s*primaryKey:\s*(true|false))?\)\n\s*final\s+([a-zA-Z<>]+)\s+([a-zA-Z0-9_]+);''')
      .allMatches(content);

  final columns = columnMatches.map((m) {
    final name = m.group(1)!;
    final primaryKey = m.group(2) == 'true';
    final type = _mapDartTypeToSqlType(m.group(3)!);

    return {
      'name': name,
      'type': type,
      'primaryKey': primaryKey,
      'last': false,
    };
  }).toList();

  if (columns.isNotEmpty) {
    columns.last['last'] = true; // no comma after last column
  }

  return columns;
}

/// Detects @OneToMany relationships.
List<Map<String, dynamic>> _extractRelations(String content) {
  final oneToManyMatches =
      RegExp(r'@OneToMany\(relatedType:\s*([A-Za-z0-9_]+)\)')
          .allMatches(content);

  return oneToManyMatches.map((m) {
    final relatedType = m.group(1)!;
    final targetTable =
        relatedType.toLowerCase() + 's'; // simplistic, but works for demo
    return {
      'targetTable': targetTable,
      'targetField': 'user_id', // you could make this configurable if needed
      'last': true,
    };
  }).toList();
}

String _mapDartTypeToSqlType(String dartType) {
  switch (dartType) {
    case 'int':
      return 'INTEGER';
    case 'String':
      return 'TEXT';
    case 'double':
      return 'REAL';
    default:
      throw Exception('Unsupported type: $dartType');
  }
}
