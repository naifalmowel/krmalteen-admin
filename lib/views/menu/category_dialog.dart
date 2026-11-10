import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category_model.dart';
import '../../core/localization/app_localization.dart';
import '../../providers/categories_provider.dart';

class CategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? categoryToEdit;

  const CategoryDialog({super.key, this.categoryToEdit});

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _sortOrderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.categoryToEdit?.nameAr ?? '');
    _nameEnController = TextEditingController(text: widget.categoryToEdit?.nameEn ?? '');
    _sortOrderController = TextEditingController(
        text: (widget.categoryToEdit?.sortOrder ?? 0).toString());
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final actions = ref.read(categoriesActionsProvider);

    try {
      if (widget.categoryToEdit == null) {
        await actions.addCategory(
          _nameArController.text.trim(),
          _nameEnController.text.trim(),
          int.tryParse(_sortOrderController.text.trim()) ?? 0,
        );
      } else {
        final updated = widget.categoryToEdit!.copyWith(
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
        );
        await actions.updateCategory(updated);
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
    final isEdit = widget.categoryToEdit != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      title: Text(
        isEdit ? loc.translate('edit_category') : loc.translate('add_category'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameArController,
                  decoration: InputDecoration(
                    labelText: loc.translate('category_name_ar'),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameEnController,
                  decoration: InputDecoration(
                    labelText: loc.translate('category_name_en'),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sortOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.translate('sort_order'),
                  ),
                ),
              ],
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(loc.translate('save')),
        ),
      ],
    );
  }
}
