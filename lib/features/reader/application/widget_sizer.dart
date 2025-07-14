/*
import 'package:flutter/material.dart';

class WidgetSizer {
  static Future<Size> getWidgetSize(Widget widget) async {
    final Completer<Size> sizeCompleter = Completer<Size>();
    final GlobalKey widgetKey = GlobalKey();

    // This is the "off-screen" widget renderer
    final renderingWidget = Offstage(
      offstage: true,
      child: RepaintBoundary(
        key: widgetKey,
        child: widget,
      ),
    );

    // This callback is triggered after the widget has been laid out and rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? context = widgetKey.currentContext;
      if (context != null) {
        sizeCompleter.complete(context.size);
      } else {
        sizeCompleter.completeError('Could not get widget size: context is null.');
      }
    });

    // We attach our off-screen widget to the widget tree to trigger a render.
    runApp(renderingWidget);

    return sizeCompleter.future;
  }
}*/
