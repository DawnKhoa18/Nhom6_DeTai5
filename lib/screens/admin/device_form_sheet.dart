import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_computer_line.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device.dart';
import 'package:nhom6_detai5_doancuoiki/models/admin_device_image.dart';
import 'package:nhom6_detai5_doancuoiki/services/admin_api_service.dart';

class DeviceFormSheet extends StatefulWidget {
  final AdminApiService api;
  final AdminDevice? device;
  final VoidCallback onSaved;

  const DeviceFormSheet({
    super.key,
    required this.api,
    required this.device,
    required this.onSaved,
  });

  @override
  State<DeviceFormSheet> createState() => _DeviceFormSheetState();
}

class _DeviceFormSheetState extends State<DeviceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<AdminComputerLine>> _linesFuture;
  Future<List<AdminDeviceImage>>? _imagesFuture;
  late final Map<String, TextEditingController> _controllers;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _pendingImages = [];
  int? _lineId;
  String _status = 'san_sang';
  DateTime? _importedDate;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final device = widget.device;
    _lineId = device?.computerLineId;
    _status = device?.status ?? 'san_sang';
    _importedDate = device?.importedDate;
    _linesFuture = widget.api.getComputerLines();
    if (device != null) {
      _imagesFuture = widget.api.getDeviceImages(device.id);
    }
    _controllers = {
      'assetCode': TextEditingController(text: device?.assetCode ?? ''),
      'serial': TextEditingController(text: device?.serialNumber ?? ''),
      'type': TextEditingController(text: device?.type ?? 'laptop'),
      'cpu': TextEditingController(text: device?.cpu ?? ''),
      'ram': TextEditingController(text: device?.ram ?? ''),
      'storage': TextEditingController(text: device?.storage ?? ''),
      'gpu': TextEditingController(text: device?.gpu ?? ''),
      'screen': TextEditingController(text: device?.screen ?? ''),
      'os': TextEditingController(text: device?.operatingSystem ?? ''),
      'value': TextEditingController(
        text: device == null ? '' : device.originalValue.toStringAsFixed(0),
      ),
      'rent': TextEditingController(
        text: device == null ? '' : device.dailyRentalPrice.toStringAsFixed(0),
      ),
      'deposit': TextEditingController(
        text: device == null ? '30' : device.depositRate.toStringAsFixed(0),
      ),
      'note': TextEditingController(text: device?.note ?? ''),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _importedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _importedDate = picked);
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (images.isNotEmpty) {
      setState(() => _pendingImages.addAll(images));
    }
  }

  void _reloadImages() {
    final device = widget.device;
    if (device == null) return;
    setState(() {
      _imagesFuture = widget.api.getDeviceImages(device.id);
    });
  }

  Future<void> _setPrimary(AdminDeviceImage image) async {
    try {
      await widget.api.setPrimaryDeviceImage(
        deviceId: image.deviceId,
        imageId: image.id,
      );
      if (mounted) _reloadImages();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _deleteImage(AdminDeviceImage image) async {
    try {
      await widget.api.deleteDeviceImage(
        deviceId: image.deviceId,
        imageId: image.id,
      );
      if (mounted) _reloadImages();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  double? _number(String key) {
    return double.tryParse(_controllers[key]!.text.trim().replaceAll(',', '.'));
  }

  String? _optional(String key) {
    final value = _controllers[key]!.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _lineId == null) {
      if (_lineId == null) setState(() => _error = 'Vui lòng chọn dòng máy.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final device = widget.device;
      final arguments = (
        computerLineId: _lineId!,
        assetCode: _controllers['assetCode']!.text.trim(),
        type: _controllers['type']!.text.trim(),
        originalValue: _number('value')!,
        dailyRentalPrice: _number('rent')!,
        depositRate: _number('deposit')!,
        status: _status,
        serialNumber: _optional('serial'),
        cpu: _optional('cpu'),
        ram: _optional('ram'),
        storage: _optional('storage'),
        gpu: _optional('gpu'),
        screen: _optional('screen'),
        operatingSystem: _optional('os'),
        importedDate: _importedDate,
        note: _optional('note'),
      );

      late final int savedDeviceId;
      if (device == null) {
        savedDeviceId = await widget.api.createDevice(
          computerLineId: arguments.computerLineId,
          assetCode: arguments.assetCode,
          type: arguments.type,
          originalValue: arguments.originalValue,
          dailyRentalPrice: arguments.dailyRentalPrice,
          depositRate: arguments.depositRate,
          status: arguments.status,
          serialNumber: arguments.serialNumber,
          cpu: arguments.cpu,
          ram: arguments.ram,
          storage: arguments.storage,
          gpu: arguments.gpu,
          screen: arguments.screen,
          operatingSystem: arguments.operatingSystem,
          importedDate: arguments.importedDate,
          note: arguments.note,
        );
      } else {
        savedDeviceId = device.id;
        await widget.api.updateDevice(
          id: device.id,
          computerLineId: arguments.computerLineId,
          assetCode: arguments.assetCode,
          type: arguments.type,
          originalValue: arguments.originalValue,
          dailyRentalPrice: arguments.dailyRentalPrice,
          depositRate: arguments.depositRate,
          status: arguments.status,
          serialNumber: arguments.serialNumber,
          cpu: arguments.cpu,
          ram: arguments.ram,
          storage: arguments.storage,
          gpu: arguments.gpu,
          screen: arguments.screen,
          operatingSystem: arguments.operatingSystem,
          importedDate: arguments.importedDate,
          note: arguments.note,
        );
      }

      for (final image in _pendingImages) {
        await widget.api.uploadDeviceImage(
          deviceId: savedDeviceId,
          filePath: image.path,
        );
      }

      if (mounted) widget.onSaved();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.device == null ? 'Thêm thiết bị' : 'Sửa thiết bị',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đóng',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildImagesSection(),
              const SizedBox(height: 18),
              FutureBuilder<List<AdminComputerLine>>(
                future: _linesFuture,
                builder: (context, snapshot) {
                  final lines = snapshot.data ?? const [];
                  return DropdownButtonFormField<int>(
                    value: lines.any((line) => line.id == _lineId) ? _lineId : null,
                    decoration: const InputDecoration(
                      labelText: 'Dòng máy *',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: lines
                        .map(
                          (line) => DropdownMenuItem(
                            value: line.id,
                            child: Text(line.brand + ' ' + line.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving ? null : (value) => setState(() => _lineId = value),
                  );
                },
              ),
              const SizedBox(height: 13),
              _field('assetCode', 'Mã tài sản *', Icons.qr_code_rounded, required: true),
              _field('serial', 'Serial', Icons.numbers_rounded),
              _field('type', 'Loại máy *', Icons.devices_other_rounded, required: true),
              const _SectionTitle('Cấu hình'),
              _field('cpu', 'CPU', Icons.memory_rounded),
              _field('ram', 'RAM', Icons.developer_board_outlined),
              _field('storage', 'Ổ cứng', Icons.storage_rounded),
              _field('gpu', 'GPU', Icons.videogame_asset_outlined),
              _field('screen', 'Màn hình', Icons.monitor_outlined),
              _field('os', 'Hệ điều hành', Icons.window_rounded),
              const _SectionTitle('Giá và trạng thái'),
              _numberField('value', 'Giá trị máy *'),
              _numberField('rent', 'Giá thuê mỗi ngày *'),
              _numberField('deposit', 'Tỷ lệ đặt cọc (%) *', max: 100),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Tình trạng',
                  prefixIcon: Icon(Icons.fact_check_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'san_sang', child: Text('Sẵn sàng')),
                  DropdownMenuItem(value: 'dang_thue', child: Text('Đang cho thuê')),
                  DropdownMenuItem(value: 'bao_tri', child: Text('Bảo trì')),
                  DropdownMenuItem(value: 'hong', child: Text('Hỏng')),
                  DropdownMenuItem(value: 'ngung_kinh_doanh', child: Text('Ngừng kinh doanh')),
                ],
                onChanged: _saving ? null : (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 13),
              InkWell(
                onTap: _saving ? null : _pickDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày nhập',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _importedDate == null
                        ? 'Chọn ngày nhập'
                        : '${_importedDate!.day.toString().padLeft(2, '0')}/${_importedDate!.month.toString().padLeft(2, '0')}/${_importedDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 13),
              _field('note', 'Ghi chú', Icons.notes_rounded, maxLines: 3),
              if (_error != null) ...[
                const SizedBox(height: 2),
                Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu thiết bị'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Ảnh thiết bị')),
            IconButton(
              tooltip: 'Chọn ảnh',
              onPressed: _saving ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
          ],
        ),
        if (widget.device != null && _imagesFuture != null)
          FutureBuilder<List<AdminDeviceImage>>(
            future: _imagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final images = snapshot.data ?? const [];
              return _ImageStrip(
                images: images,
                api: widget.api,
                onPrimary: _setPrimary,
                onDelete: _deleteImage,
              );
            },
          ),
        if (_pendingImages.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Ảnh chờ tải lên',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _pendingImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_pendingImages[index].path),
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: IconButton.filled(
                      tooltip: 'Bỏ ảnh',
                      visualDensity: VisualDensity.compact,
                      iconSize: 16,
                      onPressed: () => setState(() => _pendingImages.removeAt(index)),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (widget.device == null && _pendingImages.isEmpty)
          const Text(
            'Chọn ảnh trước, ảnh sẽ được tải lên sau khi lưu thiết bị.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
      ],
    );
  }

  Widget _field(
    String key,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: _controllers[key],
        maxLines: maxLines,
        validator: required
            ? (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập ' + label.replaceAll(' *', '').toLowerCase() + '.' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _numberField(String key, String label, {double? max}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
          if (number == null) return 'Vui lòng nhập số hợp lệ.';
          if (number < 0 || (max != null && number > max)) return 'Giá trị không hợp lệ.';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.payments_outlined),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF334155),
          ),
        ),
      );
}

class _ImageStrip extends StatelessWidget {
  final List<AdminDeviceImage> images;
  final AdminApiService api;
  final ValueChanged<AdminDeviceImage> onPrimary;
  final ValueChanged<AdminDeviceImage> onDelete;

  const _ImageStrip({
    required this.images,
    required this.api,
    required this.onPrimary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Text(
        'Thiết bị chưa có ảnh.',
        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
      );
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final image = images[index];
          return Container(
            width: 104,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: image.isPrimary
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFFE2E8F0),
                width: image.isPrimary ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    api.resolveFileUrl(image.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFF1F5F9),
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  right: 3,
                  child: PopupMenuButton<String>(
                    tooltip: 'Thao tác ảnh',
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'primary') onPrimary(image);
                      if (value == 'delete') onDelete(image);
                    },
                    itemBuilder: (_) => [
                      if (!image.isPrimary)
                        const PopupMenuItem(
                          value: 'primary',
                          child: Text('Đặt làm ảnh đại diện'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa ảnh'),
                      ),
                    ],
                  ),
                ),
                if (image.isPrimary)
                  const Positioned(
                    left: 5,
                    bottom: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xCC1D4ED8),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        child: Text(
                          'Đại diện',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
