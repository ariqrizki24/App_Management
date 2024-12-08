import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'models/product.dart';
import 'services/api_service.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _name = '';
  double _price = 0.0;
  int _jumlah = 0;
  String _deskripsi = '';

  final _priceController = TextEditingController(); 
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

      final newProduct = Product(
        id: 0,
        name: _name,
        price: _price,
        jumlah: _jumlah,
        deskripsi: _deskripsi,
      );

      try {
        await _apiService.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Produk Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nama Produk'),
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
                  decoration: InputDecoration(
                    labelText: 'Harga Produk',
                    prefixText: 'Rp ', // Awalan Rupiah
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
                    // Format input menjadi Rupiah
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
                  decoration: InputDecoration(labelText: 'Jumlah Barang'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan jumlah barang';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Jumlah harus berupa angka';
                    }
                    return null;
                  },
                  onSaved: (value) => _jumlah = int.tryParse(value ?? '') ?? 0,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Deskripsi Produk'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silahkan masukan deskripsi';
                    }
                    return null;
                  },
                  onSaved: (value) => _deskripsi = value ?? '',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Tambah Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
