import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _size = 1024;
const _designSize = 512.0;

void main() {
  final output = Directory('assets/generated')..createSync(recursive: true);

  _writePng(
    File('${output.path}/sonicnest_icon.png'),
    _renderFullIcon(),
    _size,
    _size,
  );
  _writePng(
    File('${output.path}/sonicnest_icon_foreground.png'),
    _renderForeground(),
    _size,
    _size,
  );
  _writePng(
    File('${output.path}/sonicnest_splash.png'),
    _renderSplash(),
    _size,
    _size,
  );

  stdout.writeln('Generated SonicNest native branding assets.');
}

Uint8List _renderFullIcon() {
  final image = Uint8List(_size * _size * 4);
  for (var y = 0; y < _size; y++) {
    for (var x = 0; x < _size; x++) {
      final t = ((x + y) / (2 * (_size - 1))).clamp(0.0, 1.0);
      final color = _gradient(t);
      _setPixel(image, x, y, color.$1, color.$2, color.$3, 255);
    }
  }
  _drawMark(image, _Transform.fullCanvas(), opacity: 1);
  return image;
}

Uint8List _renderForeground() {
  final image = Uint8List(_size * _size * 4);
  final transform = _Transform(
    scale: 1.38,
    offsetX: (_size - _designSize * 1.38) / 2,
    offsetY: (_size - _designSize * 1.38) / 2,
  );
  _drawMark(image, transform, opacity: 1);
  return image;
}

Uint8List _renderSplash() {
  final image = Uint8List(_size * _size * 4);
  const markSize = 560.0;
  final left = (_size - markSize) / 2;
  final top = (_size - markSize) / 2;
  final radius = markSize * (112 / _designSize);

  for (var y = math.max(0, top.floor());
      y < math.min(_size, (top + markSize).ceil());
      y++) {
    for (var x = math.max(0, left.floor());
        x < math.min(_size, (left + markSize).ceil());
        x++) {
      final coverage = _roundedRectCoverage(
        x + .5,
        y + .5,
        left,
        top,
        markSize,
        markSize,
        radius,
      );
      if (coverage <= 0) continue;
      final localX = (x - left) / markSize;
      final localY = (y - top) / markSize;
      final t = ((localX + localY) / 2).clamp(0.0, 1.0);
      final color = _gradient(t);
      _blendPixel(
        image,
        x,
        y,
        color.$1,
        color.$2,
        color.$3,
        coverage,
      );
    }
  }

  _drawMark(
    image,
    _Transform(
      scale: markSize / _designSize,
      offsetX: left,
      offsetY: top,
    ),
    opacity: 1,
  );
  return image;
}

(int, int, int) _gradient(double t) {
  const a = (0x75, 0x67, 0xFF);
  const b = (0x48, 0x56, 0xE8);
  const c = (0x24, 0x47, 0xC7);
  if (t <= .55) {
    final u = t / .55;
    return (
      _lerp(a.$1, b.$1, u),
      _lerp(a.$2, b.$2, u),
      _lerp(a.$3, b.$3, u),
    );
  }
  final u = (t - .55) / .45;
  return (
    _lerp(b.$1, c.$1, u),
    _lerp(b.$2, c.$2, u),
    _lerp(b.$3, c.$3, u),
  );
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _drawMark(
  Uint8List image,
  _Transform transform, {
  required double opacity,
}) {
  final stroke = 28 * transform.scale;
  final thinStroke = 16 * transform.scale;

  _strokeRoundedRect(
    image,
    transform.x(206),
    transform.y(94),
    100 * transform.scale,
    214 * transform.scale,
    50 * transform.scale,
    stroke,
    opacity,
  );

  final arc = <math.Point<double>>[];
  for (var i = 0; i <= 48; i++) {
    final theta = i * math.pi / 48;
    arc.add(
      math.Point(
        transform.x(352 - 96 * (1 - math.cos(theta))),
        transform.y(246 + 96 * math.sin(theta)),
      ),
    );
  }
  for (var i = 1; i < arc.length; i++) {
    _drawSegment(image, arc[i - 1], arc[i], stroke, opacity);
  }

  _drawSegment(
    image,
    math.Point(transform.x(256), transform.y(342)),
    math.Point(transform.x(256), transform.y(410)),
    stroke,
    opacity,
  );
  _drawSegment(
    image,
    math.Point(transform.x(206), transform.y(410)),
    math.Point(transform.x(306), transform.y(410)),
    stroke,
    opacity,
  );

  _drawSegment(
    image,
    math.Point(transform.x(112), transform.y(177)),
    math.Point(transform.x(112), transform.y(269)),
    thinStroke,
    opacity * .78,
  );
  _drawSegment(
    image,
    math.Point(transform.x(144), transform.y(145)),
    math.Point(transform.x(144), transform.y(301)),
    thinStroke,
    opacity * .78,
  );
  _drawSegment(
    image,
    math.Point(transform.x(368), transform.y(145)),
    math.Point(transform.x(368), transform.y(301)),
    thinStroke,
    opacity * .78,
  );
  _drawSegment(
    image,
    math.Point(transform.x(400), transform.y(177)),
    math.Point(transform.x(400), transform.y(269)),
    thinStroke,
    opacity * .78,
  );
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
  final minX = math.max(0, (x - padding).floor());
  final maxX = math.min(_size - 1, (x + width + padding).ceil());
  final minY = math.max(0, (y - padding).floor());
  final maxY = math.min(_size - 1, (y + height + padding).ceil());
  final cx = x + width / 2;
  final cy = y + height / 2;
  final bx = width / 2 - radius;
  final by = height / 2 - radius;

  for (var py = minY; py <= maxY; py++) {
    for (var px = minX; px <= maxX; px++) {
      final qx = (px + .5 - cx).abs() - bx;
      final qy = (py + .5 - cy).abs() - by;
      final ox = math.max(qx, 0.0);
      final oy = math.max(qy, 0.0);
      final outside = math.sqrt(ox * ox + oy * oy);
      final inside = math.min(math.max(qx, qy), 0.0);
      final signedDistance = outside + inside - radius;
      final distanceToStroke = signedDistance.abs();
      final coverage = _edgeCoverage(distanceToStroke, stroke / 2) * opacity;
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
  final minX = math.max(0, (math.min(start.x, end.x) - radius - 2).floor());
  final maxX = math.min(
    _size - 1,
    (math.max(start.x, end.x) + radius + 2).ceil(),
  );
  final minY = math.max(0, (math.min(start.y, end.y) - radius - 2).floor());
  final maxY = math.min(
    _size - 1,
    (math.max(start.y, end.y) + radius + 2).ceil(),
  );
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  final lengthSquared = dx * dx + dy * dy;

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      final px = x + .5;
      final py = y + .5;
      final t = lengthSquared == 0
          ? 0.0
          : (((px - start.x) * dx + (py - start.y) * dy) / lengthSquared)
              .clamp(0.0, 1.0);
      final nearestX = start.x + dx * t;
      final nearestY = start.y + dy * t;
      final ddx = px - nearestX;
      final ddy = py - nearestY;
      final distance = math.sqrt(ddx * ddx + ddy * ddy);
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
  final ox = math.max(qx, 0.0);
  final oy = math.max(qy, 0.0);
  final signedDistance =
      math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0.0) - radius;
  return (0.5 - signedDistance).clamp(0.0, 1.0);
}

double _edgeCoverage(double distance, double radius) =>
    (radius + .75 - distance).clamp(0.0, 1.0);

void _setPixel(
  Uint8List image,
  int x,
  int y,
  int r,
  int g,
  int b,
  int a,
) {
  final index = (y * _size + x) * 4;
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
  final index = (y * _size + x) * 4;
  final sourceA = alpha.clamp(0.0, 1.0);
  final destinationA = image[index + 3] / 255;
  final outA = sourceA + destinationA * (1 - sourceA);
  if (outA <= 0) return;
  image[index] = ((r * sourceA + image[index] * destinationA * (1 - sourceA)) /
          outA)
      .round()
      .clamp(0, 255);
  image[index + 1] =
      ((g * sourceA + image[index + 1] * destinationA * (1 - sourceA)) / outA)
          .round()
          .clamp(0, 255);
  image[index + 2] =
      ((b * sourceA + image[index + 2] * destinationA * (1 - sourceA)) / outA)
          .round()
          .clamp(0, 255);
  image[index + 3] = (outA * 255).round().clamp(0, 255);
}

void _writePng(File file, Uint8List rgba, int width, int height) {
  final raw = BytesBuilder(copy: false);
  final stride = width * 4;
  for (var y = 0; y < height; y++) {
    raw.addByte(0);
    raw.add(rgba.sublist(y * stride, (y + 1) * stride));
  }

  final bytes = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10]);
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 6)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);
  _addChunk(bytes, 'IHDR', header.buffer.asUint8List());
  _addChunk(bytes, 'IDAT', Uint8List.fromList(ZLibEncoder().convert(raw.takeBytes())));
  _addChunk(bytes, 'IEND', Uint8List(0));
  file.writeAsBytesSync(bytes.takeBytes(), flush: true);
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

  factory _Transform.fullCanvas() => const _Transform(
        scale: _size / _designSize,
        offsetX: 0,
        offsetY: 0,
      );

  final double scale;
  final double offsetX;
  final double offsetY;

  double x(double value) => offsetX + value * scale;
  double y(double value) => offsetY + value * scale;
}
