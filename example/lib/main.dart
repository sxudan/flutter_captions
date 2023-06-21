import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_captions/flutter_captions.dart';
import 'package:images_picker/images_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  VideoPlayerController? controller;
  final writer = CaptionWriter();
  int duration = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('Video Caption'),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [buildContent()],
        ),
      ),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        TextButton(
            onPressed: () async {
              final v =
                  await ImagesPicker.pick(count: 1, pickType: PickType.video);
              if (v == null) {
                print('error');
                return;
              }
              String path = v.single.path;
              final originalController = VideoPlayerController.file(File(path));
              await originalController.initialize();
              duration = originalController.value.duration.inMilliseconds;
              setState(() {});
              String out = await writer.process(File(path), [
                CaptionWriterParams(
                  text: 'Hello',
                  time: CaptionWriterTimestamp(start: 65, end: 6500),
                ),
                CaptionWriterParams(
                  text: 'Bye',
                  time: CaptionWriterTimestamp(start: 6500, end: 16500),
                )
              ]);
              controller = VideoPlayerController.file(File(out));
              await controller?.initialize();
              controller?.play();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.green,
              child: Text(
                'Add caption',
                style: TextStyle(color: Colors.white),
              ),
            )),
        Expanded(
            child: Stack(
          children: [
            if (controller != null &&
                (controller?.value.isInitialized ?? false))
              Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  child: AspectRatio(
                    aspectRatio: controller!.value.size.aspectRatio,
                    child: Stack(
                      children: [VideoPlayer(controller!)],
                    ),
                  ),
                ),
              ),
            StreamBuilder<int>(
              stream: writer.timeStream,
              builder: (context, snapshot) {
                if ((snapshot.data ?? 0) == 0) {
                  return SizedBox();
                }
                if (duration == 0) {
                  return Center(
                    child: Text('$duration%'),
                  );
                }
                final progress = ((snapshot.data ?? 0) * 100) ~/ duration;
                return Center(
                  child: Text('$progress%'),
                );
              },
            )
          ],
        ))
      ],
    );
  }
}
