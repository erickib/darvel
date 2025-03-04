import 'dart:io';
import 'package:mustache_template/mustache_template.dart';
import 'view_exception.dart';

class ViewRenderer {
  static const String _viewsPath = 'lib/views';
  static final Map<String, Template> _templateCache = {};

  static String render(String viewName, Map<String, dynamic> data,
      {String? layout}) {
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

    final filePath = '$_viewsPath/$viewName.mustache';
    final file = File(filePath);

    if (!file.existsSync()) {
      throw ViewException('View "$viewName" not found at path "$filePath"');
    }

    final templateContent = file.readAsStringSync();
    final template = Template(templateContent,
        name: viewName,
        lenient: true,
        partialResolver: _resolvePartialAsTemplate);

    if (const bool.fromEnvironment('dart.vm.product')) {
      _templateCache[viewName] = template;
    }

    return template;
  }

  static Template _resolvePartialAsTemplate(String name) {
    final file = File('lib/views/partials/$name.mustache');
    if (!file.existsSync()) {
      throw Exception('Partial not found: $name');
    }

    final content = file.readAsStringSync();
    return Template(content, partialResolver: _resolvePartialAsTemplate);
  }
}

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
