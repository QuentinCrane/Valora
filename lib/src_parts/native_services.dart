part of '../main.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('valora/native');

  static Future<T?> _call<T>(String method,
      [Map<String, dynamic>? args]) async {
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
        'title': title ?? tr('common.pickDate')
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

  static Future<void> setStickerEngineConfig(
      {required String mode, required bool keepCandidates}) async {
    await _call<Object>('setStickerEngineConfig',
        {'mode': mode, 'keepCandidates': keepCandidates});
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

  static Future<String?> exportTextFile(
          {required String fileName,
          required String text,
          String mimeType = 'text/plain'}) =>
      _call<String>('exportTextFile', {
        'fileName': fileName,
        'mimeType': mimeType,
        'text': text,
      });

  static Future<void> shareText(
      {required String title, required String text}) async {
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

  static Future<bool> scheduleNotification(
          {required String title,
          required String text,
          int delayMillis = 60000}) async =>
      await _call<bool>('scheduleNotification',
          {'title': title, 'text': text, 'delayMillis': delayMillis}) ??
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
    [
      tr('csv.name'),
      tr('csv.category'),
      tr('csv.price'),
      tr('csv.currentValue'),
      tr('csv.date'),
      tr('csv.status'),
      tr('csv.dailyCost'),
      tr('csv.tags'),
      tr('csv.note')
    ],
    ...store.assets.map((a) => [
          a.name,
          store.categoryName(a.categoryId),
          a.isPriceless ? '∞' : a.price.toStringAsFixed(2),
          a.isPriceless ? '∞' : a.assetValue.toStringAsFixed(2),
          dateText(a.purchaseDate),
          a.status.localizedLabel,
          a.isPriceless
              ? tr('common.noDailyCost')
              : a.dailyCost.toStringAsFixed(2),
          a.tagIds.map(store.tagName).join('/'),
          a.note,
        ]),
  ];
  return rows.map((r) => r.map(cell).join(',')).join('\n');
}

String buildMarkdownReport(AppStore store) {
  final buffer = StringBuffer();
  buffer.writeln('# ${tr('report.title')}');
  buffer.writeln();
  buffer.writeln(
      '- ${tr('report.generatedAt')}${DateTime.now().toIso8601String()}');
  buffer.writeln('- ${tr('report.assetCount')}${store.assets.length}');
  buffer.writeln(
      '- ${tr('report.wishCount')}${store.wishes.where((w) => !w.archived).length}');
  buffer.writeln(
      '- ${tr('report.totalValue')}${money(store.getTotalAssetValue(), store.settings)}');
  buffer.writeln(
      '- ${tr('report.avgDailyCost')}${money(store.getAverageDailyCost(), store.settings)}');
  buffer.writeln();
  buffer.writeln('## ${tr('report.assetList')}');
  buffer.writeln();
  if (store.assets.isEmpty) {
    buffer.writeln(tr('report.noAssets'));
  } else {
    buffer.writeln(
        '| ${tr('csv.name')} | ${tr('csv.category')} | ${tr('csv.status')} | ${tr('csv.currentValue')} | ${tr('csv.dailyCost')} |');
    buffer.writeln('|---|---|---|---:|---:|');
    for (final a in store.assets) {
      buffer.writeln(
          '| ${a.iconValue} ${a.name} | ${store.categoryName(a.categoryId)} | ${a.status.localizedLabel} | ${a.isPriceless ? '∞' : money(a.assetValue, store.settings)} | ${a.isPriceless ? tr('common.noDailyCost') : money(a.dailyCost, store.settings)} |');
    }
  }
  buffer.writeln();
  buffer.writeln('## ${tr('report.walletLeaks')}');
  final leaks = store.walletLeaks(limit: 8);
  if (leaks.isEmpty) {
    buffer.writeln(tr('report.noLeaks'));
  } else {
    for (final item in leaks) {
      buffer.writeln(
          '- **${item.asset.name}**：${item.reason}。${item.suggestion}');
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
  final bottom = MediaQuery.paddingOf(context).bottom +
      (valoraCompactSnackbars ? 92.0 : 24.0);
  messenger.showSnackBar(
    SnackBar(
      content: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
      duration: const Duration(milliseconds: 1800),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      dismissDirection: DismissDirection.horizontal,
      action: SnackBarAction(
        label: tr('common.close'),
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
    Map<String, dynamic> payload, String selectedUri,
    {required bool keepCandidates}) {
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
  const _StickerBrushStroke(
      {required this.mode, required this.points, required this.radiusFactor});
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
        ..strokeWidth =
            math.max(1.0, stroke.radiusFactor * size.shortestSide * 2)
        ..color = (stroke.mode == 'restore'
                ? const Color(0xFF44C27A)
                : const Color(0xFFFF6B6B))
            .withOpacity(faded ? .35 : .72);
      final path = Path();
      final first = Offset(stroke.points.first.dx * size.width,
          stroke.points.first.dy * size.height);
      path.moveTo(first.dx, first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      if (stroke.points.length == 1) {
        canvas.drawCircle(
            first, paint.strokeWidth / 2, Paint()..color = paint.color);
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
      255, (r / count).round(), (g / count).round(), (b / count).round());
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
    for (int yy = math.max(0, y - 1).toInt();
        yy <= math.min(height - 1, y + 1).toInt();
        yy++) {
      for (int xx = math.max(0, x - 1).toInt();
          xx <= math.min(width - 1, x + 1).toInt();
          xx++) {
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

void _applyLightStickerEdgeEnhancement(
  Uint8List rgba,
  int width,
  int height, {
  required String recognitionMode,
  required double edgeTune,
}) {
  if (rgba.isEmpty || width <= 2 || height <= 2) return;
  final length = width * height;
  final alpha = Uint8List(length);
  for (int p = 0, i = 3; p < length && i < rgba.length; p++, i += 4) {
    alpha[p] = rgba[i];
  }
  final nextAlpha = Uint8List.fromList(alpha);
  final nextRgb = Uint8List.fromList(rgba);
  final isEdgeMode = recognitionMode == 'edge';
  final smoothMix = (isEdgeMode ? .34 : .22) + edgeTune.clamp(0.0, 1.0) * .10;

  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      final p = y * width + x;
      final i = p * 4;
      final a = alpha[p];
      var solid = 0;
      var transparent = 0;
      var alphaSum = 0;
      var rSum = 0;
      var gSum = 0;
      var bSum = 0;
      var rgbCount = 0;
      for (int yy = -1; yy <= 1; yy++) {
        for (int xx = -1; xx <= 1; xx++) {
          final np = (y + yy) * width + (x + xx);
          final ni = np * 4;
          final na = alpha[np];
          alphaSum += na;
          if (na > 156) {
            solid++;
            rSum += rgba[ni];
            gSum += rgba[ni + 1];
            bSum += rgba[ni + 2];
            rgbCount++;
          } else if (na < 22) {
            transparent++;
          }
        }
      }

      // Remove isolated mask noise around the cutout edge.
      if (a > 0 && solid <= 1 && transparent >= 6) {
        nextAlpha[p] = 0;
        nextRgb[i] = 0;
        nextRgb[i + 1] = 0;
        nextRgb[i + 2] = 0;
        nextRgb[i + 3] = 0;
        continue;
      }

      // Close tiny pin-holes generated by automatic segmentation. This is
      // intentionally conservative so manual erase strokes remain respected.
      if (a < 18 && solid >= 8 && rgbCount > 0) {
        nextAlpha[p] = (alphaSum / 9).round().clamp(96, 255).toInt();
        nextRgb[i] = (rSum / rgbCount).round().clamp(0, 255).toInt();
        nextRgb[i + 1] = (gSum / rgbCount).round().clamp(0, 255).toInt();
        nextRgb[i + 2] = (bSum / rgbCount).round().clamp(0, 255).toInt();
        nextRgb[i + 3] = nextAlpha[p];
        continue;
      }

      // Sub-pixel feathering near transparent pixels makes sticker edges less
      // jagged without adding a model dependency or APK size.
      final boundary = solid > 0 && transparent > 0;
      if (boundary && a > 0) {
        final avgA = (alphaSum / 9).round().clamp(0, 255).toInt();
        final mixed = (a * (1 - smoothMix) + avgA * smoothMix)
            .round()
            .clamp(0, 255)
            .toInt();
        nextAlpha[p] = mixed < 16 ? 0 : mixed;
        nextRgb[i + 3] = nextAlpha[p];
        if (nextAlpha[p] == 0) {
          nextRgb[i] = 0;
          nextRgb[i + 1] = 0;
          nextRgb[i + 2] = 0;
        }
      }
    }
  }

  rgba.setAll(0, nextRgb);
  for (int p = 0, i = 3; p < length && i < rgba.length; p++, i += 4) {
    rgba[i] = nextAlpha[p];
  }
}

void _drawStickerWhiteEdge(Canvas canvas, ui.Image image, Rect dst, double srcW,
    double srcH, int canvasSize) {
  final outlinePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcIn);
  final radius = math.max(7.0, canvasSize * .020);
  final offsets = <Offset>[
    Offset(radius, 0),
    Offset(-radius, 0),
    Offset(0, radius),
    Offset(0, -radius),
    Offset(radius * .72, radius * .72),
    Offset(-radius * .72, radius * .72),
    Offset(radius * .72, -radius * .72),
    Offset(-radius * .72, -radius * .72),
    Offset(radius * .38, radius),
    Offset(-radius * .38, radius),
    Offset(radius * .38, -radius),
    Offset(-radius * .38, -radius),
  ];
  final src = Rect.fromLTWH(0, 0, srcW, srcH);
  for (final o in offsets) {
    canvas.drawImageRect(image, src, dst.shift(o), outlinePaint);
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
          (stroke.radiusFactor * canvasSize / math.max(drawScale, 0.001))
              .round());
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
            1);
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
    _applyLightStickerEdgeEnhancement(
      rgba,
      image.width,
      image.height,
      recognitionMode: recognitionMode,
      edgeTune: edgeTune,
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
  if (editableSourceRgba.isNotEmpty) {
    _applyLightStickerEdgeEnhancement(
      editableSourceRgba,
      image.width,
      image.height,
      recognitionMode: recognitionMode,
      edgeTune: math.max(edgeTune, .16),
    );
  }
  final processedImage = editableSourceRgba.isEmpty
      ? image
      : await _imageFromRgba(editableSourceRgba, image.width, image.height);
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final dst = Rect.fromLTWH(left, top, drawW, drawH);
  _drawStickerWhiteEdge(canvas, processedImage, dst, srcW, srcH, canvasSize);
  canvas.drawImageRect(processedImage, Rect.fromLTWH(0, 0, srcW, srcH), dst,
      Paint()..filterQuality = FilterQuality.high);
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
      '${sourceFile.parent.path}/adjusted_sticker_${DateTime.now().millisecondsSinceEpoch}.png');
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
    final strokesChanged = oldWidget.strokes.length != widget.strokes.length ||
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
    future.then((bytes) {
      if (!mounted || !identical(_previewFuture, future)) return;
      setState(() => _lastPreviewBytes = bytes);
    }).catchError((_) {});
    setState(() {});
  }

  Future<Uint8List> _buildPreview() {
    final allStrokes = [
      ...widget.strokes,
      if (widget.activeStroke != null) widget.activeStroke!
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
            (local.dy / math.max(1, size)).clamp(0.0, 1.0));
        return GestureDetector(
          onPanStart: (details) {
            if (widget.toolMode != 'move')
              widget.onStrokeStart?.call(normalize(details.localPosition));
          },
          onPanUpdate: (details) {
            if (widget.toolMode == 'move') {
              widget.onPanMove?.call(Offset(
                  details.delta.dx / math.max(1, size),
                  details.delta.dy / math.max(1, size)));
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
              child: Stack(children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: (context.isDark ? Colors.white : Colors.black)
                              .withOpacity(.05)),
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
                            child: CircularProgressIndicator(strokeWidth: 2));
                      }
                      return Image.memory(bytes,
                          fit: BoxFit.contain, gaplessPlayback: true);
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
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.38),
                                borderRadius: BorderRadius.circular(999)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.6, color: Colors.white)),
                              const SizedBox(width: 6),
                              Text(tr('sticker.updating'),
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white)),
                            ]),
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
                              activeStroke: widget.activeStroke))),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(
                        widget.contain
                            ? tr('sticker.contain')
                            : tr('sticker.fill'),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(
                        widget.toolMode == 'move'
                            ? tr('sticker.livePreview')
                            : widget.toolMode == 'erase'
                                ? tr('sticker.eraseTrim')
                                : tr('sticker.restoreTrim'),
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

Future<String?> adjustStickerCover(
    BuildContext context, String sourceUri) async {
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
                radiusFactor: brushRadiusFactor);
            setState(() {});
          }

          void appendStroke(Offset point) {
            if (activeStroke == null) return;
            activeStroke = _StickerBrushStroke(
                mode: activeStroke!.mode,
                radiusFactor: activeStroke!.radiusFactor,
                points: [...activeStroke!.points, point]);
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
                      color: context.isDark ? Colors.white10 : Colors.black12),
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
                    offset: const Offset(0, 16))
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.94,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                      child: Row(children: [
                        Expanded(
                            child: Text(tr('sticker.repairTitle'),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700))),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(tr('common.cancel'))),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(tr('sticker.repairDesc'),
                              style: TextStyle(fontSize: 12, color: kMuted))),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(tr('sticker.tools'),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 10),
                                    SegmentedButton<String>(
                                      segments: [
                                        ButtonSegment<String>(
                                            value: 'move',
                                            icon: Icon(Icons.open_with_rounded),
                                            label: Text(tr('sticker.move'))),
                                        ButtonSegment<String>(
                                            value: 'erase',
                                            icon: Icon(
                                                Icons.auto_fix_off_rounded),
                                            label: Text(tr('sticker.eraser'))),
                                        ButtonSegment<String>(
                                            value: 'restore',
                                            icon: Icon(Icons.brush_rounded),
                                            label: Text(tr('sticker.restore'))),
                                      ],
                                      selected: {toolMode},
                                      onSelectionChanged: (v) =>
                                          setState(() => toolMode = v.first),
                                    ),
                                    if (toolMode != 'move') ...[
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        const Icon(Icons.circle_outlined,
                                            size: 18, color: kMuted),
                                        const SizedBox(width: 8),
                                        Text(tr('sticker.brushSize'),
                                            style: TextStyle(
                                                fontSize: 13, color: kMuted)),
                                        Expanded(
                                            child: Slider(
                                                min: 0.008,
                                                max: 0.065,
                                                value: brushRadiusFactor,
                                                onChanged: (v) => setState(() =>
                                                    brushRadiusFactor = v))),
                                        SizedBox(
                                            width: 46,
                                            child: Text(
                                                '${(brushRadiusFactor * 1000).round()}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: kMuted))),
                                      ]),
                                      Row(children: [
                                        OutlinedButton.icon(
                                            onPressed: strokes.isEmpty
                                                ? null
                                                : () => setState(() {
                                                      if (strokes.isNotEmpty)
                                                        strokes.removeLast();
                                                    }),
                                            icon:
                                                const Icon(Icons.undo_rounded),
                                            label:
                                                Text(tr('sticker.undoTrim'))),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                            onPressed: strokes.isEmpty
                                                ? null
                                                : () => setState(
                                                    () => strokes.clear()),
                                            icon: const Icon(
                                                Icons.layers_clear_rounded),
                                            label:
                                                Text(tr('sticker.clearTrim'))),
                                      ]),
                                    ],
                                  ])),
                              const SizedBox(height: 12),
                              sectionCard(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(tr('sticker.composition'),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 10),
                                    SegmentedButton<bool>(
                                        segments: [
                                          ButtonSegment<bool>(
                                              value: true,
                                              label:
                                                  Text(tr('sticker.contain'))),
                                          ButtonSegment<bool>(
                                              value: false,
                                              label: Text(tr('sticker.fill'))),
                                        ],
                                        selected: {
                                          contain
                                        },
                                        onSelectionChanged: (v) =>
                                            setState(() => contain = v.first)),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Icon(Icons.zoom_out_map_rounded,
                                          size: 18, color: kMuted),
                                      const SizedBox(width: 8),
                                      Text(tr('sticker.zoom'),
                                          style: TextStyle(
                                              fontSize: 13, color: kMuted)),
                                      Expanded(
                                          child: Slider(
                                              min: 0.7,
                                              max: 1.55,
                                              value: scale,
                                              onChanged: (v) =>
                                                  setState(() => scale = v))),
                                      SizedBox(
                                          width: 44,
                                          child: Text(scale.toStringAsFixed(2),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: kMuted))),
                                    ]),
                                    Text(tr('sticker.moveHint'),
                                        style: TextStyle(
                                            fontSize: 11, color: kMuted)),
                                  ])),
                              const SizedBox(height: 12),
                              sectionCard(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(tr('sticker.edgeOptimization'),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 10),
                                    Wrap(spacing: 8, runSpacing: 8, children: [
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.modeBalanced')),
                                          selected:
                                              recognitionMode == 'balanced',
                                          onSelected: (_) => setState(() =>
                                              recognitionMode = 'balanced')),
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.modeSubject')),
                                          selected:
                                              recognitionMode == 'subject',
                                          onSelected: (_) => setState(() =>
                                              recognitionMode = 'subject')),
                                      ChoiceChip(
                                          label: Text(tr('sticker.modeEdge')),
                                          selected: recognitionMode == 'edge',
                                          onSelected: (_) => setState(
                                              () => recognitionMode = 'edge')),
                                      ChoiceChip(
                                          label: Text(
                                              tr('sticker.modeAggressive')),
                                          selected:
                                              recognitionMode == 'aggressive',
                                          onSelected: (_) => setState(() =>
                                              recognitionMode = 'aggressive')),
                                    ]),
                                    const SizedBox(height: 8),
                                    Text(tr('sticker.edgeOptimizationDesc'),
                                        style: TextStyle(
                                            fontSize: 11, color: kMuted)),
                                    const SizedBox(height: 10),
                                    Row(children: [
                                      const Icon(Icons.auto_fix_high_rounded,
                                          size: 18, color: kMuted),
                                      const SizedBox(width: 8),
                                      Text(tr('sticker.edgePreserve'),
                                          style: TextStyle(
                                              fontSize: 13, color: kMuted)),
                                      Expanded(
                                          child: Slider(
                                              min: -1.0,
                                              max: 1.0,
                                              value: edgeTune,
                                              onChanged: (v) => setState(
                                                  () => edgeTune = v))),
                                      SizedBox(
                                          width: 56,
                                          child: Text(
                                              edgeTune > 0.05
                                                  ? tr('sticker.edgeMore')
                                                  : edgeTune < -0.05
                                                      ? tr(
                                                          'sticker.edgeCleaner')
                                                      : tr(
                                                          'sticker.edgeDefault'),
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: kMuted))),
                                    ]),
                                    Text(tr('sticker.edgePreserveHint'),
                                        style: TextStyle(
                                            fontSize: 11, color: kMuted)),
                                    const SizedBox(height: 12),
                                    Wrap(spacing: 8, runSpacing: 8, children: [
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.cleanupNone')),
                                          selected: cleanupMode == 'none',
                                          onSelected: (_) => setState(
                                              () => cleanupMode = 'none')),
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.cleanupWhite')),
                                          selected: cleanupMode == 'white',
                                          onSelected: (_) => setState(
                                              () => cleanupMode = 'white')),
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.cleanupBlack')),
                                          selected: cleanupMode == 'black',
                                          onSelected: (_) => setState(
                                              () => cleanupMode = 'black')),
                                      ChoiceChip(
                                          label:
                                              Text(tr('sticker.cleanupCorner')),
                                          selected: cleanupMode == 'corner',
                                          onSelected: (_) => setState(
                                              () => cleanupMode = 'corner')),
                                    ]),
                                    if (cleanupMode != 'none') ...[
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        const Icon(Icons.color_lens_outlined,
                                            size: 18, color: kMuted),
                                        const SizedBox(width: 8),
                                        Text(tr('sticker.colorTolerance'),
                                            style: TextStyle(
                                                fontSize: 13, color: kMuted)),
                                        Expanded(
                                            child: Slider(
                                                min: 4,
                                                max: 90,
                                                value: colorTolerance,
                                                onChanged: (v) => setState(
                                                    () => colorTolerance = v))),
                                        SizedBox(
                                            width: 44,
                                            child: Text(
                                                colorTolerance
                                                    .toStringAsFixed(0),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: kMuted))),
                                      ]),
                                      Text(tr('sticker.colorToleranceHint'),
                                          style: TextStyle(
                                              fontSize: 11, color: kMuted)),
                                    ],
                                  ])),
                            ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(children: [
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
                            label: Text(tr('common.resetAll'))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: () =>
                                    Navigator.pop(context, '__use_direct__'),
                                icon: const Icon(
                                    Icons.check_circle_outline_rounded),
                                label: Text(tr('sticker.useOriginal')))),
                      ]),
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
                                brushStrokes: strokes);
                            if (context.mounted) Navigator.pop(context, out);
                          },
                          icon: const Icon(Icons.tune_rounded),
                          label: Text(tr('sticker.applyAndGenerate')),
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
    BuildContext context, Map<String, dynamic> payload) async {
  final keepCandidates = context.store.settings.keepStickerCandidates;
  final direct = (payload['selectedUri'] ?? '').toString().trim();
  final rawCandidates = payload['candidates'];
  final candidates = <Map<String, dynamic>>[];
  if (rawCandidates is List) {
    for (final item in rawCandidates) {
      if (item is Map<String, dynamic>) {
        candidates.add(item);
      } else if (item is Map) {
        candidates
            .add(item.map((key, value) => MapEntry(key.toString(), value)));
      }
    }
  }
  if (candidates.isEmpty)
    return direct.isEmpty ? null : await adjustStickerCover(context, direct);
  if (candidates.length == 1) {
    final uri = (candidates.first['uri'] ?? direct).toString().trim();
    if (uri.isEmpty) return null;
    cleanupUnusedStickerCandidates(payload, uri,
        keepCandidates: keepCandidates);
    final adjusted = await adjustStickerCover(context, uri);
    if (adjusted != null && adjusted != uri && !keepCandidates) {
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
                  offset: const Offset(0, 18))
            ],
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(tr('sticker.chooseCover'),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700))),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr('common.cancel'))),
                ]),
                const SizedBox(height: 4),
                Text(tr('sticker.chooseCoverHint'),
                    style: TextStyle(color: kMuted, fontSize: 12)),
                const SizedBox(height: 14),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .84),
                    itemBuilder: (context, index) {
                      final item = candidates[index];
                      final uri = (item['uri'] ?? '').toString();
                      final label = (item['label'] ??
                              tr('sticker.candidate')
                                  .replaceAll('{n}', '${index + 1}'))
                          .toString();
                      final engine = (item['engine'] ?? '').toString();
                      final scoreValue = item['score'];
                      final scoreText = scoreValue is num
                          ? '${(scoreValue * 100).toStringAsFixed(0)}${tr('common.scoreSuffix').replaceAll('{s}', '${(scoreValue * 100).toStringAsFixed(0)}')}'
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
                                width: isSuggested ? 1.6 : 1),
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
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: RepaintBoundary(
                                              child: Image.file(
                                                file,
                                                fit: BoxFit.contain,
                                                cacheWidth: _previewCacheSide(
                                                    context,
                                                    logicalSide: 260),
                                                cacheHeight: _previewCacheSide(
                                                    context,
                                                    logicalSide: 260),
                                                gaplessPlayback: true,
                                                filterQuality:
                                                    FilterQuality.medium,
                                              ),
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(
                                                Icons
                                                    .image_not_supported_outlined,
                                                color: kMuted)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Expanded(
                                      child: Text(label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600))),
                                  if (isSuggested)
                                    const Icon(Icons.auto_awesome_rounded,
                                        size: 16, color: Color(0xFF7CC6F2))
                                ]),
                                const SizedBox(height: 2),
                                Text(
                                    engine.isEmpty
                                        ? tr('sticker.localEngine')
                                        : engine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 11, color: kMuted)),
                                if (scoreText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(scoreText,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF7CC6F2),
                                            fontWeight: FontWeight.w600)),
                                  ),
                              ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
        ),
      );
    },
  );
  if (selected != null && selected.trim().isNotEmpty) {
    if (!context.mounted) return null;
    cleanupUnusedStickerCandidates(payload, selected,
        keepCandidates: keepCandidates);
    final adjusted = await adjustStickerCover(context, selected);
    if (adjusted != null && adjusted != selected && !keepCandidates) {
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
  final size =
      Size(frame.image.width.toDouble(), frame.image.height.toDouble());
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
      boxSize.width / imageSize.width, boxSize.height / imageSize.height);
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
      rect.width.abs() * imageSize.width, rect.height.abs() * imageSize.height);
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
  final cardRect = Rect.fromLTWH(outerInset, outerInset,
      canvasSizeDouble - outerInset * 2, canvasSizeDouble - outerInset * 2);
  final radius =
      (canvasSizeDouble * cornerRadiusFactor).clamp(20.0, 180.0).toDouble();
  final cardRRect = RRect.fromRectAndRadius(cardRect, Radius.circular(radius));
  final frameWidth =
      (canvasSizeDouble * frameWidthFactor).clamp(14.0, 120.0).toDouble();
  final innerRect = cardRect.deflate(frameWidth);
  final innerRadius = math.max(12.0, radius - frameWidth * 0.7).toDouble();

  canvas.drawShadow(
      Path()..addRRect(cardRRect), Colors.black.withOpacity(.18), 18, true);
  canvas.drawRRect(cardRRect, Paint()..color = Colors.white);

  final srcRect = Rect.fromLTRB(
    cropRect.left * image.width,
    cropRect.top * image.height,
    cropRect.right * image.width,
    cropRect.bottom * image.height,
  );
  final clipRRect =
      RRect.fromRectAndRadius(innerRect, Radius.circular(innerRadius));
  canvas.save();
  canvas.clipRRect(clipRRect);
  canvas.drawImageRect(
      image, srcRect, innerRect, Paint()..filterQuality = FilterQuality.high);
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
      '${sourceFile.parent.path}/framed_cover_${DateTime.now().millisecondsSinceEpoch}.png');
  await outFile.writeAsBytes(pngBytes, flush: true);
  return 'file://${outFile.path}';
}

class _CropSelectionPainter extends CustomPainter {
  final Rect imageRect;
  final Rect cropRect;
  final double borderRadius;
  const _CropSelectionPainter(
      {required this.imageRect,
      required this.cropRect,
      required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final crop = Path()
      ..addRRect(
          RRect.fromRectAndRadius(cropRect, Radius.circular(borderRadius)));
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
              next = Rect.fromLTRB(cropRect.left + ndx, cropRect.top + ndy,
                  cropRect.right, cropRect.bottom);
              break;
            case 'tr':
              next = Rect.fromLTRB(cropRect.left, cropRect.top + ndy,
                  cropRect.right + ndx, cropRect.bottom);
              break;
            case 'bl':
              next = Rect.fromLTRB(cropRect.left + ndx, cropRect.top,
                  cropRect.right, cropRect.bottom + ndy);
              break;
            case 'br':
              next = Rect.fromLTRB(cropRect.left, cropRect.top,
                  cropRect.right + ndx, cropRect.bottom + ndy);
              break;
          }
          return _normalizeSquareCropRect(next, imageSize);
        }

        Widget handle(String type, Alignment alignment) {
          final x =
              alignment.x < 0 ? cropDisplayRect.left : cropDisplayRect.right;
          final y =
              alignment.y < 0 ? cropDisplayRect.top : cropDisplayRect.bottom;
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
                        offset: const Offset(0, 4))
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
            child: Stack(children: [
              Positioned.fill(child: Image.file(file, fit: BoxFit.contain)),
              Positioned.fill(
                child: CustomPaint(
                  painter: _CropSelectionPainter(
                      imageRect: imageRect,
                      cropRect: cropDisplayRect,
                      borderRadius: borderRadius),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.42),
                      borderRadius: BorderRadius.circular(999)),
                  child: Text(tr('sticker.directCrop'),
                      style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ]),
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
                      color: context.isDark ? Colors.white10 : Colors.black12),
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
                    offset: const Offset(0, 16))
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.92,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                    child: Row(children: [
                      Expanded(
                          child: Text(tr('sticker.frameCrop'),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700))),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(tr('common.cancel'))),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tr('sticker.frameCropDesc'),
                          style: TextStyle(fontSize: 12, color: kMuted)),
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
                                            strokeWidth: 2))));
                          }
                          final imageSize = snapshot.data ?? const Size(1, 1);
                          if (!cropInitializedForImage) {
                            cropInitializedForImage = true;
                            cropRect =
                                _defaultSquareCropForImageSize(imageSize);
                          }
                          return _DirectCropSelectionPreview(
                            uri: sourceUri,
                            imageSize: imageSize,
                            cropRect: cropRect,
                            borderRadius: 28,
                            onCropRectChanged: (v) => setState(() => cropRect =
                                _normalizeSquareCropRect(v, imageSize)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(tr('sticker.frameStyle'),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    const Icon(Icons.crop_square_rounded,
                                        size: 18, color: kMuted),
                                    const SizedBox(width: 8),
                                    Text(tr('sticker.frameThickness'),
                                        style: TextStyle(
                                            fontSize: 13, color: kMuted)),
                                    Expanded(
                                        child: Slider(
                                            min: 0.02,
                                            max: 0.10,
                                            value: frameWidthFactor,
                                            onChanged: (v) => setState(
                                                () => frameWidthFactor = v))),
                                    SizedBox(
                                        width: 44,
                                        child: Text(
                                            frameWidthFactor.toStringAsFixed(2),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 12, color: kMuted))),
                                  ]),
                                  Row(children: [
                                    const Icon(Icons.rounded_corner_rounded,
                                        size: 18, color: kMuted),
                                    const SizedBox(width: 8),
                                    Text(tr('sticker.cornerRadius'),
                                        style: TextStyle(
                                            fontSize: 13, color: kMuted)),
                                    Expanded(
                                        child: Slider(
                                            min: 0.06,
                                            max: 0.18,
                                            value: cornerRadiusFactor,
                                            onChanged: (v) => setState(
                                                () => cornerRadiusFactor = v))),
                                    SizedBox(
                                        width: 44,
                                        child: Text(
                                            cornerRadiusFactor
                                                .toStringAsFixed(2),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 12, color: kMuted))),
                                  ]),
                                  Row(children: [
                                    const Icon(Icons.fit_screen_rounded,
                                        size: 18, color: kMuted),
                                    const SizedBox(width: 8),
                                    Text(tr('sticker.outerMargin'),
                                        style: TextStyle(
                                            fontSize: 13, color: kMuted)),
                                    Expanded(
                                        child: Slider(
                                            min: 0.03,
                                            max: 0.12,
                                            value: cardInsetFactor,
                                            onChanged: (v) => setState(
                                                () => cardInsetFactor = v))),
                                    SizedBox(
                                        width: 44,
                                        child: Text(
                                            cardInsetFactor.toStringAsFixed(2),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 12, color: kMuted))),
                                  ]),
                                ])),
                          ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          cropInitializedForImage = false;
                          cropRect =
                              const Rect.fromLTWH(0.12, 0.12, 0.76, 0.76);
                          frameWidthFactor = 0.04;
                          cornerRadiusFactor = 0.11;
                          cardInsetFactor = 0.06;
                        }),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(tr('common.reset')),
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
                            if (context.mounted) Navigator.pop(context, out);
                          },
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: Text(tr('sticker.generateFrame')),
                        ),
                      ),
                    ]),
                  ),
                ]),
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
  if (!context.mounted) return null;
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
      .map((p) => Offset(
          p.dx.clamp(0.0, 1.0).toDouble(), p.dy.clamp(0.0, 1.0).toDouble()))
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
    final normalized =
        points.length > 3 ? _smoothTracePoints(points, iterations: 1) : points;
    final mapped = normalized
        .map((p) => Offset(imageRect.left + p.dx * imageRect.width,
            imageRect.top + p.dy * imageRect.height))
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
            ..color = const Color(0xFF7CC6F2).withOpacity(.10));
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withOpacity(.88));
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFF7CC6F2));
    } else {
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFF7CC6F2));
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
            ..color = const Color(0xFF7CC6F2));
    }
  }

  @override
  bool shouldRepaint(covariant _TraceOverlayPainter oldDelegate) {
    if (oldDelegate.imageRect != imageRect ||
        oldDelegate.points.length != points.length) return true;
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
                  _normalizedPointFromLocal(details.localPosition, imageRect)),
              onPanUpdate: (details) => onPointAppend(
                  _normalizedPointFromLocal(details.localPosition, imageRect)),
              child: Stack(children: [
                Positioned.fill(
                    child: RepaintBoundary(
                        child: Image.file(file,
                            fit: BoxFit.contain,
                            cacheWidth: _previewCacheSide(context),
                            cacheHeight: _previewCacheSide(context),
                            gaplessPlayback: true,
                            filterQuality: FilterQuality.medium))),
                Positioned.fill(
                    child: RepaintBoundary(
                        child: CustomPaint(
                            isComplex: true,
                            willChange: true,
                            painter: _TraceOverlayPainter(
                                imageRect: imageRect,
                                points: List<Offset>.of(points))))),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(tr('sticker.manualTrace'),
                        style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

Future<String> saveTracedStickerImage(
    String sourceUri, List<Offset> points) async {
  final sourcePath = filePathFromUriText(sourceUri);
  final sourceSize = await _decodeImageSizeFromUri(sourceUri);
  final bytes = await File(sourcePath).readAsBytes();
  final maxSide = math.max(sourceSize.width, sourceSize.height);
  final targetWidth =
      maxSide > 1800 ? (sourceSize.width / maxSide * 1800).round() : null;
  final targetHeight =
      maxSide > 1800 ? (sourceSize.height / maxSide * 1800).round() : null;
  final codec = await instantiateImageCodec(bytes,
      targetWidth: targetWidth, targetHeight: targetHeight);
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
      close: true);
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
      image, Offset(-minX, -minY), Paint()..filterQuality = FilterQuality.high);
  canvas.restore();
  final outImage = await recorder.endRecording().toImage(outW, outH);
  final byteData = await outImage.toByteData(format: ImageByteFormat.png);
  final outFile = File(
      '${File(sourcePath).parent.path}/manual_trace_sticker_${DateTime.now().millisecondsSinceEpoch}.png');
  await outFile.writeAsBytes(byteData?.buffer.asUint8List() ?? Uint8List(0),
      flush: true);
  return 'file://${outFile.path}';
}

Future<String?> editManualTraceSticker(
    BuildContext context, String sourceUri) async {
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
                      color: context.isDark ? Colors.white10 : Colors.black12),
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
                    offset: const Offset(0, 16))
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.92,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
                    child: Row(children: [
                      Expanded(
                          child: Text(tr('sticker.manualTrace'),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700))),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(tr('common.cancel'))),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(tr('sticker.manualTraceDesc'),
                          style: TextStyle(fontSize: 12, color: kMuted)),
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
                                            strokeWidth: 2))));
                          }
                          return _ManualTracePreview(
                            uri: sourceUri,
                            imageSize: snapshot.data ?? const Size(1, 1),
                            points: points,
                            onPointStart: (p) => setState(() => points.add(p)),
                            onPointAppend: (p) {
                              if (points.isEmpty) {
                                setState(() => points.add(p));
                              } else {
                                final last = points.last;
                                final dist = (last - p).distance;
                                if (dist > 0.008) setState(() => points.add(p));
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
                      child: Column(children: [
                        sectionCard(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(tr('sticker.traceHint'),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text(tr('sticker.traceSteps'),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: kMuted,
                                      height: 1.5)),
                              const SizedBox(height: 12),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                OutlinedButton.icon(
                                    onPressed: points.isEmpty
                                        ? null
                                        : () => setState(() {
                                              if (points.isNotEmpty)
                                                points.removeLast();
                                            }),
                                    icon: const Icon(Icons.undo_rounded),
                                    label: Text(tr('sticker.undoPoint'))),
                                OutlinedButton.icon(
                                    onPressed: points.isEmpty
                                        ? null
                                        : () => setState(() => points.clear()),
                                    icon:
                                        const Icon(Icons.layers_clear_rounded),
                                    label: Text(tr('sticker.clearRedraw'))),
                              ]),
                            ])),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (points.length < 3) {
                            showNativeSnack(
                                context, tr('sticker.needMinPoints'));
                            return;
                          }
                          final out =
                              await saveTracedStickerImage(sourceUri, points);
                          if (context.mounted) Navigator.pop(context, out);
                        },
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: Text(tr('sticker.generateAndAdjust')),
                      ),
                    ),
                  ),
                ]),
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
  if (!context.mounted) return null;
  final traced = await editManualTraceSticker(context, uri);
  if (traced == null || traced.trim().isEmpty || !context.mounted)
    return traced;
  return adjustStickerCover(context, traced);
}

Future<void> restoreJsonFromText(BuildContext context, String? text) async {
  if (text == null || text.trim().isEmpty) {
    showNativeSnack(context, tr('restore.noData'));
    return;
  }
  final store = context.store;
  final ok = await store.restoreFromJson(text);
  if (!context.mounted) return;
  if (ok) {
    successHaptic();
    if (Navigator.canPop(context)) Navigator.pop(context);
    showNativeSnack(context, tr('restore.nativeSuccess'));
  } else {
    warningHaptic();
    showNativeSnack(context, tr('restore.invalidJson'));
  }
}

Future<void> restoreDataArchiveFromPicker(BuildContext context) async {
  final store = context.store;
  final payload = await NativeBridge.importDataArchive();
  if (!context.mounted) return;
  if (payload.isEmpty) {
    showNativeSnack(context, tr('restore.noZip'));
    return;
  }
  final ok = payload['ok'] == true;
  final message = (payload['message'] ?? '').toString();
  if (!ok) {
    warningHaptic();
    if (context.mounted)
      showNativeSnack(
          context, message.isEmpty ? tr('restore.zipReadFailed') : message);
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
    if (context.mounted) showNativeSnack(context, tr('restore.zipNoJson'));
    return;
  }
  int countList(String key) {
    try {
      final raw = jsonDecode(jsonText);
      if (raw is Map && raw[key] is List) return (raw[key] as List).length;
    } catch (_) {}
    return 0;
  }

  final mediaCount =
      payload['mediaCount'] is num ? (payload['mediaCount'] as num).toInt() : 0;
  final sqliteCount = payload['sqliteCount'] is num
      ? (payload['sqliteCount'] as num).toInt()
      : 0;
  final entryCount =
      payload['entryCount'] is num ? (payload['entryCount'] as num).toInt() : 0;
  final assetCount = countList('assets');
  final wishCount = countList('wishes');
  final categoryCount = countList('categories');
  final tagCount = countList('tags');

  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(tr('restore.confirmTitle')),
      content: Text(tr('restore.confirmContent')
          .replaceAll('{assets}', '$assetCount')
          .replaceAll('{wishes}', '$wishCount')
          .replaceAll('{categories}', '$categoryCount')
          .replaceAll('{tags}', '$tagCount')
          .replaceAll('{media}', '$mediaCount')
          .replaceAll('{entries}', '$entryCount')
          .replaceAll('{sqlite}', '$sqliteCount')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(tr('common.cancel'))),
        FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(tr('restore.confirm'))),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await store.createSnapshot('${tr('restore.autoSnapshot')} ${dateStamp()}');
  } catch (_) {}

  final restored = await store.restoreFromJson(jsonText);
  if (!context.mounted) return;
  if (restored) {
    successHaptic();
    if (Navigator.canPop(context)) Navigator.pop(context);
    showNativeSnack(context,
        '${tr('restore.zipSuccess').replaceAll('{a}', '$assetCount').replaceAll('{m}', '$mediaCount')}');
  } else {
    warningHaptic();
    showNativeSnack(context, tr('restore.zipJsonFailed'));
  }
}

class NativeFeaturePanel extends StatelessWidget {
  const NativeFeaturePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SettingsSection(title: tr('native.capabilities'), children: [
        SettingRow(
          icon: Icons.touch_app_rounded,
          iconBg: const Color(0xFFBDEB7E),
          label: tr('native.hapticTest'),
          description: tr('native.hapticTestDesc'),
          trailing: const ValuePill('A'),
          onTap: () {
            successHaptic();
            showNativeSnack(context, tr('native.hapticTriggered'));
          },
        ),
        SettingRow(
          icon: Icons.image_search_rounded,
          iconBg: const Color(0xFFC8EBFF),
          label: tr('native.mediaAccess'),
          description: tr('native.mediaAccessDesc'),
          trailing: const ValuePill('E'),
          onTap: () => showNativeMediaSheet(context),
        ),
        SettingRow(
          icon: Icons.notifications_active_rounded,
          iconBg: const Color(0xFFFFDC65),
          label: tr('native.notifications'),
          description: tr('native.notificationsDesc'),
          trailing: const ValuePill('C/G'),
          onTap: () => showNativeAutomationSheet(context),
        ),
        SettingRow(
          icon: Icons.widgets_rounded,
          iconBg: const Color(0xFF98E0FF),
          label: tr('native.widgetRefresh'),
          description: tr('native.widgetRefreshDesc'),
          trailing: const ValuePill('D'),
          onTap: () async {
            await NativeBridge.updateHomeWidget(
              assetCount: store.assets.length,
              wishCount: store.wishes.where((w) => !w.archived).length,
              totalAssetValue: store.getTotalAssetValue(),
              averageDailyCost: store.getAverageDailyCost(),
              currency: store.settings.currencyUnit,
            );
            if (!context.mounted) return;
            showNativeSnack(context, tr('native.widgetRefreshed'));
          },
        ),
        SettingRow(
          icon: Icons.content_paste_search_rounded,
          iconBg: const Color(0xFFA78BFA),
          label: tr('native.clipboard'),
          description: tr('native.clipboardDesc'),
          trailing: ValuePill(tr('native.clipboardPill')),
          onTap: () => showClipboardImportSheet(context),
        ),
        SettingRow(
          icon: Icons.share_rounded,
          iconBg: const Color(0xFFFFB5A6),
          label: tr('native.share'),
          description: tr('native.shareDesc'),
          trailing: const ValuePill('G'),
          onTap: () => showNativeSystemSheet(context),
        ),
      ]),
      const SizedBox(height: 12),
      SettingsSection(title: tr('native.backup'), children: [
        SettingRow(
          icon: Icons.file_upload_rounded,
          iconBg: const Color(0xFF8FD0F6),
          label: tr('native.exportJson'),
          description: tr('native.exportJsonDesc'),
          trailing: const ValuePill('F'),
          onTap: () async {
            final uri = await NativeBridge.exportTextFile(
                fileName: 'zhipu_backup_${dateStamp()}.json',
                text: store.exportJson(),
                mimeType: 'application/json');
            if (!context.mounted) return;
            showNativeSnack(
                context,
                uri == null
                    ? tr('common.exportCancelled')
                    : tr('common.exportedToFile'));
          },
        ),
        SettingRow(
          icon: Icons.archive_rounded,
          iconBg: const Color(0xFFBDEB7E),
          label: tr('native.restoreZip'),
          description: tr('native.restoreZipDesc'),
          trailing: const ValuePill('ZIP'),
          onTap: () async => restoreDataArchiveFromPicker(context),
        ),
        SettingRow(
          icon: Icons.file_download_rounded,
          iconBg: const Color(0xFFBDEB7E),
          label: tr('native.restoreJson'),
          description: tr('native.restoreJsonDesc'),
          trailing: const ValuePill('JSON'),
          onTap: () async {
            final text =
                await NativeBridge.importTextFile(mimeType: 'application/json');
            if (!context.mounted) return;
            await restoreJsonFromText(context, text);
          },
        ),
        SettingRow(
          icon: Icons.table_chart_rounded,
          iconBg: const Color(0xFFC8EBFF),
          label: tr('native.exportCsv'),
          description: tr('native.exportCsvDesc'),
          trailing: const ValuePill('CSV'),
          onTap: () async {
            final uri = await NativeBridge.exportTextFile(
                fileName: 'valora_assets_${dateStamp()}.csv',
                text: buildAssetsCsv(store),
                mimeType: 'text/csv');
            if (!context.mounted) return;
            showNativeSnack(
                context,
                uri == null
                    ? tr('common.exportCancelled')
                    : tr('common.csvExported'));
          },
        ),
        SettingRow(
          icon: Icons.description_rounded,
          iconBg: const Color(0xFF7CC6F2),
          label: tr('native.exportMd'),
          description: tr('native.exportMdDesc'),
          trailing: const ValuePill('MD'),
          onTap: () async => showReportExportSheet(context),
        ),
      ]),
    ]);
  }
}

void showNativeMediaSheet(BuildContext context) {
  appSheet(context,
      title: tr('media.title'),
      subtitle: tr('media.subtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(
            onPressed: () async {
              final uri = await NativeBridge.pickImage();
              if (context.mounted)
                showNativeSnack(
                    context,
                    uri == null
                        ? tr('media.noImage')
                        : '${tr('media.savedCover')}$uri');
            },
            icon: const Icon(Icons.photo_library_rounded),
            label: Text(tr('media.openGallery'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final uri = await NativeBridge.capturePhoto();
              if (context.mounted)
                showNativeSnack(
                    context,
                    uri == null
                        ? tr('media.photoCancelled')
                        : '${tr('media.photoSaved')}$uri');
            },
            icon: const Icon(Icons.photo_camera_rounded),
            label: Text(tr('media.takePhoto'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final payload =
                  await NativeBridge.cutoutImageFromPickerDetailed();
              final uri = context.mounted
                  ? await chooseStickerCandidate(context, payload)
                  : null;
              if (context.mounted)
                showNativeSnack(
                    context,
                    uri == null
                        ? tr('media.noSticker')
                        : '${tr('media.stickerSelected')}$uri');
            },
            icon: const Icon(Icons.auto_fix_high_rounded),
            label: Text(tr('media.testSticker'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final data =
                  nativeJsonMap(await NativeBridge.scanBarcodeFromImage());
              if (context.mounted)
                showNativeSnack(
                    context,
                    data['found'] == true
                        ? "${tr('media.barcodeFound')}${data['rawValue']}"
                        : tr('media.barcodeNotFound'));
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(tr('media.scanBarcode'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final data =
                  nativeJsonMap(await NativeBridge.recognizeReceiptFromImage());
              final price = data['priceCandidate']?.toString() ?? '';
              if (context.mounted)
                showNativeSnack(
                    context,
                    price.isEmpty
                        ? tr('media.ocrNoPrice')
                        : '${tr('media.ocrPrice')}$price');
            },
            icon: const Icon(Icons.receipt_long_rounded),
            label: Text(tr('media.ocrReceipt'))),
        const SizedBox(height: 10),
        Text(tr('media.ocrHint'),
            style: TextStyle(color: kMuted, fontSize: 12, height: 1.45)),
      ]));
}

void showNativeAutomationSheet(BuildContext context) {
  appSheet(context,
      title: tr('auto.title'),
      subtitle: tr('auto.subtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(
            onPressed: () async {
              final ok = await NativeBridge.scheduleNotification(
                  title: tr('auto.notifTitle'),
                  text: tr('auto.notifBody'),
                  delayMillis: 60000);
              if (context.mounted)
                showNativeSnack(context,
                    ok ? tr('auto.testScheduled') : tr('auto.testFailed'));
            },
            icon: const Icon(Icons.alarm_rounded),
            label: Text(tr('auto.testReminder'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final ok = await NativeBridge.createShortcuts();
              if (context.mounted)
                showNativeSnack(
                    context,
                    ok
                        ? tr('auto.shortcutCreated')
                        : tr('auto.shortcutFailed'));
            },
            icon: const Icon(Icons.add_to_home_screen_rounded),
            label: Text(tr('auto.createShortcut'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final ok = await NativeBridge.requestNotificationPermission();
              if (context.mounted)
                showNativeSnack(context,
                    ok ? tr('auto.permRequested') : tr('auto.permNotNeeded'));
            },
            icon: const Icon(Icons.verified_rounded),
            label: Text(tr('auto.requestPerm'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async => NativeBridge.openNotificationSettings(),
            icon: const Icon(Icons.settings_rounded),
            label: Text(tr('auto.openNotifSettings'))),
      ]));
}

void showClipboardImportSheet(BuildContext context) {
  appSheet(context,
      title: tr('clipboard.title'),
      subtitle: tr('clipboard.subtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(
            onPressed: () async {
              final text = await NativeBridge.readClipboard();
              if (text == null || text.trim().isEmpty) {
                if (context.mounted)
                  showNativeSnack(context, tr('clipboard.empty'));
                return;
              }
              if (text.trimLeft().startsWith('{')) {
                if (context.mounted) await restoreJsonFromText(context, text);
              } else {
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.of(context).push(softRoute(ComposePage(
                    initialTab: ComposeTab.asset,
                    initialName: text.trim().split('\n').first.take(24))));
              }
            },
            icon: const Icon(Icons.content_paste_go_rounded),
            label: Text(tr('clipboard.read'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              await NativeBridge.writeClipboard(context.store.exportJson());
              if (context.mounted)
                showNativeSnack(context, tr('clipboard.copied'));
            },
            icon: const Icon(Icons.copy_all_rounded),
            label: Text(tr('clipboard.copyJson'))),
      ]));
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
    title: tr('archive.title'),
    fileName: 'zhipu_complete_backup_${dateStamp()}.zip',
    json: store.exportJson(),
    csv: buildAssetsCsv(store),
    markdown: buildMarkdownReport(store),
    mediaPaths: mediaPaths,
  );
  if (context.mounted) {
    showNativeSnack(
        context,
        mediaPaths.isEmpty
            ? tr('archive.generated')
            : '${tr('archive.generatedWithMedia').replaceAll('{n}', '${mediaPaths.length}')}');
  }
}

void showNativeSystemSheet(BuildContext context) {
  final store = context.store;
  appSheet(context,
      title: tr('system.title'),
      subtitle: tr('system.subtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(
            onPressed: () async => shareCompleteDataArchive(context),
            icon: const Icon(Icons.archive_rounded),
            label: Text(tr('system.shareArchive'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async => restoreDataArchiveFromPicker(context),
            icon: const Icon(Icons.unarchive_rounded),
            label: Text(tr('system.restoreArchive'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async => NativeBridge.shareText(
                title: tr('system.shareSummary'),
                text: buildMarkdownReport(store)),
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(tr('system.shareText'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async {
              final info = await NativeBridge.getInitialIntentInfo();
              if (context.mounted)
                showNativeSnack(
                    context,
                    info == null || info.isEmpty
                        ? tr('system.noShareData')
                        : info);
            },
            icon: const Icon(Icons.call_received_rounded),
            label: Text(tr('system.readIntent'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async => NativeBridge.openAppSettings(),
            icon: const Icon(Icons.app_settings_alt_rounded),
            label: Text(tr('system.openAppSettings'))),
      ]));
}

void showReportExportSheet(BuildContext context) {
  final report = buildMarkdownReport(context.store);
  appSheet(context,
      title: tr('report.exportTitle'),
      subtitle: tr('report.exportSubtitle'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FilledButton.icon(
            onPressed: () async {
              final uri = await NativeBridge.exportTextFile(
                  fileName: 'valora_report_${dateStamp()}.md',
                  text: report,
                  mimeType: 'text/markdown');
              if (context.mounted)
                showNativeSnack(
                    context,
                    uri == null
                        ? tr('common.exportCancelled')
                        : tr('report.exported'));
            },
            icon: const Icon(Icons.save_alt_rounded),
            label: Text(tr('report.saveFile'))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () async => NativeBridge.shareText(
                title: tr('report.shareTitle'), text: report),
            icon: const Icon(Icons.share_rounded),
            label: Text(tr('report.shareVia'))),
      ]));
}
