import 'dart:io';
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
        makeMigration(args[1]);
        break;
      case 'serve':
        serveApp();
        break;
      case 'scan':
        scanControllers();
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
              r'''@(Route\.(get|post)\(["'](.*?)["']\))\s+Response\s+(\w+)\(''')
          .allMatches(content);

      if (annotationsEnabled && methodMatches.isNotEmpty) {
        for (var match in methodMatches) {
          final methodType = match.group(2)?.toUpperCase();
          final path = match.group(3);
          final methodName = match.group(4);

          bufferRoutes.writeln(
              "  '$methodType $path': (Request request, Map<String, dynamic> services) => $fullClassName().$methodName(request, services),");
        }
      } else {
        var index = fullClassName.indexOf('Controller');
        var className = fullClassName.substring(0, index);
        bufferRoutes.writeln(
            "  'GET /${className.toLowerCase()}': (Request request, Map<String, dynamic> services) => $fullClassName().index(request, services),");
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
}
