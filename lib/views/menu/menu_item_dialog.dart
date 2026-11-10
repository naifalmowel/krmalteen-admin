import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/menu_item_model.dart';
import '../../models/category_model.dart';
import '../../core/localization/app_localization.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/menu_provider.dart';

class MenuItemDialog extends ConsumerStatefulWidget {
  final MenuItemModel? itemToEdit;
  final List<CategoryModel> categories;
  final String? initialCategoryId;

  const MenuItemDialog({
    super.key,
    this.itemToEdit,
    required this.categories,
    this.initialCategoryId,
  });

  @override
  ConsumerState<MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends ConsumerState<MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _priceController;
  late TextEditingController _tagsController;
  late TextEditingController _sortOrderController;

  String? _selectedCategoryId;
  bool _isAvailable = true;
  String _imageUrl = '';
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;

  bool _isSaving = false;
  String? _uploadStatusText;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameArController = TextEditingController(text: item?.nameAr ?? '');
    _nameEnController = TextEditingController(text: item?.nameEn ?? '');
    _descArController = TextEditingController(text: item?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: item?.descriptionEn ?? '');
    _priceController = TextEditingController(
        text: item != null ? item.price.toStringAsFixed(0) : '');
    _tagsController = TextEditingController(text: item?.tags.join(', ') ?? '');
    _sortOrderController =
        TextEditingController(text: (item?.sortOrder ?? 0).toString());

    _isAvailable = item?.isAvailable ?? true;
    _imageUrl = item?.imageUrl ?? '';

    if (item != null) {
      _selectedCategoryId = item.categoryId;
    } else if (widget.initialCategoryId != null &&
        widget.initialCategoryId!.isNotEmpty) {
      _selectedCategoryId = widget.initialCategoryId;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = xfile.name;
      });
    }
  }

  Future<void> _save() async {
    final loc = AppLocalization.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('select_category'))),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _uploadStatusText = loc.translate('upload_image');
    });

    try {
      String finalImageUrl = _imageUrl;

      // Upload image to Supabase if new image bytes picked
      if (_selectedImageBytes != null) {
        final fileName = _selectedFileName ?? 'image.jpg';
        try {
          finalImageUrl = await SupabaseService.uploadMenuImage(
            _selectedImageBytes!,
            fileName,
          );
        } catch (uploadError) {
          finalImageUrl = _imageUrl.isNotEmpty
              ? _imageUrl
              : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500';
        }
      }

      final tagsList = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final actions = ref.read(menuActionsProvider);

      if (widget.itemToEdit == null) {
        final newItem = MenuItemModel(
          id: '',
          categoryId: _selectedCategoryId!,
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          imageUrl: finalImageUrl,
          isAvailable: _isAvailable,
          tags: tagsList,
          sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
          createdAt: DateTime.now(),
        );
        await actions.addMenuItem(newItem);
      } else {
        final updated = widget.itemToEdit!.copyWith(
          categoryId: _selectedCategoryId!,
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          descriptionAr: _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          imageUrl: finalImageUrl,
          isAvailable: _isAvailable,
          tags: tagsList,
          sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
        );
        await actions.updateMenuItem(updated);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    final isEdit = widget.itemToEdit != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 12 : 24,
      ),
      titlePadding: EdgeInsets.all(isMobile ? 12 : 20),
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 8),
      title: Text(
        isEdit ? loc.translate('edit_item') : loc.translate('add_item'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 580),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Upload Preview Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.softCream,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder, width: 2),
                            image: _selectedImageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_selectedImageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : (_imageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(_imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (_selectedImageBytes == null && _imageUrl.isEmpty)
                              ? const Icon(
                                  Icons.image_rounded,
                                  size: 40,
                                  color: AppColors.textMuted,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                          label: Text(
                            _selectedImageBytes != null || _imageUrl.isNotEmpty
                                ? loc.translate('change_image')
                                : loc.translate('upload_image'),
                            style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selection Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: loc.translate('select_category'),
                    ),
                    items: widget.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(
                          loc.isArabic ? cat.nameAr : cat.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) => val == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 12),

                  // Name Ar / En (Mobile responsive column / row)
                  if (isMobile) ...[
                    TextFormField(
                      controller: _nameArController,
                      decoration: InputDecoration(
                        labelText: loc.translate('item_name_ar'),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameEnController,
                      decoration: InputDecoration(
                        labelText: loc.translate('item_name_en'),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameArController,
                            decoration: InputDecoration(
                              labelText: loc.translate('item_name_ar'),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _nameEnController,
                            decoration: InputDecoration(
                              labelText: loc.translate('item_name_en'),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Description Ar / En
                  TextFormField(
                    controller: _descArController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: loc.translate('desc_ar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descEnController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: loc.translate('desc_en'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price SYP & Sort Order
                  if (isMobile) ...[
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('price_syp'),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sortOrderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('sort_order'),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.translate('price_syp'),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _sortOrderController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: loc.translate('sort_order'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Tags
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: loc.translate('tags_comma'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Availability Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isAvailable
                          ? loc.translate('available')
                          : loc.translate('unavailable'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Cairo'),
                    ),
                    value: _isAvailable,
                    activeThumbColor: AppColors.forestGreen,
                    onChanged: (val) {
                      setState(() {
                        _isAvailable = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(_uploadStatusText ?? loc.translate('loading')),
                  ],
                )
              : Text(loc.translate('save')),
        ),
      ],
    );
  }
}
