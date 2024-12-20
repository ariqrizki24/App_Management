import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'models/product.dart';
import 'services/api_service.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({Key? key}) : super(key: key);

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
          SnackBar(
            content: Text('Produk berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Produk Baru',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade50,
              Colors.lightBlue.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tambah Produk Baru',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildProductNameField(),
                        const SizedBox(height: 16),
                        _buildPriceField(),
                        const SizedBox(height: 16),
                        _buildQuantityField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      decoration: _getInputDecoration('Nama Produk', Icons.shopping_bag),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silahkan masukan nama produk';
        }
        return null;
      },
      onSaved: (value) => _name = value ?? '',
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: _getInputDecoration('Harga Produk', Icons.attach_money, prefixText: 'Rp '),
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
          final parsedValue = double.tryParse(value.replaceAll('.', '')) ?? 0.0;
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
                value?.replaceAll('.', '').replaceAll('Rp', '') ?? '') ??
            0.0;
      },
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      decoration: _getInputDecoration('Jumlah Barang', Icons.numbers),
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
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: _getInputDecoration('Deskripsi Produk', Icons.description),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silahkan masukan deskripsi';
        }
        return null;
      },
      onSaved: (value) => _deskripsi = value ?? '',
      style: TextStyle(color: Colors.black),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Tambah Produk',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      prefixIcon: Icon(icon, color: Colors.lightBlue),
      labelStyle: TextStyle(color: Colors.lightBlue),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}