import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/theme/ui_density.dart';

void main() {
  group('UiDensity', () {
    test('fromKey resolves known keys', () {
      expect(UiDensity.fromKey('comfortable'), UiDensity.comfortable);
      expect(UiDensity.fromKey('compact'), UiDensity.compact);
    });

    test('fromKey defaults to comfortable for null/unknown', () {
      expect(UiDensity.fromKey(null), UiDensity.comfortable);
      expect(UiDensity.fromKey('bogus'), UiDensity.comfortable);
    });

    test('visualDensity mapping matches Flutter presets', () {
      expect(UiDensity.comfortable.visualDensity, VisualDensity.standard);
      expect(UiDensity.compact.visualDensity, VisualDensity.compact);
    });

    test('key round-trips through fromKey', () {
      for (final d in UiDensity.values) {
        expect(UiDensity.fromKey(d.key), d);
      }
    });
  });
}
