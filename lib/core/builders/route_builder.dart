import 'dart:async';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:darvel/core/annotations/route.dart';

class RouteGenerator extends GeneratorForAnnotation<Route> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! MethodElement) {
      throw InvalidGenerationSourceError(
        '@Route can only be applied to methods.',
        element: element,
      );
    }

    final methodElement = element as MethodElement;
    final classElement = methodElement.enclosingElement3 as ClassElement;

    final className = classElement.name;
    final methodName = methodElement.name;
    final method = annotation.read('method').stringValue;
    final path = annotation.read('path').stringValue;

    return '''
    controllerRoutes['$method $path'] = (Request request, Map<String, dynamic> services) => $className().$methodName(request, services);
    ''';
  }
}
