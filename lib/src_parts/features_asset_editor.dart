part of '../main.dart';

class AssetEditorPage extends StatefulWidget {
  final Asset? initial;
  const AssetEditorPage({super.key, this.initial});
  @override
  State<AssetEditorPage> createState() => _AssetEditorPageState();
}

class _AssetEditorPageState extends State<AssetEditorPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController name,
      icon,
      price,
      purchaseDate,
      soldPrice,
      retiredAt,
      soldAt,
      targetDaily,
      targetDate,
      targetDays,
      expiresAt,
      remindDays,
      tagsText,
      note;
  late String? categoryId;
  late AssetStatus status;
  late AssetValueMode valueMode;
  late TargetMode targetMode;
  late bool includeInTotal;
  late bool includeInDailyCost;
  final List<AddonItem> addons = [];
  bool _savePressed = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    name = TextEditingController(text: item?.name ?? '');
    icon = TextEditingController(text: item?.iconValue ?? '📦');
    price = TextEditingController(
        text: item == null || item.isPriceless
            ? ''
            : item.price.toStringAsFixed(0));
    purchaseDate = TextEditingController(
        text: dateText(item?.purchaseDate ?? DateTime.now()));
    soldPrice =
        TextEditingController(text: item?.soldPrice?.toStringAsFixed(0) ?? '');
    retiredAt = TextEditingController(
        text: item?.retiredAt == null ? '' : dateText(item!.retiredAt!));
    soldAt = TextEditingController(
        text: item?.soldAt == null ? '' : dateText(item!.soldAt!));
    targetDaily = TextEditingController(
        text: item?.targetDailyCost?.toStringAsFixed(0) ?? '');
    targetDate = TextEditingController(
        text: item?.targetDate == null ? '' : dateText(item!.targetDate!));
    targetDays =
        TextEditingController(text: item?.targetCustomDays?.toString() ?? '');
    expiresAt = TextEditingController(
        text: item?.expiresAt == null ? '' : dateText(item!.expiresAt!));
    remindDays =
        TextEditingController(text: item?.remindBeforeDays?.toString() ?? '');
    tagsText = TextEditingController(
        text: item?.tagIds.map((id) => '').join('') ?? '');
    note = TextEditingController(text: item?.note ?? '');
    categoryId = item?.categoryId;
    status = item?.status ?? AssetStatus.serving;
    valueMode = item?.valueMode ?? AssetValueMode.priced;
    targetMode = item?.targetMode ?? TargetMode.none;
    if (valueMode == AssetValueMode.priceless && targetMode == TargetMode.daily)
      targetMode = TargetMode.none;
    includeInTotal = item?.includeInTotal ?? true;
    includeInDailyCost = item?.includeInDailyCost ?? true;
    if (valueMode == AssetValueMode.priceless) {
      includeInTotal = false;
      includeInDailyCost = false;
    }
    addons.addAll(item?.addons ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final item = widget.initial;
    if (tagsText.text.isEmpty && item != null) {
      tagsText.text = item.tagIds
          .map((id) => context.store.tagName(id))
          .join('、');
    }
  }

  @override
  void dispose() {
    for (final c in [
      name,
      icon,
      price,
      purchaseDate,
      soldPrice,
      retiredAt,
      soldAt,
      targetDaily,
      targetDate,
      targetDays,
      expiresAt,
      remindDays,
      tagsText,
      note
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  lge.LiquidGlass _buildAssetEditorSaveGlass(
      Widget saveContent, MediaQueryData media, double saveWidth, bool dark) {
    final spring = _savePressed ? 1.0 : 0.0;
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
    final editing = widget.initial != null;
    final store = context.store;
    final media = MediaQuery.of(context);
    final dark = context.isDark;
    final priceless = valueMode == AssetValueMode.priceless;
    final statusOptions = (priceless
            ? const [AssetStatus.serving, AssetStatus.retired]
            : AssetStatus.values)
        .map((e) => SelectOption<AssetStatus>(
            value: e,
            label: e.localizedLabel,
            iconText: e == AssetStatus.serving
                ? '🟢'
                : e == AssetStatus.retired
                    ? '🟡'
                    : '⚪'))
        .toList();
    final targetOptions = (priceless
            ? TargetMode.values.where((e) => e != TargetMode.daily)
            : TargetMode.values)
        .map((e) => SelectOption<TargetMode>(
            value: e,
            label: e.localizedLabel,
            iconText: e == TargetMode.none
                ? '—'
                : e == TargetMode.daily
                    ? '🎯'
                    : e == TargetMode.date
                        ? '📅'
                        : '✍️'))
        .toList();
    final pageBody = SafeArea(
      bottom: false,
      child: Stack(children: [
        Form(
          key: formKey,
          child: PageFrame(
              padding: const EdgeInsets.fromLTRB(kPagePad, 72, kPagePad, 120),
              children: [
                Text(editing ? tr('editor.editAsset') : tr('editor.newAsset'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.normal)),
                const SizedBox(height: 12),
                Center(
                    child: EditableIconPreview(
                        controller: icon, onChanged: () => setState(() {}))),
                const SizedBox(height: 8),
                SmartAssetImportBar(
                  onPickCover: pickNativeCover,
                  onScanBarcode: scanBarcodeIntoForm,
                  onOcrReceipt: ocrReceiptIntoForm,
                  onCutoutCover: cutoutCoverIntoForm,
                  onFramedCover: framedCoverIntoForm,
                  onTraceCover: traceCoverIntoForm,
                ),
                const SizedBox(height: 10),
                AppCard(
                    child: Column(children: [
                  AppField(
                      controller: name, label: tr('editor.assetName'), requiredField: true),
                  const SizedBox(height: 12),
                  RoundedSelectField<String?>(
                    label: tr('editor.category'),
                    value: categoryId,
                    options: [
                      SelectOption<String?>(
                          value: null, label: tr('editor.uncategorized'), iconText: '📦'),
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
                          onCreated: (id) => setState(() => categoryId = id)),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: Text(tr('editor.smartNewCategory')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RoundedSelectField<AssetValueMode>(
                    label: tr('editor.valueMode'),
                    value: valueMode,
                    options: AssetValueMode.values
                        .map((e) => SelectOption<AssetValueMode>(
                            value: e,
                            label: e.localizedLabel,
                            iconText:
                                e == AssetValueMode.priceless ? '∞' : '¥'))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        valueMode = v;
                        if (valueMode == AssetValueMode.priceless) {
                          includeInTotal = false;
                          includeInDailyCost = false;
                          if (status == AssetStatus.sold)
                            status = AssetStatus.serving;
                          if (targetMode == TargetMode.daily)
                            targetMode = TargetMode.none;
                        } else if (widget.initial == null) {
                          includeInTotal = true;
                          includeInDailyCost = true;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: priceless
                          ? TextFormField(
                              key: const ValueKey('asset.price.priceless'),
                              initialValue: '∞',
                              readOnly: true,
                              decoration:
                                  InputDecoration(labelText: tr('editor.value')),
                            )
                          : AppField(
                              key: const ValueKey('asset.price.normal'),
                              controller: price,
                              label: tr('editor.buyPrice'),
                              number: true,
                              requiredField: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: DateFormField(
                            controller: purchaseDate,
                            label: priceless ? tr('editor.recordDate') : tr('editor.purchaseDate'),
                            requiredField: true,
                            onChanged: () => setState(() {}))),
                  ]),
                  const SizedBox(height: 12),
                  RoundedSelectField<AssetStatus>(
                    label: tr('editor.status'),
                    value: status,
                    options: statusOptions,
                    onChanged: (v) => setState(() => status = v),
                  ),
                  if (status == AssetStatus.retired) ...[
                    const SizedBox(height: 12),
                    DateFormField(
                        controller: retiredAt,
                        label: tr('editor.retiredDate'),
                        onChanged: () => setState(() {}))
                  ],
                  if (status == AssetStatus.sold) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: DateFormField(
                              controller: soldAt,
                              label: tr('editor.soldDate'),
                              onChanged: () => setState(() {}))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppField(
                              controller: soldPrice,
                              label: tr('editor.soldPrice'),
                              number: true))
                    ]),
                  ],
                  const SizedBox(height: 12),
                  AppField(controller: tagsText, label: tr('editor.tagsHint')),
                  const SizedBox(height: 8),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                          onPressed: editTags,
                          icon: const Icon(Icons.sell_rounded),
                          label: Text(tr('editor.selectExistingTags')))),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: note,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(labelText: tr('editor.note'))),
                ])),
                const SizedBox(height: 12),
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(tr('editor.targetsAndReminders'),
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18)),
                      const SizedBox(height: 12),
                      RoundedSelectField<TargetMode>(
                        label: tr('editor.targetMode'),
                        value: targetMode,
                        options: targetOptions,
                        onChanged: (v) => setState(() => targetMode = v),
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: targetMode == TargetMode.daily
                            ? AppField(
                                key: const ValueKey('target.daily'),
                                controller: targetDaily,
                                label: tr('editor.targetDailyCost'),
                                number: true)
                            : targetMode == TargetMode.date
                                ? DateFormField(
                                    key: const ValueKey('target.date'),
                                    controller: targetDate,
                                    label: tr('editor.targetDate'),
                                    onChanged: () => setState(() {}))
                                : targetMode == TargetMode.custom
                                    ? AppField(
                                        key: const ValueKey('target.custom'),
                                        controller: targetDays,
                                        label: tr('editor.targetDays'),
                                        number: true)
                                    : const SizedBox(
                                        key: ValueKey('target.none'),
                                        height: 0),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: DateFormField(
                                controller: expiresAt,
                                label: tr('editor.expiryDate'),
                                onChanged: () => setState(() {}))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: AppField(
                                controller: remindDays,
                                label: tr('editor.remindBeforeDays'),
                                number: true))
                      ]),
                      if (priceless)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
                          child: Text(tr('editor.pricelessNote'),
                              style: TextStyle(color: kMuted, height: 1.35)),
                        )
                      else ...[
                        SwitchListTile(
                            value: includeInTotal,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => includeInTotal = v);
                            },
                            title: Text(tr('editor.includeInTotal'))),
                        SwitchListTile(
                            value: includeInDailyCost,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => includeInDailyCost = v);
                            },
                            title: Text(tr('editor.includeInDailyCost'))),
                      ],
                    ])),
                const SizedBox(height: 12),
                if (!priceless)
                  AppCard(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(
                              child: Text(tr('editor.addons'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18))),
                          TextButton.icon(
                              onPressed: () {
                                lightHaptic();
                                addAddon();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: Text(tr('common.add')))
                        ]),
                        if (addons.isEmpty)
                          Text(tr('editor.addonHint'),
                              style: TextStyle(color: kMuted)),
                        ...addons.map((a) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(a.name),
                              subtitle: Text(
                                  '${tr('editor.addonPurchaseTime')}：${a.effectivePurchaseDateLabel(parseUserDateOrNull(purchaseDate.text) ?? DateTime.now())} · ${tr('editor.includeInTotal')}：${a.includeInTotal ? tr('common.yes') : tr('common.no')} · ${tr('editor.includeInDailyCost')}：${a.includeInDailyCost ? tr('common.yes') : tr('common.no')}'),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(money(a.price, store.settings)),
                                    ValoraGlassIconButton(
                                        tooltip: tr('common.edit'),
                                        icon: Icons.edit_rounded,
                                        size: 36,
                                        onTap: () => editAddon(a)),
                                    ValoraGlassIconButton(
                                        tooltip: tr('common.delete'),
                                        icon: Icons.delete_outline_rounded,
                                        size: 36,
                                        onTap: () => setState(() =>
                                            addons.removeWhere(
                                                (item) => item.id == a.id))),
                                  ]),
                              onTap: () => editAddon(a),
                            )),
                      ])),
              ]),
        ),
        GlobalBackButton(onTap: () => Navigator.pop(context)),
      ]),
    );

    final useLiquidGlass =
        context.store.settings.glassEffectMode == GlassEffectMode.liquid;
    final saveContent = ValoraGlassSaveContent(
      label: editing ? tr('editor.saveChanges') : tr('editor.addToAssets'),
      icon: Icons.check_rounded,
      onPressed: () {
        mediumHaptic();
        saveAsset();
      },
      onPressChanged: (v) => setState(() => _savePressed = v),
    );
    final saveWidth = media.size.width - 32;
    final saveScale = _savePressed ? 1.035 : 1.0;
    final saveGlassWidth = saveWidth * saveScale;
    final saveGlassHeight = 58.0 * saveScale;
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
        pixelRatio: _savePressed ? .84 : .92,
        backgroundWidget:
            ValoraGlassSceneBackground(child: RepaintBoundary(child: pageBody)),
        children: [
          _buildAssetEditorSaveGlass(saveContent, media, saveWidth, dark),
        ],
      ),
    );
  }

  Future<void> pickNativeCover() async {
    lightHaptic();
    final uri = await NativeBridge.pickImage();
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('editor.coverSet'));
  }

  Future<void> framedCoverIntoForm() async {
    mediumHaptic();
    final uri = await createFramedCoverFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('editor.framedCoverGenerated'));
  }

  Future<void> traceCoverIntoForm() async {
    mediumHaptic();
    final uri = await createManualTraceStickerFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, tr('editor.manualTraceGenerated'));
  }

  Future<void> cutoutCoverIntoForm() async {
    mediumHaptic();
    final payload = await NativeBridge.cutoutImageFromPickerDetailed();
    final uri = mounted ? await chooseStickerCandidate(context, payload) : null;
    if (uri == null || uri.trim().isEmpty) {
      if (mounted) showNativeSnack(context, tr('editor.noStickerGenerated'));
      return;
    }
    setState(() => icon.text = uri);
    final count = payload['candidates'] is List
        ? (payload['candidates'] as List).length
        : 0;
    if (mounted)
      showNativeSnack(
          context, count > 1 ? '${tr('editor.stickerSelectedFrom')} $count ${tr('editor.candidates')}' : tr('editor.aiStickerGenerated'));
  }

  Future<void> scanBarcodeIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.scanBarcodeFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, tr('editor.barcodeNotFound'));
      return;
    }
    final value =
        (data['displayValue'] ?? data['rawValue'] ?? '').toString().trim();
    setState(() {
      if (name.text.trim().isEmpty && value.isNotEmpty)
        name.text = value.take(32);
      tagsText.text = appendTagText(tagsText.text, tr('editor.tagScanned'));
      note.text = appendLine(note.text, '${tr('editor.barcodeLabel')}：$value');
    });
    if (mounted) showNativeSnack(context, tr('editor.barcodeApplied'));
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

    appSheet(context, title: tr('editor.tagsTitle'), subtitle: tr('editor.tagsSubtitle'),
        child: StatefulBuilder(builder: (context, setLocal) {
      final presets = [tr('tag.commute'), tr('tag.office'), tr('tag.study'), tr('tag.collection'), tr('tag.dusty'), tr('tag.repair'), tr('tag.accessory'), tr('tag.longTerm')];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
            controller: ctl,
            autofocus: true,
            decoration: InputDecoration(hintText: tr('editor.tagHint'))),
        const SizedBox(height: 12),
        SectionLabel(tr('editor.presetTags')),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((t) {
              final selected = splitTags(ctl.text).contains(t);
              return FilterChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) => setLocal(() => toggleLocalTag(t)));
            }).toList()),
        if (store.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionLabel(tr('editor.existingTags')),
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
          label: Text(tr('editor.newTag')),
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

  Future<void> ocrReceiptIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.recognizeReceiptFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, tr('editor.ocrNoText'));
      return;
    }
    final priceText = (data['priceCandidate'] ?? '').toString();
    final dateTextValue = (data['dateCandidate'] ?? '').toString();
    final titleText = (data['nameCandidate'] ?? '').toString();
    final fullText = (data['fullText'] ?? '').toString();
    setState(() {
      if (price.text.trim().isEmpty && priceText.isNotEmpty)
        price.text = priceText;
      if (purchaseDate.text.trim().isEmpty && dateTextValue.isNotEmpty)
        purchaseDate.text = dateTextValue;
      if (name.text.trim().isEmpty && titleText.isNotEmpty)
        name.text = titleText.take(24);
      tagsText.text = appendTagText(tagsText.text, tr('editor.tagReceiptOcr'));
      note.text = appendLine(note.text, '${tr('editor.ocrLabel')}：\n${fullText.take(500)}');
    });
    if (mounted)
      showNativeSnack(
          context, priceText.isEmpty ? tr('editor.ocrWrittenToNote') : '${tr('editor.ocrPriceFilled')}：$priceText');
  }

  void addAddon() => editAddon(null);

  void editAddon(AddonItem? existing) {
    final parentDate = parseUserDateOrNull(purchaseDate.text) ?? DateTime.now();
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final priceCtl = TextEditingController(
        text: existing == null
            ? ''
            : existing.price.toStringAsFixed(
                existing.price.truncateToDouble() == existing.price ? 0 : 2));
    final dateCtl = TextEditingController(
        text: existing?.purchaseDate == null
            ? ''
            : dateText(existing!.purchaseDate!));
    bool followParent = existing?.followParentPurchaseDate ?? true;
    bool inTotal = existing?.includeInTotal ?? true;
    bool inDaily = existing?.includeInDailyCost ?? true;
    showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (context, setLocal) => AlertDialog(
                  title: Text(existing == null ? tr('editor.addAddon') : tr('editor.editAddon')),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: nameCtl,
                        decoration: InputDecoration(labelText: tr('editor.addonName'))),
                    const SizedBox(height: 10),
                    TextField(
                        controller: priceCtl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(labelText: tr('editor.addonPrice'))),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      value: followParent,
                      onChanged: (v) {
                        tapHaptic();
                        setLocal(() => followParent = v);
                      },
                      title: Text(tr('editor.followParentDate')),
                      subtitle: Text('${tr('editor.parentPurchaseTime')}：${dateText(parentDate)}'),
                    ),
                    if (!followParent)
                      DateFormField(
                          controller: dateCtl,
                          label: tr('editor.addonPurchaseDate'),
                          onChanged: () => setLocal(() {})),
                    SwitchListTile(
                        value: inTotal,
                        onChanged: (v) {
                          tapHaptic();
                          setLocal(() => inTotal = v);
                        },
                        title: Text(tr('editor.includeInTotal'))),
                    SwitchListTile(
                        value: inDaily,
                        onChanged: (v) {
                          tapHaptic();
                          setLocal(() => inDaily = v);
                        },
                        title: Text(tr('editor.includeInDailyCost'))),
                  ])),
                  actions: [
                    if (existing != null)
                      TextButton(
                          onPressed: () {
                            setState(() =>
                                addons.removeWhere((a) => a.id == existing.id));
                            Navigator.pop(dialogContext);
                          },
                          child: Text(tr('common.delete'))),
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(tr('common.cancel'))),
                    FilledButton(
                        onPressed: () {
                          final parsedDate =
                              followParent || dateCtl.text.trim().isEmpty
                                  ? null
                                  : parseUserDateOrNull(dateCtl.text);
                          if (!followParent &&
                              dateCtl.text.trim().isNotEmpty &&
                              parsedDate == null) {
                            showNativeSnack(context, tr('editor.invalidAddonDate'));
                            return;
                          }
                          final next = AddonItem(
                            id: existing?.id ?? newId('addon'),
                            name: nameCtl.text.trim().isEmpty
                                ? tr('editor.defaultAddonName')
                                : nameCtl.text.trim(),
                            price: asDouble(priceCtl.text),
                            purchaseDate: parsedDate,
                            followParentPurchaseDate: followParent,
                            includeInTotal: inTotal,
                            includeInDailyCost: inDaily,
                          );
                          setState(() {
                            final index =
                                addons.indexWhere((a) => a.id == next.id);
                            if (index >= 0) {
                              addons[index] = next;
                            } else {
                              addons.add(next);
                            }
                          });
                          Navigator.pop(dialogContext);
                        },
                        child: Text(existing == null ? tr('common.add') : tr('common.save'))),
                  ],
                )));
  }

  Future<void> saveAsset() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final parsedPurchaseDate = parseUserDateOrNull(purchaseDate.text);
    if (parsedPurchaseDate == null) {
      showNativeSnack(
          context,
          valueMode == AssetValueMode.priceless
              ? tr('editor.invalidRecordDate')
              : tr('editor.invalidPurchaseDate'));
      return;
    }
    final parsedRetiredAt = parseOptionalUserDate(retiredAt.text);
    final parsedSoldAt = parseOptionalUserDate(soldAt.text);
    final parsedTargetDate = parseOptionalUserDate(targetDate.text);
    final parsedExpiresAt = parseOptionalUserDate(expiresAt.text);
    final now = DateTime.now();
    final store = context.store;
    final savedStatus =
        valueMode == AssetValueMode.priceless && status == AssetStatus.sold
            ? AssetStatus.serving
            : status;
    final enteredTags = splitTags(tagsText.text);
    final tagIds = <String>[];
    for (final name in enteredTags) {
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
    final item = Asset(
      id: widget.initial?.id ?? newId('asset'),
      name: name.text.trim().isEmpty ? tr('editor.unnamedAsset') : name.text.trim(),
      iconValue: icon.text.trim().isEmpty ? '📦' : icon.text.trim(),
      valueMode: valueMode,
      price: valueMode == AssetValueMode.priceless ? 0 : asDouble(price.text),
      purchaseDate: parsedPurchaseDate,
      categoryId: categoryId,
      tagIds: tagIds,
      addons: valueMode == AssetValueMode.priceless ? [] : List.of(addons),
      note: note.text.trim(),
      status: savedStatus,
      includeInTotal:
          valueMode == AssetValueMode.priceless ? false : includeInTotal,
      includeInDailyCost:
          valueMode == AssetValueMode.priceless ? false : includeInDailyCost,
      retiredAt:
          savedStatus == AssetStatus.retired && retiredAt.text.trim().isNotEmpty
              ? parsedRetiredAt
              : null,
      soldAt: savedStatus == AssetStatus.sold && soldAt.text.trim().isNotEmpty
          ? parsedSoldAt
          : null,
      soldPrice:
          savedStatus == AssetStatus.sold && soldPrice.text.trim().isNotEmpty
              ? asDouble(soldPrice.text)
              : null,
      targetMode: valueMode == AssetValueMode.priceless &&
              targetMode == TargetMode.daily
          ? TargetMode.none
          : targetMode,
      targetDailyCost: valueMode == AssetValueMode.priceless ||
              targetDaily.text.trim().isEmpty
          ? null
          : asDouble(targetDaily.text),
      targetDate: targetDate.text.trim().isEmpty ? null : parsedTargetDate,
      targetCustomDays:
          targetDays.text.trim().isEmpty ? null : asInt(targetDays.text),
      expiresAt: expiresAt.text.trim().isEmpty ? null : parsedExpiresAt,
      remindBeforeDays:
          remindDays.text.trim().isEmpty ? null : asInt(remindDays.text),
      createdAt: widget.initial?.createdAt ?? now,
      updatedAt: now,
    );
    await store.upsertAsset(item);
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;
  final bool requiredField;
  const AppField(
      {super.key,
      required this.controller,
      required this.label,
      this.number = false,
      this.requiredField = false});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        validator: requiredField
            ? (v) => (v == null || v.trim().isEmpty) ? tr('common.required') : null
            : null,
        decoration: InputDecoration(labelText: label),
      );
}

enum ComposeTab { asset, wish }
