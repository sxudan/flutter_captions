import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_captions/flutter_captions.dart';

void main() {
  test('adds one to input values', () {
    final writer = CaptionWriter();
    // writer.generateText([
    //   CaptionWriterParams(
    //     text: 'Hello',
    //     time: CaptionWriterTimestamp(start: 65, end: 6500),
    //   ),
    //   CaptionWriterParams(
    //     text: 'Bye',
    //     time: CaptionWriterTimestamp(start: 6500, end: 16500),
    //   )
    // ]);

    writer.process(File(''), [
      CaptionWriterParams(
        text: 'Hello',
        time: CaptionWriterTimestamp(start: 65, end: 6500),
      ),
      CaptionWriterParams(
        text: 'Bye',
        time: CaptionWriterTimestamp(start: 6500, end: 16500),
      )
    ]);
  });
}
