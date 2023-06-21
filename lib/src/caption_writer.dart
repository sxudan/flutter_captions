import 'dart:io';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CaptionWriterDecoration {
  CaptionWriterDecoration(
      {this.postion = CaptionWriterPostion.bottomCenter,
      this.fontSize = 12,
      this.margins = const EdgeInsets.all(24),
      this.shadow = 0.5,
      this.outline = 0,
      this.fontName,
      this.fontColor = Colors.white,
      this.bold = false,
      this.italic = false,
      this.underlined = false,
      this.borderStyle = 0,
      this.wrapStyle = 0,
      this.outlineColor});

  final CaptionWriterPostion postion;
  final double fontSize;
  final EdgeInsets margins;
  final double shadow;
  final double outline;
  final Color? outlineColor;
  final String? fontName;
  final Color fontColor;
  final bool bold;
  final bool italic;
  final bool underlined;
  final int borderStyle;
  final int wrapStyle;
}

enum CaptionWriterPostion {
  bottomLeft,
  bottomCenter,
  bottomRight,
  centerLeft,
  center,
  centerRight,
  topLeft,
  topCenter,
  topRight;

  int getValue() {
    switch (this) {
      case bottomLeft:
        return 1;
      case bottomCenter:
        return 2;
      case bottomRight:
        return 3;
      case centerLeft:
        return 8;
      case center:
        return 10;
      case centerRight:
        return 11;
      case topLeft:
        return 4;
      case topCenter:
        return 6;
      case topRight:
        return 7;
    }
  }
}

class CaptionWriterTimestamp {
  /// [start] caption start time in ms
  /// [end] caption end time in ms
  CaptionWriterTimestamp({required this.start, required this.end});
  final int start;
  final int end;
}

class CaptionWriterParams {
  CaptionWriterParams({required this.text, required this.time});
  final String text;
  final CaptionWriterTimestamp time;
}

extension ColorX on Color {
  String toHexTriplet() =>
      (value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
}

class CaptionWriter {
  CaptionWriter({this.decoration});
  final StreamController<int> _streamController = StreamController.broadcast();
  Stream<int> get timeStream => _streamController.stream;

  String _srtTimestamp(int ms) {
    var milliseconds = ms;
    var seconds = (milliseconds / 1000).floor();
    var minutes = (seconds / 60).floor();
    var hours = (minutes / 60).floor();
    milliseconds = milliseconds % 1000;
    seconds = seconds % 60;
    minutes = minutes % 60;
    return "${(hours < 10 ? '0' : '')}$hours:${(minutes < 10 ? '0' : '')}$minutes:${(seconds < 10 ? '0' : '')}$seconds,${milliseconds < 100 ? '0' : ''}${milliseconds < 10 ? '0' : ''}$milliseconds";
  }

  String _generateText(List<CaptionWriterParams> param) {
    final sub = param
        .mapIndexed((i, p) =>
            '${i + 1}\n${_srtTimestamp(p.time.start)} --> ${_srtTimestamp(p.time.end)}\n${p.text}')
        .toList()
        .join('\n\n');
    return sub;
  }

  Future<String> _getSubtitlePath(List<CaptionWriterParams> param) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    File subtitleFile = File('${tempDir.path}/subtitles/sub.srt');
    if (subtitleFile.existsSync()) {
      subtitleFile.deleteSync(recursive: true);
    }
    subtitleFile.createSync(recursive: true);
    String sub = _generateText(param);
    return (await subtitleFile.writeAsString(sub)).path;
  }

  String _generateCommand(
      String videoInputPath, String subtitlePath, String outputPath) {
    // ignore: prefer_collection_literals
    Map<String, dynamic> style = Map();
    decoration ??= CaptionWriterDecoration();
    style['Alignment'] = decoration!.postion.getValue();
    style['Fontsize'] = decoration!.fontSize;
    style['Outline'] = decoration!.outline;
    style['OutlineColour'] = decoration!.outlineColor == null
        ? null
        : '&H${decoration!.outlineColor!.toHexTriplet()}&';
    style['Shadow'] = decoration!.shadow;
    style['MarginT'] = decoration!.margins.top;
    style['MarginB'] = decoration!.margins.bottom;
    style['MarginL'] = decoration!.margins.left;
    style['MarginR'] = decoration!.margins.right;
    style['FontName'] = decoration!.fontName;
    style['BorderStyle'] = decoration!.borderStyle;
    style['WrapStyle'] = decoration!.wrapStyle;
    style['Bold'] = decoration!.bold ? 1 : 0;
    style['italic'] = decoration!.italic ? 1 : 0;
    style['Underline'] = decoration!.underlined ? 1 : 0;
    style['PrimaryColour'] = '&H${decoration!.fontColor.toHexTriplet()}&';
    final str = style.keys
        .where((element) => style[element] != null)
        .map((e) => style[e] == null ? '' : '$e=${style[e]}')
        .toList()
        .join(',');

    final command =
        '-i $videoInputPath -filter_complex "subtitles=$subtitlePath:force_style=\'$str\'" -b:v 20M -vcodec h264 $outputPath';
    return command;
  }

  Future<String> _getVideoOutputPath({bool delete = false}) async {
    // // setup outputPath
    Directory tempDir = await getApplicationDocumentsDirectory();
    File output = File('${tempDir.path}/output/out.mp4');
    if (delete) {
      if (output.existsSync()) {
        output.deleteSync(recursive: true);
      }
    }
    // output.createSync(recursive: true);
    return output.path;
  }

  Future<String> process(
      final File videoInput, List<CaptionWriterParams> param) async {
    // /// file path for the subtitle
    String sub = await _getSubtitlePath(param);
    String out = await _getVideoOutputPath(delete: true);
    String command = _generateCommand(videoInput.path, sub, out);
    final Completer<String> completer = Completer<String>();
    FFmpegKit.executeAsync(
        command,
        (session) async {
          final code = await session.getReturnCode();
          if (ReturnCode.isSuccess(code)) {
            completer.complete(out);
          } else {
            completer.completeError(session.getOutput());
          }
          _streamController.add(0);
        },
        (log) {},
        (stats) {
          if (stats.getTime() > 0) {
            _streamController.add(stats.getTime());
          }
        });
    return completer.future;
  }

  CaptionWriterDecoration? decoration;
}
