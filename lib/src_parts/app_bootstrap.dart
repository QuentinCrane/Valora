part of '../main.dart';

const Color kBg = Color(0xFFFFFFFF);
const Color kBgDark = Color(0xFF061522);
const Color kCard = Color(0xFFFFFFFF);
const Color kCardDark = Color(0xFF0D2434);
const Color kSoft = Color(0xFFF7F9FC);
const Color kSoftDark = Color(0xFF102D42);
const Color kText = Color(0xFF141518);
const Color kMuted = Color(0xFF8B8C92);
const Color kBrand = Color(0xFF7CC6F2);
const Color kBrandStrong = Color(0xFF48AEE9);
const Color kBrandInk = Color(0xFF071D2B);
const Color kDarkBlue = Color(0xFF0A324A);
const Color kDarkBlueSoft = Color(0xFF0E405D);
const Color kDanger = Color(0xFFFF674D);
const double kRadiusMd = 20;
const double kRadiusLg = 28;
const double kPagePad = 10;

String localizedAppName(Locale locale) =>
    _localeKey(locale) == 'en' ? tr('app.name.en') : tr('app.name');

Locale currentPlatformLocale() {
  final locales = WidgetsBinding.instance.platformDispatcher.locales;
  if (locales.isNotEmpty) return locales.first;
  return WidgetsBinding.instance.platformDispatcher.locale;
}

String appDisplayName(BuildContext context) {
  return localizedAppName(Localizations.localeOf(context));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NativeBridge.configureSystemUi();
  ErrorWidget.builder = (details) => Material(
        color: kBg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoMark(size: 64),
                const SizedBox(height: 14),
                Text(tr('error.title'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal)),
                const SizedBox(height: 8),
                Text(tr('error.description')),
                const SizedBox(height: 12),
                Expanded(
                    child: SingleChildScrollView(
                        child: Text(details.exceptionAsString(),
                            style: const TextStyle(fontSize: 12)))),
              ],
            ),
          ),
        ),
      );
  runApp(const ValoraApp());
}

class ValoraApp extends StatefulWidget {
  const ValoraApp({super.key});

  @override
  State<ValoraApp> createState() => _ValoraAppState();
}

class _ValoraAppState extends State<ValoraApp> {
  late final AppStore store;
  late final Future<void> boot;

  @override
  void initState() {
    super.initState();
    store = AppStore();
    boot = store.load().then((_) {
      configureRuntimeSettings(store.settings);
      return NativeBridge.setStickerEngineConfig(
        mode: store.settings.stickerEngineMode.name,
        keepCandidates: store.settings.keepStickerCandidates,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: boot,
      builder: (context, snapshot) {
        return AppScope(
          store: store,
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => appDisplayName(context),
                locale: store.settings.language.locale,
                localeResolutionCallback: resolveAppLocale,
                theme: buildAppTheme(Brightness.light),
                darkTheme: buildAppTheme(Brightness.dark),
                themeMode: store.resolvedThemeMode,
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
                  Locale('en'),
                ],
                home: snapshot.connectionState == ConnectionState.done
                    ? const ShellPage()
                    : const BootPage(),
              );
            },
          ),
        );
      },
    );
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(seedColor: kBrand, brightness: brightness).copyWith(
    surface: dark ? kCardDark : Colors.white,
    onSurface: dark ? Colors.white.withOpacity(.94) : kText,
    surfaceContainerHighest: dark ? kSoftDark : kSoft,
    primary: dark ? const Color(0xFF8FD4FF) : kBrand,
    onPrimary: dark ? const Color(0xFF062033) : kBrandInk,
    secondary: dark ? const Color(0xFF4DAEE2) : kBrandStrong,
    onSecondary: dark ? Colors.white.withOpacity(.94) : kText,
    outline: dark
        ? const Color(0xFF7CC6F2).withOpacity(.20)
        : Colors.black.withOpacity(.08),
  );
  final theme = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? kBgDark : Colors.white,
    fontFamily: 'sans-serif',
    fontFamilyFallback: const [
      'SF Pro Text',
      '.SF Pro Text',
      'PingFang SC',
      'Noto Sans CJK SC',
      'HarmonyOS Sans SC',
      'MiSans',
      'Roboto',
      'sans-serif'
    ],
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      displaySmall: theme.textTheme.displaySmall?.copyWith(
          fontSize: 23,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.45,
          height: 1.05),
      headlineMedium: theme.textTheme.headlineMedium?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.2,
          height: 1.12),
      headlineSmall: theme.textTheme.headlineSmall?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.12,
          height: 1.16),
      titleLarge: theme.textTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.12,
          height: 1.18),
      titleMedium: theme.textTheme.titleMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.06,
          height: 1.2),
      titleSmall: theme.textTheme.titleSmall?.copyWith(
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          height: 1.18),
      bodyLarge: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14.2, fontWeight: FontWeight.normal, height: 1.36),
      bodyMedium: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13.2, fontWeight: FontWeight.normal, height: 1.34),
      bodySmall: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11.8, fontWeight: FontWeight.normal, height: 1.28),
      labelLarge: theme.textTheme.labelLarge?.copyWith(
          fontSize: 13, fontWeight: FontWeight.normal, letterSpacing: .02),
      labelMedium: theme.textTheme.labelMedium?.copyWith(
          fontSize: 11.8, fontWeight: FontWeight.normal, letterSpacing: .02),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: dark ? Colors.white : kText,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white.withOpacity(.94) : kText,
        fontSize: 18,
        fontWeight: FontWeight.normal,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? kSoftDark.withOpacity(.88) : Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kBrandStrong, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: kBrand,
        foregroundColor: kBrandInk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: dark ? Colors.white : kText,
        side:
            BorderSide(color: (dark ? Colors.white : kText).withOpacity(0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    ),
    chipTheme: theme.chipTheme.copyWith(
      showCheckmark: false,
      selectedColor: kBrand,
      backgroundColor: dark ? kSoftDark.withOpacity(.84) : kSoft,
      labelStyle: TextStyle(
          color: dark ? Colors.white : kText, fontWeight: FontWeight.normal),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? kSoftDark.withOpacity(.88) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: kBrandStrong, width: 1.1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      menuStyle: MenuStyle(
        elevation: const MaterialStatePropertyAll(0),
        backgroundColor: MaterialStatePropertyAll(
            dark ? kCardDark.withOpacity(.98) : Colors.white),
        shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        padding:
            const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        elevation: const MaterialStatePropertyAll(0),
        backgroundColor: MaterialStatePropertyAll(
            dark ? kCardDark.withOpacity(.98) : Colors.white),
        shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        side: MaterialStatePropertyAll(BorderSide(
            color: (dark ? Colors.white : Colors.black).withOpacity(.06))),
        padding:
            const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      elevation: 0,
      color: dark ? kCardDark.withOpacity(.98) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: (dark ? Colors.white : Colors.black).withOpacity(.06))),
      textStyle: TextStyle(
          color: dark ? Colors.white : kText,
          fontSize: 14,
          fontWeight: FontWeight.normal),
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: dark ? kCardDark.withOpacity(.98) : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      titleTextStyle: TextStyle(
          color: dark ? Colors.white : kText,
          fontSize: 18,
          fontWeight: FontWeight.normal),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: dark ? kCardDark : Colors.white,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: dark ? kDarkBlueSoft : const Color(0xFFDFF3FF),
      headerForegroundColor: dark ? Colors.white : kBrandInk,
      dayForegroundColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? kBrandInk
              : (dark ? Colors.white.withOpacity(.92) : kBrandInk)),
      dayBackgroundColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? kBrand
              : states.contains(MaterialState.disabled)
                  ? Colors.transparent
                  : null),
      todayForegroundColor:
          MaterialStatePropertyAll(dark ? Colors.white : kBrandInk),
      todayBackgroundColor:
          MaterialStatePropertyAll(kBrand.withOpacity(dark ? .18 : .22)),
      todayBorder: const BorderSide(color: kBrandStrong, width: 1),
      yearForegroundColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? kBrandInk
              : (dark ? Colors.white.withOpacity(.92) : kBrandInk)),
      yearBackgroundColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected) ? kBrand : null),
      dayShape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      yearShape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor:
          dark ? kCardDark.withOpacity(.96) : const Color(0xFF111214),
      contentTextStyle: TextStyle(
          color: Colors.white.withOpacity(.94), fontWeight: FontWeight.normal),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const MaterialStatePropertyAll(Colors.transparent),
      thumbColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? (dark ? Colors.white : kBrandInk)
              : Colors.white),
      trackColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? kBrand
              : (dark ? Colors.white12 : const Color(0xFFE6E7EA))),
    ),
  );
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required Widget child})
      : super(notifier: store, child: child);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

extension StoreContext on BuildContext {
  AppStore get store => AppScope.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class BootPage extends StatelessWidget {
  const BootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 72),
            const SizedBox(height: 16),
            Text(tr('boot.loading')),
          ],
        ),
      ),
    );
  }
}

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [
                    Color(0xFF071D2B),
                    Color(0xFF061522),
                    Color(0xFF0A2435),
                    kBgDark
                  ]
                : const [Colors.white, Colors.white, Colors.white],
            stops: dark ? const [0, .42, .76, 1] : null,
          ),
        ),
        child: child,
      ),
    );
  }
}

String newId(String prefix) =>
    '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${math.Random().nextInt(99999)}';

bool _valoraHapticsEnabled = true;
bool _valoraNativeHapticsEnabled = true;
bool _valoraCompactSnackbars = true;

void configureRuntimeSettings(AppSettings settings) {
  _valoraHapticsEnabled = settings.hapticsEnabled;
  _valoraNativeHapticsEnabled = settings.nativeHapticsEnabled;
  _valoraCompactSnackbars = settings.compactSnackbars;
}

bool get valoraCompactSnackbars => _valoraCompactSnackbars;

Future<void> _emitNativeHaptic(String style) async {
  if (!_valoraNativeHapticsEnabled) return;
  await NativeBridge.haptic(style);
}

void tapHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('selection');
  HapticFeedback.selectionClick();
}

void selectionHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('selection');
  HapticFeedback.selectionClick();
}

void lightHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('light');
  HapticFeedback.lightImpact();
}

void mediumHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('medium');
  HapticFeedback.mediumImpact();
}

void successHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('success');
  HapticFeedback.mediumImpact();
}

void warningHaptic() {
  if (!_valoraHapticsEnabled) return;
  _emitNativeHaptic('warning');
  HapticFeedback.heavyImpact();
}

Route<T> softRoute<T>(Widget page,
    {ValoraRouteStyle style = ValoraRouteStyle.auto}) {
  final resolved =
      style == ValoraRouteStyle.auto ? valoraRouteStyleFor(page) : style;

  // 预测式返回必须保留 MaterialPageRoute，交给 Flutter 的
  // PredictiveBackPageTransitionsBuilder 接入 Android 系统返回进度。
  // 自定义 PageRouteBuilder 会让系统预测式返回退化成普通返回动画。
  return MaterialPageRoute<T>(
    settings:
        RouteSettings(name: 'valora:${resolved.name}:${page.runtimeType}'),
    builder: (_) => PredictiveBackBoundary(style: resolved, child: page),
  );
}

Path smoothPathFromValues(List<double> values, Size size,
    {double topPadding = 0, double bottomPadding = 0}) {
  final path = Path();
  if (values.isEmpty || size.width <= 0 || size.height <= 0) return path;
  final maxV = math.max(values.reduce(math.max), 1.0);
  final minV = values.reduce(math.min);
  final range = math.max(maxV - minV, 1.0);
  final chartHeight = math.max(1.0, size.height - topPadding - bottomPadding);
  Offset pointAt(int i) {
    final x = size.width * i / math.max(values.length - 1, 1);
    final y =
        topPadding + chartHeight - ((values[i] - minV) / range) * chartHeight;
    return Offset(x, y);
  }

  path.moveTo(pointAt(0).dx, pointAt(0).dy);
  if (values.length == 1) return path;
  for (var i = 0; i < values.length - 1; i++) {
    final p0 = pointAt(i);
    final p1 = pointAt(i + 1);
    final midX = (p0.dx + p1.dx) / 2;
    path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
  }
  return path;
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
DateTime? parseFlexibleDate(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;
  final now = DateTime.now();
  final lower = value.toLowerCase().replaceAll(' ', '');
  if (['今天', '今日', 'today', 'td'].contains(lower)) return dateOnly(now);
  if (['昨天', '昨日', 'yesterday', 'yd'].contains(lower))
    return dateOnly(now.subtract(const Duration(days: 1)));
  if (['前天'].contains(lower))
    return dateOnly(now.subtract(const Duration(days: 2)));
  if (['明天', 'tomorrow', 'tm'].contains(lower))
    return dateOnly(now.add(const Duration(days: 1)));
  final daysAgo = RegExp(r'^(\d{1,3})天前$').firstMatch(lower);
  if (daysAgo != null)
    return dateOnly(now.subtract(Duration(days: int.parse(daysAgo.group(1)!))));
  final daysLater = RegExp(r'^(\d{1,3})天后$').firstMatch(lower);
  if (daysLater != null)
    return dateOnly(now.add(Duration(days: int.parse(daysLater.group(1)!))));

  value = value
      .replaceAll('年', '-')
      .replaceAll('月', '-')
      .replaceAll('日', '')
      .replaceAll('号', '')
      .replaceAll('/', '-')
      .replaceAll('.', '-')
      .replaceAll('_', '-')
      .replaceAll(' ', '');
  while (value.contains('--')) {
    value = value.replaceAll('--', '-');
  }
  value = value.replaceAll(RegExp(r'^-|-$'), '');

  final direct = DateTime.tryParse(value);
  if (direct != null) return dateOnly(direct);

  DateTime? safeDate(int year, int month, int day) {
    if (year < 1900 ||
        year > 2100 ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) return null;
    final d = DateTime(year, month, day);
    if (d.year == year && d.month == month && d.day == day) return dateOnly(d);
    return null;
  }

  final parts = value.split('-').where((e) => e.isNotEmpty).toList();
  if (parts.length == 3) {
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y != null && m != null && d != null)
      return safeDate(y < 100 ? 2000 + y : y, m, d);
  }
  if (parts.length == 2) {
    final m = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    if (m != null && d != null) return safeDate(now.year, m, d);
  }

  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 8) {
    final y = int.tryParse(digits.substring(0, 4));
    final m = int.tryParse(digits.substring(4, 6));
    final d = int.tryParse(digits.substring(6, 8));
    if (y != null && m != null && d != null) return safeDate(y, m, d);
  }
  if (digits.length == 6) {
    final y = int.tryParse(digits.substring(0, 2));
    final m = int.tryParse(digits.substring(2, 4));
    final d = int.tryParse(digits.substring(4, 6));
    if (y != null && m != null && d != null) return safeDate(2000 + y, m, d);
  }
  if (digits.length == 4) {
    final m = int.tryParse(digits.substring(0, 2));
    final d = int.tryParse(digits.substring(2, 4));
    if (m != null && d != null) return safeDate(now.year, m, d);
  }
  if (digits.length == 3) {
    final m = int.tryParse(digits.substring(0, 1));
    final d = int.tryParse(digits.substring(1, 3));
    if (m != null && d != null) return safeDate(now.year, m, d);
  }
  return null;
}

DateTime today() => DateTime.now();
String dateText(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
String dateStorageText(DateTime value) => dateText(dateOnly(value));

const List<String> _englishMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _englishMonthShortNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

bool get _dateLocaleIsEnglish => _localeKey(_activeLocale) == 'en';

String datePickerYearWheelLabel(int year) =>
    _dateLocaleIsEnglish ? '$year' : '$year年';

String datePickerMonthWheelLabel(int month) => _dateLocaleIsEnglish
    ? _englishMonthNames[(month - 1).clamp(0, 11).toInt()]
    : '${month.toString().padLeft(2, '0')}月';

String datePickerMonthTitle(DateTime month) => _dateLocaleIsEnglish
    ? '${_englishMonthNames[(month.month - 1).clamp(0, 11).toInt()]} ${month.year}'
    : '${month.year}年 ${month.month.toString().padLeft(2, '0')}月';

String datePickerSelectedTitle(DateTime date) => _dateLocaleIsEnglish
    ? '${_englishMonthShortNames[(date.month - 1).clamp(0, 11).toInt()]} ${date.day}'
    : '${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';

int dateEpochDay(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;
DateTime? dateFromEpochDay(dynamic raw) {
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty || text == 'null') return null;
  final day = int.tryParse(text);
  if (day == null || day <= 1) return null;
  final utc = DateTime.fromMillisecondsSinceEpoch(
      day * Duration.millisecondsPerDay,
      isUtc: true);
  if (_looksLikeEpochDefault(utc)) return null;
  return DateTime(utc.year, utc.month, utc.day);
}

/// UI helper only. Do not use this for persisted required fields unless the
/// caller deliberately provides a stable fallback.
DateTime parseDate(String raw, {DateTime? fallback}) =>
    parseFlexibleDate(raw) ?? fallback ?? today();
DateTime? parseUserDateOrNull(String raw) =>
    parseFlexibleDate(raw.trim()) == null
        ? null
        : dateOnly(parseFlexibleDate(raw.trim())!);
DateTime? parseOptionalUserDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final parsed = parseFlexibleDate(text);
  return parsed == null ? null : dateOnly(parsed);
}

bool _looksLikeEpochDefault(DateTime value) => value.year <= 1971;

DateTime? parseOptionalPersistedDate(dynamic raw) {
  if (raw == null) return null;
  final text = raw.toString().trim();
  if (text.isEmpty || text == 'null') return null;

  if (RegExp(r'^\d{6}$|^\d{8}$').hasMatch(text)) {
    final compact = parseFlexibleDate(text);
    if (compact != null && !_looksLikeEpochDefault(compact)) return compact;
  }

  // Some old bridge / JSON paths may accidentally persist milliseconds or seconds.
  // Treat 0 / 1 / epoch-like values as missing instead of converting them to 1970-01-01.
  final numeric = int.tryParse(text);
  if (numeric != null) {
    if (numeric <= 0) return null;
    final fromMillis = numeric > 100000000000
        ? DateTime.fromMillisecondsSinceEpoch(numeric)
        : DateTime.fromMillisecondsSinceEpoch(numeric * 1000);
    return _looksLikeEpochDefault(fromMillis) ? null : fromMillis;
  }

  final parsed = parseFlexibleDate(text);
  if (parsed == null || _looksLikeEpochDefault(parsed)) return null;
  return parsed;
}

DateTime? parseOptionalPersistedDateTime(dynamic raw) {
  if (raw == null) return null;
  final text = raw.toString().trim();
  if (text.isEmpty || text == 'null') return null;

  final numeric = int.tryParse(text);
  if (numeric != null) {
    if (numeric <= 0) return null;
    final fromMillis = numeric > 100000000000
        ? DateTime.fromMillisecondsSinceEpoch(numeric)
        : DateTime.fromMillisecondsSinceEpoch(numeric * 1000);
    return _looksLikeEpochDefault(fromMillis) ? null : fromMillis;
  }

  final direct =
      DateTime.tryParse(text) ?? DateTime.tryParse(text.replaceFirst(' ', 'T'));
  if (direct != null && !_looksLikeEpochDefault(direct)) return direct;

  final dateOnlyValue = parseFlexibleDate(text);
  if (dateOnlyValue == null || _looksLikeEpochDefault(dateOnlyValue))
    return null;
  return dateOnly(dateOnlyValue);
}

DateTime parsePersistedDateTime(dynamic raw, {DateTime? fallback}) {
  final parsed = parseOptionalPersistedDateTime(raw);
  if (parsed != null) return parsed;
  if (fallback != null && !_looksLikeEpochDefault(fallback)) return fallback;
  return DateTime.now();
}

DateTime parsePersistedDate(dynamic raw, {DateTime? fallback}) {
  final parsed = parseOptionalPersistedDate(raw);
  if (parsed != null) return dateOnly(parsed);
  if (fallback != null && !_looksLikeEpochDefault(fallback))
    return dateOnly(fallback);
  return dateOnly(DateTime.now());
}

DateTime parsePersistedRequiredDate(dynamic raw, {DateTime? fallback}) {
  final parsed = parseOptionalPersistedDate(raw);
  if (parsed != null) return dateOnly(parsed);
  if (fallback != null && !_looksLikeEpochDefault(fallback))
    return dateOnly(fallback);
  // Only used for genuinely missing legacy records. Normal save paths always
  // persist yyyy-MM-dd, so this fallback should not run after v28.
  return dateOnly(DateTime.now());
}

int diffDaysInclusive(DateTime start, DateTime end) {
  final a = DateTime(start.year, start.month, start.day);
  final b = DateTime(end.year, end.month, end.day);
  return math.max(1, b.difference(a).inDays + 1);
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  final text = value?.toString().trim() ?? '';
  final normalized = text
      .replaceAll('，', ',')
      .replaceAll(RegExp(r'[,¥￥元\s]'), '')
      .replaceAll(RegExp(r'[^0-9+\-.]'), '');
  return double.tryParse(normalized) ?? fallback;
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.round();
  final text = value?.toString().trim() ?? '';
  final normalized = text.replaceAll(RegExp(r'[^0-9+-]'), '');
  return int.tryParse(normalized) ?? fallback;
}

List<String> splitTags(String raw) => raw
    .split(RegExp(r'[,，、\s]+'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

Color parseColor(String raw, {Color fallback = kBrand}) {
  var value = raw.trim().replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}

String money(double value, AppSettings settings) {
  final fixed = value.toStringAsFixed(settings.decimalPlaces);
  final parts = fixed.split('.');
  var integer = parts.first;
  if (settings.useThousandsSeparator) {
    integer =
        integer.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }
  if (settings.decimalPlaces == 0) return '${settings.currencyUnit}$integer';
  return '${settings.currencyUnit}$integer.${parts.length > 1 ? parts.last : ''.padRight(settings.decimalPlaces, '0')}';
}

String durationCalendarText(int days) {
  final safeDays = math.max(days, 0);
  if (safeDays < 30) return '$safeDays ${tr('time.day')}';
  final years = safeDays ~/ 365;
  final months = (safeDays % 365) ~/ 30;
  final restDays = (safeDays % 365) % 30;
  if (years > 0) {
    if (months > 0)
      return '$years ${tr('time.year')} $months ${tr('time.month')}';
    if (restDays > 0 && years == 0)
      return '$years ${tr('time.year')} $restDays ${tr('time.day')}';
    return '$years ${tr('time.year')}';
  }
  if (months > 0 && restDays > 0 && safeDays < 90)
    return '$months ${tr('time.month')} $restDays ${tr('time.day')}';
  return '$months ${tr('time.month')}';
}

String durationText(int days, DurationMode mode) {
  final safeDays = math.max(days, 0);
  if (mode == DurationMode.weeks)
    return '${(safeDays / 7).toStringAsFixed(safeDays >= 70 ? 0 : 1)} ${tr('time.week')}';
  if (mode == DurationMode.months)
    return '${(safeDays / 30).toStringAsFixed(safeDays >= 300 ? 0 : 1)} ${tr('time.month')}';
  if (mode == DurationMode.years) return durationCalendarText(safeDays);
  return '$safeDays ${tr('time.day')}';
}

String durationWithCalendarText(int days, DurationMode mode) {
  final base = durationText(days, mode);
  final calendar = durationCalendarText(days);
  if (base == calendar || days < 30) return base;
  return '$base · $calendar';
}

enum AssetStatus { serving, retired, sold }

enum WishStatus { active, archived }

enum AssetValueMode { priced, priceless }

enum TargetMode { none, daily, date, custom }

enum ThemeSetting { light, dark, system }

enum DurationMode { days, weeks, months, years }

enum HomeViewMode { grid, list, sticker }

enum StickerEngineMode { compact, balanced, quality, hqExperimental }

enum GlassEffectMode { classic, liquid }

enum SortMode { dailyCost, price, days, recent }

extension AssetStatusX on AssetStatus {
  String get label {
    switch (this) {
      case AssetStatus.serving:
        return '服役中';
      case AssetStatus.retired:
        return '退役';
      case AssetStatus.sold:
        return '卖出';
    }
  }

  String get localizedLabel => tr('AssetStatus.$name');

  String get value => name;
  static AssetStatus fromValue(String? value) {
    return AssetStatus.values.firstWhere(
        (e) => e.name == value || e.label == value,
        orElse: () => AssetStatus.serving);
  }
}

extension AssetValueModeX on AssetValueMode {
  String get label {
    switch (this) {
      case AssetValueMode.priced:
        return '普通资产';
      case AssetValueMode.priceless:
        return '无价之宝';
    }
  }

  String get localizedLabel => tr('AssetValueMode.$name');

  static AssetValueMode fromValue(String? value) {
    return AssetValueMode.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => AssetValueMode.priced,
    );
  }
}

extension TargetModeX on TargetMode {
  String get label {
    switch (this) {
      case TargetMode.none:
        return '无目标';
      case TargetMode.daily:
        return '日均';
      case TargetMode.date:
        return '日期';
      case TargetMode.custom:
        return '天数';
    }
  }

  String get localizedLabel => tr('TargetMode.$name');

  static TargetMode fromValue(String? value) {
    return TargetMode.values.firstWhere(
        (e) => e.name == value || e.label == value,
        orElse: () => TargetMode.none);
  }
}

String assetDateLabel(Asset asset) =>
    asset.isPriceless ? tr('asset.recordDate') : tr('asset.purchaseDate');

String assetValueLabelText(Asset asset, AppSettings settings) =>
    asset.isPriceless ? '∞' : money(asset.totalDisplayValue, settings);

String assetBasePriceText(Asset asset, AppSettings settings) =>
    asset.isPriceless ? '∞' : money(asset.price, settings);

String assetMetricLabel(Asset asset) =>
    asset.isPriceless ? tr('asset.sinceLast') : tr('asset.dailyCost');

String assetMetricValueText(Asset asset, AppSettings settings) =>
    asset.isPriceless
        ? durationWithCalendarText(asset.serviceDays, settings.durationMode)
        : '${money(asset.dailyCost, settings)} ${tr('time.perDay')}';

String assetMetricCompactValue(Asset asset, AppSettings settings) =>
    asset.isPriceless
        ? '${asset.serviceDays}'
        : money(asset.dailyCost, settings);

String assetMetricCompactSuffix(Asset asset) =>
    asset.isPriceless ? ' ${tr('time.day')}' : tr('time.perDay');

extension StickerEngineModeX on StickerEngineMode {
  String get label {
    switch (this) {
      case StickerEngineMode.compact:
        return '轻量';
      case StickerEngineMode.balanced:
        return '均衡';
      case StickerEngineMode.quality:
        return '精细';
      case StickerEngineMode.hqExperimental:
        return '高质量实验';
    }
  }

  String get localizedLabel => tr('StickerEngineMode.$name');

  String get localizedDescription => tr('StickerEngineMode.$name.desc');

  String get description {
    switch (this) {
      case StickerEngineMode.compact:
        return '输入更小、候选更少，速度快且更省体积';
      case StickerEngineMode.balanced:
        return '日常默认，速度与效果平衡';
      case StickerEngineMode.quality:
        return '输入更大、候选更多，效果更稳但更慢';
      case StickerEngineMode.hqExperimental:
        return '更大的输入和更多候选，尽量提升抠图质量，但会更慢';
    }
  }

  static StickerEngineMode fromValue(String? value) {
    return StickerEngineMode.values.firstWhere(
        (e) => e.name == value || e.label == value,
        orElse: () => StickerEngineMode.balanced);
  }
}

extension GlassEffectModeX on GlassEffectMode {
  String get label {
    switch (this) {
      case GlassEffectMode.classic:
        return '经典毛玻璃';
      case GlassEffectMode.liquid:
        return '液态玻璃';
    }
  }

  String get localizedLabel => tr('GlassEffectMode.$name');

  String get localizedDescription => tr('GlassEffectMode.$name.desc');

  String get description {
    switch (this) {
      case GlassEffectMode.classic:
        return '使用 0.79 风格的轻量高斯模糊，稳定、省电、清晰';
      case GlassEffectMode.liquid:
        return '使用场景级液态玻璃折射效果，Dock、加号和保存按钮更有流动质感';
    }
  }

  static GlassEffectMode fromValue(String? value) {
    return GlassEffectMode.values.firstWhere(
        (e) => e.name == value || e.label == value,
        orElse: () => GlassEffectMode.liquid);
  }
}

extension HomeViewModeX on HomeViewMode {
  String get label {
    switch (this) {
      case HomeViewMode.grid:
        return '卡片';
      case HomeViewMode.list:
        return '列表';
      case HomeViewMode.sticker:
        return '贴纸';
    }
  }

  String get localizedLabel => tr('HomeViewMode.$name');

  static HomeViewMode fromValue(String? value) {
    return HomeViewMode.values.firstWhere(
        (e) => e.name == value || e.label == value,
        orElse: () => HomeViewMode.grid);
  }
}

extension SortModeX on SortMode {
  String get label {
    switch (this) {
      case SortMode.dailyCost:
        return '日均';
      case SortMode.price:
        return '价格';
      case SortMode.days:
        return '时长';
      case SortMode.recent:
        return '最新';
    }
  }

  String get localizedLabel => tr('SortMode.$name');
}
