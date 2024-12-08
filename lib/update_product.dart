import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'models/product.dart';
import 'services/api_service.dart';

class EditProductForm extends StatefulWidget {
  final Product product;
  const EditProductForm({super.key, required this.product});

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late String _name;
  late double _price;
  late int _jumlah;
  late String _deskripsi;

  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _jumlah = widget.product.jumlah;
    _deskripsi = widget.product.deskripsi;

    _priceController.text = formatRupiah(_price).replaceAll('Rp', '').trim();
  }

  String formatRupiah(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        price: _price,
        jumlah: _jumlah,
        deskripsi: _deskripsi,
      );

      try {
        await _apiService.updateProduct(updatedProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan nama produk';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value ?? '',
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Produk',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan harga produk';
                    }
                    if (double.tryParse(value.replaceAll('.', '')) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final parsedValue =
                          double.tryParse(value.replaceAll('.', '')) ?? 0.0;
                      _priceController.text = formatRupiah(parsedValue)
                          .replaceAll('Rp', '')
                          .trim();
                      _priceController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _priceController.text.length),
                      );
                    }
                  },
                  onSaved: (value) {
                    _price = double.tryParse(
                            value?.replaceAll('.', '').replaceAll('Rp', '') ??
                                '') ??
                        0.0;
                  },
                ),
                TextFormField(
                  initialValue: _jumlah.toString(),
                  decoration: const InputDecoration(labelText: 'Jumlah Produk'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan jumlah produk';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Jumlah harus berupa angka';
                    }
                    return null;
                  },
                  onSaved: (value) => _jumlah = int.tryParse(value ?? '') ?? 0,
                ),
                TextFormField(
                  initialValue: _deskripsi,
                  decoration: const InputDecoration(labelText: 'Deskripsi Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan deskripsi produk';
                    }
                    return null;
                  },
                  onSaved: (value) => _deskripsi = value ?? '',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Update Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
