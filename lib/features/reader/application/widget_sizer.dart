/*
 * This file contains a custom implementation of a widget sizer that was replaced
 * by the third-party package 'widget_sizer: ^0.0.1' (see pubspec.yaml).
 * 
 * This implementation is kept for reference purposes only and is not used in the project.
 * 
 * If debugging is needed for widget sizing, use the following pattern:
 * debugPrint("[DEBUG] WidgetSizer: <message>");
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class WidgetSizer {
  static Future<Size> getWidgetSize(Widget widget) async {
    debugPrint("[DEBUG] WidgetSizer: Measuring widget size");
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
      try {
        final BuildContext? context = widgetKey.currentContext;
        if (context != null) {
          final size = context.size;
          debugPrint("[DEBUG] WidgetSizer: Measured size: $size");
          sizeCompleter.complete(size);
        } else {
          debugPrint("[ERROR] WidgetSizer: Could not get widget size: context is null");
          sizeCompleter.completeError('Could not get widget size: context is null.');
        }
      } catch (e) {
        debugPrint("[ERROR] WidgetSizer: Error measuring widget: $e");
        sizeCompleter.completeError('Error measuring widget: $e');
      }
    });

    // We attach our off-screen widget to the widget tree to trigger a render.
    try {
      runApp(renderingWidget);
      debugPrint("[DEBUG] WidgetSizer: Attached measuring widget to render tree");
    } catch (e) {
      debugPrint("[ERROR] WidgetSizer: Failed to attach measuring widget: $e");
      sizeCompleter.completeError('Failed to attach measuring widget: $e');
    }

    return sizeCompleter.future;
  }
}
