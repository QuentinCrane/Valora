part of '../main.dart';

class ComposePage extends StatefulWidget {
  final ComposeTab initialTab;
  final String? initialName;
  final String? initialIcon;
  const ComposePage(
      {super.key,
      required this.initialTab,
      this.initialName,
      this.initialIcon});
  @override
  State<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends State<ComposePage> {
  final formKey = GlobalKey<FormState>();
  late ComposeTab tab;
  late final TextEditingController name;
  late final TextEditingController icon;
  late final TextEditingController price;
  late final TextEditingController purchaseDate;
  late final TextEditingController tagsText;
  late final TextEditingController targetDaily;
  late final TextEditingController targetDate;
  late final TextEditingController targetCustomDays;
  late final TextEditingController expiresAt;
  late final TextEditingController note;
  String? categoryId;
  AssetValueMode valueMode = AssetValueMode.priced;
  TargetMode targetMode = TargetMode.none;
  bool includeInTotal = true;
  bool includeInDailyCost = true;
  bool retired = false;
  bool sold = false;
  bool reminder = false;
  bool _savePressed = false;
  bool _cancelPressed = false;
  final List<AddonItem> addons = [];

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
    name = TextEditingController(text: widget.initialName ?? '');
    final initialIcon = widget.initialIcon?.trim() ?? '';
    icon = TextEditingController(
        text: initialIcon.isNotEmpty
            ? initialIcon
            : widget.initialTab == ComposeTab.asset
                ? '📦'
                : '✨');
    price = TextEditingController();
    purchaseDate = TextEditingController(text: dateText(DateTime.now()));
    tagsText = TextEditingController();
    targetDaily = TextEditingController();
    targetDate = TextEditingController();
    targetCustomDays = TextEditingController();
    expiresAt = TextEditingController();
    note = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      name,
      icon,
      price,
      purchaseDate,
      tagsText,
      targetDaily,
      targetDate,
      targetCustomDays,
      expiresAt,
      note
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  lge.LiquidGlass _buildComposeCancelGlass(
      Widget cancelContent, EdgeInsets safe, bool dark) {
    final spring = _cancelPressed ? 1.0 : 0.0;
    final w = 92.0 * (1.0 + .045 * spring);
    final h = 44.0 * (1.0 + .045 * spring);
    return lge.LiquidGlass(
      width: w,
      height: h,
      position: lge.LiquidGlassAlignPosition(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(
            left: 12 - (w - 92.0) / 2, top: safe.top + 10 - (h - 44.0) / 2),
      ),
      shape: lge.RoundedRectangleShape(
        cornerRadius: 999,
        borderWidth: 1.35 + .24 * spring,
        borderColor: Colors.white.withOpacity(dark ? .28 : .64),
        lightColor: Colors.white.withOpacity(dark ? .74 : .90),
        lightIntensity: 1.35 + .28 * spring,
        lightDirection: 132,
        borderType: lge.OpticalBorder(
            borderSaturation: 1.45 + .18 * spring,
            ambientIntensity: 1.06 + .18 * spring,
            borderSolidity: 0.0),
      ),
      blur: const lge.LiquidGlassBlur(sigmaX: .010, sigmaY: .010),
      distortion: .086 + .022 * spring,
      distortionWidth: 30 + 6 * spring,
      magnification: 1.038 + .024 * spring,
      chromaticAberration: .00048 + .00012 * spring,
      saturation: 1.055,
      refractionMode: lge.LiquidGlassRefractionMode.shapeRefraction,
      color: Colors.white.withOpacity(dark ? .018 : .026),
      child: cancelContent,
    );
  }

  lge.LiquidGlass _buildComposeSaveGlass(
      Widget saveContent, EdgeInsets safe, bool dark, double saveWidth) {
    final spring = _savePressed ? 1.0 : 0.0;
    final w = saveWidth * (1.0 + .038 * spring);
    final h = 58.0 * (1.0 + .038 * spring);
    return lge.LiquidGlass(
      width: w,
      height: h,
      position: lge.LiquidGlassAlignPosition(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.only(bottom: 18 + safe.bottom - (h - 58.0) / 2),
      ),
      shape: lge.RoundedRectangleShape(
        cornerRadius: 999,
        borderWidth: 1.65 + .30 * spring,
        borderColor: Colors.white.withOpacity(dark ? .30 : .66),
        lightColor: Colors.white.withOpacity(dark ? .76 : .92),
        lightIntensity: 1.55 + .34 * spring,
        lightDirection: 132,
        borderType: lge.OpticalBorder(
            borderSaturation: 1.55 + .24 * spring,
            ambientIntensity: 1.08 + .22 * spring,
            borderSolidity: 0.0),
      ),
      blur: const lge.LiquidGlassBlur(sigmaX: .003, sigmaY: .003),
      distortion: .096 + .026 * spring,
      distortionWidth: 32 + 7 * spring,
      magnification: 1.044 + .030 * spring,
      chromaticAberration: .00052 + .00014 * spring,
      saturation: 1.055,
      refractionMode: lge.LiquidGlassRefractionMode.shapeRefraction,
      color: Colors.white.withOpacity(dark ? .018 : .026),
      child: saveContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetMode = tab == ComposeTab.asset;
    final priceless = assetMode && valueMode == AssetValueMode.priceless;
    final media = MediaQuery.of(context);
    final safe = media.padding;
    final dark = context.isDark;

    final pageBody = SafeArea(
      bottom: false,
      child: Form(
        key: formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding:
              EdgeInsets.fromLTRB(kPagePad, 66, kPagePad, 104 + safe.bottom),
          children: [
            TutorialTargetAnchor(
                id: 'compose.tabs',
                child: Center(
                    child: ComposeSegmentedTabs(
                        value: tab,
                        onChanged: (v) {
                          tapHaptic();
                          setState(() {
                            tab = v;
                            icon.text = v == ComposeTab.asset ? '📦' : '✨';
                            if (v == ComposeTab.wish) {
                              valueMode = AssetValueMode.priced;
                              if (price.text.trim() == '∞') price.clear();
                            }
                          });
                        }))),
            const SizedBox(height: 12),
            Center(
                child: EditableIconPreview(
                    controller: icon, onChanged: () => setState(() {}))),
            const SizedBox(height: 8),
            if (assetMode)
              TutorialTargetAnchor(
                  id: 'compose.import',
                  child: SmartAssetImportBar(
                    onPickCover: pickNativeCover,
                    onScanBarcode: scanBarcodeIntoForm,
                    onOcrReceipt: ocrReceiptIntoForm,
                    onCutoutCover: cutoutCoverIntoForm,
                    onFramedCover: framedCoverIntoForm,
                    onTraceCover: traceCoverIntoForm,
                  ))
            else
              TutorialTargetAnchor(
                  id: 'compose.import',
                  child: CoverImportBar(
                    onPickCover: pickNativeCover,
                    onCutoutCover: cutoutCoverIntoForm,
                    onFramedCover: framedCoverIntoForm,
                    onTraceCover: traceCoverIntoForm,
                  )),
            const SizedBox(height: 8),
            TutorialTargetAnchor(
                id: 'compose.name',
                child: TextFormField(
                  controller: name,
                  textAlign: TextAlign.center,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? tr('compose.nameRequired')
                      : null,
                  style: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    hintText: assetMode
                        ? tr('compose.assetNameHint')
                        : tr('compose.wishNameHint'),
                    hintStyle: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.normal,
                        color: kMuted.withOpacity(.38)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                )),
            const SizedBox(height: 12),
            TutorialTargetAnchor(
                id: 'compose.price',
                child: SoftFormCard(
                    child: Column(children: [
                  if (assetMode) ...[
                    FormLine(
                        icon: Icons.auto_awesome_rounded,
                        label: tr('compose.valueMode'),
                        trailing: _PlainRightText(valueMode.localizedLabel),
                        onTap: pickAssetValueMode),
                    const Divider(height: 8),
                  ],
                  FormLine(
                    icon: priceless
                        ? Icons.all_inclusive_rounded
                        : Icons.currency_yen_rounded,
                    label: priceless
                        ? tr('compose.value')
                        : assetMode
                            ? tr('compose.price')
                            : tr('compose.expectedPrice'),
                    trailing: SizedBox(
                      width: priceless ? 72 : 140,
                      child: TextFormField(
                        controller: price,
                        readOnly: priceless,
                        textAlign: TextAlign.right,
                        keyboardType: priceless
                            ? TextInputType.text
                            : const TextInputType.numberWithOptions(
                                decimal: true),
                        validator: (v) => priceless
                            ? null
                            : v == null || v.trim().isEmpty
                                ? tr('compose.required')
                                : (parseUserDouble(v)?.isFinite ?? false)
                                    ? null
                                    : tr('common.invalidNumber'),
                        style: TextStyle(
                            fontSize: priceless ? 25 : 18,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            hintText: priceless ? '∞' : '0',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false),
                      ),
                    ),
                  ),
                ]))),
            const SizedBox(height: 12),
            TutorialTargetAnchor(
                id: 'compose.meta',
                child: SoftFormCard(
                    child: Column(children: [
                  if (assetMode)
                    FormLine(
                        icon: Icons.calendar_month_rounded,
                        label: priceless
                            ? tr('compose.recordDate')
                            : tr('compose.purchaseDate'),
                        trailing: _PlainRightText(purchaseDate.text),
                        onTap: () => pickDate(purchaseDate)),
                  FormLine(
                      icon: Icons.category_rounded,
                      label: tr('compose.category'),
                      trailing: _PlainRightText(
                          context.store.categoryName(categoryId)),
                      onTap: pickCategory),
                  FormLine(
                      icon: Icons.sell_rounded,
                      label: tr('compose.tags'),
                      trailing: _PlainRightText(tagsText.text.trim().isEmpty
                          ? tr('common.unset')
                          : tagsText.text.trim()),
                      onTap: editTags),
                ]))),
            if (assetMode) ...[
              const SizedBox(height: 12),
              TutorialTargetAnchor(
                  id: 'compose.target',
                  child: SoftFormCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          const Icon(Icons.track_changes_rounded, size: 22),
                          const SizedBox(width: 12),
                          Text(
                              priceless
                                  ? tr('compose.recordGoal')
                                  : tr('compose.dailyCostGoal'),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.normal))
                        ]),
                        const SizedBox(height: 10),
                        _TargetModeSwitch(
                            value: targetMode,
                            modes: priceless
                                ? const [
                                    TargetMode.none,
                                    TargetMode.date,
                                    TargetMode.custom
                                  ]
                                : TargetMode.values,
                            onChanged: (mode) {
                              selectionHaptic();
                              setState(() => targetMode = mode);
                            }),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment: -1,
                                        child: child)),
                            child: KeyedSubtree(
                                key: ValueKey(targetMode.name),
                                child: _buildTargetModeFields()),
                          ),
                        ),
                      ]))),
            ],
            const SizedBox(height: 12),
            if (!priceless)
              TutorialTargetAnchor(
                  id: 'compose.addons',
                  child: SoftFormCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          const Icon(Icons.inventory_2_outlined, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(tr('compose.addons'),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal))),
                          SmallCaret()
                        ]),
                        const SizedBox(height: 10),
                        if (addons.isNotEmpty)
                          ...addons.map((a) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(a.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal)),
                                subtitle: Text(
                                    '${tr('compose.addonPurchaseTime')}${a.purchaseDateLabel}',
                                    style: const TextStyle(
                                        color: kMuted, fontSize: 12)),
                                trailing: Text(
                                    money(a.price, context.store.settings)),
                                onLongPress: () =>
                                    setState(() => addons.remove(a)),
                              )),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                                onPressed: addAddon,
                                icon: const Icon(Icons.add_rounded),
                                label: Text(tr('compose.addItem')))),
                      ]))),
            const SizedBox(height: 12),
            SoftFormCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    const Icon(Icons.sticky_note_2_outlined, size: 22),
                    const SizedBox(width: 12),
                    Text(tr('compose.note'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal))
                  ]),
                  const SizedBox(height: 12),
                  TextField(
                      controller: note,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 200,
                      decoration: InputDecoration(
                          hintText: tr('compose.noteHint'),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none)),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: pickNativeCover,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                              color: context.isDark
                                  ? kSoftDark
                                  : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(18)),
                          child: icon.text.trim().isEmpty
                              ? const Icon(Icons.add_photo_alternate_outlined,
                                  color: kMuted)
                              : valoraIconVisual(context, icon.text,
                                  emojiSize: 28, borderRadius: 18),
                        ),
                      )),
                ])),
            if (assetMode) ...[
              const SizedBox(height: 12),
              SoftFormCard(
                  child: Column(children: [
                if (priceless)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(tr('compose.pricelessHint'),
                        style: const TextStyle(color: kMuted, height: 1.35)),
                  )
                else ...[
                  SwitchListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      value: !includeInTotal,
                      onChanged: (v) {
                        tapHaptic();
                        setState(() => includeInTotal = !v);
                      },
                      title: Text(tr('compose.excludeFromTotal'),
                          style:
                              const TextStyle(fontWeight: FontWeight.normal))),
                  SwitchListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      value: !includeInDailyCost,
                      onChanged: (v) {
                        tapHaptic();
                        setState(() => includeInDailyCost = !v);
                      },
                      title: Text(tr('compose.excludeFromDaily'),
                          style:
                              const TextStyle(fontWeight: FontWeight.normal))),
                  SwitchListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      value: sold,
                      onChanged: (v) {
                        tapHaptic();
                        setState(() {
                          sold = v;
                          if (v) retired = false;
                        });
                      },
                      title: Text(tr('compose.sold'),
                          style:
                              const TextStyle(fontWeight: FontWeight.normal))),
                ],
                SwitchListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    value: retired,
                    onChanged: (v) {
                      tapHaptic();
                      setState(() {
                        retired = v;
                        if (v) sold = false;
                      });
                    },
                    title: Text(
                        priceless
                            ? tr('compose.paused')
                            : tr('compose.retired'),
                        style: const TextStyle(fontWeight: FontWeight.normal))),
              ])),
              const SizedBox(height: 12),
              SoftFormCard(
                  child: Column(children: [
                FormLine(
                    icon: Icons.hourglass_empty_rounded,
                    label: tr('compose.expiryTime'),
                    trailing: _PlainRightText(expiresAt.text.trim().isEmpty
                        ? tr('common.unset')
                        : expiresAt.text),
                    onTap: () => pickDate(expiresAt)),
                SwitchListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    value: reminder,
                    onChanged: (v) {
                      tapHaptic();
                      setState(() => reminder = v);
                    },
                    title: Text(tr('compose.expiryReminder'),
                        style: const TextStyle(fontWeight: FontWeight.normal))),
              ])),
            ],
          ],
        ),
      ),
    );

    final useLiquidGlass =
        context.store.settings.glassEffectMode == GlassEffectMode.liquid;
    final cancelContent = ValoraGlassSaveContent(
      label: tr('common.cancel'),
      icon: Icons.close_rounded,
      onPressed: () {
        lightHaptic();
        Navigator.pop(context);
      },
      onPressChanged: (v) => setState(() => _cancelPressed = v),
    );
    final saveContent = TutorialTargetAnchor(
      id: 'compose.save',
      child: ValoraGlassSaveContent(
        label: tr('common.save'),
        icon: Icons.check_rounded,
        onPressed: () async {
          mediumHaptic();
          await save();
        },
        onPressChanged: (v) => setState(() => _savePressed = v),
      ),
    );
    final saveWidth =
        math.min(media.size.width - 144, 230.0).clamp(184.0, 230.0).toDouble();

    if (!useLiquidGlass) {
      return GradientScaffold(
        child: Stack(children: [
          pageBody,
          Positioned(
            left: 12,
            top: safe.top + 10,
            width: 92,
            height: 44,
            child: ValoraLiquidGlassSurface(
              height: 44,
              radius: 999,
              tintOpacity: .16,
              blurSigma: .52,
              child: cancelContent,
            ),
          ),
          Positioned(
            left: (media.size.width - saveWidth) / 2,
            bottom: 18 + safe.bottom,
            width: saveWidth,
            height: 58,
            child: ValoraLiquidGlassSurface(
              height: 58,
              radius: 999,
              tintOpacity: .16,
              blurSigma: .52,
              child: saveContent,
            ),
          ),
        ]),
      );
    }

    return GradientScaffold(
      child: lge.LiquidGlassView(
        realTimeCapture: true,
        useSync: true,
        refreshRate: lge.LiquidGlassRefreshRate.deviceRefreshRate,
        pixelRatio: _savePressed ? .84 : .92,
        backgroundWidget:
            ValoraGlassSceneBackground(child: RepaintBoundary(child: pageBody)),
        children: [
          _buildComposeCancelGlass(cancelContent, safe, dark),
          _buildComposeSaveGlass(saveContent, safe, dark, saveWidth),
        ],
      ),
    );
  }

  Widget _buildTargetModeFields() {
    final priceless =
        tab == ComposeTab.asset && valueMode == AssetValueMode.priceless;
    switch (targetMode) {
      case TargetMode.none:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
              priceless
                  ? tr('compose.noGoalHintPriceless')
                  : tr('compose.noGoalHintNormal'),
              style:
                  const TextStyle(color: kMuted, fontSize: 12.5, height: 1.35)),
        );
      case TargetMode.daily:
        if (priceless) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(tr('compose.pricelessNoDailyGoal'),
                style: const TextStyle(
                    color: kMuted, fontSize: 12.5, height: 1.35)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: AppField(
              controller: targetDaily,
              label: tr('compose.targetDailyCost'),
              number: true),
        );
      case TargetMode.date:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DateFormField(
              controller: targetDate,
              label: tr('compose.targetDate'),
              onChanged: () => setState(() {})),
        );
      case TargetMode.custom:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: AppField(
              controller: targetCustomDays,
              label: tr('compose.targetDays'),
              number: true),
        );
    }
  }

  Future<void> pickNativeCover() async {
    lightHaptic();
    final uri = await NativeBridge.pickImage();
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('compose.coverSet'));
  }

  Future<void> framedCoverIntoForm() async {
    mediumHaptic();
    final uri = await createFramedCoverFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('compose.framedCoverGenerated'));
  }

  Future<void> traceCoverIntoForm() async {
    mediumHaptic();
    final uri = await createManualTraceStickerFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('compose.traceCoverGenerated'));
  }

  Future<void> cutoutCoverIntoForm() async {
    mediumHaptic();
    final payload = await NativeBridge.cutoutImageFromPickerDetailed();
    final uri = mounted ? await chooseStickerCandidate(context, payload) : null;
    if (uri == null || uri.trim().isEmpty) {
      if (mounted) showNativeSnack(context, tr('compose.noStickerGenerated'));
      return;
    }
    setState(() => icon.text = uri);
    final count = payload['candidates'] is List
        ? (payload['candidates'] as List).length
        : 0;
    if (mounted)
      showNativeSnack(
          context,
          count > 1
              ? tr('compose.cutoutSelectedFromN').replaceAll('{n}', '$count')
              : tr('compose.aiStickerGenerated'));
  }

  Future<void> scanBarcodeIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.scanBarcodeFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, tr('compose.barcodeNotFound'));
      return;
    }
    final value =
        (data['displayValue'] ?? data['rawValue'] ?? '').toString().trim();
    setState(() {
      if (name.text.trim().isEmpty && value.isNotEmpty)
        name.text = value.take(32);
      tagsText.text = appendTagText(tagsText.text, tr('compose.tagScan'));
      note.text = appendLine(note.text, '${tr('compose.barcodeNote')}$value');
    });
    if (mounted) showNativeSnack(context, tr('compose.barcodeWritten'));
  }

  Future<void> ocrReceiptIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.recognizeReceiptFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, tr('compose.ocrNoText'));
      return;
    }
    final priceText = (data['priceCandidate'] ?? '').toString();
    final dateTextValue = (data['dateCandidate'] ?? '').toString();
    final titleText = (data['nameCandidate'] ?? '').toString();
    final fullText = (data['fullText'] ?? '').toString();
    setState(() {
      if (price.text.trim().isEmpty && priceText.isNotEmpty)
        price.text = priceText;
      if (purchaseDate.text.trim().isEmpty ||
          purchaseDate.text == dateText(DateTime.now())) {
        if (dateTextValue.isNotEmpty) purchaseDate.text = dateTextValue;
      }
      if (name.text.trim().isEmpty && titleText.isNotEmpty)
        name.text = titleText.take(24);
      tagsText.text = appendTagText(tagsText.text, tr('compose.tagReceiptOcr'));
      note.text = appendLine(
          note.text, '${tr('compose.ocrNote')}\n${fullText.take(500)}');
    });
    if (mounted)
      showNativeSnack(
          context,
          priceText.isEmpty
              ? tr('compose.ocrWrittenToNote')
              : tr('compose.ocrFilledPrice').replaceAll('{price}', priceText));
  }

  void pickDate(TextEditingController controller) async {
    await pickAndroidOfficialDate(context, controller,
        onChanged: () => setState(() {}));
  }

  void pickAssetValueMode() {
    appSheet(context,
        title: tr('compose.valueMode'),
        subtitle: tr('compose.valueModeSubtitle'),
        child: Column(
            children: AssetValueMode.values.map((mode) {
          final active = valueMode == mode;
          return ListTile(
            leading: Text(mode == AssetValueMode.priceless ? '∞' : '¥',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.normal)),
            title: Text(mode.localizedLabel),
            subtitle: Text(mode == AssetValueMode.priceless
                ? tr('compose.valueModePricelessDesc')
                : tr('compose.valueModePricedDesc')),
            trailing: active
                ? const Icon(Icons.check_circle_rounded, color: kBrandStrong)
                : null,
            onTap: () {
              mediumHaptic();
              setState(() {
                valueMode = mode;
                if (mode == AssetValueMode.priceless) {
                  price.text = '∞';
                  includeInTotal = false;
                  includeInDailyCost = false;
                  sold = false;
                  addons.clear();
                  if (targetMode == TargetMode.daily)
                    targetMode = TargetMode.none;
                } else if (price.text.trim() == '∞') {
                  price.clear();
                  includeInTotal = true;
                  includeInDailyCost = true;
                }
              });
              Navigator.pop(context);
            },
          );
        }).toList()));
  }

  void pickCategory() {
    appSheet(context,
        title: tr('compose.selectCategory'),
        subtitle: tr('compose.selectCategorySubtitle'),
        child: Column(children: [
          ListTile(
              title:
                  Text(tr('common.all') + ' / ' + tr('common.uncategorized')),
              onTap: () {
                setState(() => categoryId = null);
                Navigator.pop(context);
              }),
          ...context.store.categories.map((c) => ListTile(
              leading: Text(c.icon, style: const TextStyle(fontSize: 24)),
              title: Text(context.store.categoryName(c.id)),
              trailing:
                  categoryId == c.id ? const Icon(Icons.check_rounded) : null,
              onTap: () {
                setState(() => categoryId = c.id);
                Navigator.pop(context);
              })),
          const Divider(height: 20),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: Text(tr('compose.smartNewCategory')),
            subtitle: Text(tr('compose.smartNewCategoryHint')),
            onTap: () => showSmartCategoryCreateSheet(context,
                initialName: name.text, onCreated: (id) {
              setState(() => categoryId = id);
            }),
          ),
        ]));
  }

  void editTags() {
    final ctl = TextEditingController(text: tagsText.text);
    final store = context.store;

    void toggleLocalTag(String tag) {
      final parts = splitTags(ctl.text);
      if (parts.contains(tag)) {
        parts.remove(tag);
      } else {
        parts.add(tag);
      }
      ctl.text = parts.join('、');
    }

    appSheet(context,
        title: tr('compose.tags'), subtitle: tr('compose.tagsSubtitle'),
        child: StatefulBuilder(builder: (context, setLocal) {
      final presets = ['通勤', '办公', '学习', '收藏', '吃灰', '维修', '配件', '长期持有'];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
            controller: ctl,
            autofocus: true,
            decoration: InputDecoration(hintText: tr('compose.tagsHint'))),
        const SizedBox(height: 12),
        SectionLabel(tr('compose.commonTags')),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((t) {
              final label = tl(t);
              final selected = splitTags(ctl.text).contains(label);
              return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setLocal(() => toggleLocalTag(label)));
            }).toList()),
        if (store.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionLabel(tr('compose.existingTags')),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.tags
                  .map((tag) => FilterChip(
                        avatar: CircleAvatar(
                            radius: 8, backgroundColor: parseColor(tag.color)),
                        label: Text(tag.name),
                        selected: splitTags(ctl.text).contains(tag.name),
                        onSelected: (_) =>
                            setLocal(() => toggleLocalTag(tag.name)),
                      ))
                  .toList()),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showSmartTagCreateSheet(context,
              initialName: ctl.text.trim(),
              onCreated: (label) => setLocal(() => toggleLocalTag(label))),
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('compose.newTag')),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(
              onPressed: () => setLocal(() => ctl.clear()),
              child: Text(tr('common.clear'))),
          const SizedBox(width: 8),
          Expanded(
              child: FilledButton(
                  onPressed: () {
                    setState(() => tagsText.text = ctl.text.trim());
                    Navigator.pop(context);
                  },
                  child: Text(tr('common.done')))),
        ]),
      ]);
    }));
  }

  void addAddon() {
    final nameCtl = TextEditingController();
    final priceCtl = TextEditingController();
    final dateCtl = TextEditingController(text: dateText(DateTime.now()));
    appSheet(context,
        title: tr('compose.addAddonTitle'),
        subtitle: tr('compose.addAddonSubtitle'),
        child: Column(children: [
          TextField(
              controller: nameCtl,
              decoration: InputDecoration(labelText: tr('compose.addonName'))),
          const SizedBox(height: 10),
          TextField(
              controller: priceCtl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: tr('compose.addonPrice'))),
          const SizedBox(height: 10),
          DateFormField(
              controller: dateCtl, label: tr('compose.addonPurchaseTime')),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () {
                    final parsedDate = dateCtl.text.trim().isEmpty
                        ? null
                        : parseUserDateOrNull(dateCtl.text);
                    if (dateCtl.text.trim().isNotEmpty && parsedDate == null) {
                      showNativeSnack(context, tr('compose.addonDateInvalid'));
                      return;
                    }
                    setState(() => addons.add(AddonItem(
                          id: newId('addon'),
                          name: nameCtl.text.trim().isEmpty
                              ? tr('compose.addonDefaultName')
                              : nameCtl.text.trim(),
                          price: asDouble(priceCtl.text),
                          purchaseDate: parsedDate,
                        )));
                    Navigator.pop(context);
                  },
                  child: Text(tr('common.add')))),
        ]));
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final pricelessAsset =
        tab == ComposeTab.asset && valueMode == AssetValueMode.priceless;
    final parsedPurchaseDate = parseUserDateOrNull(purchaseDate.text);
    final parsedExpiresAt = parseOptionalUserDate(expiresAt.text);
    final parsedTargetDate = parseOptionalUserDate(targetDate.text);
    final parsedTargetCustomDays = targetCustomDays.text.trim().isEmpty
        ? null
        : asInt(targetCustomDays.text);
    if (tab == ComposeTab.asset && parsedPurchaseDate == null) {
      showNativeSnack(
          context,
          pricelessAsset
              ? tr('compose.recordDateInvalid')
              : tr('compose.purchaseDateInvalid'));
      return;
    }
    if (tab == ComposeTab.asset &&
        !pricelessAsset &&
        targetMode == TargetMode.daily &&
        (targetDaily.text.trim().isEmpty || asDouble(targetDaily.text) <= 0)) {
      showNativeSnack(context, tr('compose.targetDailyCostRequired'));
      return;
    }
    if (tab == ComposeTab.asset &&
        targetMode == TargetMode.date &&
        (targetDate.text.trim().isEmpty || parsedTargetDate == null)) {
      showNativeSnack(context, tr('compose.targetDateRequired'));
      return;
    }
    if (tab == ComposeTab.asset &&
        targetMode == TargetMode.custom &&
        (parsedTargetCustomDays == null || parsedTargetCustomDays <= 0)) {
      showNativeSnack(context, tr('compose.targetCustomDaysRequired'));
      return;
    }
    final store = context.store;
    final now = DateTime.now();
    final tagIds = await ensureTags(store, splitTags(tagsText.text), now);
    if (tab == ComposeTab.asset) {
      final status = !pricelessAsset && sold
          ? AssetStatus.sold
          : retired
              ? AssetStatus.retired
              : AssetStatus.serving;
      await store.upsertAsset(Asset(
        id: newId('asset'),
        name: name.text.trim(),
        iconValue: icon.text.trim().isEmpty ? '📦' : icon.text.trim(),
        valueMode: valueMode,
        price: pricelessAsset ? 0 : asDouble(price.text),
        purchaseDate: parsedPurchaseDate ?? dateOnly(now),
        categoryId: categoryId,
        tagIds: tagIds,
        addons: pricelessAsset ? [] : List.of(addons),
        note: note.text.trim(),
        status: status,
        includeInTotal: pricelessAsset ? false : includeInTotal,
        includeInDailyCost: pricelessAsset ? false : includeInDailyCost,
        retiredAt: retired ? DateTime.now() : null,
        soldAt: !pricelessAsset && sold ? DateTime.now() : null,
        soldPrice: null,
        targetMode: pricelessAsset && targetMode == TargetMode.daily
            ? TargetMode.none
            : targetMode,
        targetDailyCost: !pricelessAsset &&
                targetMode == TargetMode.daily &&
                targetDaily.text.trim().isNotEmpty
            ? asDouble(targetDaily.text)
            : null,
        targetDate: targetMode == TargetMode.date ? parsedTargetDate : null,
        targetCustomDays:
            targetMode == TargetMode.custom ? parsedTargetCustomDays : null,
        expiresAt: expiresAt.text.trim().isEmpty ? null : parsedExpiresAt,
        remindBeforeDays: reminder ? 7 : null,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      await store.upsertWish(Wish(
        id: newId('wish'),
        name: name.text.trim(),
        iconValue: icon.text.trim().isEmpty ? '✨' : icon.text.trim(),
        expectedPrice: asDouble(price.text),
        note: note.text.trim(),
        categoryId: categoryId,
        tagIds: tagIds,
        archived: false,
        convertedAt: null,
        convertedAssetId: null,
        addons: List.of(addons),
        createdAt: now,
        updatedAt: now,
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _TargetModeSwitch extends StatelessWidget {
  final TargetMode value;
  final Iterable<TargetMode> modes;
  final ValueChanged<TargetMode> onChanged;
  const _TargetModeSwitch(
      {required this.value,
      required this.onChanged,
      this.modes = TargetMode.values});

  String _label(TargetMode mode) {
    switch (mode) {
      case TargetMode.none:
        return tr('compose.targetModeNone');
      case TargetMode.daily:
        return tr('compose.targetModeDaily');
      case TargetMode.date:
        return tr('compose.targetModeDate');
      case TargetMode.custom:
        return tr('compose.targetModeCustom');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? kSoftDark : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
          children: modes.map((mode) {
        final active = value == mode;
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              decoration: BoxDecoration(
                color: active
                    ? (dark ? Colors.white.withOpacity(.12) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active && !dark
                    ? [
                        BoxShadow(
                            color: Colors.black.withOpacity(.055),
                            blurRadius: 12,
                            offset: const Offset(0, 5))
                      ]
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 13.2,
                  height: 1.1,
                  fontWeight: FontWeight.normal,
                  color: active
                      ? (dark ? Colors.white.withOpacity(.95) : kText)
                      : kMuted,
                ),
                child: Text(_label(mode),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        );
      }).toList()),
    );
  }
}

Future<List<String>> ensureTags(
    AppStore store, List<String> names, DateTime now) async {
  final tagIds = <String>[];
  for (final name in names) {
    final existed =
        store.tags.where((t) => t.name == name || t.id == name).firstOrNull;
    if (existed != null) {
      tagIds.add(existed.id);
    } else {
      final tag = Tag(
          id: newId('tag'),
          name: name,
          color: '#7cc6f2',
          sortOrder: store.tags.length,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String());
      await store.upsertTag(tag);
      tagIds.add(tag.id);
    }
  }
  return tagIds;
}

class _PlainRightText extends StatelessWidget {
  final String text;
  const _PlainRightText(this.text);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 210),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    fontSize: 15,
                    height: 1.18,
                    fontWeight: FontWeight.normal,
                    color: context.isDark ? Colors.white : kText),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, color: kMuted),
          ]),
    );
  }
}

class SmallCaret extends StatelessWidget {
  const SmallCaret({super.key});
  @override
  Widget build(BuildContext context) => ValoraLiquidGlassSurface(
        width: 26,
        height: 26,
        radius: 9,
        distortion: .08,
        distortionWidth: 12,
        blurSigma: .35,
        tintOpacity: context.isDark ? .12 : .22,
        child: Icon(Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: context.isDark
                ? Colors.white.withOpacity(.92)
                : kText.withOpacity(.84)),
      );
}

class WishHomePage extends StatelessWidget {
  const WishHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final active = store.wishes.where((w) => !w.archived).toList();
    final archived = store.wishes.where((w) => w.archived).toList();
    final list = store.wishShowArchived ? archived : active;
    final total = active.fold(0.0, (s, w) => s + w.expectedPrice);
    return PageFrame(children: [
      Row(children: [
        Expanded(
            child: Text(tr('wish.title'),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.normal, height: .95))),
        HeaderIcon(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () {
              tapHaptic();
              store.setWishArchivedFilter(!store.wishShowArchived);
            }),
      ]),
      const SizedBox(height: 24),
      TutorialTargetAnchor(
          id: 'wish.summary',
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: context.isDark ? kCardDark : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [softShadow(context)]),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(tr('wish.totalValue'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 12),
                    Text(money(total, store.settings),
                        style: const TextStyle(
                            fontSize: 21,
                            height: .95,
                            fontWeight: FontWeight.normal)),
                    const SizedBox(height: 12),
                    Text(tr('wish.count').replaceAll('{n}', '${active.length}'),
                        style: const TextStyle(
                            color: kMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.normal)),
                  ])),
              Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                      color: kBrand.withOpacity(.62),
                      borderRadius: BorderRadius.circular(28)),
                  child: const Center(
                      child: Text('✨', style: TextStyle(fontSize: 27)))),
            ]),
          )),
      const SizedBox(height: 12),
      TutorialTargetAnchor(
          id: 'wish.filters',
          child: Row(children: [
            FilterPill(
                label: tr('wish.active'),
                active: !store.wishShowArchived,
                onTap: () => store.setWishArchivedFilter(false)),
            FilterPill(
                label: tr('wish.archived'),
                active: store.wishShowArchived,
                onTap: () => store.setWishArchivedFilter(true)),
          ])),
      const SizedBox(height: 12),
      if (list.isEmpty)
        TutorialTargetAnchor(
            id: 'wish.list',
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.sizeOf(context).height * .22),
              child: Column(children: [
                Text('📦',
                    style: TextStyle(
                        fontSize: 76, color: kMuted.withOpacity(.25))),
                const SizedBox(height: 10),
                Text(tr('wish.empty'),
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.normal)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(tr('wish.emptyTapPrefix'),
                      style: const TextStyle(color: kMuted, fontSize: 18)),
                  const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF111214),
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 20)),
                  Text(tr('wish.emptyTapSuffix'),
                      style: const TextStyle(color: kMuted, fontSize: 18))
                ]),
              ]),
            ))
      else
        ...List.generate(
            list.length,
            (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: i == 0
                    ? TutorialTargetAnchor(
                        id: 'wish.list', child: WishCard(wish: list[i]))
                    : WishCard(wish: list[i]))),
    ]);
  }
}

class WishCard extends StatelessWidget {
  final Wish wish;
  const WishCard({super.key, required this.wish});
  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        lightHaptic();
        Navigator.of(context).push(softRoute(WishEditorPage(initial: wish)));
      },
      child: AppCard(
          child: Row(children: [
        Container(
            width: 54,
            height: 54,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: kBrand.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18)),
            child: valoraIconVisual(context, wish.iconValue,
                emojiSize: 21, borderRadius: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(wish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 16))),
            if (wish.archived)
              TinyTag(label: tr('wish.archived'), color: Colors.green)
          ]),
          const SizedBox(height: 4),
          Text(
              '${store.categoryIcon(wish.categoryId)} ${store.categoryName(wish.categoryId)} · ${money(wish.expectedPrice, store.settings)}',
              style: const TextStyle(color: kMuted, fontSize: 12)),
          if (wish.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(wish.note, maxLines: 2, overflow: TextOverflow.ellipsis)
          ],
        ])),
        PopupMenuButton<String>(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Theme.of(context).brightness == Brightness.dark
              ? kCardDark
              : Colors.white,
          onSelected: (v) async {
            if (v == 'convert') {
              await store.convertWishToAsset(wish.id);
              if (!context.mounted) return;
              showNativeSnack(context, tr('wish.convertedToAsset'));
            }
            if (v == 'archive')
              await store.upsertWish(wish.copyWith(archived: !wish.archived));
            if (v == 'delete') await store.deleteWish(wish.id);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'convert', child: Text(tr('wish.convertToAsset'))),
            PopupMenuItem(
                value: 'archive',
                child: Text(
                    wish.archived ? tr('wish.restore') : tr('wish.archive'))),
            PopupMenuItem(value: 'delete', child: Text(tr('common.delete')))
          ],
        ),
      ])),
    );
  }
}

class WishEditorPage extends StatefulWidget {
  final Wish? initial;
  const WishEditorPage({super.key, this.initial});
  @override
  State<WishEditorPage> createState() => _WishEditorPageState();
}

class _WishEditorPageState extends State<WishEditorPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController name, icon, price, tagsText, note;
  late String? categoryId;
  late bool archived;
  bool _wishSavePressed = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    name = TextEditingController(text: item?.name ?? '');
    icon = TextEditingController(text: item?.iconValue ?? '✨');
    price = TextEditingController(
        text: item?.expectedPrice.toStringAsFixed(0) ?? '');
    tagsText = TextEditingController();
    note = TextEditingController(text: item?.note ?? '');
    categoryId = item?.categoryId;
    archived = item?.archived ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final item = widget.initial;
    if (tagsText.text.isEmpty && item != null)
      tagsText.text =
          item.tagIds.map((id) => context.store.tagName(id)).join('、');
  }

  @override
  void dispose() {
    for (final c in [name, icon, price, tagsText, note]) {
      c.dispose();
    }
    super.dispose();
  }

  lge.LiquidGlass _buildWishSaveGlass(
      Widget saveContent, MediaQueryData media, double saveWidth, bool dark) {
    final spring = _wishSavePressed ? 1.0 : 0.0;
    final w = saveWidth * (1.0 + .038 * spring);
    final h = 58.0 * (1.0 + .038 * spring);
    return lge.LiquidGlass(
      width: w,
      height: h,
      position: lge.LiquidGlassAlignPosition(
        alignment: Alignment.bottomCenter,
        margin:
            EdgeInsets.only(bottom: 16 + media.padding.bottom - (h - 58.0) / 2),
      ),
      shape: lge.RoundedRectangleShape(
        cornerRadius: 999,
        borderWidth: 1.65 + .30 * spring,
        borderColor: Colors.white.withOpacity(dark ? .30 : .66),
        lightColor: Colors.white.withOpacity(dark ? .76 : .92),
        lightIntensity: 1.55 + .34 * spring,
        lightDirection: 132,
        borderType: lge.OpticalBorder(
            borderSaturation: 1.55 + .24 * spring,
            ambientIntensity: 1.08 + .22 * spring,
            borderSolidity: 0.0),
      ),
      blur: const lge.LiquidGlassBlur(sigmaX: .003, sigmaY: .003),
      distortion: .096 + .026 * spring,
      distortionWidth: 32 + 7 * spring,
      magnification: 1.044 + .030 * spring,
      chromaticAberration: .00052 + .00014 * spring,
      saturation: 1.055,
      refractionMode: lge.LiquidGlassRefractionMode.shapeRefraction,
      color: Colors.white.withOpacity(dark ? .018 : .026),
      child: saveContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final media = MediaQuery.of(context);
    final dark = context.isDark;
    final pageBody = SafeArea(
        bottom: false,
        child: Stack(children: [
          Form(
              key: formKey,
              child: PageFrame(
                  padding:
                      const EdgeInsets.fromLTRB(kPagePad, 72, kPagePad, 120),
                  children: [
                    Text(
                        widget.initial == null
                            ? tr('wish.titleNew')
                            : tr('wish.titleEdit'),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.normal)),
                    const SizedBox(height: 12),
                    AppCard(
                        child: Column(children: [
                      GestureDetector(
                          onTap: () => pickValoraIcon(context, icon,
                              onChanged: () => setState(() {})),
                          child: EditableIconPreview(
                              controller: icon,
                              onChanged: () => setState(() {}))),
                      const SizedBox(height: 8),
                      CoverImportBar(
                        onPickCover: pickNativeCover,
                        onCutoutCover: cutoutCoverIntoForm,
                        onFramedCover: framedCoverIntoForm,
                        onTraceCover: traceCoverIntoForm,
                      ),
                      const SizedBox(height: 8),
                      AppField(
                          controller: name,
                          label: tr('wish.name'),
                          requiredField: true),
                      const SizedBox(height: 12),
                      AppField(
                          controller: price,
                          label: tr('wish.expectedPrice'),
                          number: true,
                          requiredField: true),
                      const SizedBox(height: 12),
                      RoundedSelectField<String?>(
                        label: tr('compose.category'),
                        value: categoryId,
                        options: [
                          SelectOption<String?>(
                              value: null,
                              label: tr('common.uncategorized'),
                              iconText: '📦'),
                          ...store.categories.map((c) => SelectOption<String?>(
                              value: c.id,
                              label: store.categoryName(c.id),
                              iconText: c.icon))
                        ],
                        onChanged: (v) => setState(() => categoryId = v),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => showSmartCategoryCreateSheet(context,
                              initialName: name.text,
                              onCreated: (id) =>
                                  setState(() => categoryId = id)),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: Text(tr('compose.smartNewCategory')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppField(controller: tagsText, label: tr('compose.tags')),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                              onPressed: editTags,
                              icon: const Icon(Icons.sell_rounded),
                              label: Text(tr('compose.selectExistingTags')))),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: note,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                              labelText: tr('wish.purchaseReason'))),
                      SwitchListTile(
                          value: archived,
                          onChanged: (v) {
                            tapHaptic();
                            setState(() => archived = v);
                          },
                          title: Text(tr('wish.archive'))),
                    ])),
                  ])),
          GlobalBackButton(onTap: () => Navigator.pop(context)),
        ]));

    final useLiquidGlass =
        context.store.settings.glassEffectMode == GlassEffectMode.liquid;
    final saveContent = ValoraGlassSaveContent(
      label: tr('wish.save'),
      icon: Icons.check_rounded,
      onPressed: () async {
        mediumHaptic();
        await saveWish();
      },
      onPressChanged: (v) => setState(() => _wishSavePressed = v),
    );
    final saveWidth = media.size.width - 32;
    if (!useLiquidGlass) {
      return GradientScaffold(
        child: Stack(children: [
          pageBody,
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + media.padding.bottom,
            height: 58,
            child: ValoraLiquidGlassSurface(
              height: 58,
              radius: 999,
              tintOpacity: .16,
              blurSigma: .52,
              child: saveContent,
            ),
          ),
        ]),
      );
    }

    return GradientScaffold(
      child: lge.LiquidGlassView(
        realTimeCapture: true,
        useSync: true,
        refreshRate: lge.LiquidGlassRefreshRate.deviceRefreshRate,
        pixelRatio: _wishSavePressed ? .84 : .92,
        backgroundWidget:
            ValoraGlassSceneBackground(child: RepaintBoundary(child: pageBody)),
        children: [
          _buildWishSaveGlass(saveContent, media, saveWidth, dark),
        ],
      ),
    );
  }

  Future<void> pickNativeCover() async {
    lightHaptic();
    final uri = await NativeBridge.pickImage();
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('wish.coverSet'));
  }

  Future<void> framedCoverIntoForm() async {
    mediumHaptic();
    final uri = await createFramedCoverFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('compose.framedCoverGenerated'));
  }

  Future<void> traceCoverIntoForm() async {
    mediumHaptic();
    final uri = await createManualTraceStickerFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('compose.traceCoverGenerated'));
  }

  void editTags() {
    final ctl = TextEditingController(text: tagsText.text);
    final store = context.store;

    void toggleLocalTag(String tag) {
      final parts = splitTags(ctl.text);
      if (parts.contains(tag)) {
        parts.remove(tag);
      } else {
        parts.add(tag);
      }
      ctl.text = parts.join('、');
    }

    appSheet(context,
        title: tr('compose.tags'), subtitle: tr('compose.tagsSubtitle'),
        child: StatefulBuilder(builder: (context, setLocal) {
      final presets = ['通勤', '办公', '学习', '收藏', '吃灰', '维修', '配件', '长期持有'];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
            controller: ctl,
            autofocus: true,
            decoration: InputDecoration(hintText: tr('compose.tagsHint'))),
        const SizedBox(height: 12),
        SectionLabel(tr('compose.commonTags')),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((t) {
              final label = tl(t);
              final selected = splitTags(ctl.text).contains(label);
              return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setLocal(() => toggleLocalTag(label)));
            }).toList()),
        if (store.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionLabel(tr('compose.existingTags')),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.tags
                  .map((tag) => FilterChip(
                        avatar: CircleAvatar(
                            radius: 8, backgroundColor: parseColor(tag.color)),
                        label: Text(tag.name),
                        selected: splitTags(ctl.text).contains(tag.name),
                        onSelected: (_) =>
                            setLocal(() => toggleLocalTag(tag.name)),
                      ))
                  .toList()),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showSmartTagCreateSheet(context,
              initialName: ctl.text.trim(),
              onCreated: (label) => setLocal(() => toggleLocalTag(label))),
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('compose.newTag')),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton(
              onPressed: () => setLocal(() => ctl.clear()),
              child: Text(tr('common.clear'))),
          const SizedBox(width: 8),
          Expanded(
              child: FilledButton(
                  onPressed: () {
                    setState(() => tagsText.text = ctl.text.trim());
                    Navigator.pop(context);
                  },
                  child: Text(tr('common.done')))),
        ]),
      ]);
    }));
  }

  Future<void> cutoutCoverIntoForm() async {
    mediumHaptic();
    final payload = await NativeBridge.cutoutImageFromPickerDetailed();
    final uri = mounted ? await chooseStickerCandidate(context, payload) : null;
    if (uri == null || uri.trim().isEmpty) {
      if (mounted) showNativeSnack(context, tr('wish.noStickerGenerated'));
      return;
    }
    setState(() => icon.text = uri);
    final count = payload['candidates'] is List
        ? (payload['candidates'] as List).length
        : 0;
    if (mounted)
      showNativeSnack(
          context,
          count > 1
              ? tr('wish.cutoutSelectedFromN').replaceAll('{n}', '$count')
              : tr('wish.stickerCoverGenerated'));
  }

  Future<void> saveWish() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final store = context.store;
    final now = DateTime.now();
    final tagIds = await ensureTags(store, splitTags(tagsText.text), now);
    await store.upsertWish(Wish(
        id: widget.initial?.id ?? newId('wish'),
        name: name.text.trim(),
        iconValue: icon.text.trim().isEmpty ? '✨' : icon.text.trim(),
        expectedPrice: asDouble(price.text),
        note: note.text.trim(),
        categoryId: categoryId,
        tagIds: tagIds,
        archived: archived,
        convertedAt: widget.initial?.convertedAt,
        convertedAssetId: widget.initial?.convertedAssetId,
        addons: widget.initial?.addons ?? [],
        createdAt: widget.initial?.createdAt ?? now,
        updatedAt: now));
    if (!mounted) return;
    Navigator.pop(context);
  }
}
