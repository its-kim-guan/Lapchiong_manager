import 'package:flutter/material.dart';
import 'package:my_app/models/models.dart';
import 'package:my_app/utils/formatters.dart';
import 'package:my_app/utils/validators.dart';
import 'package:my_app/widgets/app_text_field.dart';
import 'package:my_app/widgets/empty_state.dart';

enum TransactionMode { purchase, sale }

class TransactionDialog extends StatefulWidget {
  const TransactionDialog({
    super.key,
    required this.title,
    required this.items,
    required this.mode,
    required this.onSave,
  });

  final String title;
  final List<InventoryItem> items;
  final TransactionMode mode;
  final Future<void> Function(TransactionPayload payload) onSave;

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _partnerController = TextEditingController();
  InventoryItem? _selectedItem;
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final List<TransactionDetailPayload> _details = [];
  bool _saving = false;

  bool get _isPurchase => widget.mode == TransactionMode.purchase;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _selectedItem = widget.items.first;
      _syncDefaultPrice();
    }
  }

  @override
  void dispose() {
    _partnerController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _syncDefaultPrice() {
    final item = _selectedItem;
    if (item == null) {
      _priceController.text = '';
      return;
    }

    _priceController.text = (_isPurchase ? item.purchasePrice : item.salePrice)
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    final total = _details.fold<int>(0, (sum, item) => sum + item.subtotal);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _partnerController,
                  label: _isPurchase ? 'Nama supplier' : 'Nama pelanggan',
                  validator: requiredValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<InventoryItem>(
                  initialValue: _selectedItem,
                  decoration: const InputDecoration(labelText: 'Pilih barang'),
                  items: widget.items
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text('${item.name} (stok ${item.stock})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItem = value;
                      _syncDefaultPrice();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _quantityController,
                        label: 'Jumlah',
                        keyboardType: TextInputType.number,
                        validator: positiveNumberValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _priceController,
                        label: _isPurchase ? 'Harga beli' : 'Harga jual',
                        keyboardType: TextInputType.number,
                        validator: positiveNumberValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: _addDetail,
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Tambah Detail'),
                  ),
                ),
                const SizedBox(height: 12),
                if (_details.isEmpty)
                  const EmptyState(message: 'Belum ada item transaksi.')
                else
                  ..._details.asMap().entries.map(
                    (entry) => Card(
                      child: ListTile(
                        title: Text(entry.value.item.name),
                        subtitle: Text(
                          '${entry.value.quantity} x ${formatCurrency(entry.value.unitPrice)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(formatCurrency(entry.value.subtotal)),
                            IconButton(
                              onPressed: () => _removeDetail(entry.key),
                              icon: const Icon(Icons.close),
                              tooltip: 'Hapus detail',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Total: ${formatCurrency(total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Menyimpan...' : 'Simpan Transaksi'),
        ),
      ],
    );
  }

  void _addDetail() {
    final item = _selectedItem;
    if (item == null) {
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah dan harga harus lebih dari 0.')),
      );
      return;
    }

    final existingQuantity = _details
        .where((detail) => detail.item.id == item.id)
        .fold<int>(0, (sum, detail) => sum + detail.quantity);

    if (!_isPurchase && quantity + existingQuantity > item.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${item.name} tidak mencukupi.')),
      );
      return;
    }

    setState(() {
      _details.add(
        TransactionDetailPayload(
          item: item,
          quantity: quantity,
          unitPrice: price,
        ),
      );
      _quantityController.text = '1';
      _syncDefaultPrice();
    });
  }

  void _removeDetail(int index) {
    setState(() {
      _details.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal satu detail transaksi.'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.onSave(
        TransactionPayload(
          partnerName: _partnerController.text.trim(),
          date: DateTime.now(),
          details: _details,
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
