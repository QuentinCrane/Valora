part of '../main.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('valora/native');

  static Future<T?> _call<T>(
    String method, [
    Map<String, dynamic>? args,
  ]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } catch (_) {
      return null;
    }
  }

  static Future<void> configureSystemUi() async {
    await _call<Object>('configureSystemUi');
  }

  static Future<void> haptic(String style) async {
    await _call<Object>('haptic', {'style': style});
  }

  static Future<String?> pickImage() => _call<String>('pickImage');

  static Future<String?> pickNativeDate({String? initialDate, String? title}) =>
      _call<String>('pickNativeDate', {
        'initialDate': initialDate ?? '',
        'title': title ?? '选择日期',
      });

  static Future<String?> capturePhoto() => _call<String>('capturePhoto');

  static Future<String?> scanBarcodeFromImage() =>
      _call<String>('scanBarcodeFromImage');

  static Future<String?> recognizeReceiptFromImage() =>
      _call<String>('recognizeReceiptFromImage');

  static Future<String?> cutoutImageFromPicker() =>
      _call<String>('cutoutImageFromPicker');

  static Future<Map<String, dynamic>> cutoutImageFromPickerDetailed() async =>
      nativeJsonMap(await _call<String>('cutoutImageFromPickerDetailed'));

  static Future<void> setStickerEngineConfig({
    required String mode,
    required bool keepCandidates,
  }) async {
    await _call<Object>('setStickerEngineConfig', {
      'mode': mode,
      'keepCandidates': keepCandidates,
    });
  }

  static Future<Map<String, dynamic>> getStickerEngineConfig() async =>
      nativeJsonMap(await _call<String>('getStickerEngineConfig'));

  static Future<String?> persistImageUri(String uri) =>
      _call<String>('persistImageUri', {'uri': uri});

  static Future<String?> readClipboard() => _call<String>('readClipboard');

  static Future<void> writeClipboard(String text) async {
    await _call<Object>('writeClipboard', {'text': text});
  }

  static Future<String?> importTextFile({String mimeType = '*/*'}) =>
      _call<String>('importTextFile', {'mimeType': mimeType});

  static Future<String?> exportTextFile({
    required String fileName,
    required String text,
    String mimeType = 'text/plain',
  }) => _call<String>('exportTextFile', {
    'fileName': fileName,
    'mimeType': mimeType,
    'text': text,
  });

  static Future<void> shareText({
    required String title,
    required String text,
  }) async {
    await _call<Object>('shareText', {'title': title, 'text': text});
  }

  static Future<void> shareDataArchive({
    required String title,
    required String json,
    required String csv,
    required String markdown,
    required List<String> mediaPaths,
    required String fileName,
  }) async {
    await _call<Object>('shareDataArchive', {
      'title': title,
      'json': json,
      'csv': csv,
      'markdown': markdown,
      'mediaPaths': mediaPaths,
      'fileName': fileName,
    });
  }

  static Future<Map<String, dynamic>> importDataArchive() async =>
      nativeJsonMap(await _call<String>('importDataArchive'));

  static Future<String?> readPrivateTextFile(String path) =>
      _call<String>('readPrivateTextFile', {'path': path});

  static Future<bool> scheduleNotification({
    required String title,
    required String text,
    int delayMillis = 60000,
  }) async =>
      await _call<bool>('scheduleNotification', {
        'title': title,
        'text': text,
        'delayMillis': delayMillis,
      }) ??
      false;

  static Future<bool> cancelNotifications() async =>
      await _call<bool>('cancelNotifications') ?? false;

  static Future<bool> createShortcuts() async =>
      await _call<bool>('createShortcuts') ?? false;

  static Future<void> updateHomeWidget({
    required int assetCount,
    required int wishCount,
    required double totalAssetValue,
    required double averageDailyCost,
    required String currency,
    int servingCount = 0,
    int retiredCount = 0,
    int soldCount = 0,
    int dueSoonCount = 0,
    int leakCount = 0,
    int snapshotCount = 0,
  }) async {
    await _call<Object>('updateHomeWidget', {
      'assetCount': assetCount,
      'wishCount': wishCount,
      'totalAssetValue': totalAssetValue,
      'averageDailyCost': averageDailyCost,
      'currency': currency,
      'servingCount': servingCount,
      'retiredCount': retiredCount,
      'soldCount': soldCount,
      'dueSoonCount': dueSoonCount,
      'leakCount': leakCount,
      'snapshotCount': snapshotCount,
    });
  }

  static Future<String?> getInitialIntentInfo() =>
      _call<String>('getInitialIntentInfo');

  static void listenIncomingIntents(ValueChanged<String> onInfo) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'incomingShareChanged') {
        onInfo(call.arguments?.toString() ?? '');
      }
    });
  }

  static Future<bool> requestNotificationPermission() async =>
      await _call<bool>('requestNotificationPermission') ?? false;

  static Future<bool> openNotificationSettings() async =>
      await _call<bool>('openNotificationSettings') ?? false;

  static Future<bool> openAppSettings() async =>
      await _call<bool>('openAppSettings') ?? false;
}

String buildAssetsCsv(AppStore store) {
  String cell(String value) => '"${value.replaceAll('"', '""')}"';
  final rows = <List<String>>[
    ['名称', '分类', '价格', '当前价值', '购买日期', '状态', '日均成本', '标签', '备注'],
    ...store.assets.map(
      (a) => [
        a.name,
        store.categoryName(a.categoryId),
        a.price.toStringAsFixed(2),
        a.assetValue.toStringAsFixed(2),
        dateText(a.purchaseDate),
        a.status.label,
        a.dailyCost.toStringAsFixed(2),
        a.tagIds.map((id) => store.tagById(id)?.name ?? id).join('/'),
        a.note,
      ],
    ),
  ];
  return rows.map((r) => r.map(cell).join(',')).join('\n');
}

String buildMarkdownReport(AppStore store) {
  final buffer = StringBuffer();
  buffer.writeln('# 值谱资产报告');
  buffer.writeln();
  buffer.writeln('- 生成时间：${DateTime.now().toIso8601String()}');
  buffer.writeln('- 资产数量：${store.assets.length}');
  buffer.writeln('- 心愿数量：${store.wishes.where((w) => !w.archived).length}');
  buffer.writeln('- 总资产：${money(store.getTotalAssetValue(), store.settings)}');
  buffer.writeln(
    '- 平均日耗：${money(store.getAverageDailyCost(), store.settings)} / 天',
  );
  buffer.writeln();
  buffer.writeln('## 资产清单');
  buffer.writeln();
  if (store.assets.isEmpty) {
    buffer.writeln('暂无资产。');
  } else {
    buffer.writeln('| 名称 | 分类 | 状态 | 当前价值 | 日均成本 |');
    buffer.writeln('|---|---|---|---:|---:|');
    for (final a in store.assets) {
      buffer.writeln(
        '| ${a.iconValue} ${a.name} | ${store.categoryName(a.categoryId)} | ${a.status.label} | ${money(a.assetValue, store.settings)} | ${money(a.dailyCost, store.settings)} |',
      );
    }
  }
  buffer.writeln();
  buffer.writeln('## 钱包漏洞');
  final leaks = store.walletLeaks(limit: 8);
  if (leaks.isEmpty) {
    buffer.writeln('暂无明显高日耗、闲置或临期风险。');
  } else {
    for (final item in leaks) {
      buffer.writeln(
        '- **${item.asset.name}**：${item.reason}。${item.suggestion}',
      );
    }
  }
  return buffer.toString();
}

String dateStamp() {
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}';
}

String dateLabel(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)} ${two(date.hour)}:${two(date.minute)}';
}

void showNativeSnack(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  final bottom =
      MediaQuery.paddingOf(context).bottom +
      (valoraCompactSnackbars ? 92.0 : 24.0);
  messenger.showSnackBar(
    SnackBar(
      content: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
      duration: const Duration(milliseconds: 1800),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      dismissDirection: DismissDirection.horizontal,
      action: SnackBarAction(
        label: '关闭',
        textColor: const Color(0xFF7CC6F2),
        onPressed: () => messenger.hideCurrentSnackBar(),
      ),
    ),
  );
}

Map<String, dynamic> nativeJsonMap(String? raw) {
  if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map)
      return decoded.map((key, value) => MapEntry(key.toString(), value));
  } catch (_) {}
  return <String, dynamic>{};
}

String appendLine(String current, String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return current;
  if (current.trim().isEmpty) return trimmed;
  return '${current.trim()}\n$trimmed';
}

String appendTagText(String current, String tag) {
  final trimmed = tag.trim();
  if (trimmed.isEmpty) return current;
  final parts = splitTags(current);
  if (parts.contains(trimmed)) return current;
  return parts.isEmpty ? trimmed : '${parts.join('、')}、$trimmed';
}

String filePathFromUriText(String uri) {
  if (uri.startsWith('file://')) {
    try {
      return Uri.parse(uri).toFilePath();
    } catch (_) {}
  }
  return uri;
}

void cleanupUnusedStickerCandidates(
  Map<String, dynamic> payload,
  String selectedUri, {
  required bool keepCandidates,
}) {
  if (keepCandidates) return;
  final rawCandidates = payload['candidates'];
  if (rawCandidates is! List) return;
  for (final item in rawCandidates) {
    final map = item is Map<String, dynamic>
        ? item
        : (item is Map
              ? item.map((key, value) => MapEntry(key.toString(), value))
              : null);
    if (map == null) continue;
    final uri = (map['uri'] ?? '').toString().trim();
    if (uri.isEmpty || uri == selectedUri) continue;
    try {
      final file = File(filePathFromUriText(uri));
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }
}

void deleteGeneratedStickerFile(String uri) {
  try {
    if (!isValoraStickerImage(uri)) return;
    final file = File(filePathFromUriText(uri));
    if (file.existsSync()) file.deleteSync();
  } catch (_) {}
}

class _StickerBrushStroke {
  final String mode;
  final List<Offset> points;
  final double radiusFactor;
  const _StickerBrushStroke({
    required this.mode,
    required this.points,
    required this.radiusFactor,
  });
}

class _StickerStrokePainter extends CustomPainter {
  final List<_StickerBrushStroke> strokes;
  final _StickerBrushStroke? activeStroke;
  const _StickerStrokePainter({required this.strokes, this.activeStroke});

  @override
  void paint(Canvas canvas, Size size) {
    void drawStroke(_StickerBrushStroke stroke, bool faded) {
      if (stroke.points.isEmpty) return;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(
          1.0,
          stroke.radiusFactor * size.shortestSide * 2,
        )
        ..color =
            (stroke.mode == 'restore'
                    ? const Color(0xFF44C27A)
                    : const Color(0xFFFF6B6B))
                .withOpacity(faded ? .35 : .72);
      final path = Path();
      final first = Offset(
        stroke.points.first.dx * size.width,
        stroke.points.first.dy * size.height,
      );
      path.moveTo(first.dx, first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          first,
          paint.strokeWidth / 2,
          Paint()..color = paint.color,
        );
      } else {
        canvas.drawPath(path, paint);
      }
    }

    for (final stroke in strokes) {
      drawStroke(stroke, true);
    }
    if (activeStroke != null) drawStroke(activeStroke!, false);
  }

  @override
  bool shouldRepaint(covariant _StickerStrokePainter oldDelegate) => true;
}

Future<dynamic> _imageFromRgba(Uint8List pixels, int width, int height) {
  final completer = Completer();
  decodeImageFromPixels(
    pixels,
    width,
    height,
    PixelFormat.rgba8888,
    (image) => completer.complete(image),
  );
  return completer.future;
}

Color _sampleCornerCleanupColor(Uint8List rgba, int width, int height) {
  const border = 18;
  int r = 0, g = 0, b = 0, count = 0;
  bool isBorder(int x, int y) =>
      x < border || y < border || x >= width - border || y >= height - border;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (!isBorder(x, y)) continue;
      final i = (y * width + x) * 4;
      final a = rgba[i + 3];
      if (a < 8) continue;
      r += rgba[i];
      g += rgba[i + 1];
      b += rgba[i + 2];
      count++;
    }
  }
  if (count == 0) return Colors.white;
  return Color.fromARGB(
    255,
    (r / count).round(),
    (g / count).round(),
    (b / count).round(),
  );
}

void _applyStickerPixelCleanup(
  Uint8List rgba,
  int width,
  int height, {
  required double edgeTune,
  required String cleanupMode,
  required double colorTolerance,
  required String recognitionMode,
}) {
  if (rgba.isEmpty || width <= 0 || height <= 0) return;
  final alpha = Uint8List(width * height);
  for (int p = 0, i = 3; p < alpha.length && i < rgba.length; p++, i += 4) {
    alpha[p] = rgba[i];
  }

  bool nearTransparent(int x, int y) {
    for (
      int yy = math.max(0, y - 1).toInt();
      yy <= math.min(height - 1, y + 1).toInt();
      yy++
    ) {
      for (
        int xx = math.max(0, x - 1).toInt();
        xx <= math.min(width - 1, x + 1).toInt();
        xx++
      ) {
        if (alpha[yy * width + xx] < 22) return true;
      }
    }
    return false;
  }

  final mode = recognitionMode;
  final baseCutoff = mode == 'aggressive'
      ? 46
      : mode == 'subject'
      ? 22
      : mode == 'edge'
      ? 28
      : 34;
  final cutoff = (baseCutoff - edgeTune * 24).clamp(4, 96).round();
  Color? targetColor;
  switch (cleanupMode) {
    case 'white':
      targetColor = Colors.white;
      break;
    case 'black':
      targetColor = Colors.black;
      break;
    case 'corner':
      targetColor = _sampleCornerCleanupColor(rgba, width, height);
      break;
  }
  final tolFactor = mode == 'aggressive'
      ? 1.25
      : mode == 'subject'
      ? 0.85
      : mode == 'edge'
      ? 1.0
      : 1.0;
  final tol = (colorTolerance * tolFactor).clamp(0, 130).toDouble();
  final tolSq = tol * tol;
  final edgeNegativeStrength = mode == 'aggressive'
      ? 0.90
      : mode == 'subject'
      ? 0.38
      : mode == 'edge'
      ? 0.60
      : 0.72;
  final edgePositiveStrength = mode == 'subject'
      ? 0.85
      : mode == 'edge'
      ? 0.70
      : mode == 'aggressive'
      ? 0.48
      : 0.55;
  final alphaZeroThreshold = mode == 'subject'
      ? 40
      : mode == 'edge'
      ? 58
      : mode == 'aggressive'
      ? 76
      : 68;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final p = y * width + x;
      final i = p * 4;
      var a = alpha[p];
      if (a == 0) continue;
      final boundary = nearTransparent(x, y);

      if (a < cutoff) {
        rgba[i] = 0;
        rgba[i + 1] = 0;
        rgba[i + 2] = 0;
        rgba[i + 3] = 0;
        continue;
      }

      if (boundary && edgeTune.abs() > 0.01) {
        if (edgeTune < 0) {
          final factor = (1.0 + edgeTune * edgeNegativeStrength)
              .clamp(0.12, 1.0)
              .toDouble();
          a = (a * factor).round().clamp(0, 255).toInt();
          if (a < alphaZeroThreshold) a = 0;
        } else {
          final factor = (1.0 + edgeTune * edgePositiveStrength)
              .clamp(1.0, mode == 'subject' ? 1.95 : 1.75)
              .toDouble();
          a = (a * factor).round().clamp(0, 255).toInt();
        }
        rgba[i + 3] = a;
        if (a == 0) {
          rgba[i] = 0;
          rgba[i + 1] = 0;
          rgba[i + 2] = 0;
          continue;
        }
      }

      if (targetColor != null && tol > 0 && (boundary || a < 246)) {
        final dr = rgba[i] - targetColor.red;
        final dg = rgba[i + 1] - targetColor.green;
        final db = rgba[i + 2] - targetColor.blue;
        final distSq = (dr * dr + dg * dg + db * db).toDouble();
        if (distSq <= tolSq) {
          final distanceFactor = distSq <= 1 ? 0.0 : math.sqrt(distSq) / tol;
          final boundaryBoost = boundary
              ? (mode == 'aggressive'
                    ? 0.88
                    : mode == 'subject'
                    ? 0.52
                    : 0.72)
              : (mode == 'subject' ? 0.26 : 0.38);
          final newAlpha = (rgba[i + 3] * (distanceFactor * boundaryBoost))
              .round()
              .clamp(0, 255)
              .toInt();
          rgba[i + 3] = newAlpha;
          if (newAlpha == 0) {
            rgba[i] = 0;
            rgba[i + 1] = 0;
            rgba[i + 2] = 0;
          }
        }
      }
    }
  }
}

void _applyBrushStrokesToSourceRgba(
  Uint8List targetRgba,
  Uint8List originalRgba,
  int width,
  int height,
  List<_StickerBrushStroke> strokes, {
  required int canvasSize,
  required double left,
  required double top,
  required double drawScale,
}) {
  void applyPoint(int cx, int cy, int radius, String mode) {
    final r2 = radius * radius;
    final y0 = math.max(0, cy - radius);
    final y1 = math.min(height - 1, cy + radius);
    final x0 = math.max(0, cx - radius);
    final x1 = math.min(width - 1, cx + radius);
    for (int y = y0; y <= y1; y++) {
      for (int x = x0; x <= x1; x++) {
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy > r2) continue;
        final idx = (y * width + x) * 4;
        if (mode == 'erase') {
          targetRgba[idx] = 0;
          targetRgba[idx + 1] = 0;
          targetRgba[idx + 2] = 0;
          targetRgba[idx + 3] = 0;
        } else {
          targetRgba[idx] = originalRgba[idx];
          targetRgba[idx + 1] = originalRgba[idx + 1];
          targetRgba[idx + 2] = originalRgba[idx + 2];
          targetRgba[idx + 3] = originalRgba[idx + 3];
        }
      }
    }
  }

  for (final stroke in strokes) {
    if (stroke.points.isEmpty) continue;
    for (int i = 0; i < stroke.points.length; i++) {
      final p = stroke.points[i];
      final canvasX = p.dx.clamp(0.0, 1.0) * canvasSize;
      final canvasY = p.dy.clamp(0.0, 1.0) * canvasSize;
      final imgX = ((canvasX - left) / drawScale).round();
      final imgY = ((canvasY - top) / drawScale).round();
      final radius = math.max(
        2,
        (stroke.radiusFactor * canvasSize / math.max(drawScale, 0.001)).round(),
      );
      applyPoint(imgX, imgY, radius, stroke.mode);
      if (i > 0) {
        final prev = stroke.points[i - 1];
        final prevCanvasX = prev.dx.clamp(0.0, 1.0) * canvasSize;
        final prevCanvasY = prev.dy.clamp(0.0, 1.0) * canvasSize;
        final prevImgX = ((prevCanvasX - left) / drawScale).round();
        final prevImgY = ((prevCanvasY - top) / drawScale).round();
        final steps = math.max(
          (math.max((imgX - prevImgX).abs(), (imgY - prevImgY).abs()) /
                  math.max(1, radius / 2))
              .ceil(),
          1,
        );
        for (int s = 1; s < steps; s++) {
          final t = s / steps;
          final ix = (prevImgX + (imgX - prevImgX) * t).round();
          final iy = (prevImgY + (imgY - prevImgY) * t).round();
          applyPoint(ix, iy, radius, stroke.mode);
        }
      }
    }
  }
}

Future<Uint8List> renderAdjustedStickerPngBytes(
  String sourceUri, {
  required bool contain,
  required double scale,
  required double offsetXFactor,
  required double offsetYFactor,
  required double edgeTune,
  required String cleanupMode,
  required double colorTolerance,
  required String recognitionMode,
  List<_StickerBrushStroke> brushStrokes = const [],
  int canvasSize = 1024,
}) async {
  final sourcePath = filePathFromUriText(sourceUri);
  final bytes = await File(sourcePath).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final raw = await image.toByteData(format: ImageByteFormat.rawRgba);
  final rgba = raw?.buffer.asUint8List() ?? Uint8List(0);
  if (rgba.isNotEmpty) {
    _applyStickerPixelCleanup(
      rgba,
      image.width,
      image.height,
      edgeTune: edgeTune,
      cleanupMode: cleanupMode,
      colorTolerance: colorTolerance,
      recognitionMode: recognitionMode,
    );
  }
  final editableSourceRgba = Uint8List.fromList(rgba);
  final originalSourceRgba = Uint8List.fromList(rgba);
  final canvasSizeDouble = canvasSize.toDouble();
  final srcW = image.width.toDouble();
  final srcH = image.height.toDouble();
  final baseScale = contain
      ? math.min(canvasSizeDouble / srcW, canvasSizeDouble / srcH)
      : math.max(canvasSizeDouble / srcW, canvasSizeDouble / srcH);
  final drawScale = baseScale * scale;
  final drawW = srcW * drawScale;
  final drawH = srcH * drawScale;
  final left =
      (canvasSizeDouble - drawW) / 2 + offsetXFactor * canvasSizeDouble * 0.42;
  final top =
      (canvasSizeDouble - drawH) / 2 + offsetYFactor * canvasSizeDouble * 0.42;
  if (editableSourceRgba.isNotEmpty && brushStrokes.isNotEmpty) {
    _applyBrushStrokesToSourceRgba(
      editableSourceRgba,
      originalSourceRgba,
      image.width,
      image.height,
      brushStrokes,
      canvasSize: canvasSize,
      left: left,
      top: top,
      drawScale: drawScale,
    );
  }
  final processedImage = editableSourceRgba.isEmpty
      ? image
      : await _imageFromRgba(editableSourceRgba, image.width, image.height);
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final dst = Rect.fromLTWH(left, top, drawW, drawH);
  canvas.drawImageRect(
    processedImage,
    Rect.fromLTWH(0, 0, srcW, srcH),
    dst,
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final finalImage = await picture.toImage(canvasSize, canvasSize);
  final byteData = await finalImage.toByteData(format: ImageByteFormat.png);
  return byteData?.buffer.asUint8List() ?? Uint8List(0);
}

Future<String> saveAdjustedStickerImage(
  String sourceUri, {
  required bool contain,
  required double scale,
  required double offsetXFactor,
  required double offsetYFactor,
  required double edgeTune,
  required String cleanupMode,
  required double colorTolerance,
  required String recognitionMode,
  List<_StickerBrushStroke> brushStrokes = const [],
}) async {
  final pngBytes = await renderAdjustedStickerPngBytes(
    sourceUri,
    contain: contain,
    scale: scale,
    offsetXFactor: offsetXFactor,
    offsetYFactor: offsetYFactor,
    edgeTune: edgeTune,
    cleanupMode: cleanupMode,
    colorTolerance: colorTolerance,
    recognitionMode: recognitionMode,
    brushStrokes: brushStrokes,
    canvasSize: 1024,
  );
  final sourcePath = filePathFromUriText(sourceUri);
  final sourceFile = File(sourcePath);
  final outFile = File(
    '${sourceFile.parent.path}/adjusted_sticker_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await outFile.writeAsBytes(pngBytes, flush: true);
  return 'file://${outFile.path}';
}

class _StickerAdjustPreview extends StatefulWidget {
  final String uri;
  final bool contain;
  final double scale;
  final double offsetXFactor;
  final double offsetYFactor;
  final double edgeTune;
  final String cleanupMode;
  final double colorTolerance;
  final String recognitionMode;
  final List<_StickerBrushStroke> strokes;
  final _StickerBrushStroke? activeStroke;
  final String toolMode;
  final double brushRadiusFactor;
  final ValueChanged<Offset>? onPanMove;
  final ValueChanged<Offset>? onStrokeStart;
  final ValueChanged<Offset>? onStrokeAppend;
  final VoidCallback? onStrokeEnd;
  const _StickerAdjustPreview({
    required this.uri,
    required this.contain,
    required this.scale,
    required this.offsetXFactor,
    required this.offsetYFactor,
    required this.edgeTune,
    required this.cleanupMode,
    required this.colorTolerance,
    required this.recognitionMode,
    required this.strokes,
    required this.activeStroke,
    required this.toolMode,
    required this.brushRadiusFactor,
    this.onPanMove,
    this.onStrokeStart,
    this.onStrokeAppend,
    this.onStrokeEnd,
  });

  @override
  State<_StickerAdjustPreview> createState() => _StickerAdjustPreviewState();
}

class _StickerAdjustPreviewState extends State<_StickerAdjustPreview> {
  Future<Uint8List>? _previewFuture;
  Uint8List? _lastPreviewBytes;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  @override
  void didUpdateWidget(covariant _StickerAdjustPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final strokesChanged =
        oldWidget.strokes.length != widget.strokes.length ||
        oldWidget.activeStroke != widget.activeStroke;
    if (oldWidget.uri != widget.uri ||
        oldWidget.contain != widget.contain ||
        oldWidget.scale != widget.scale ||
        oldWidget.offsetXFactor != widget.offsetXFactor ||
        oldWidget.offsetYFactor != widget.offsetYFactor ||
        oldWidget.edgeTune != widget.edgeTune ||
        oldWidget.cleanupMode != widget.cleanupMode ||
        oldWidget.colorTolerance != widget.colorTolerance ||
        oldWidget.recognitionMode != widget.recognitionMode ||
        strokesChanged) {
      _refreshPreview();
    }
  }

  void _refreshPreview() {
    final future = _buildPreview();
    _previewFuture = future;
    future
        .then((bytes) {
          if (!mounted || !identical(_previewFuture, future)) return;
          setState(() => _lastPreviewBytes = bytes);
        })
        .catchError((_) {});
    setState(() {});
  }

  Future<Uint8List> _buildPreview() {
    final allStrokes = [
      ...widget.strokes,
      if (widget.activeStroke != null) widget.activeStroke!,
    ];
    return renderAdjustedStickerPngBytes(
      widget.uri,
      contain: widget.contain,
      scale: widget.scale,
      offsetXFactor: widget.offsetXFactor,
      offsetYFactor: widget.offsetYFactor,
      edgeTune: widget.edgeTune,
      cleanupMode: widget.cleanupMode,
      colorTolerance: widget.colorTolerance,
      recognitionMode: widget.recognitionMode,
      brushStrokes: allStrokes,
      canvasSize: 768,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        Offset normalize(Offset local) => Offset(
          (local.dx / math.max(1, size)).clamp(0.0, 1.0),
          (local.dy / math.max(1, size)).clamp(0.0, 1.0),
        );
        return GestureDetector(
          onPanStart: (details) {
            if (widget.toolMode != 'move')
              widget.onStrokeStart?.call(normalize(details.localPosition));
          },
          onPanUpdate: (details) {
            if (widget.toolMode == 'move') {
              widget.onPanMove?.call(
                Offset(
                  details.delta.dx / math.max(1, size),
                  details.delta.dy / math.max(1, size),
                ),
              );
            } else {
              widget.onStrokeAppend?.call(normalize(details.localPosition));
            }
          },
          onPanEnd: (_) {
            if (widget.toolMode != 'move') widget.onStrokeEnd?.call();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              color: context.isDark
                  ? Colors.white.withOpacity(.04)
                  : const Color(0xFFF6F8FB),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: (context.isDark ? Colors.white : Colors.black)
                              .withOpacity(.05),
                        ),
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: FutureBuilder<Uint8List>(
                      future: _previewFuture,
                      initialData: _lastPreviewBytes,
                      builder: (context, snapshot) {
                        final bytes = snapshot.data ?? _lastPreviewBytes;
                        if (bytes == null || bytes.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        );
                      },
                    ),
                  ),
                  if (_lastPreviewBytes != null)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FutureBuilder<Uint8List>(
                        future: _previewFuture,
                        builder: (context, snapshot) {
                          final loading =
                              snapshot.connectionState != ConnectionState.done;
                          return AnimatedOpacity(
                            opacity: loading ? 1 : 0,
                            duration: const Duration(milliseconds: 120),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.38),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '更新中',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _StickerStrokePainter(
                          strokes: widget.strokes,
                          activeStroke: widget.activeStroke,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.contain ? '完整显示' : '铺满显示',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.toolMode == 'move'
                            ? '实时预览'
                            : widget.toolMode == 'erase'
                            ? '橡皮修边'
                            : '恢复修边',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<String?> adjustStickerCover(
  BuildContext context,
  String sourceUri,
) async {
  double scale = 0.92;
  double offsetXFactor = 0;
  double offsetYFactor = 0;
  bool contain = true;
  double edgeTune = 0.0;
  String cleanupMode = 'none';
  double colorTolerance = 28.0;
  String recognitionMode = 'balanced';
  String toolMode = 'move';
  double brushRadiusFactor = 0.024;
  final strokes = <_StickerBrushStroke>[];
  _StickerBrushStroke? activeStroke;

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          void startStroke(Offset point) {
            if (toolMode == 'move') return;
            activeStroke = _StickerBrushStroke(
              mode: toolMode == 'restore' ? 'restore' : 'erase',
              points: [point],
              radiusFactor: brushRadiusFactor,
            );
            setState(() {});
          }

          void appendStroke(Offset point) {
            if (activeStroke == null) return;
            activeStroke = _StickerBrushStroke(
              mode: activeStroke!.mode,
              radiusFactor: activeStroke!.radiusFactor,
              points: [...activeStroke!.points, point],
            );
            setState(() {});
          }

          void endStroke() {
            if (activeStroke == null) return;
            strokes.add(activeStroke!);
            activeStroke = null;
            setState(() {});
          }

          Widget sectionCard({required Widget child}) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(.04)
                  : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: child,
          );

          return Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF111316) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.16),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.94,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '贴纸修复与调整',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '现在除了手动修边，还可以切换识别模式。预览区会实时显示结果；选“橡皮/恢复”可以更接近手动抠图。',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _StickerAdjustPreview(
                          uri: sourceUri,
                          contain: contain,
                          scale: scale,
                          offsetXFactor: offsetXFactor,
                          offsetYFactor: offsetYFactor,
                          edgeTune: edgeTune,
                          cleanupMode: cleanupMode,
                          colorTolerance: colorTolerance,
                          recognitionMode: recognitionMode,
                          strokes: strokes,
                          activeStroke: activeStroke,
                          toolMode: toolMode,
                          brushRadiusFactor: brushRadiusFactor,
                          onPanMove: (delta) => setState(() {
                            offsetXFactor = (offsetXFactor + delta.dx)
                                .clamp(-0.8, 0.8)
                                .toDouble();
                            offsetYFactor = (offsetYFactor + delta.dy)
                                .clamp(-0.8, 0.8)
                                .toDouble();
                          }),
                          onStrokeStart: startStroke,
                          onStrokeAppend: appendStroke,
                          onStrokeEnd: endStroke,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '工具',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment<String>(
                                        value: 'move',
                                        icon: Icon(Icons.open_with_rounded),
                                        label: Text('移动'),
                                      ),
                                      ButtonSegment<String>(
                                        value: 'erase',
                                        icon: Icon(Icons.auto_fix_off_rounded),
                                        label: Text('橡皮'),
                                      ),
                                      ButtonSegment<String>(
                                        value: 'restore',
                                        icon: Icon(Icons.brush_rounded),
                                        label: Text('恢复'),
                                      ),
                                    ],
                                    selected: {toolMode},
                                    onSelectionChanged: (v) =>
                                        setState(() => toolMode = v.first),
                                  ),
                                  if (toolMode != 'move') ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.circle_outlined,
                                          size: 18,
                                          color: kMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '笔刷大小',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: kMuted,
                                          ),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            min: 0.008,
                                            max: 0.065,
                                            value: brushRadiusFactor,
                                            onChanged: (v) => setState(
                                              () => brushRadiusFactor = v,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 46,
                                          child: Text(
                                            '${(brushRadiusFactor * 1000).round()}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: kMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: strokes.isEmpty
                                              ? null
                                              : () => setState(() {
                                                  if (strokes.isNotEmpty)
                                                    strokes.removeLast();
                                                }),
                                          icon: const Icon(Icons.undo_rounded),
                                          label: const Text('撤销修边'),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: strokes.isEmpty
                                              ? null
                                              : () => setState(
                                                  () => strokes.clear(),
                                                ),
                                          icon: const Icon(
                                            Icons.layers_clear_rounded,
                                          ),
                                          label: const Text('清空修边'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '构图与显示',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SegmentedButton<bool>(
                                    segments: const [
                                      ButtonSegment<bool>(
                                        value: true,
                                        label: Text('完整显示'),
                                      ),
                                      ButtonSegment<bool>(
                                        value: false,
                                        label: Text('铺满'),
                                      ),
                                    ],
                                    selected: {contain},
                                    onSelectionChanged: (v) =>
                                        setState(() => contain = v.first),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.zoom_out_map_rounded,
                                        size: 18,
                                        color: kMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '缩放',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 0.7,
                                          max: 1.55,
                                          value: scale,
                                          onChanged: (v) =>
                                              setState(() => scale = v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        child: Text(
                                          scale.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '移动模式下可直接在预览图上拖动位置。',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '智能边缘优化',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('标准'),
                                        selected: recognitionMode == 'balanced',
                                        onSelected: (_) => setState(
                                          () => recognitionMode = 'balanced',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('主体优先'),
                                        selected: recognitionMode == 'subject',
                                        onSelected: (_) => setState(
                                          () => recognitionMode = 'subject',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('边缘优先'),
                                        selected: recognitionMode == 'edge',
                                        onSelected: (_) => setState(
                                          () => recognitionMode = 'edge',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('强力去底'),
                                        selected:
                                            recognitionMode == 'aggressive',
                                        onSelected: (_) => setState(
                                          () => recognitionMode = 'aggressive',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '标准适合大多数情况；主体优先更保守，适合容易被吃掉的主体；边缘优先更重视细边；强力去底更适合残留背景较多的图片。',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.auto_fix_high_rounded,
                                        size: 18,
                                        color: kMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '边缘保留',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: -1.0,
                                          max: 1.0,
                                          value: edgeTune,
                                          onChanged: (v) =>
                                              setState(() => edgeTune = v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 56,
                                        child: Text(
                                          edgeTune > 0.05
                                              ? '更多'
                                              : edgeTune < -0.05
                                              ? '更净'
                                              : '默认',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    '往左更容易去掉边缘残留，往右会尽量保留更多细小边缘。',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('不清理颜色'),
                                        selected: cleanupMode == 'none',
                                        onSelected: (_) => setState(
                                          () => cleanupMode = 'none',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('去白边'),
                                        selected: cleanupMode == 'white',
                                        onSelected: (_) => setState(
                                          () => cleanupMode = 'white',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('去黑边'),
                                        selected: cleanupMode == 'black',
                                        onSelected: (_) => setState(
                                          () => cleanupMode = 'black',
                                        ),
                                      ),
                                      ChoiceChip(
                                        label: const Text('去角落残色'),
                                        selected: cleanupMode == 'corner',
                                        onSelected: (_) => setState(
                                          () => cleanupMode = 'corner',
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (cleanupMode != 'none') ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.color_lens_outlined,
                                          size: 18,
                                          color: kMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          '颜色容差',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: kMuted,
                                          ),
                                        ),
                                        Expanded(
                                          child: Slider(
                                            min: 4,
                                            max: 90,
                                            value: colorTolerance,
                                            onChanged: (v) => setState(
                                              () => colorTolerance = v,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 44,
                                          child: Text(
                                            colorTolerance.toStringAsFixed(0),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: kMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '容差越大，越容易把接近目标颜色的残边一起清理掉。',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: kMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => setState(() {
                              scale = 0.92;
                              offsetXFactor = 0;
                              offsetYFactor = 0;
                              contain = true;
                              edgeTune = 0.0;
                              cleanupMode = 'none';
                              colorTolerance = 28.0;
                              recognitionMode = 'balanced';
                              toolMode = 'move';
                              brushRadiusFactor = 0.024;
                              strokes.clear();
                              activeStroke = null;
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('全部重置'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  Navigator.pop(context, '__use_direct__'),
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                              label: const Text('使用原候选'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final out = await saveAdjustedStickerImage(
                              sourceUri,
                              contain: contain,
                              scale: scale,
                              offsetXFactor: offsetXFactor,
                              offsetYFactor: offsetYFactor,
                              edgeTune: edgeTune,
                              cleanupMode: cleanupMode,
                              colorTolerance: colorTolerance,
                              recognitionMode: recognitionMode,
                              brushStrokes: strokes,
                            );
                            if (context.mounted) Navigator.pop(context, out);
                          },
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('应用调整并生成贴纸'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  if (result == '__use_direct__') return sourceUri;
  return result;
}

Future<String?> chooseStickerCandidate(
  BuildContext context,
  Map<String, dynamic> payload,
) async {
  final direct = (payload['selectedUri'] ?? '').toString().trim();
  final rawCandidates = payload['candidates'];
  final candidates = <Map<String, dynamic>>[];
  if (rawCandidates is List) {
    for (final item in rawCandidates) {
      if (item is Map<String, dynamic>) {
        candidates.add(item);
      } else if (item is Map) {
        candidates.add(
          item.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    }
  }
  if (candidates.isEmpty)
    return direct.isEmpty ? null : await adjustStickerCover(context, direct);
  if (candidates.length == 1) {
    final uri = (candidates.first['uri'] ?? direct).toString().trim();
    if (uri.isEmpty) return null;
    cleanupUnusedStickerCandidates(
      payload,
      uri,
      keepCandidates: context.store.settings.keepStickerCandidates,
    );
    final adjusted = await adjustStickerCover(context, uri);
    if (adjusted != null &&
        adjusted != uri &&
        !context.store.settings.keepStickerCandidates) {
      deleteGeneratedStickerFile(uri);
    }
    return adjusted;
  }
  final selected = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF111316) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '选择贴纸封面',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '系统会先给出多个本地候选，避免一次抠图失败就直接写入封面。',
                style: TextStyle(color: kMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .84,
                  ),
                  itemBuilder: (context, index) {
                    final item = candidates[index];
                    final uri = (item['uri'] ?? '').toString();
                    final label = (item['label'] ?? '候选 ${index + 1}')
                        .toString();
                    final engine = (item['engine'] ?? '').toString();
                    final scoreValue = item['score'];
                    final scoreText = scoreValue is num
                        ? '${(scoreValue * 100).toStringAsFixed(0)}分'
                        : '';
                    final isSuggested = uri.isNotEmpty && uri == direct;
                    final file = File(filePathFromUriText(uri));
                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.pop(context, uri),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? Colors.white.withOpacity(.05)
                              : const Color(0xFFF8F9FB),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSuggested
                                ? const Color(0xFF7CC6F2)
                                : (context.isDark
                                      ? Colors.white12
                                      : Colors.black12),
                            width: isSuggested ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: context.isDark
                                      ? Colors.black.withOpacity(.18)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: file.existsSync()
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: RepaintBoundary(
                                          child: Image.file(
                                            file,
                                            fit: BoxFit.contain,
                                            cacheWidth: _previewCacheSide(
                                              context,
                                              logicalSide: 260,
                                            ),
                                            cacheHeight: _previewCacheSide(
                                              context,
                                              logicalSide: 260,
                                            ),
                                            gaplessPlayback: true,
                                            filterQuality: FilterQuality.medium,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: kMuted,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSuggested)
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: Color(0xFF7CC6F2),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              engine.isEmpty ? '本地贴纸引擎' : engine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: kMuted,
                              ),
                            ),
                            if (scoreText.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  scoreText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF7CC6F2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (selected != null && selected.trim().isNotEmpty) {
    cleanupUnusedStickerCandidates(
      payload,
      selected,
      keepCandidates: context.store.settings.keepStickerCandidates,
    );
    final adjusted = await adjustStickerCover(context, selected);
    if (adjusted != null &&
        adjusted != selected &&
        !context.store.settings.keepStickerCandidates) {
      deleteGeneratedStickerFile(selected);
    }
    return adjusted;
  }
  return null;
}

final Map<String, Size> _valoraImageSizeCache = <String, Size>{};

int _previewCacheSide(BuildContext context, {double logicalSide = 360}) {
  final ratio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
  return (logicalSide * ratio).round().clamp(480, 1440).toInt();
}

Future<Size> _decodeImageSizeFromUri(String sourceUri) async {
  final sourcePath = filePathFromUriText(sourceUri);
  final cached = _valoraImageSizeCache[sourcePath];
  if (cached != null) return cached;
  final bytes = await File(sourcePath).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final size = Size(
    frame.image.width.toDouble(),
    frame.image.height.toDouble(),
  );
  _valoraImageSizeCache[sourcePath] = size;
  return size;
}

Rect _fitContainRect(Size imageSize, Size boxSize) {
  if (imageSize.width <= 0 ||
      imageSize.height <= 0 ||
      boxSize.width <= 0 ||
      boxSize.height <= 0) {
    return Rect.zero;
  }
  final scale = math.min(
    boxSize.width / imageSize.width,
    boxSize.height / imageSize.height,
  );
  final drawW = imageSize.width * scale;
  final drawH = imageSize.height * scale;
  final left = (boxSize.width - drawW) / 2;
  final top = (boxSize.height - drawH) / 2;
  return Rect.fromLTWH(left, top, drawW, drawH);
}

Rect _defaultSquareCropForImageSize(Size imageSize) {
  const visibleSide = 0.76;
  if (imageSize.width <= 0 || imageSize.height <= 0) {
    return const Rect.fromLTWH(0.12, 0.12, 0.76, 0.76);
  }
  final shortest = math.min(imageSize.width, imageSize.height);
  final sidePx = shortest * visibleSide;
  final w = (sidePx / imageSize.width).clamp(0.12, 1.0).toDouble();
  final h = (sidePx / imageSize.height).clamp(0.12, 1.0).toDouble();
  return Rect.fromLTWH((1 - w) / 2, (1 - h) / 2, w, h);
}

Rect _normalizeSquareCropRect(Rect rect, Size imageSize) {
  if (imageSize.width <= 0 || imageSize.height <= 0) {
    return const Rect.fromLTWH(0.12, 0.12, 0.76, 0.76);
  }
  final shortest = math.min(imageSize.width, imageSize.height);
  final minSidePx = shortest * 0.16;
  final maxSidePx = shortest;
  final requestedSidePx = math.max(
    rect.width.abs() * imageSize.width,
    rect.height.abs() * imageSize.height,
  );
  final sidePx = requestedSidePx.clamp(minSidePx, maxSidePx).toDouble();
  final w = (sidePx / imageSize.width).clamp(0.01, 1.0).toDouble();
  final h = (sidePx / imageSize.height).clamp(0.01, 1.0).toDouble();
  final cx = rect.center.dx.clamp(w / 2, 1 - w / 2).toDouble();
  final cy = rect.center.dy.clamp(h / 2, 1 - h / 2).toDouble();
  return Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
}

Offset _normalizedPointFromLocal(Offset local, Rect imageRect) {
  if (imageRect.width <= 0 || imageRect.height <= 0)
    return const Offset(.5, .5);
  final dx = ((local.dx - imageRect.left) / imageRect.width)
      .clamp(0.0, 1.0)
      .toDouble();
  final dy = ((local.dy - imageRect.top) / imageRect.height)
      .clamp(0.0, 1.0)
      .toDouble();
  return Offset(dx, dy);
}

Future<Uint8List> renderFramedCoverPngBytes(
  String sourceUri, {
  required Rect cropRect,
  required double frameWidthFactor,
  required double cornerRadiusFactor,
  required double cardInsetFactor,
  int canvasSize = 1024,
}) async {
  final sourcePath = filePathFromUriText(sourceUri);
  final bytes = await File(sourcePath).readAsBytes();
  final codec = await instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final canvasSizeDouble = canvasSize.toDouble();

  final outerInset = canvasSizeDouble * cardInsetFactor;
  final cardRect = Rect.fromLTWH(
    outerInset,
    outerInset,
    canvasSizeDouble - outerInset * 2,
    canvasSizeDouble - outerInset * 2,
  );
  final radius = (canvasSizeDouble * cornerRadiusFactor)
      .clamp(20.0, 180.0)
      .toDouble();
  final cardRRect = RRect.fromRectAndRadius(cardRect, Radius.circular(radius));
  final frameWidth = (canvasSizeDouble * frameWidthFactor)
      .clamp(14.0, 120.0)
      .toDouble();
  final innerRect = cardRect.deflate(frameWidth);
  final innerRadius = math.max(12.0, radius - frameWidth * 0.7).toDouble();

  canvas.drawShadow(
    Path()..addRRect(cardRRect),
    Colors.black.withOpacity(.18),
    18,
    true,
  );
  canvas.drawRRect(cardRRect, Paint()..color = Colors.white);

  final srcRect = Rect.fromLTRB(
    cropRect.left * image.width,
    cropRect.top * image.height,
    cropRect.right * image.width,
    cropRect.bottom * image.height,
  );
  final clipRRect = RRect.fromRectAndRadius(
    innerRect,
    Radius.circular(innerRadius),
  );
  canvas.save();
  canvas.clipRRect(clipRRect);
  canvas.drawImageRect(
    image,
    srcRect,
    innerRect,
    Paint()..filterQuality = FilterQuality.high,
  );
  canvas.restore();

  final picture = recorder.endRecording();
  final outImage = await picture.toImage(canvasSize, canvasSize);
  final byteData = await outImage.toByteData(format: ImageByteFormat.png);
  return byteData?.buffer.asUint8List() ?? Uint8List(0);
}

Future<String> saveFramedCoverImage(
  String sourceUri, {
  required Rect cropRect,
  required double frameWidthFactor,
  required double cornerRadiusFactor,
  required double cardInsetFactor,
}) async {
  final pngBytes = await renderFramedCoverPngBytes(
    sourceUri,
    cropRect: cropRect,
    frameWidthFactor: frameWidthFactor,
    cornerRadiusFactor: cornerRadiusFactor,
    cardInsetFactor: cardInsetFactor,
    canvasSize: 1024,
  );
  final sourcePath = filePathFromUriText(sourceUri);
  final sourceFile = File(sourcePath);
  final outFile = File(
    '${sourceFile.parent.path}/framed_cover_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await outFile.writeAsBytes(pngBytes, flush: true);
  return 'file://${outFile.path}';
}

class _CropSelectionPainter extends CustomPainter {
  final Rect imageRect;
  final Rect cropRect;
  final double borderRadius;
  const _CropSelectionPainter({
    required this.imageRect,
    required this.cropRect,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final crop = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cropRect, Radius.circular(borderRadius)),
      );
    final mask = Path.combine(PathOperation.difference, full, crop);
    canvas.drawPath(mask, Paint()..color = Colors.black.withOpacity(.38));
    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, Radius.circular(borderRadius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _CropSelectionPainter oldDelegate) =>
      oldDelegate.imageRect != imageRect ||
      oldDelegate.cropRect != cropRect ||
      oldDelegate.borderRadius != borderRadius;
}

class _DirectCropSelectionPreview extends StatelessWidget {
  final String uri;
  final Size imageSize;
  final Rect cropRect;
  final double borderRadius;
  final ValueChanged<Rect> onCropRectChanged;
  const _DirectCropSelectionPreview({
    required this.uri,
    required this.imageSize,
    required this.cropRect,
    required this.borderRadius,
    required this.onCropRectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePathFromUriText(uri));
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _fitContainRect(imageSize, areaSize);
        final cropDisplayRect = Rect.fromLTRB(
          imageRect.left + cropRect.left * imageRect.width,
          imageRect.top + cropRect.top * imageRect.height,
          imageRect.left + cropRect.right * imageRect.width,
          imageRect.top + cropRect.bottom * imageRect.height,
        );

        Rect movedBy(Offset delta) {
          final ndx = delta.dx / math.max(1, imageRect.width);
          final ndy = delta.dy / math.max(1, imageRect.height);
          final width = cropRect.width;
          final height = cropRect.height;
          final left = (cropRect.left + ndx).clamp(0.0, 1.0 - width).toDouble();
          final top = (cropRect.top + ndy).clamp(0.0, 1.0 - height).toDouble();
          return Rect.fromLTWH(left, top, width, height);
        }

        Rect resizeRect(String handle, Offset delta) {
          final ndx = delta.dx / math.max(1, imageRect.width);
          final ndy = delta.dy / math.max(1, imageRect.height);
          Rect next = cropRect;
          switch (handle) {
            case 'tl':
              next = Rect.fromLTRB(
                cropRect.left + ndx,
                cropRect.top + ndy,
                cropRect.right,
                cropRect.bottom,
              );
              break;
            case 'tr':
              next = Rect.fromLTRB(
                cropRect.left,
                cropRect.top + ndy,
                cropRect.right + ndx,
                cropRect.bottom,
              );
              break;
            case 'bl':
              next = Rect.fromLTRB(
                cropRect.left + ndx,
                cropRect.top,
                cropRect.right,
                cropRect.bottom + ndy,
              );
              break;
            case 'br':
              next = Rect.fromLTRB(
                cropRect.left,
                cropRect.top,
                cropRect.right + ndx,
                cropRect.bottom + ndy,
              );
              break;
          }
          return _normalizeSquareCropRect(next, imageSize);
        }

        Widget handle(String type, Alignment alignment) {
          final x = alignment.x < 0
              ? cropDisplayRect.left
              : cropDisplayRect.right;
          final y = alignment.y < 0
              ? cropDisplayRect.top
              : cropDisplayRect.bottom;
          return Positioned(
            left: x - 14,
            top: y - 14,
            child: GestureDetector(
              onPanUpdate: (details) =>
                  onCropRectChanged(resizeRect(type, details.delta)),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            color: context.isDark
                ? Colors.white.withOpacity(.05)
                : const Color(0xFFF2F5F8),
            child: Stack(
              children: [
                Positioned.fill(child: Image.file(file, fit: BoxFit.contain)),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CropSelectionPainter(
                      imageRect: imageRect,
                      cropRect: cropDisplayRect,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),
                Positioned.fromRect(
                  rect: cropDisplayRect,
                  child: GestureDetector(
                    onPanUpdate: (details) =>
                        onCropRectChanged(movedBy(details.delta)),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                handle('tl', Alignment.topLeft),
                handle('tr', Alignment.topRight),
                handle('bl', Alignment.bottomLeft),
                handle('br', Alignment.bottomRight),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.42),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '直接框选裁切',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<String?> editFramedCover(BuildContext context, String sourceUri) async {
  Rect cropRect = const Rect.fromLTWH(0.12, 0.12, 0.76, 0.76);
  bool cropInitializedForImage = false;
  double frameWidthFactor = 0.04;
  double cornerRadiusFactor = 0.11;
  double cardInsetFactor = 0.06;
  final imageSizeFuture = _decodeImageSizeFromUri(sourceUri);

  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget sectionCard({required Widget child}) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(.04)
                  : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: child,
          );
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF111316) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.16),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.92,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '裁切白框封面',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '直接在图片上拖动和拉伸正方形裁切框。白框封面最终是正方形，因此裁切框也锁定为正方形，避免导出时把图片拉伸变形。',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FutureBuilder<Size>(
                          future: imageSizeFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: const ColoredBox(
                                  color: Color(0xFFF2F5F8),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final imageSize = snapshot.data ?? const Size(1, 1);
                            if (!cropInitializedForImage) {
                              cropInitializedForImage = true;
                              cropRect = _defaultSquareCropForImageSize(
                                imageSize,
                              );
                            }
                            return _DirectCropSelectionPreview(
                              uri: sourceUri,
                              imageSize: imageSize,
                              cropRect: cropRect,
                              borderRadius: 28,
                              onCropRectChanged: (v) => setState(
                                () => cropRect = _normalizeSquareCropRect(
                                  v,
                                  imageSize,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '白框样式',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.crop_square_rounded,
                                        size: 18,
                                        color: kMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '边框厚度',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 0.02,
                                          max: 0.10,
                                          value: frameWidthFactor,
                                          onChanged: (v) => setState(
                                            () => frameWidthFactor = v,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        child: Text(
                                          frameWidthFactor.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.rounded_corner_rounded,
                                        size: 18,
                                        color: kMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '圆角大小',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 0.06,
                                          max: 0.18,
                                          value: cornerRadiusFactor,
                                          onChanged: (v) => setState(
                                            () => cornerRadiusFactor = v,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        child: Text(
                                          cornerRadiusFactor.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.fit_screen_rounded,
                                        size: 18,
                                        color: kMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '外边留白',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: kMuted,
                                        ),
                                      ),
                                      Expanded(
                                        child: Slider(
                                          min: 0.03,
                                          max: 0.12,
                                          value: cardInsetFactor,
                                          onChanged: (v) => setState(
                                            () => cardInsetFactor = v,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 44,
                                        child: Text(
                                          cardInsetFactor.toStringAsFixed(2),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => setState(() {
                              cropInitializedForImage = false;
                              cropRect = const Rect.fromLTWH(
                                0.12,
                                0.12,
                                0.76,
                                0.76,
                              );
                              frameWidthFactor = 0.04;
                              cornerRadiusFactor = 0.11;
                              cardInsetFactor = 0.06;
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('重置'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final out = await saveFramedCoverImage(
                                  sourceUri,
                                  cropRect: cropRect,
                                  frameWidthFactor: frameWidthFactor,
                                  cornerRadiusFactor: cornerRadiusFactor,
                                  cardInsetFactor: cardInsetFactor,
                                );
                                if (context.mounted)
                                  Navigator.pop(context, out);
                              },
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                              ),
                              label: const Text('生成白框封面'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  return result;
}

Future<String?> createFramedCoverFromPicker(BuildContext context) async {
  final uri = await NativeBridge.pickImage();
  if (uri == null || uri.trim().isEmpty) return null;
  return editFramedCover(context, uri);
}

List<Offset> _smoothTracePoints(List<Offset> raw, {int iterations = 2}) {
  if (raw.length < 3) return List<Offset>.from(raw);
  var points = List<Offset>.from(raw);
  for (int it = 0; it < iterations; it++) {
    final next = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final p0 = points[i];
      final p1 = points[(i + 1) % points.length];
      final q = Offset(p0.dx * .75 + p1.dx * .25, p0.dy * .75 + p1.dy * .25);
      final r = Offset(p0.dx * .25 + p1.dx * .75, p0.dy * .25 + p1.dy * .75);
      next
        ..add(q)
        ..add(r);
    }
    points = next;
  }
  return points
      .map(
        (p) => Offset(
          p.dx.clamp(0.0, 1.0).toDouble(),
          p.dy.clamp(0.0, 1.0).toDouble(),
        ),
      )
      .toList();
}

Path _pathFromPoints(List<Offset> points, {required bool close}) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  for (final point in points.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  if (close && points.length > 2) path.close();
  return path;
}

class _TraceOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final List<Offset> points;
  const _TraceOverlayPainter({required this.imageRect, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final normalized = points.length > 3
        ? _smoothTracePoints(points, iterations: 1)
        : points;
    final mapped = normalized
        .map(
          (p) => Offset(
            imageRect.left + p.dx * imageRect.width,
            imageRect.top + p.dy * imageRect.height,
          ),
        )
        .toList();
    final path = _pathFromPoints(mapped, close: mapped.length > 2);
    if (mapped.length > 2) {
      final full = Path()..addRect(Offset.zero & size);
      final mask = Path.combine(PathOperation.difference, full, path);
      canvas.drawPath(mask, Paint()..color = Colors.black.withOpacity(.28));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF7CC6F2).withOpacity(.10),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(.88),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF7CC6F2),
      );
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF7CC6F2),
      );
    }
    // Show only a few anchor dots so the preview does not look jagged/noisy.
    final stride = math.max(1, (mapped.length / 18).ceil());
    for (int i = 0; i < mapped.length; i += stride) {
      final p = mapped[i];
      canvas.drawCircle(p, 3.6, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        3.6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF7CC6F2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TraceOverlayPainter oldDelegate) {
    if (oldDelegate.imageRect != imageRect ||
        oldDelegate.points.length != points.length)
      return true;
    if (points.isEmpty) return false;
    return oldDelegate.points.first != points.first ||
        oldDelegate.points.last != points.last;
  }
}

class _ManualTracePreview extends StatelessWidget {
  final String uri;
  final Size imageSize;
  final List<Offset> points;
  final ValueChanged<Offset> onPointStart;
  final ValueChanged<Offset> onPointAppend;
  const _ManualTracePreview({
    required this.uri,
    required this.imageSize,
    required this.points,
    required this.onPointStart,
    required this.onPointAppend,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePathFromUriText(uri));
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _fitContainRect(imageSize, areaSize);
        return ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Container(
            color: context.isDark
                ? Colors.white.withOpacity(.05)
                : const Color(0xFFF2F5F8),
            child: GestureDetector(
              onPanStart: (details) => onPointStart(
                _normalizedPointFromLocal(details.localPosition, imageRect),
              ),
              onPanUpdate: (details) => onPointAppend(
                _normalizedPointFromLocal(details.localPosition, imageRect),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                        cacheWidth: _previewCacheSide(context),
                        cacheHeight: _previewCacheSide(context),
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        isComplex: true,
                        willChange: true,
                        painter: _TraceOverlayPainter(
                          imageRect: imageRect,
                          points: List<Offset>.of(points),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '手动勾勒物体边缘',
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<String> saveTracedStickerImage(
  String sourceUri,
  List<Offset> points,
) async {
  final sourcePath = filePathFromUriText(sourceUri);
  final sourceSize = await _decodeImageSizeFromUri(sourceUri);
  final bytes = await File(sourcePath).readAsBytes();
  final maxSide = math.max(sourceSize.width, sourceSize.height);
  final targetWidth = maxSide > 1800
      ? (sourceSize.width / maxSide * 1800).round()
      : null;
  final targetHeight = maxSide > 1800
      ? (sourceSize.height / maxSide * 1800).round()
      : null;
  final codec = await instantiateImageCodec(
    bytes,
    targetWidth: targetWidth,
    targetHeight: targetHeight,
  );
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final smooth = _smoothTracePoints(points, iterations: 2);
  final pixelPoints = smooth
      .map((p) => Offset(p.dx * image.width, p.dy * image.height))
      .toList();
  double minX = pixelPoints.map((e) => e.dx).reduce(math.min);
  double maxX = pixelPoints.map((e) => e.dx).reduce(math.max);
  double minY = pixelPoints.map((e) => e.dy).reduce(math.min);
  double maxY = pixelPoints.map((e) => e.dy).reduce(math.max);
  final baseSide = math.max(maxX - minX, maxY - minY);
  final strokeWidth = math.max(14.0, baseSide * 0.055);
  final padding =
      math.max(image.width, image.height) * 0.025 + strokeWidth * 1.4;
  minX = (minX - padding).clamp(0.0, image.width.toDouble()).toDouble();
  minY = (minY - padding).clamp(0.0, image.height.toDouble()).toDouble();
  maxX = (maxX + padding).clamp(0.0, image.width.toDouble()).toDouble();
  maxY = (maxY + padding).clamp(0.0, image.height.toDouble()).toDouble();
  final outW = math.max(1, (maxX - minX).ceil());
  final outH = math.max(1, (maxY - minY).ceil());
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final path = _pathFromPoints(
    pixelPoints.map((p) => Offset(p.dx - minX, p.dy - minY)).toList(),
    close: true,
  );
  // Sticker style: draw a white outline and a soft shadow behind the clipped subject.
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.18
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withOpacity(.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white,
  );
  canvas.save();
  canvas.clipPath(path);
  canvas.drawImage(
    image,
    Offset(-minX, -minY),
    Paint()..filterQuality = FilterQuality.high,
  );
  canvas.restore();
  final outImage = await recorder.endRecording().toImage(outW, outH);
  final byteData = await outImage.toByteData(format: ImageByteFormat.png);
  final outFile = File(
    '${File(sourcePath).parent.path}/manual_trace_sticker_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await outFile.writeAsBytes(
    byteData?.buffer.asUint8List() ?? Uint8List(0),
    flush: true,
  );
  return 'file://${outFile.path}';
}

Future<String?> editManualTraceSticker(
  BuildContext context,
  String sourceUri,
) async {
  final imageSizeFuture = _decodeImageSizeFromUri(sourceUri);
  final points = <Offset>[];
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget sectionCard({required Widget child}) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withOpacity(.04)
                  : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: child,
          );
          return Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF111316) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.16),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.92,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '手动勾勒贴纸',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '直接在图片上沿着物体边缘划一圈。系统会平滑轮廓、自动闭合、加白色贴纸边，再进入最终调整。',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FutureBuilder<Size>(
                          future: imageSizeFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: const ColoredBox(
                                  color: Color(0xFFF2F5F8),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return _ManualTracePreview(
                              uri: sourceUri,
                              imageSize: snapshot.data ?? const Size(1, 1),
                              points: points,
                              onPointStart: (p) =>
                                  setState(() => points.add(p)),
                              onPointAppend: (p) {
                                if (points.isEmpty) {
                                  setState(() => points.add(p));
                                } else {
                                  final last = points.last;
                                  final dist = (last - p).distance;
                                  if (dist > 0.008)
                                    setState(() => points.add(p));
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          children: [
                            sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '操作提示',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '1. 从物体轮廓一侧开始画。\n2. 尽量连续地绕物体一圈。\n3. 至少保留 3 个点后再生成。\n4. 勾勒完成后会自动平滑、闭合、裁切并加白边。',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: points.isEmpty
                                            ? null
                                            : () => setState(() {
                                                if (points.isNotEmpty)
                                                  points.removeLast();
                                              }),
                                        icon: const Icon(Icons.undo_rounded),
                                        label: const Text('撤销一点'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: points.isEmpty
                                            ? null
                                            : () => setState(
                                                () => points.clear(),
                                              ),
                                        icon: const Icon(
                                          Icons.layers_clear_rounded,
                                        ),
                                        label: const Text('清空重画'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            if (points.length < 3) {
                              showNativeSnack(context, '至少需要勾勒出 3 个点才能生成');
                              return;
                            }
                            final out = await saveTracedStickerImage(
                              sourceUri,
                              points,
                            );
                            if (context.mounted) Navigator.pop(context, out);
                          },
                          icon: const Icon(Icons.auto_fix_high_rounded),
                          label: const Text('生成贴纸并继续调整'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  return result;
}

Future<String?> createManualTraceStickerFromPicker(BuildContext context) async {
  final uri = await NativeBridge.pickImage();
  if (uri == null || uri.trim().isEmpty) return null;
  final traced = await editManualTraceSticker(context, uri);
  if (traced == null || traced.trim().isEmpty || !context.mounted)
    return traced;
  return adjustStickerCover(context, traced);
}

Future<void> restoreJsonFromText(BuildContext context, String? text) async {
  if (text == null || text.trim().isEmpty) {
    showNativeSnack(context, '没有读取到可恢复的数据');
    return;
  }
  final ok = context.store.restoreFromJson(text);
  if (ok) {
    successHaptic();
    if (Navigator.canPop(context)) Navigator.pop(context);
    showNativeSnack(context, '已从原生数据源恢复');
  } else {
    warningHaptic();
    showNativeSnack(context, '内容不是有效的值谱 JSON 备份');
  }
}

Future<void> restoreDataArchiveFromPicker(BuildContext context) async {
  final store = context.store;
  final payload = await NativeBridge.importDataArchive();
  if (payload.isEmpty) {
    if (context.mounted) showNativeSnack(context, '未选择 ZIP 资料包');
    return;
  }
  final ok = payload['ok'] == true;
  final message = (payload['message'] ?? '').toString();
  if (!ok) {
    warningHaptic();
    if (context.mounted)
      showNativeSnack(context, message.isEmpty ? 'ZIP 资料包读取失败' : message);
    return;
  }
  var jsonText = (payload['json'] ?? '').toString();
  final jsonPath = (payload['jsonPath'] ?? '').toString();
  if (jsonText.trim().isEmpty && jsonPath.trim().isNotEmpty) {
    try {
      jsonText = await File(filePathFromUriText(jsonPath)).readAsString();
    } catch (_) {
      jsonText = await NativeBridge.readPrivateTextFile(jsonPath) ?? '';
    }
  }
  if (jsonText.trim().isEmpty) {
    warningHaptic();
    if (context.mounted)
      showNativeSnack(context, 'ZIP 中没有可恢复的 JSON 数据，或恢复文件读取失败');
    return;
  }
  int countList(String key) {
    try {
      final raw = jsonDecode(jsonText);
      if (raw is Map && raw[key] is List) return (raw[key] as List).length;
    } catch (_) {}
    return 0;
  }

  final mediaCount = payload['mediaCount'] is num
      ? (payload['mediaCount'] as num).toInt()
      : 0;
  final sqliteCount = payload['sqliteCount'] is num
      ? (payload['sqliteCount'] as num).toInt()
      : 0;
  final entryCount = payload['entryCount'] is num
      ? (payload['entryCount'] as num).toInt()
      : 0;
  final assetCount = countList('assets');
  final wishCount = countList('wishes');
  final categoryCount = countList('categories');
  final tagCount = countList('tags');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('恢复完整资料包？'),
      content: Text(
        '这会用 ZIP 中的备份覆盖当前数据。\n\n'
        '将恢复：$assetCount 个资产、$wishCount 个心愿、$categoryCount 个分类、$tagCount 个标签。\n'
        '已复制媒体文件：$mediaCount 个。\n'
        'ZIP 条目数量：$entryCount 个。\n'
        'ZIP 内 SQLite 文件：$sqliteCount 个（不会直接覆盖运行中的数据库，会通过 JSON 重建当前 SQLite 数据）。\n\n'
        '恢复前会先自动创建一份本机快照，方便回退。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('确认恢复'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    store.createSnapshot('ZIP恢复前自动快照 ${dateStamp()}');
  } catch (_) {}

  final restored = store.restoreFromJson(jsonText);
  if (restored) {
    successHaptic();
    if (Navigator.canPop(context)) Navigator.pop(context);
    if (context.mounted)
      showNativeSnack(
        context,
        '已从 ZIP 资料包恢复：$assetCount 个资产，$mediaCount 个媒体文件',
      );
  } else {
    warningHaptic();
    if (context.mounted) showNativeSnack(context, 'ZIP 中的 JSON 数据无法恢复');
  }
}

class NativeFeaturePanel extends StatelessWidget {
  const NativeFeaturePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: 'Android 原生能力',
          children: [
            SettingRow(
              icon: Icons.touch_app_rounded,
              iconBg: const Color(0xFFBDEB7E),
              label: '原生触感测试',
              description: 'Vibrator / VibrationEffect，覆盖导航、保存、弹层、开关',
              trailing: const ValuePill('A'),
              onTap: () {
                successHaptic();
                showNativeSnack(context, '已触发触感测试');
              },
            ),
            SettingRow(
              icon: Icons.image_search_rounded,
              iconBg: const Color(0xFFC8EBFF),
              label: '相册 / 拍照接入',
              description: '调用 Android Photo Picker 和系统相机 Intent',
              trailing: const ValuePill('E'),
              onTap: () => showNativeMediaSheet(context),
            ),
            SettingRow(
              icon: Icons.notifications_active_rounded,
              iconBg: const Color(0xFFFFDC65),
              label: '提醒、通知与快捷方式',
              description: '本地通知、通知设置、桌面长按快捷入口',
              trailing: const ValuePill('C/G'),
              onTap: () => showNativeAutomationSheet(context),
            ),
            SettingRow(
              icon: Icons.widgets_rounded,
              iconBg: const Color(0xFF98E0FF),
              label: '桌面小组件刷新',
              description: '把资产总值、资产数、心愿数同步到 Android Widget',
              trailing: const ValuePill('D'),
              onTap: () async {
                await NativeBridge.updateHomeWidget(
                  assetCount: store.assets.length,
                  wishCount: store.wishes.where((w) => !w.archived).length,
                  totalAssetValue: store.getTotalAssetValue(),
                  averageDailyCost: store.getAverageDailyCost(),
                  currency: store.settings.currencyUnit,
                );
                showNativeSnack(context, '已请求刷新桌面小组件');
              },
            ),
            SettingRow(
              icon: Icons.content_paste_search_rounded,
              iconBg: const Color(0xFFA78BFA),
              label: '剪贴板读入',
              description: '读取系统剪贴板，支持识别 JSON 备份或生成资产草稿',
              trailing: const ValuePill('剪贴板'),
              onTap: () => showClipboardImportSheet(context),
            ),
            SettingRow(
              icon: Icons.share_rounded,
              iconBg: const Color(0xFFFFB5A6),
              label: '分享 / 接收分享',
              description: '系统分享面板、外部文本分享接收、App 设置跳转',
              trailing: const ValuePill('G'),
              onTap: () => showNativeSystemSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsSection(
          title: '原生备份与报告',
          children: [
            SettingRow(
              icon: Icons.file_upload_rounded,
              iconBg: const Color(0xFF8FD0F6),
              label: '导出 JSON 到系统文件',
              description: '使用 Android Storage Access Framework 选择保存位置',
              trailing: const ValuePill('F'),
              onTap: () async {
                final uri = await NativeBridge.exportTextFile(
                  fileName: 'valora_backup_${dateStamp()}.json',
                  text: store.exportJson(),
                  mimeType: 'application/json',
                );
                showNativeSnack(context, uri == null ? '导出已取消或失败' : '已导出到系统文件');
              },
            ),
            SettingRow(
              icon: Icons.archive_rounded,
              iconBg: const Color(0xFFBDEB7E),
              label: '从完整资料包 ZIP 恢复',
              description: '选择 v48/v49 导出的 ZIP，恢复 JSON 数据并复制封面、贴纸等媒体文件',
              trailing: const ValuePill('ZIP'),
              onTap: () async => restoreDataArchiveFromPicker(context),
            ),
            SettingRow(
              icon: Icons.file_download_rounded,
              iconBg: const Color(0xFFBDEB7E),
              label: '从系统文件恢复 JSON',
              description: '只恢复结构化数据，不包含封面、贴纸图片',
              trailing: const ValuePill('JSON'),
              onTap: () async => restoreJsonFromText(
                context,
                await NativeBridge.importTextFile(mimeType: 'application/json'),
              ),
            ),
            SettingRow(
              icon: Icons.table_chart_rounded,
              iconBg: const Color(0xFFC8EBFF),
              label: '导出 CSV 资产表',
              description: '可用 Excel / WPS 打开，用于整理资产清单',
              trailing: const ValuePill('CSV'),
              onTap: () async {
                final uri = await NativeBridge.exportTextFile(
                  fileName: 'valora_assets_${dateStamp()}.csv',
                  text: buildAssetsCsv(store),
                  mimeType: 'text/csv',
                );
                showNativeSnack(context, uri == null ? '导出已取消或失败' : 'CSV 已导出');
              },
            ),
            SettingRow(
              icon: Icons.description_rounded,
              iconBg: const Color(0xFF7CC6F2),
              label: '导出 Markdown 报告',
              description: '生成资产复盘报告，也可通过系统分享面板发送',
              trailing: const ValuePill('MD'),
              onTap: () async => showReportExportSheet(context),
            ),
          ],
        ),
      ],
    );
  }
}

void showNativeMediaSheet(BuildContext context) {
  appSheet(
    context,
    title: '相册 / 拍照 / 智能识别',
    subtitle: '相册和拍照会复制到 App 私有目录；条码与小票 OCR 使用 Android ML Kit 离线识别。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final uri = await NativeBridge.pickImage();
            if (context.mounted)
              showNativeSnack(context, uri == null ? '未选择图片' : '已保存封面文件：$uri');
          },
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('打开系统相册并持久化'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final uri = await NativeBridge.capturePhoto();
            if (context.mounted)
              showNativeSnack(
                context,
                uri == null ? '拍照已取消或设备不支持' : '相机照片已保存：$uri',
              );
          },
          icon: const Icon(Icons.photo_camera_rounded),
          label: const Text('拍照添加封面'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final payload = await NativeBridge.cutoutImageFromPickerDetailed();
            final uri = context.mounted
                ? await chooseStickerCandidate(context, payload)
                : null;
            if (context.mounted)
              showNativeSnack(
                context,
                uri == null ? '未生成贴纸封面' : '已选中贴纸 PNG：$uri',
              );
          },
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: const Text('测试贴纸封面'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final data = nativeJsonMap(
              await NativeBridge.scanBarcodeFromImage(),
            );
            if (context.mounted)
              showNativeSnack(
                context,
                data['found'] == true
                    ? "识别到条码：${data['rawValue']}"
                    : '未识别到条码 / 二维码',
              );
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('从图片扫描条码 / 二维码'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final data = nativeJsonMap(
              await NativeBridge.recognizeReceiptFromImage(),
            );
            final price = data['priceCandidate']?.toString() ?? '';
            if (context.mounted)
              showNativeSnack(
                context,
                price.isEmpty ? '已完成 OCR，但没有提取到价格' : 'OCR 价格候选：$price',
              );
          },
          icon: const Icon(Icons.receipt_long_rounded),
          label: const Text('从小票图片 OCR 识别'),
        ),
        const SizedBox(height: 10),
        const Text(
          '提示：真正新增资产时，请在右下角 + 的新增页使用“选封面 / 扫条码 / 小票 OCR”，识别结果会自动回填名称、价格、日期和备注。',
          style: TextStyle(color: kMuted, fontSize: 12, height: 1.45),
        ),
      ],
    ),
  );
}

void showNativeAutomationSheet(BuildContext context) {
  appSheet(
    context,
    title: '提醒、通知与快捷方式',
    subtitle:
        '用 Android Notification / AlarmManager / ShortcutManager 增加系统级入口。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final ok = await NativeBridge.scheduleNotification(
              title: '值谱资产体检',
              text: '到时间复盘一下高日耗、临期和闲置资产了。',
              delayMillis: 60000,
            );
            if (context.mounted)
              showNativeSnack(context, ok ? '已安排 1 分钟后的测试提醒' : '提醒安排失败');
          },
          icon: const Icon(Icons.alarm_rounded),
          label: const Text('1 分钟后测试提醒'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await NativeBridge.createShortcuts();
            if (context.mounted)
              showNativeSnack(context, ok ? '已创建桌面长按快捷入口' : '当前系统不支持动态快捷方式');
          },
          icon: const Icon(Icons.add_to_home_screen_rounded),
          label: const Text('创建长按快捷入口'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await NativeBridge.requestNotificationPermission();
            if (context.mounted)
              showNativeSnack(context, ok ? '已请求通知权限' : '当前系统无需运行时通知权限');
          },
          icon: const Icon(Icons.verified_rounded),
          label: const Text('请求通知权限'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => NativeBridge.openNotificationSettings(),
          icon: const Icon(Icons.settings_rounded),
          label: const Text('打开通知设置'),
        ),
      ],
    ),
  );
}

void showClipboardImportSheet(BuildContext context) {
  appSheet(
    context,
    title: '剪贴板读入',
    subtitle: '可以从剪贴板恢复值谱 JSON，或把普通文本作为资产名称草稿。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final text = await NativeBridge.readClipboard();
            if (text == null || text.trim().isEmpty) {
              if (context.mounted) showNativeSnack(context, '剪贴板为空');
              return;
            }
            if (text.trimLeft().startsWith('{')) {
              if (context.mounted) await restoreJsonFromText(context, text);
            } else {
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.of(context).push(
                softRoute(
                  ComposePage(
                    initialTab: ComposeTab.asset,
                    initialName: text.trim().split('\n').first.take(24),
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.content_paste_go_rounded),
          label: const Text('读取剪贴板'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await NativeBridge.writeClipboard(context.store.exportJson());
            if (context.mounted) showNativeSnack(context, '已写入当前 JSON 到剪贴板');
          },
          icon: const Icon(Icons.copy_all_rounded),
          label: const Text('复制当前 JSON'),
        ),
      ],
    ),
  );
}

List<String> collectLocalMediaPaths(AppStore store) {
  final values = <String>[
    ...store.assets.map((a) => a.iconValue),
    ...store.wishes.map((w) => w.iconValue),
  ];
  final paths = <String>{};
  for (final value in values) {
    final v = value.trim();
    if (v.isEmpty || !isValoraImageIcon(v)) continue;
    final path = filePathFromUriText(v);
    if (path.startsWith('/')) paths.add(path);
  }
  return paths.toList();
}

Future<void> shareCompleteDataArchive(BuildContext context) async {
  final store = context.store;
  final mediaPaths = collectLocalMediaPaths(store);
  await NativeBridge.shareDataArchive(
    title: '值谱完整资料包',
    fileName: 'valora_complete_backup_${dateStamp()}.zip',
    json: store.exportJson(),
    csv: buildAssetsCsv(store),
    markdown: buildMarkdownReport(store),
    mediaPaths: mediaPaths,
  );
  if (context.mounted) {
    showNativeSnack(
      context,
      mediaPaths.isEmpty
          ? '已生成完整资料包：包含数据库、JSON、CSV 和报告'
          : '已生成完整资料包：包含数据库、JSON、CSV、报告和 ${mediaPaths.length} 个媒体文件',
    );
  }
}

void showNativeSystemSheet(BuildContext context) {
  final store = context.store;
  appSheet(
    context,
    title: '分享 / 系统集成',
    subtitle: 'JSON 只适合纯数据恢复；完整资料包会打包 SQLite、JSON、CSV、报告和本地封面/贴纸图片。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async => shareCompleteDataArchive(context),
          icon: const Icon(Icons.archive_rounded),
          label: const Text('分享完整资料包 ZIP'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => restoreDataArchiveFromPicker(context),
          icon: const Icon(Icons.unarchive_rounded),
          label: const Text('从完整资料包 ZIP 恢复'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => NativeBridge.shareText(
            title: '值谱资产摘要',
            text: buildMarkdownReport(store),
          ),
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('分享文字摘要'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final info = await NativeBridge.getInitialIntentInfo();
            if (context.mounted)
              showNativeSnack(
                context,
                info == null || info.isEmpty ? '暂无外部分享数据' : info,
              );
          },
          icon: const Icon(Icons.call_received_rounded),
          label: const Text('读取启动 Intent / 分享数据'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async => NativeBridge.openAppSettings(),
          icon: const Icon(Icons.app_settings_alt_rounded),
          label: const Text('打开系统应用设置'),
        ),
      ],
    ),
  );
}

void showReportExportSheet(BuildContext context) {
  final report = buildMarkdownReport(context.store);
  appSheet(
    context,
    title: '导出 Markdown 报告',
    subtitle: '可保存成文件，也可直接调起系统分享面板。',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            final uri = await NativeBridge.exportTextFile(
              fileName: 'valora_report_${dateStamp()}.md',
              text: report,
              mimeType: 'text/markdown',
            );
            if (context.mounted)
              showNativeSnack(context, uri == null ? '导出已取消或失败' : '报告已导出');
          },
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text('保存 Markdown 文件'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async =>
              NativeBridge.shareText(title: '值谱资产报告', text: report),
          icon: const Icon(Icons.share_rounded),
          label: const Text('通过系统分享'),
        ),
      ],
    ),
  );
}
