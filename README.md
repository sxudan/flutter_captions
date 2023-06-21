# Flutter Captions

A Flutter library for adding captions to a video.

## Installation


## Example

You can find the example project here in this repository.

## Usage
> 
`Initialize CaptionWriter`
>
> final writer = CaptionWriter();
> 
> or
> 
> final writer = CaptionWriter(
      decoration: CaptionWriterDecoration(
          postion: CaptionWriterPostion.BottomCenter,
          fontSize: 12,
          margins: const EdgeInsets.all(24),
          shadow: 0.5,
          outline: 0,
          fontName: 'Arial',
          fontColor: Colors.white,
          bold: false,
          italic: false,
          underlined: false,
          borderStyle: 0,
          wrapStyle: 0,
          outlineColor: Colors.amber));
> 
`Adds caption and return output file`
>
> String out = await writer.process(File(path), \[
                CaptionWriterParams(
                  text: 'Hello',
                  time: CaptionWriterTimestamp(start: 65, end: 6500),
                ),
                CaptionWriterParams(
                  text: 'Bye',
                  time: CaptionWriterTimestamp(start: 6500, end: 16500),
                )
              \]);
### Caption Postions
- BottomLeft
- BottomCenter
- BottomRight
- CenterLeft
- Center
- CenterRight
- TopLeft
- TopCenter
- TopRight
