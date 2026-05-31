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
  late TargetMode targetMode;
  late bool includeInTotal;
  late bool includeInDailyCost;
  final List<AddonItem> addons = [];

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    name = TextEditingController(text: item?.name ?? '');
    icon = TextEditingController(text: item?.iconValue ?? '📦');
    price = TextEditingController(
      text: item == null ? '' : item.price.toStringAsFixed(0),
    );
    purchaseDate = TextEditingController(
      text: dateText(item?.purchaseDate ?? DateTime.now()),
    );
    soldPrice = TextEditingController(
      text: item?.soldPrice?.toStringAsFixed(0) ?? '',
    );
    retiredAt = TextEditingController(
      text: item?.retiredAt == null ? '' : dateText(item!.retiredAt!),
    );
    soldAt = TextEditingController(
      text: item?.soldAt == null ? '' : dateText(item!.soldAt!),
    );
    targetDaily = TextEditingController(
      text: item?.targetDailyCost?.toStringAsFixed(0) ?? '',
    );
    targetDate = TextEditingController(
      text: item?.targetDate == null ? '' : dateText(item!.targetDate!),
    );
    targetDays = TextEditingController(
      text: item?.targetCustomDays?.toString() ?? '',
    );
    expiresAt = TextEditingController(
      text: item?.expiresAt == null ? '' : dateText(item!.expiresAt!),
    );
    remindDays = TextEditingController(
      text: item?.remindBeforeDays?.toString() ?? '',
    );
    tagsText = TextEditingController(
      text: item?.tagIds.map((id) => '').join('') ?? '',
    );
    note = TextEditingController(text: item?.note ?? '');
    categoryId = item?.categoryId;
    status = item?.status ?? AssetStatus.serving;
    targetMode = item?.targetMode ?? TargetMode.none;
    includeInTotal = item?.includeInTotal ?? true;
    includeInDailyCost = item?.includeInDailyCost ?? true;
    addons.addAll(item?.addons ?? []);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final item = widget.initial;
    if (tagsText.text.isEmpty && item != null) {
      tagsText.text = item.tagIds
          .map((id) => context.store.tagById(id)?.name ?? id)
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
      note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initial != null;
    final store = context.store;
    return GradientScaffold(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: PageFrame(
                padding: const EdgeInsets.fromLTRB(kPagePad, 72, kPagePad, 120),
                children: [
                  Text(
                    editing ? '编辑资产' : '新增资产',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: EditableIconPreview(
                      controller: icon,
                      onChanged: () => setState(() {}),
                    ),
                  ),
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
                    child: Column(
                      children: [
                        AppField(
                          controller: name,
                          label: '资产名称',
                          requiredField: true,
                        ),
                        const SizedBox(height: 12),
                        RoundedSelectField<String?>(
                          label: '分类',
                          value: categoryId,
                          options: [
                            const SelectOption<String?>(
                              value: null,
                              label: '未分类',
                              iconText: '📦',
                            ),
                            ...store.categories.map(
                              (c) => SelectOption<String?>(
                                value: c.id,
                                label: c.name,
                                iconText: c.icon,
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => categoryId = v),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => showSmartCategoryCreateSheet(
                              context,
                              initialName: name.text,
                              onCreated: (id) =>
                                  setState(() => categoryId = id),
                            ),
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            label: const Text('智能新增分类'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppField(
                                controller: price,
                                label: '买入价',
                                number: true,
                                requiredField: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DateFormField(
                                controller: purchaseDate,
                                label: '购买日期',
                                requiredField: true,
                                onChanged: () => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        RoundedSelectField<AssetStatus>(
                          label: '状态',
                          value: status,
                          options: AssetStatus.values
                              .map(
                                (e) => SelectOption<AssetStatus>(
                                  value: e,
                                  label: e.label,
                                  iconText: e == AssetStatus.serving
                                      ? '🟢'
                                      : e == AssetStatus.retired
                                      ? '🟡'
                                      : '⚪',
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => status = v),
                        ),
                        if (status == AssetStatus.retired) ...[
                          const SizedBox(height: 12),
                          DateFormField(
                            controller: retiredAt,
                            label: '退役日期',
                            onChanged: () => setState(() {}),
                          ),
                        ],
                        if (status == AssetStatus.sold) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DateFormField(
                                  controller: soldAt,
                                  label: '卖出日期',
                                  onChanged: () => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppField(
                                  controller: soldPrice,
                                  label: '卖出价',
                                  number: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        AppField(controller: tagsText, label: '标签，用顿号或逗号分隔'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: editTags,
                            icon: const Icon(Icons.sell_rounded),
                            label: const Text('选择已有标签'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: note,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(labelText: '备注'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '目标与提醒',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RoundedSelectField<TargetMode>(
                          label: '目标模式',
                          value: targetMode,
                          options: TargetMode.values
                              .map(
                                (e) => SelectOption<TargetMode>(
                                  value: e,
                                  label: e.label,
                                  iconText: e == TargetMode.none
                                      ? '—'
                                      : e == TargetMode.daily
                                      ? '🎯'
                                      : e == TargetMode.date
                                      ? '📅'
                                      : '✍️',
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => targetMode = v),
                        ),
                        const SizedBox(height: 12),
                        if (targetMode == TargetMode.daily)
                          AppField(
                            controller: targetDaily,
                            label: '目标日均成本',
                            number: true,
                          ),
                        if (targetMode == TargetMode.date)
                          DateFormField(
                            controller: targetDate,
                            label: '目标日期',
                            onChanged: () => setState(() {}),
                          ),
                        if (targetMode == TargetMode.custom)
                          AppField(
                            controller: targetDays,
                            label: '目标天数',
                            number: true,
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DateFormField(
                                controller: expiresAt,
                                label: '到期日期',
                                onChanged: () => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppField(
                                controller: remindDays,
                                label: '提前提醒天数',
                                number: true,
                              ),
                            ),
                          ],
                        ),
                        SwitchListTile(
                          value: includeInTotal,
                          onChanged: (v) {
                            tapHaptic();
                            setState(() => includeInTotal = v);
                          },
                          title: const Text('计入总资产'),
                        ),
                        SwitchListTile(
                          value: includeInDailyCost,
                          onChanged: (v) {
                            tapHaptic();
                            setState(() => includeInDailyCost = v);
                          },
                          title: const Text('计入日均成本'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '附加项目',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                lightHaptic();
                                addAddon();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('添加'),
                            ),
                          ],
                        ),
                        if (addons.isEmpty)
                          const Text(
                            '例如保护壳、配件、维修费。',
                            style: TextStyle(color: kMuted),
                          ),
                        ...addons.map(
                          (a) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(a.name),
                            subtitle: Text(
                              '购买时间：${a.effectivePurchaseDateLabel(parseUserDateOrNull(purchaseDate.text) ?? DateTime.now())} · 计入总资产：${a.includeInTotal ? '是' : '否'} · 计入日均：${a.includeInDailyCost ? '是' : '否'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(money(a.price, store.settings)),
                                IconButton(
                                  tooltip: '编辑',
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => editAddon(a),
                                ),
                                IconButton(
                                  tooltip: '删除',
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => addons.removeWhere(
                                      (item) => item.id == a.id,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => editAddon(a),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GlobalBackButton(onTap: () => Navigator.pop(context)),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              child: FilledButton.icon(
                onPressed: () {
                  mediumHaptic();
                  saveAsset();
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(editing ? '保存修改' : '添加到资产清单'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickNativeCover() async {
    lightHaptic();
    final uri = await NativeBridge.pickImage();
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, '已设置真实封面');
  }

  Future<void> framedCoverIntoForm() async {
    mediumHaptic();
    final uri = await createFramedCoverFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, '已生成白框裁切封面');
  }

  Future<void> traceCoverIntoForm() async {
    mediumHaptic();
    final uri = await createManualTraceStickerFromPicker(context);
    if (uri == null || uri.trim().isEmpty) return;
    setState(() => icon.text = uri);
    if (mounted) showNativeSnack(context, '已生成手动勾勒贴纸');
  }

  Future<void> cutoutCoverIntoForm() async {
    mediumHaptic();
    final payload = await NativeBridge.cutoutImageFromPickerDetailed();
    final uri = mounted ? await chooseStickerCandidate(context, payload) : null;
    if (uri == null || uri.trim().isEmpty) {
      if (mounted) showNativeSnack(context, '没有生成可用的贴纸封面');
      return;
    }
    setState(() => icon.text = uri);
    final count = payload['candidates'] is List
        ? (payload['candidates'] as List).length
        : 0;
    if (mounted)
      showNativeSnack(
        context,
        count > 1 ? '已从 ${count} 个候选中选中贴纸封面' : '已生成 AI 贴纸封面',
      );
  }

  Future<void> scanBarcodeIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.scanBarcodeFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, '未识别到条码 / 二维码');
      return;
    }
    final value = (data['displayValue'] ?? data['rawValue'] ?? '')
        .toString()
        .trim();
    setState(() {
      if (name.text.trim().isEmpty && value.isNotEmpty)
        name.text = value.take(32);
      tagsText.text = appendTagText(tagsText.text, '扫码');
      note.text = appendLine(note.text, '条码/二维码：$value');
    });
    if (mounted) showNativeSnack(context, '已把扫码结果写入编辑表单');
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

    appSheet(
      context,
      title: '标签',
      subtitle: '点击即可选择/取消；也可以新增标签并自动加入。',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          final presets = ['通勤', '办公', '学习', '收藏', '吃灰', '维修', '配件', '长期持有'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctl,
                autofocus: true,
                decoration: const InputDecoration(hintText: '例如：生产力、通勤、吃灰'),
              ),
              const SizedBox(height: 12),
              const SectionLabel('常用标签'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((t) {
                  final selected = splitTags(ctl.text).contains(t);
                  return FilterChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (_) => setLocal(() => toggleLocalTag(t)),
                  );
                }).toList(),
              ),
              if (store.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                const SectionLabel('已有标签'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: store.tags
                      .map(
                        (tag) => FilterChip(
                          avatar: CircleAvatar(
                            radius: 8,
                            backgroundColor: parseColor(tag.color),
                          ),
                          label: Text(tag.name),
                          selected: splitTags(ctl.text).contains(tag.name),
                          onSelected: (_) =>
                              setLocal(() => toggleLocalTag(tag.name)),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => showSmartTagCreateSheet(
                  context,
                  initialName: ctl.text.trim(),
                  onCreated: (label) => setLocal(() => toggleLocalTag(label)),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('新增标签'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setLocal(() => ctl.clear()),
                    child: const Text('清空'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() => tagsText.text = ctl.text.trim());
                        Navigator.pop(context);
                      },
                      child: const Text('完成'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> ocrReceiptIntoForm() async {
    mediumHaptic();
    final data = nativeJsonMap(await NativeBridge.recognizeReceiptFromImage());
    if (data['found'] != true) {
      if (mounted) showNativeSnack(context, '没有识别到清晰文字');
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
      tagsText.text = appendTagText(tagsText.text, '小票OCR');
      note.text = appendLine(note.text, 'OCR识别：\n${fullText.take(500)}');
    });
    if (mounted)
      showNativeSnack(
        context,
        priceText.isEmpty ? 'OCR 已写入备注' : 'OCR 已回填价格：$priceText',
      );
  }

  void addAddon() => editAddon(null);

  void editAddon(AddonItem? existing) {
    final parentDate = parseUserDateOrNull(purchaseDate.text) ?? DateTime.now();
    final nameCtl = TextEditingController(text: existing?.name ?? '');
    final priceCtl = TextEditingController(
      text: existing == null
          ? ''
          : existing.price.toStringAsFixed(
              existing.price.truncateToDouble() == existing.price ? 0 : 2,
            ),
    );
    final dateCtl = TextEditingController(
      text: existing?.purchaseDate == null
          ? ''
          : dateText(existing!.purchaseDate!),
    );
    bool followParent = existing?.followParentPurchaseDate ?? true;
    bool inTotal = existing?.includeInTotal ?? true;
    bool inDaily = existing?.includeInDailyCost ?? true;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(existing == null ? '添加附加项目' : '编辑附加项目'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: '价格'),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: followParent,
                  onChanged: (v) {
                    tapHaptic();
                    setLocal(() => followParent = v);
                  },
                  title: const Text('购买时间跟随父资产'),
                  subtitle: Text('父资产购买时间：${dateText(parentDate)}'),
                ),
                if (!followParent)
                  DateFormField(
                    controller: dateCtl,
                    label: '附加项目购买时间',
                    onChanged: () => setLocal(() {}),
                  ),
                SwitchListTile(
                  value: inTotal,
                  onChanged: (v) {
                    tapHaptic();
                    setLocal(() => inTotal = v);
                  },
                  title: const Text('计入总资产'),
                ),
                SwitchListTile(
                  value: inDaily,
                  onChanged: (v) {
                    tapHaptic();
                    setLocal(() => inDaily = v);
                  },
                  title: const Text('计入日均成本'),
                ),
              ],
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () {
                  setState(
                    () => addons.removeWhere((a) => a.id == existing.id),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('删除'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final parsedDate = followParent || dateCtl.text.trim().isEmpty
                    ? null
                    : parseUserDateOrNull(dateCtl.text);
                if (!followParent &&
                    dateCtl.text.trim().isNotEmpty &&
                    parsedDate == null) {
                  showNativeSnack(context, '附加项目购买时间格式不正确');
                  return;
                }
                final next = AddonItem(
                  id: existing?.id ?? newId('addon'),
                  name: nameCtl.text.trim().isEmpty
                      ? '附加项目'
                      : nameCtl.text.trim(),
                  price: asDouble(priceCtl.text),
                  purchaseDate: parsedDate,
                  followParentPurchaseDate: followParent,
                  includeInTotal: inTotal,
                  includeInDailyCost: inDaily,
                );
                setState(() {
                  final index = addons.indexWhere((a) => a.id == next.id);
                  if (index >= 0) {
                    addons[index] = next;
                  } else {
                    addons.add(next);
                  }
                });
                Navigator.pop(dialogContext);
              },
              child: Text(existing == null ? '添加' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveAsset() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final parsedPurchaseDate = parseUserDateOrNull(purchaseDate.text);
    if (parsedPurchaseDate == null) {
      showNativeSnack(context, '购买日期格式不正确，请重新选择或输入');
      return;
    }
    final parsedRetiredAt = parseOptionalUserDate(retiredAt.text);
    final parsedSoldAt = parseOptionalUserDate(soldAt.text);
    final parsedTargetDate = parseOptionalUserDate(targetDate.text);
    final parsedExpiresAt = parseOptionalUserDate(expiresAt.text);
    final now = DateTime.now();
    final store = context.store;
    final enteredTags = splitTags(tagsText.text);
    final tagIds = <String>[];
    for (final name in enteredTags) {
      final existed = store.tags
          .where((t) => t.name == name || t.id == name)
          .firstOrNull;
      if (existed != null) {
        tagIds.add(existed.id);
      } else {
        final tag = Tag(
          id: newId('tag'),
          name: name,
          color: '#7cc6f2',
          sortOrder: store.tags.length,
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        );
        store.upsertTag(tag);
        tagIds.add(tag.id);
      }
    }
    final item = Asset(
      id: widget.initial?.id ?? newId('asset'),
      name: name.text.trim().isEmpty ? '未命名资产' : name.text.trim(),
      iconValue: icon.text.trim().isEmpty ? '📦' : icon.text.trim(),
      price: asDouble(price.text),
      purchaseDate: parsedPurchaseDate,
      categoryId: categoryId,
      tagIds: tagIds,
      addons: List.of(addons),
      note: note.text.trim(),
      status: status,
      includeInTotal: includeInTotal,
      includeInDailyCost: includeInDailyCost,
      retiredAt: retiredAt.text.trim().isEmpty ? null : parsedRetiredAt,
      soldAt: soldAt.text.trim().isEmpty ? null : parsedSoldAt,
      soldPrice: soldPrice.text.trim().isEmpty
          ? null
          : asDouble(soldPrice.text),
      targetMode: targetMode,
      targetDailyCost: targetDaily.text.trim().isEmpty
          ? null
          : asDouble(targetDaily.text),
      targetDate: targetDate.text.trim().isEmpty ? null : parsedTargetDate,
      targetCustomDays: targetDays.text.trim().isEmpty
          ? null
          : asInt(targetDays.text),
      expiresAt: expiresAt.text.trim().isEmpty ? null : parsedExpiresAt,
      remindBeforeDays: remindDays.text.trim().isEmpty
          ? null
          : asInt(remindDays.text),
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
  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.number = false,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    validator: requiredField
        ? (v) => (v == null || v.trim().isEmpty) ? '必填' : null
        : null,
    decoration: InputDecoration(labelText: label),
  );
}

enum ComposeTab { asset, wish }
