import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart';
import 'package:flutter_html/flutter_html.dart';

class CssParserService {
  Map<String, Style> parseCssToHtmlStyles(Map<String, String> cssFiles) {
    final styles = <String, Style>{};
    final selectorStyles = <String, Style>{};

    for (final cssPath in cssFiles.values) {
      final cssContent = File(cssPath).readAsStringSync();
      final stylesheet = css_parser.parse(cssContent);

      for (final rule in stylesheet.topLevels.whereType<RuleSet>()) {
        final selectorGroup = rule.selectorGroup;
        if (selectorGroup == null) continue;

        for (final selector in selectorGroup.selectors) {
          final fullSelector = selector.simpleSelectorSequences.map((seq) {
            final s = seq.simpleSelector;
            if (s is ClassSelector) return '.${s.name}';
            if (s is IdSelector) return '#${s.name}';
            return s.name ?? '';
          }).join(' ');

          Color? color;
          FontSize? fontSize;
          FontWeight? fontWeight;
          Color? backgroundColor;
          TextAlign? textAlign;
          double? margin;
          double? padding;

          for (final decl in rule.declarationGroup.declarations) {
            if (decl is Declaration) {
              switch (decl.property) {
                case 'color':
                  color = _parseCssColor(decl.expression.toString());
                  break;
                case 'font-size':
                  fontSize = _parseCssFontSize(decl.expression.toString());
                  break;
                case 'font-weight':
                  fontWeight = _parseCssFontWeight(decl.expression.toString());
                  break;
                case 'background-color':
                  backgroundColor = _parseCssColor(decl.expression.toString());
                  break;
                case 'text-align':
                  textAlign = _parseCssTextAlign(decl.expression.toString());
                  break;
                case 'margin':
                  margin = _parseCssSpacing(decl.expression.toString());
                  break;
                case 'padding':
                  padding = _parseCssSpacing(decl.expression.toString());
                  break;
              }
            }
          }

          selectorStyles[fullSelector] = Style(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            backgroundColor: backgroundColor,
            textAlign: TextAlign.justify,
            margin: margin != null ? Margins.all(margin) : null,
            padding: padding != null ? HtmlPaddings.all(padding) : null,
          );
        }
      }
    }

    for (var i = 1; i <= 6; i++) {
      selectorStyles['h$i'] = Style(textAlign: TextAlign.center);
    }
    selectorStyles['img'] = Style(textAlign: TextAlign.center);

    styles.addAll(selectorStyles);

    return styles;
  }

  Color? _parseCssColor(String value) {
    value = value.trim();
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 3) {
        final r = hex[0] * 2, g = hex[1] * 2, b = hex[2] * 2;
        return Color(int.parse('FF$r$g$b', radix: 16));
      }
    }
    return null;
  }

  FontSize? _parseCssFontSize(String value) {
    value = value.trim();
    if (value.endsWith('px')) {
      final numStr = value.replaceAll('px', '');
      final size = double.tryParse(numStr);
      if (size != null) return FontSize(size);
    }
    if (value.endsWith('em')) {
      final numStr = value.replaceAll('em', '');
      final size = double.tryParse(numStr);
      if (size != null) return FontSize(size * 16);
    }
    final size = double.tryParse(value);
    if (size != null) return FontSize(size);
    return null;
  }

  FontWeight? _parseCssFontWeight(String value) {
    value = value.trim();
    switch (value) {
      case 'bold':
      case '700':
        return FontWeight.bold;
      case 'normal':
      case '400':
        return FontWeight.normal;
      case '300':
        return FontWeight.w300;
      case '500':
        return FontWeight.w500;
      case '900':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  TextAlign? _parseCssTextAlign(String value) {
    value = value.trim();
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  double? _parseCssSpacing(String value) {
    value = value.trim();
    if (value.endsWith('px')) {
      return double.tryParse(value.replaceAll('px', ''));
    }
    if (value.endsWith('em')) {
      final size = double.tryParse(value.replaceAll('em', ''));
      if (size != null) return size * 16;
    }
    return double.tryParse(value);
  }
}
