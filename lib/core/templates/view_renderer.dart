import 'dart:io';
import 'package:darvel/core/helpers/response.dart';
import 'package:darvel/core/logging/logger_service.dart';
import 'package:darvel/core/views/view_exception.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:shelf/shelf.dart';

class ViewRenderer {
  static const String _viewsPath = 'lib/views';
  static const String _viewsPathCore = 'lib/core/views';
  static final Map<String, Template> _templateCache = {};
  static bool core = false;

  static Response renderAsResponse(String viewName, Map<String, dynamic> data,
      {String? layout, bool? internal}) {
    try {
      final html = render(viewName, data, layout: layout, internal: internal);
      return Response.ok(html, headers: {'Content-Type': 'text/html'});
    } on ViewException catch (e, stack) {
      return _renderFrameworkError(e.message, stack);
    } catch (e, stack) {
      return _renderFrameworkError('Unexpected error: $e', stack);
    }
  }

  static String render(String viewName, Map<String, dynamic> data,
      {String? layout, bool? internal}) {
    if (internal != null && internal) core = internal;
    final content = _renderTemplate(viewName, data);

    if (layout != null) {
      return _renderTemplate(layout, {...data, 'content': content});
    } else {
      return content;
    }
  }

  static String _renderTemplate(String viewName, Map<String, dynamic> data) {
    final template = _loadTemplate(viewName);
    return template.renderString(data);
  }

  static Template _loadTemplate(String viewName) {
    if (const bool.fromEnvironment('dart.vm.product') &&
        _templateCache.containsKey(viewName)) {
      return _templateCache[viewName]!;
    }

    final filePath = core
        ? '$_viewsPathCore/$viewName.mustache'
        : '$_viewsPath/$viewName.mustache';

    final file = File(filePath);

    if (!file.existsSync()) {
      throw ViewException('View "$viewName" not found at "$filePath"');
    }
    try {
      final content = file.readAsStringSync();
      final template = Template(content,
          name: viewName, partialResolver: _resolvePartialAsTemplate);

      if (const bool.fromEnvironment('dart.vm.product')) {
        _templateCache[viewName] = template;
      }

      return template;
    } catch (e, stack) {
      throw ViewException('Error loading template $viewName: $e $stack');
    }
  }

  static Template _resolvePartialAsTemplate(String name) {
    final partialPath = core
        ? '$_viewsPathCore/partials/$name.mustache'
        : '$_viewsPath/partials/$name.mustache';

    final file = File(partialPath);

    if (!file.existsSync()) {
      throw ViewException('Partial "$name" not found at "$partialPath"');
    }

    final content = file.readAsStringSync();
    return Template(content, partialResolver: _resolvePartialAsTemplate);
  }

  static Response _renderFrameworkError(String message, StackTrace stack) {
    final errorHtml = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>Framework Error</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; background: #f8d7da; }
            h1 { color: #721c24; }
            pre { background: #f1f1f1; padding: 10px; border-radius: 5px; }
        </style>
    </head>
    <body>
        <h1>Framework Error</h1>
        <p><strong>Error:</strong> $message</p>
        <pre>${stack.toString()}</pre>
    </body>
    </html>
  ''';

    return Response.internalServerError(
      body: errorHtml,
      headers: {'Content-Type': 'text/html'},
    );
  }
}



















































































// import 'dart:io';
// import 'package:darvel/core/helpers/response.dart';
// import 'package:darvel/core/logging/logger_service.dart';
// import 'package:mustache_template/mustache_template.dart';
// import 'package:shelf/shelf.dart';
// import 'view_exception.dart';

// class ViewRenderer {
//   static const String _viewsPath = 'lib/views';
//   static const String _viewsPathCore = 'lib/core/views';
//   static final Map<String, Template> _templateCache = {};
//   static bool core = false;
//   static String filePath = '';

//   static String render(String viewName, Map<String, dynamic> data,
//       {String? layout, bool? internal}) {
//     if (internal != null && internal == true) core = internal;
//     final content = _renderTemplate(viewName, data);

//     if (layout != null) {
//       return _renderTemplate(layout, {...data, 'content': content});
//     } else {
//       return content;
//     }
//   }

//   static String _renderTemplate(String viewName, Map<String, dynamic> data) {
//     final template = _loadTemplate(viewName);
//     return template.renderString(data);
//   }

//   static Template _loadTemplate(String viewName) {
//     if (const bool.fromEnvironment('dart.vm.product') &&
//         _templateCache.containsKey(viewName)) {
//       return _templateCache[viewName]!;
//     }

//     if (core) {
//       filePath = '$_viewsPathCore/$viewName.mustache';
//     } else {
//       filePath = '$_viewsPath/$viewName.mustache';
//     }

//     final file = File(filePath);

//     if (!file.existsSync()) {
//       throw ViewException('View "$viewName" not found at path "$filePath"');
//     }

//     final templateContent = file.readAsStringSync();
//     final template = Template(templateContent,
//         name: viewName,
//         lenient: false,
//         partialResolver: _resolvePartialAsTemplate);

//     if (const bool.fromEnvironment('dart.vm.product')) {
//       _templateCache[viewName] = template;
//     }

//     return template;
//   }

//   static Template _resolvePartialAsTemplate(String name) {
//     if (core) {
//       filePath = _viewsPathCore;
//     } else {
//       filePath = _viewsPath;
//     }
//     final file = File('$filePath/partials/$name.mustache');
//     if (!file.existsSync()) {
//       throw Exception('Partial not found: $name');
//     }

//     final content = file.readAsStringSync();
//     Template resultTemplate = new Template('');
//     try {
//       resultTemplate =
//           Template(content, partialResolver: _resolvePartialAsTemplate);
//     } on TemplateException catch (e, stack) {
//       LoggerService.logError('Error handling request: $e', stack);
//       final html = ViewRenderer.render('error',
//           {'title': 'darvel internal error', 'error': e, 'stack': stack},
//           layout: 'layout', internal: true);
//       Response.found(html);
//     } catch (e, stack) {
//       LoggerService.logError('Error handling request: $e', stack);
//       final html = ViewRenderer.render('error',
//           {'title': 'darvel internal error', 'error': e, 'stack': stack},
//           layout: 'layout', internal: true);
//       return responseAsHtml(html);
//     }
//     return resultTemplate;
//   }
// }





























































// import 'dart:io';
// import 'package:mustache_template/mustache_template.dart';

// class ViewRenderer {
//   static final Map<String, Template> _cache = {};

//   static String render(String viewPath, Map<String, dynamic> context, {String? layout}) {
//     final template = _loadTemplate(viewPath);

//     final renderedView = template.renderString(context);

//     if (layout != null) {
//       final layoutTemplate = _loadTemplate('layouts/$layout');
//       context['content'] = renderedView;
//       return layoutTemplate.renderString(context);
//     } else {
//       return renderedView;
//     }
//   }

//   static Template _loadTemplate(String path) {
//     if (bool.fromEnvironment('dart.vm.product') && _cache.containsKey(path)) {
//       return _cache[path]!;
//     }

//     final file = File('lib/app/views/$path.mustache');
//     if (!file.existsSync()) {
//       throw Exception('Template not found: lib/app/views/$path.mustache');
//     }

//     final content = file.readAsStringSync();
//     final template = Template(content, partialResolver: _resolvePartialAsTemplate);

//     if (bool.fromEnvironment('dart.vm.product')) {
//       _cache[path] = template;
//     }

//     return template;
//   }

//   static Template _resolvePartialAsTemplate(String name) {
//     final file = File('lib/app/views/partials/$name.mustache');
//     if (!file.existsSync()) {
//       throw Exception('Partial not found: $name');
//     }

//     final content = file.readAsStringSync();
//     return Template(content, partialResolver: _resolvePartialAsTemplate);
//   }
// }
