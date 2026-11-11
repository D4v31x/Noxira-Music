import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('Flutter widget deeplink opt-out belongs to MainActivity metadata', () {
    final document = XmlDocument.parse(
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync());
    final application = document.findAllElements('application').single;
    final activity = application.findElements('activity').singleWhere(
        (node) => node.getAttribute('android:name') == '.MainActivity');
    final optOut = activity.findElements('meta-data').singleWhere((node) =>
        node.getAttribute('android:name') == 'flutter_deeplinking_enabled');
    expect(optOut.getAttribute('android:value'), 'false');
    expect(
        application.findElements('meta-data').where((node) =>
            node.getAttribute('android:name') == 'flutter_deeplinking_enabled'),
        isEmpty);
  });
}
