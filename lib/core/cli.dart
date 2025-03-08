import 'dart:io';
import 'package:darvel/app/models/User.dart';
import 'package:darvel/core/orm/entity_metadata.dart';
import 'package:darvel/core/orm/migration_generator.dart';
import 'package:yaml/yaml.dart';

class Cli {
  static void handle(List<String> args) {
    if (args.isEmpty) {
      print('No command provided');
      return;
    }

    switch (args[0]) {
      case 'make:controller':
        if (args.length < 2) {
          print('Please provide a controller name');
          return;
        }
        makeController(args[1]);
        break;
      case 'make:model':
        if (args.length < 2) {
          print('Please provide a model name');
          return;
        }
        makeModel(args[1]);
        break;
      case 'make:service':
        if (args.length < 2) {
          print('Please provide a service name');
          return;
        }
        makeService(args[1]);
        break;
      case 'make:migration':
        if (args.length < 2) {
          print('Please provide a migration name');
          return;
        }
        final entityName = args[1];
        //generateMigration(entityName);
        makeMigration(args[1]);
        break;
      case 'serve':
        serveApp();
        break;
      case 'scan':
        scanControllers();
        break;
      case 'build:routes':
        buildRoutes();
        break;
      case 'route:build':
        //runBuild();
        scanControllers2();
        break;
      // Other cases...
      default:
        print('Unknown command: ${args[0]}');
    }
  }

  static void makeController(String name) {
    final file = File('lib/app/controllers/${name}Controller.dart');
    final content = """
import 'package:shelf/shelf.dart';
import 'dart:io';
import 'package:mustache_template/mustache_template.dart';

class ${name}Controller {
  Response index(Request request) {
    final template = Template(File('lib/views/${name.toLowerCase()}.mustache').readAsStringSync());
    final output = template.renderString({'title': '$name Controller', 'message': 'Welcome to the $name page!'});
    return Response.ok(output, headers: {'Content-Type': 'text/html'});
  }
}
""";
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('Controller $name created');

    final viewFile = File('lib/views/${name.toLowerCase()}.mustache');
    viewFile.writeAsStringSync("""
<html>
<head>
    <title>{{title}}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 2rem;
        }
        h1 {
            color: #2c3e50;
        }
    </style>
</head>
<body>
    <h1>{{title}}</h1>
    <p>{{message}}</p>
</body>
</html>
""");
    print('View ${name.toLowerCase()}.mustache created');
  }

  void generateController(String name) {
    final controllerName = '${name}Controller';
    final controllerFile = File('lib/app/controllers/$controllerName.dart');
    if (controllerFile.existsSync()) {
      print('Controller already exists!');
      return;
    }

    final content = '''
import '../../core/view_renderer.dart';
import '../../core/response_helpers.dart';

class $controllerName {
  Response index(Request request, Map<String, dynamic> services) {
    final context = {
      'title': '$name Page'
    };

    final html = ViewRenderer.render('${name.toLowerCase()}/index', context, layout: 'main');
    return responseHtml(html);
  }
}
  ''';

    controllerFile.writeAsStringSync(content);
    print('Controller $controllerName created!');

    final viewDir = Directory('lib/app/views/${name.toLowerCase()}');
    if (!viewDir.existsSync()) {
      viewDir.createSync(recursive: true);
    }

    final viewFile = File('${viewDir.path}/index.mustache');
    viewFile.writeAsStringSync('<h1>Welcome to $name Page</h1>');
    print('View for $name created!');

    // Optionally regenerate routes if needed
  }

  static void makeModel(String name) {
    final file = File('lib/app/models/$name.dart');
    final content = """
class $name {
  final int id;
  final String name;

  $name(this.id, this.name);
}
""";
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('Model $name created');
  }

  static void makeService(String name) {
    final file = File('lib/app/services/${name}Service.dart');
    final content = """
class ${name}Service {
  void exampleMethod() {
    print('$name Service method called');
  }
}
""";
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('Service $name created');
  }

  static void makeMigration(String name) {
    final file = File('lib/database/migrations/${name}_migration.dart');
    final content = """
class ${name}Migration {
  void up() {
    print('Running $name migration');
  }

  void down() {
    print('Reverting $name migration');
  }
}
""";
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    print('Migration $name created');
  }

  static void generateMigration(String entityName) {
    // Supondo uma pasta lib/app/models com entidades
    final entityClass = loadEntityClass(entityName);
    final metadata = EntityMetadata.fromType(entityClass);

    final migrationSql = MigrationGenerator.createTable(metadata);
    final migrationFile = File(
        'migrations/${DateTime.now().millisecondsSinceEpoch}_create_${metadata.tableName}.sql');

    migrationFile.writeAsStringSync(migrationSql);
    print('Migration criada: ${migrationFile.path}');
  }

  static Type loadEntityClass(String entityName) {
    // Aqui pode ser por dart:mirrors ou código gerado (builder) para resolver types dinamicamente
    switch (entityName) {
      case 'User':
      //return User;
      default:
        throw Exception('Entidade desconhecida: $entityName');
    }
  }

  static void serveApp() {
    print('Starting server...');
    Process.run('dart', ['run', 'lib/main.dart']).then((result) {
      print(result.stdout);
      print(result.stderr);
    });
  }

  static void scanControllers() {
    final env = File('.env');
    bool annotationsEnabled = false;

    if (env.existsSync()) {
      final content = env.readAsStringSync();
      final rawEnvVars = loadYaml(content);

      // Force cast to Map<String, dynamic>
      var envVars = <String, dynamic>{};
      if (rawEnvVars is Map) {
        for (var entry in rawEnvVars.entries) {
          envVars[entry.key.toString()] = entry.value;
        }
      } else {
        envVars = rawEnvVars;
      }

      annotationsEnabled = envVars['ANNOTATIONS_ENABLED']?.toString() == 'true';
    }

    final controllersDir = Directory('lib/app/controllers');
    final controllers = controllersDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    final bufferImports = StringBuffer();
    final bufferRoutes = StringBuffer();

    for (var file in controllers) {
      final name = file.uri.pathSegments.last.replaceAll('.dart', '');
      var fullClassName = name;
      bufferImports.writeln("import '../app/controllers/$name.dart';");

      final content = file.readAsStringSync();

      // Extract methods and annotations (if enabled)
      final methodMatches = RegExp(
              r'''@(Route\.(get|post|put|delete)\(["'](.*?)["']\))\s+Response\s+(\w+)\(''')
          .allMatches(content);

      if (annotationsEnabled && methodMatches.isNotEmpty) {
        for (var match in methodMatches) {
          final methodType = match.group(2)?.toUpperCase();
          final path = match.group(3);
          final methodName = match.group(4);
          final params = _extractPathParams(path);

          bufferRoutes.writeln(
              "  '$methodType $path': (Request request, Map<String, dynamic> services) {");

          // Extract path params into variables
          for (final param in params) {
            if (param.endsWith('?')) {
              bufferRoutes.writeln(
                  "    final String? ${param.replaceAll('?', '')} = request.params['${param.replaceAll('?', '')}'];");
            } else {
              bufferRoutes.writeln(
                  "    final String? $param = request.params['$param'];");
              bufferRoutes.writeln(
                  "    if ($param == null) return Response.badRequest(body: 'Missing required parameter: $param');");
            }
          }
          final paramList = params
              .map((p) => p.endsWith('?') ? p.replaceAll('?', '') : p)
              .join(', ');

          final paramString = paramList.isEmpty ? '' : ', $paramList';
          bufferRoutes.writeln(
              "    return $fullClassName().$methodName(request, services$paramString);");

          bufferRoutes.writeln("  },");
        }
      } else {
        var index = fullClassName.indexOf('Controller');
        var className = fullClassName.substring(0, index);
        //bufferRoutes.writeln(
        //    "  'GET /${className.toLowerCase()}': (Request request, Map<String, dynamic> services) => $fullClassName().index(request, services),");
        final fixedPath = convertToShelfRouterPath('/users/:id');
        bufferRoutes.writeln(
            "  'GET $fixedPath': (Request request, Map<String, dynamic> services) => HomeController().getUser(request, services, request.params['id']),");
      }
    }

    //build final buffer
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln("// DARVEL-GENERATED - DO NOT EDIT $now");
    buffer.writeln("import 'package:shelf/shelf.dart';");
    buffer.writeln("import 'package:shelf_router/shelf_router.dart';");
    buffer.write(bufferImports.toString());
    buffer.writeln("final Map<String, Function> controllerRoutes = {");
    buffer.write(bufferRoutes.toString());
    buffer.writeln("};");

    final routesFile = File('lib/core/controller_routes.dart');
    routesFile.writeAsStringSync(buffer.toString());
    print('Controller routes generated successfully.');
  }

  static List<String> _extractPathParams(String? path) {
    if (path!.isEmpty) return [];
    final paramRegex = RegExp(r':(\w+)');
    return paramRegex.allMatches(path).map((match) => match.group(1)!).toList();
  }

  static String convertToShelfRouterPath(String path) {
    return path.replaceAllMapped(RegExp(r':(\w+)(\?)?'), (match) {
      final paramName = match.group(1);
      final isOptional = match.group(2) != null;
      return '<$paramName>';
    });
  }

  static void buildRoutes() {
    print('Scanning controllers and generating routes...');

    // Run build_runner
    var result = Process.runSync('dart',
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        runInShell: true, workingDirectory: Directory.current.path);
    print(result.stdout);
    print(result.stderr);

    // After build_runner, regenerate router.dart
    generateGlobalRouter();

    print('Routes built and global router generated successfully!');
  }

  static void generateGlobalRouter() {
    final controllersDir = Directory('lib/app/controllers');
    final controllers = controllersDir
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'))
        .toList();

    final buffer = StringBuffer();
    buffer.writeln('// AUTO-GENERATED - DO NOT EDIT');
    buffer.writeln("import 'package:shelf/shelf.dart';");
    buffer.writeln("import 'package:shelf_router/shelf_router.dart';");

    for (var file in controllers) {
      final name = file.uri.pathSegments.last.replaceAll('.dart', '');
      buffer.writeln("import '../app/controllers/$name.dart';");
    }

    buffer.writeln('class RouterConfig {');
    buffer.writeln('  Handler get handler {');
    buffer.writeln('    final router = Router();');

    for (var file in controllers) {
      final className = file.uri.pathSegments.last.replaceAll('.dart', '');
      buffer.writeln('    router.mount("/", $className().router);');
    }

    buffer.writeln('    return router;');
    buffer.writeln('  }');
    buffer.writeln('}');

    final routerFile = File('lib/core/router.dart');
    routerFile.writeAsStringSync(buffer.toString());
    print('Global router generated in lib/core/router.dart');
  }

  static void runBuild() {
    print('Running build_runner...');

    final result = Process.runSync(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      print('Build runner failed: ${result.stderr}');
      exit(result.exitCode);
    } else {
      print('Build runner completed successfully');
    }
  }

  static void scanControllers2() {
    final env = File('.env');
    bool annotationsEnabled = false;

    if (env.existsSync()) {
      final content = env.readAsStringSync();
      final envVars = loadYaml(content) as Map;
      annotationsEnabled = envVars['ANNOTATIONS_ENABLED']?.toString() == 'true';
    }

    final controllersDir = Directory('lib/app/controllers');
    final controllers = controllersDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    final bufferImports = StringBuffer();
    final bufferRoutes = StringBuffer();

    for (var file in controllers) {
      final name = file.uri.pathSegments.last.replaceAll('.dart', '');
      var fullClassName = name;

      bufferImports.writeln("import '../app/controllers/$name.dart';");

      final content = file.readAsStringSync();

      final methodMatches = RegExp(
              r'''@(Route\.(get|post|put|delete)\(["\'](.*?)["\']\))\s+Response\s+(\w+)\(''')
          .allMatches(content);
      for (var match in methodMatches) {
        //print(match.group(3));
        final methodType = match.group(2)?.toUpperCase() ?? 'GET';

        final path = match.group(3) ?? '/';
        final methodName = match.group(4);

        final paramNames = _extractParamsFromPath(path);

        bufferRoutes.writeln("  '$methodType $path': (Request request) {");

        if (paramNames.isNotEmpty) {
          for (var i = 0; i < paramNames.length; i++) {
            final paramName = paramNames[i];
            bufferRoutes.writeln(
                "    final String? $paramName = request.url.pathSegments.length > ${i + 1} ? request.url.pathSegments[${i + 1}] : null;");
            bufferRoutes.writeln(
                "    if ($paramName == null) return Response.badRequest(body: 'Missing required parameter: $paramName');");
          }

          // Generate method call with parameters
          final paramsList = ['request'] + paramNames;
          bufferRoutes.writeln(
              "    return $fullClassName().$methodName(${paramsList.join(', ')});");
        } else {
          var index = fullClassName.indexOf('Controller');
          var className = fullClassName.substring(0, index);
          bufferRoutes
              .writeln("    return $fullClassName().$methodName(request);");
        }

        bufferRoutes.writeln("  },");
      }
    }

    //build final buffer
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln("// DARVEL-GENERATED - DO NOT EDIT $now");
    buffer.writeln("import 'package:shelf/shelf.dart';");
    buffer.write(bufferImports.toString());
    buffer.writeln("final Map<String, Function> controllerRoutes = {");
    buffer.write(bufferRoutes.toString());
    buffer.writeln("};");

    final routesFile = File('lib/core/controller_routes.dart');
    routesFile.writeAsStringSync(buffer.toString());
    print('Controller routes generated successfully.');
  }

  static List<String> _extractParamsFromPath(String path) {
    final paramMatches = RegExp(r'<(\w+)>').allMatches(path);
    return paramMatches.map((match) => match.group(1)!).toList();
  }
}
