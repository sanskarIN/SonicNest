import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int canvasSize = 1024;
const double designSize = 512;

void main() {
  final output = Directory('assets/generated')..createSync(recursive: true);

  _writePng(
    File('${output.path}/sonicnest_icon.png'),
    _renderIcon(),
    canvasSize,
    canvasSize,
  );
  _writePng(
    File('${output.path}/sonicnest_icon_foreground.png'),
    _renderForeground(),
    canvasSize,
    canvasSize,
  );
  _writePng(
    File('${output.path}/sonicnest_splash.png'),
    _renderSplash(),
    canvasSize,
    canvasSize,
  );

  stdout.writeln('Generated deterministic SonicNest native branding PNGs.');
}

Uint8List _renderIcon() {
  final image = Uint8List(canvasSize * canvasSize * 4);
  for (var y = 0; y < canvasSize; y++) {
    for (var x = 0; x < canvasSize; x++) {
      final t = ((x + y) / (2 * (canvasSize - 1))).clamp(0.0, 1.0).toDouble();
      final color = _gradient(t);
      _setPixel(image, x, y, color.$1, color.$2, color.$3, 255);
    }
  }
  _drawMark(image, const _Transform(scale: 2, offsetX: 0, offsetY: 0));
  return image;
}

Uint8List _renderForeground() {
  final image = Uint8List(canvasSize * canvasSize * 4);
  const scale = 1.38;
  final offset = (canvasSize - designSize * scale) / 2;
  _drawMark(image, _Transform(scale: scale, offsetX: offset, offsetY: offset));
  return image;
}

Uint8List _renderSplash() {
  final image = Uint8List(canvasSize * canvasSize * 4);
  const markSize = 560.0;
  final left = (canvasSize - markSize) / 2;
  final top = (canvasSize - markSize) / 2;
  final radius = markSize * 112 / designSize;
  final minX = math.max(0, left.floor()).toInt();
  final maxX = math.min(canvasSize - 1, (left + markSize).ceil()).toInt();
  final minY = math.max(0, top.floor()).toInt();
  final maxY = math.min(canvasSize - 1, (top + markSize).ceil()).toInt();

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final coverage = _roundedRectCoverage(
        x + .5,
        y + .5,
        left,
        top,
        markSize,
        markSize,
        radius,
      );
      if (coverage <= 0) {
        continue;
      }
      final t = (((x - left) / markSize + (y - top) / markSize) / 2)
          .clamp(0.0, 1.0)
          .toDouble();
      final color = _gradient(t);
      _blendPixel(image, x, y, color.$1, color.$2, color.$3, coverage);
    }
  }

  _drawMark(
    image,
    _Transform(scale: markSize / designSize, offsetX: left, offsetY: top),
  );
  return image;
}

(int, int, int) _gradient(double t) {
  const start = (0x75, 0x67, 0xFF);
  const middle = (0x48, 0x56, 0xE8);
  const end = (0x24, 0x47, 0xC7);
  if (t <= .55) {
    final u = t / .55;
    return (
      _lerp(start.$1, middle.$1, u),
      _lerp(start.$2, middle.$2, u),
      _lerp(start.$3, middle.$3, u),
    );
  }
  final u = (t - .55) / .45;
  return (
    _lerp(middle.$1, end.$1, u),
    _lerp(middle.$2, end.$2, u),
    _lerp(middle.$3, end.$3, u),
  );
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _drawMark(Uint8List image, _Transform transform) {
  final mainStroke = 28 * transform.scale;
  final waveStroke = 16 * transform.scale;

  _strokeRoundedRect(
    image,
    transform.x(206),
    transform.y(94),
    100 * transform.scale,
    214 * transform.scale,
    50 * transform.scale,
    mainStroke,
    1,
  );

  final arc = <math.Point<double>>[];
  for (var i = 0; i <= 48; i++) {
    final theta = i * math.pi / 48;
    arc.add(
      math.Point<double>(
        transform.x(256 + 96 * math.cos(theta)),
        transform.y(246 + 96 * math.sin(theta)),
      ),
    );
  }
  for (var i = 1; i < arc.length; i++) {
    _drawSegment(image, arc[i - 1], arc[i], mainStroke, 1);
  }

  _drawSegment(
    image,
    math.Point<double>(transform.x(256), transform.y(342)),
    math.Point<double>(transform.x(256), transform.y(410)),
    mainStroke,
    1,
  );
  _drawSegment(
    image,
    math.Point<double>(transform.x(206), transform.y(410)),
    math.Point<double>(transform.x(306), transform.y(410)),
    mainStroke,
    1,
  );

  for (final wave in const [
    (112.0, 177.0, 269.0),
    (144.0, 145.0, 301.0),
    (368.0, 145.0, 301.0),
    (400.0, 177.0, 269.0),
  ]) {
    _drawSegment(
      image,
      math.Point<double>(transform.x(wave.$1), transform.y(wave.$2)),
      math.Point<double>(transform.x(wave.$1), transform.y(wave.$3)),
      waveStroke,
      .78,
    );
  }
}

void _strokeRoundedRect(
  Uint8List image,
  double x,
  double y,
  double width,
  double height,
  double radius,
  double stroke,
  double opacity,
) {
  final padding = stroke / 2 + 2;
  final minX = math.max(0, (x - padding).floor()).toInt();
  final maxX = math.min(canvasSize - 1, (x + width + padding).ceil()).toInt();
  final minY = math.max(0, (y - padding).floor()).toInt();
  final maxY = math.min(canvasSize - 1, (y + height + padding).ceil()).toInt();
  final cx = x + width / 2;
  final cy = y + height / 2;
  final bx = width / 2 - radius;
  final by = height / 2 - radius;

  for (var py = minY; py <= maxY; py++) {
    for (var px = minX; px <= maxX; px++) {
      final qx = (px + .5 - cx).abs() - bx;
      final qy = (py + .5 - cy).abs() - by;
      final ox = math.max(qx, 0.0).toDouble();
      final oy = math.max(qy, 0.0).toDouble();
      final outside = math.sqrt(ox * ox + oy * oy);
      final inside = math.min(math.max(qx, qy), 0.0).toDouble();
      final signedDistance = outside + inside - radius;
      final coverage =
          _edgeCoverage(signedDistance.abs(), stroke / 2) * opacity;
      if (coverage > 0) {
        _blendPixel(image, px, py, 255, 255, 255, coverage);
      }
    }
  }
}

void _drawSegment(
  Uint8List image,
  math.Point<double> start,
  math.Point<double> end,
  double stroke,
  double opacity,
) {
  final radius = stroke / 2;
  final minX = math
      .max(0, (math.min(start.x, end.x) - radius - 2).floor())
      .toInt();
  final maxX = math
      .min(canvasSize - 1, (math.max(start.x, end.x) + radius + 2).ceil())
      .toInt();
  final minY = math
      .max(0, (math.min(start.y, end.y) - radius - 2).floor())
      .toInt();
  final maxY = math
      .min(canvasSize - 1, (math.max(start.y, end.y) + radius + 2).ceil())
      .toInt();
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  final lengthSquared = dx * dx + dy * dy;

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final px = x + .5;
      final py = y + .5;
      final projection = lengthSquared == 0
          ? 0.0
          : (((px - start.x) * dx + (py - start.y) * dy) / lengthSquared)
                .clamp(0.0, 1.0)
                .toDouble();
      final nearestX = start.x + dx * projection;
      final nearestY = start.y + dy * projection;
      final distance = math.sqrt(
        math.pow(px - nearestX, 2) + math.pow(py - nearestY, 2),
      );
      final coverage = _edgeCoverage(distance, radius) * opacity;
      if (coverage > 0) {
        _blendPixel(image, x, y, 255, 255, 255, coverage);
      }
    }
  }
}

double _roundedRectCoverage(
  double px,
  double py,
  double x,
  double y,
  double width,
  double height,
  double radius,
) {
  final cx = x + width / 2;
  final cy = y + height / 2;
  final qx = (px - cx).abs() - (width / 2 - radius);
  final qy = (py - cy).abs() - (height / 2 - radius);
  final ox = math.max(qx, 0.0).toDouble();
  final oy = math.max(qy, 0.0).toDouble();
  final signedDistance =
      math.sqrt(ox * ox + oy * oy) +
      math.min(math.max(qx, qy), 0.0).toDouble() -
      radius;
  return (0.5 - signedDistance).clamp(0.0, 1.0).toDouble();
}

double _edgeCoverage(double distance, double radius) =>
    (radius + .75 - distance).clamp(0.0, 1.0).toDouble();

void _setPixel(Uint8List image, int x, int y, int r, int g, int b, int a) {
  final index = (y * canvasSize + x) * 4;
  image[index] = r;
  image[index + 1] = g;
  image[index + 2] = b;
  image[index + 3] = a;
}

void _blendPixel(
  Uint8List image,
  int x,
  int y,
  int r,
  int g,
  int b,
  double alpha,
) {
  final index = (y * canvasSize + x) * 4;
  final sourceA = alpha.clamp(0.0, 1.0).toDouble();
  final destinationA = image[index + 3] / 255;
  final outA = sourceA + destinationA * (1 - sourceA);
  if (outA <= 0) {
    return;
  }

  image[index] = _channel(
    (r * sourceA + image[index] * destinationA * (1 - sourceA)) / outA,
  );
  image[index + 1] = _channel(
    (g * sourceA + image[index + 1] * destinationA * (1 - sourceA)) / outA,
  );
  image[index + 2] = _channel(
    (b * sourceA + image[index + 2] * destinationA * (1 - sourceA)) / outA,
  );
  image[index + 3] = _channel(outA * 255);
}

int _channel(num value) => value.round().clamp(0, 255).toInt();

void _writePng(File file, Uint8List rgba, int width, int height) {
  final raw = BytesBuilder(copy: false);
  final stride = width * 4;
  for (var y = 0; y < height; y++) {
    raw.addByte(0);
    raw.add(rgba.sublist(y * stride, (y + 1) * stride));
  }

  final output = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10]);
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 6)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  _addChunk(output, 'IHDR', header.buffer.asUint8List());
  _addChunk(
    output,
    'IDAT',
    Uint8List.fromList(ZLibEncoder().convert(raw.takeBytes())),
  );
  _addChunk(output, 'IEND', Uint8List(0));
  file.writeAsBytesSync(output.takeBytes(), flush: true);
}

void _addChunk(BytesBuilder output, String type, Uint8List data) {
  final typeBytes = Uint8List.fromList(type.codeUnits);
  final length = ByteData(4)..setUint32(0, data.length);
  output
    ..add(length.buffer.asUint8List())
    ..add(typeBytes)
    ..add(data);
  final crcInput = Uint8List(typeBytes.length + data.length)
    ..setAll(0, typeBytes)
    ..setAll(typeBytes.length, data);
  final crc = ByteData(4)..setUint32(0, _crc32(crcInput));
  output.add(crc.buffer.asUint8List());
}

int _crc32(Uint8List bytes) {
  var crc = 0xFFFFFFFF;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

class _Transform {
  const _Transform({
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  final double scale;
  final double offsetX;
  final double offsetY;

  double x(double value) => offsetX + value * scale;
  double y(double value) => offsetY + value * scale;
}
