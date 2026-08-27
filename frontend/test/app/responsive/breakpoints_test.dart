import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('windowSizeClassFromWidth', () {
    test('given a width of 0, then the class is compact', () {
      // when / then
      expect(windowSizeClassFromWidth(0), WindowSizeClass.compact);
    });

    test('given a width of 599, then the class is compact', () {
      // when / then
      expect(windowSizeClassFromWidth(599), WindowSizeClass.compact);
    });

    test('given a width of 600, then the class is medium', () {
      // when / then
      expect(windowSizeClassFromWidth(600), WindowSizeClass.medium);
    });

    test('given a width of 839, then the class is medium', () {
      // when / then
      expect(windowSizeClassFromWidth(839), WindowSizeClass.medium);
    });

    test('given a width of 840, then the class is expanded', () {
      // when / then
      expect(windowSizeClassFromWidth(840), WindowSizeClass.expanded);
    });

    test('given a width of 1920, then the class is expanded', () {
      // when / then
      expect(windowSizeClassFromWidth(1920), WindowSizeClass.expanded);
    });
  });
}