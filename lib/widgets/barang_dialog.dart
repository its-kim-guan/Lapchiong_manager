import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/app_constants.dart';
import 'package:my_app/utils/validators.dart';
import 'package:my_app/widgets/app_text_field.dart';

class BarangDialog extends StatefulWidget {
  const BarangDialog({super.key, this.item, required this.onSave});

  final InventoryItem? item;
  final Future<void> Function(ItemPayload payload) onSave;

  @override
  State<BarangDialog> createState() => _BarangDialogState();
}

class _BarangDialogState extends State<BarangDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _purchaseController;
  late final TextEditingController _saleController;
  late final TextEditingController _stockController;
  late String _selectedCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _purchaseController = TextEditingController(
      text: widget.item?.purchasePrice.toString() ?? '',
    );
    _saleController = TextEditingController(
      text: widget.item?.salePrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.item?.stock.toString() ?? '0',
    );
    _selectedCategory = widget.item?.category ?? barangCategoryOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchaseController.dispose();
    _saleController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = [
      if (!barangCategoryOptions.contains(_selectedCategory)) _selectedCategory,
      ...barangCategoryOptions,
    ];

    return AlertDialog(
      title: Text(widget.item == null ? 'Tambah Barang' : 'Ubah Barang'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nama barang',
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori rasa'),
                  items: categoryOptions
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _purchaseController,
                  label: 'Harga beli',
                  keyboardType: TextInputType.number,
                  validator: positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _saleController,
                  label: 'Harga jual',
                  keyboardType: TextInputType.number,
                  validator: positiveNumberValidator,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _stockController,
                  label: 'Stok awal',
                  keyboardType: TextInputType.number,
                  validator: nonNegativeValidator,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.onSave(
        ItemPayload(
          name: _nameController.text.trim(),
          category: _selectedCategory,
          purchasePrice: int.parse(_purchaseController.text),
          salePrice: int.parse(_saleController.text),
          stock: int.parse(_stockController.text),
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
