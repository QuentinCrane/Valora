part of '../main.dart';

class ComposePage extends StatefulWidget {
  final ComposeTab initialTab;
  final String? initialName;
  const ComposePage({super.key, required this.initialTab, this.initialName});
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
  TargetMode targetMode = TargetMode.none;
  bool includeInTotal = true;
  bool includeInDailyCost = true;
  bool retired = false;
  bool sold = false;
  bool reminder = false;
  final List<AddonItem> addons = [];

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
    name = TextEditingController(text: widget.initialName ?? '');
    icon = TextEditingController(
      text: widget.initialTab == ComposeTab.asset ? '📦' : '✨',
    );
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
      note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetMode = tab == ComposeTab.asset;
    return GradientScaffold(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  kPagePad,
                  66,
                  kPagePad,
                  104 + MediaQuery.paddingOf(context).bottom,
                ),
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
                          });
                        },
                      ),
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
                      ),
                    )
                  else
                    TutorialTargetAnchor(
                      id: 'compose.import',
                      child: CoverImportBar(
                        onPickCover: pickNativeCover,
                        onCutoutCover: cutoutCoverIntoForm,
                        onFramedCover: framedCoverIntoForm,
                        onTraceCover: traceCoverIntoForm,
                      ),
                    ),
                  const SizedBox(height: 8),
                  TutorialTargetAnchor(
                    id: 'compose.name',
                    child: TextFormField(
                      controller: name,
                      textAlign: TextAlign.center,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '请输入名称' : null,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        hintText: assetMode ? '请输入物品名称' : '请输入您的愿望',
                        hintStyle: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.normal,
                          color: kMuted.withOpacity(.38),
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TutorialTargetAnchor(
                    id: 'compose.price',
                    child: SoftFormCard(
                      child: FormLine(
                        icon: Icons.currency_yen_rounded,
                        label: assetMode ? '价格' : '预计价格',
                        trailing: SizedBox(
                          width: 140,
                          child: TextFormField(
                            controller: price,
                            textAlign: TextAlign.right,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? '必填' : null,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TutorialTargetAnchor(
                    id: 'compose.meta',
                    child: SoftFormCard(
                      child: Column(
                        children: [
                          if (assetMode)
                            FormLine(
                              icon: Icons.calendar_month_rounded,
                              label: '购买日期',
                              trailing: _PlainRightText(purchaseDate.text),
                              onTap: () => pickDate(purchaseDate),
                            ),
                          FormLine(
                            icon: Icons.category_rounded,
                            label: '类别',
                            trailing: _PlainRightText(
                              context.store.categoryName(categoryId),
                            ),
                            onTap: pickCategory,
                          ),
                          FormLine(
                            icon: Icons.sell_rounded,
                            label: '标签',
                            trailing: _PlainRightText(
                              tagsText.text.trim().isEmpty
                                  ? '未设置'
                                  : tagsText.text.trim(),
                            ),
                            onTap: editTags,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (assetMode) ...[
                    const SizedBox(height: 12),
                    TutorialTargetAnchor(
                      id: 'compose.target',
                      child: SoftFormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.track_changes_rounded, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  '日耗目标',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _TargetModeSwitch(
                              value: targetMode,
                              onChanged: (mode) {
                                selectionHaptic();
                                setState(() => targetMode = mode);
                              },
                            ),
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
                                        child: child,
                                      ),
                                    ),
                                child: KeyedSubtree(
                                  key: ValueKey(targetMode.name),
                                  child: _buildTargetModeFields(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TutorialTargetAnchor(
                    id: 'compose.addons',
                    child: SoftFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 22),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  '附加物品',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              SmallCaret(),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (addons.isNotEmpty)
                            ...addons.map(
                              (a) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  a.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '购买时间：${a.purchaseDateLabel}',
                                  style: const TextStyle(
                                    color: kMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  money(a.price, context.store.settings),
                                ),
                                onLongPress: () =>
                                    setState(() => addons.remove(a)),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: addAddon,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('添加物品'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftFormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.sticky_note_2_outlined, size: 22),
                            SizedBox(width: 12),
                            Text(
                              '备注',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: note,
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 200,
                          decoration: const InputDecoration(
                            hintText: '输入备注，最多200字',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
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
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: icon.text.trim().isEmpty
                                  ? const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: kMuted,
                                    )
                                  : valoraIconVisual(
                                      context,
                                      icon.text,
                                      emojiSize: 28,
                                      borderRadius: 18,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (assetMode) ...[
                    const SizedBox(height: 12),
                    SoftFormCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: !includeInTotal,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => includeInTotal = !v);
                            },
                            title: const Text(
                              '不计入总资产',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          SwitchListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: !includeInDailyCost,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => includeInDailyCost = !v);
                            },
                            title: const Text(
                              '不计入日均',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          SwitchListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: retired,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => retired = v);
                            },
                            title: const Text(
                              '已退役',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                          SwitchListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: sold,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => sold = v);
                            },
                            title: const Text(
                              '已卖出',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SoftFormCard(
                      child: Column(
                        children: [
                          FormLine(
                            icon: Icons.hourglass_empty_rounded,
                            label: '到期时间',
                            trailing: _PlainRightText(
                              expiresAt.text.trim().isEmpty
                                  ? '未设置'
                                  : expiresAt.text,
                            ),
                            onTap: () => pickDate(expiresAt),
                          ),
                          SwitchListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.zero,
                            value: reminder,
                            onChanged: (v) {
                              tapHaptic();
                              setState(() => reminder = v);
                            },
                            title: const Text(
                              '到期提醒',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  lightHaptic();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 96,
              right: 96,
              bottom: 18 + MediaQuery.paddingOf(context).bottom,
              child: TutorialTargetAnchor(
                id: 'compose.save',
                child: LiquidSaveButton(
                  label: '保存',
                  onPressed: () {
                    mediumHaptic();
                    save();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetModeFields() {
    switch (targetMode) {
      case TargetMode.none:
        return const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            '不设置目标时，资产仍会正常计算当前日耗。',
            style: TextStyle(color: kMuted, fontSize: 12.5, height: 1.35),
          ),
        );
      case TargetMode.daily:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: AppField(
            controller: targetDaily,
            label: '目标日耗 / 天',
            number: true,
          ),
        );
      case TargetMode.date:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DateFormField(
            controller: targetDate,
            label: '目标达成日期',
            onChanged: () => setState(() {}),
          ),
        );
      case TargetMode.custom:
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: AppField(
            controller: targetCustomDays,
            label: '目标使用天数',
            number: true,
          ),
        );
    }
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
    if (mounted) showNativeSnack(context, '已把扫码结果写入资产草稿');
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
      if (purchaseDate.text.trim().isEmpty ||
          purchaseDate.text == dateText(DateTime.now())) {
        if (dateTextValue.isNotEmpty) purchaseDate.text = dateTextValue;
      }
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

  void pickDate(TextEditingController controller) async {
    await pickAndroidOfficialDate(
      context,
      controller,
      onChanged: () => setState(() {}),
    );
  }

  void pickCategory() {
    appSheet(
      context,
      title: '选择类别',
      subtitle: '给资产或心愿放进一个轻分类；也可以直接新增分类。',
      child: Column(
        children: [
          ListTile(
            title: const Text('全部 / 未分类'),
            onTap: () {
              setState(() => categoryId = null);
              Navigator.pop(context);
            },
          ),
          ...context.store.categories.map(
            (c) => ListTile(
              leading: Text(c.icon, style: const TextStyle(fontSize: 24)),
              title: Text(c.name),
              trailing: categoryId == c.id
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                setState(() => categoryId = c.id);
                Navigator.pop(context);
              },
            ),
          ),
          const Divider(height: 20),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: const Text('智能新增分类'),
            subtitle: const Text('直接选择图标和颜色'),
            onTap: () => showSmartCategoryCreateSheet(
              context,
              initialName: name.text,
              onCreated: (id) {
                setState(() => categoryId = id);
              },
            ),
          ),
        ],
      ),
    );
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

  void addAddon() {
    final nameCtl = TextEditingController();
    final priceCtl = TextEditingController();
    final dateCtl = TextEditingController(text: dateText(DateTime.now()));
    appSheet(
      context,
      title: '添加附加物品',
      subtitle: '比如保护壳、收纳包、维修费等。',
      child: Column(
        children: [
          TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: '名称'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: priceCtl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '价格'),
          ),
          const SizedBox(height: 10),
          DateFormField(controller: dateCtl, label: '购买时间'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final parsedDate = dateCtl.text.trim().isEmpty
                    ? null
                    : parseUserDateOrNull(dateCtl.text);
                if (dateCtl.text.trim().isNotEmpty && parsedDate == null) {
                  showNativeSnack(context, '附加物品购买时间格式不正确');
                  return;
                }
                setState(
                  () => addons.add(
                    AddonItem(
                      id: newId('addon'),
                      name: nameCtl.text.trim().isEmpty
                          ? '附加物品'
                          : nameCtl.text.trim(),
                      price: asDouble(priceCtl.text),
                      purchaseDate: parsedDate,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final parsedPurchaseDate = parseUserDateOrNull(purchaseDate.text);
    final parsedExpiresAt = parseOptionalUserDate(expiresAt.text);
    final parsedTargetDate = parseOptionalUserDate(targetDate.text);
    final parsedTargetCustomDays = targetCustomDays.text.trim().isEmpty
        ? null
        : asInt(targetCustomDays.text);
    if (tab == ComposeTab.asset && parsedPurchaseDate == null) {
      showNativeSnack(context, '购买日期格式不正确，请重新选择或输入');
      return;
    }
    if (tab == ComposeTab.asset &&
        targetMode == TargetMode.daily &&
        (targetDaily.text.trim().isEmpty || asDouble(targetDaily.text) <= 0)) {
      showNativeSnack(context, '目标日耗需要大于 0');
      return;
    }
    if (tab == ComposeTab.asset &&
        targetMode == TargetMode.date &&
        (targetDate.text.trim().isEmpty || parsedTargetDate == null)) {
      showNativeSnack(context, '请为“按周期”选择目标达成日期');
      return;
    }
    if (tab == ComposeTab.asset &&
        targetMode == TargetMode.custom &&
        (parsedTargetCustomDays == null || parsedTargetCustomDays <= 0)) {
      showNativeSnack(context, '请为“自定义”填写大于 0 的目标天数');
      return;
    }
    final store = context.store;
    final now = DateTime.now();
    final tagIds = ensureTags(store, splitTags(tagsText.text), now);
    if (tab == ComposeTab.asset) {
      final status = sold
          ? AssetStatus.sold
          : retired
          ? AssetStatus.retired
          : AssetStatus.serving;
      await store.upsertAsset(
        Asset(
          id: newId('asset'),
          name: name.text.trim(),
          iconValue: icon.text.trim().isEmpty ? '📦' : icon.text.trim(),
          price: asDouble(price.text),
          purchaseDate: parsedPurchaseDate ?? dateOnly(now),
          categoryId: categoryId,
          tagIds: tagIds,
          addons: List.of(addons),
          note: note.text.trim(),
          status: status,
          includeInTotal: includeInTotal,
          includeInDailyCost: includeInDailyCost,
          retiredAt: retired ? DateTime.now() : null,
          soldAt: sold ? DateTime.now() : null,
          soldPrice: null,
          targetMode: targetMode,
          targetDailyCost:
              targetMode == TargetMode.daily &&
                  targetDaily.text.trim().isNotEmpty
              ? asDouble(targetDaily.text)
              : null,
          targetDate: targetMode == TargetMode.date ? parsedTargetDate : null,
          targetCustomDays: targetMode == TargetMode.custom
              ? parsedTargetCustomDays
              : null,
          expiresAt: expiresAt.text.trim().isEmpty ? null : parsedExpiresAt,
          remindBeforeDays: reminder ? 7 : null,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await store.upsertWish(
        Wish(
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
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _TargetModeSwitch extends StatelessWidget {
  final TargetMode value;
  final ValueChanged<TargetMode> onChanged;
  const _TargetModeSwitch({required this.value, required this.onChanged});

  String _label(TargetMode mode) {
    switch (mode) {
      case TargetMode.none:
        return '不设定';
      case TargetMode.daily:
        return '按日耗';
      case TargetMode.date:
        return '按周期';
      case TargetMode.custom:
        return '自定义';
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
        children: TargetMode.values.map((mode) {
          final active = value == mode;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 2,
                ),
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
                            offset: const Offset(0, 5),
                          ),
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
                  child: Text(
                    _label(mode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

List<String> ensureTags(AppStore store, List<String> names, DateTime now) {
  final tagIds = <String>[];
  for (final name in names) {
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
                color: context.isDark ? Colors.white : kText,
              ),
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, color: kMuted),
        ],
      ),
    );
  }
}

class SmallCaret extends StatelessWidget {
  const SmallCaret({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: kBrand.withOpacity(.9),
      borderRadius: BorderRadius.circular(7),
    ),
    child: const Icon(
      Icons.keyboard_arrow_down_rounded,
      size: 18,
      color: kBrandInk,
    ),
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
    return PageFrame(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '心愿',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  height: .95,
                ),
              ),
            ),
            HeaderIcon(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: () {
                tapHaptic();
                store.setWishArchivedFilter(!store.wishShowArchived);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        TutorialTargetAnchor(
          id: 'wish.summary',
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: context.isDark ? kCardDark : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [softShadow(context)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '心愿总值',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        money(total, store.settings),
                        style: const TextStyle(
                          fontSize: 21,
                          height: .95,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '心愿数量 ${active.length} 个',
                        style: const TextStyle(
                          color: kMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: kBrand.withOpacity(.62),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 27)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TutorialTargetAnchor(
          id: 'wish.filters',
          child: Row(
            children: [
              FilterPill(
                label: '进行中',
                active: !store.wishShowArchived,
                onTap: () => store.setWishArchivedFilter(false),
              ),
              FilterPill(
                label: '已归档',
                active: store.wishShowArchived,
                onTap: () => store.setWishArchivedFilter(true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          TutorialTargetAnchor(
            id: 'wish.list',
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).height * .22,
              ),
              child: Column(
                children: [
                  Text(
                    '📦',
                    style: TextStyle(
                      fontSize: 76,
                      color: kMuted.withOpacity(.25),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '空空如也',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '点击 ',
                        style: TextStyle(color: kMuted, fontSize: 18),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF111214),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Text(
                        ' 添加心愿',
                        style: TextStyle(color: kMuted, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(
            list.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: i == 0
                  ? TutorialTargetAnchor(
                      id: 'wish.list',
                      child: WishCard(wish: list[i]),
                    )
                  : WishCard(wish: list[i]),
            ),
          ),
      ],
    );
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
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: kBrand.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: valoraIconVisual(
                context,
                wish.iconValue,
                emojiSize: 21,
                borderRadius: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          wish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (wish.archived)
                        const TinyTag(label: '已归档', color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${store.categoryIcon(wish.categoryId)} ${store.categoryName(wish.categoryId)} · ${money(wish.expectedPrice, store.settings)}',
                    style: const TextStyle(color: kMuted, fontSize: 12),
                  ),
                  if (wish.note.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      wish.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? kCardDark
                  : Colors.white,
              onSelected: (v) {
                if (v == 'convert') {
                  store.convertWishToAsset(wish.id);
                  showNativeSnack(context, '已转为资产');
                }
                if (v == 'archive')
                  store.upsertWish(wish.copyWith(archived: !wish.archived));
                if (v == 'delete') store.deleteWish(wish.id);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'convert', child: Text('转为资产')),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(wish.archived ? '恢复进行中' : '归档'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
      ),
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

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    name = TextEditingController(text: item?.name ?? '');
    icon = TextEditingController(text: item?.iconValue ?? '✨');
    price = TextEditingController(
      text: item?.expectedPrice.toStringAsFixed(0) ?? '',
    );
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
      tagsText.text = item.tagIds
          .map((id) => context.store.tagById(id)?.name ?? id)
          .join('、');
  }

  @override
  void dispose() {
    for (final c in [name, icon, price, tagsText, note]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    widget.initial == null ? '新增心愿' : '编辑心愿',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => pickValoraIcon(
                            context,
                            icon,
                            onChanged: () => setState(() {}),
                          ),
                          child: EditableIconPreview(
                            controller: icon,
                            onChanged: () => setState(() {}),
                          ),
                        ),
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
                          label: '心愿名称',
                          requiredField: true,
                        ),
                        const SizedBox(height: 12),
                        AppField(
                          controller: price,
                          label: '预计价格',
                          number: true,
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
                        AppField(controller: tagsText, label: '标签'),
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
                          decoration: const InputDecoration(
                            labelText: '购买理由 / 观察点',
                          ),
                        ),
                        SwitchListTile(
                          value: archived,
                          onChanged: (v) {
                            tapHaptic();
                            setState(() => archived = v);
                          },
                          title: const Text('归档'),
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
              child: LiquidSaveButton(
                label: '保存心愿',
                icon: Icons.check_rounded,
                onPressed: () {
                  mediumHaptic();
                  saveWish();
                },
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
    if (mounted) showNativeSnack(context, '已设置心愿封面');
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

  Future<void> cutoutCoverIntoForm() async {
    mediumHaptic();
    final payload = await NativeBridge.cutoutImageFromPickerDetailed();
    final uri = mounted ? await chooseStickerCandidate(context, payload) : null;
    if (uri == null || uri.trim().isEmpty) {
      if (mounted) showNativeSnack(context, '没有生成可用的心愿贴纸');
      return;
    }
    setState(() => icon.text = uri);
    final count = payload['candidates'] is List
        ? (payload['candidates'] as List).length
        : 0;
    if (mounted)
      showNativeSnack(
        context,
        count > 1 ? '已从 ${count} 个候选中选中心愿贴纸' : '已生成心愿贴纸封面',
      );
  }

  void saveWish() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final store = context.store;
    final now = DateTime.now();
    final tagIds = ensureTags(store, splitTags(tagsText.text), now);
    store.upsertWish(
      Wish(
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
        updatedAt: now,
      ),
    );
    Navigator.pop(context);
  }
}
