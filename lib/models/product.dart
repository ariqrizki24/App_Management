class Product {
  final int id;
  final String name;
  final double price;
  final int jumlah;
  final String deskripsi;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.jumlah,
    required this.deskripsi,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown', 
      price: (json['price'] != null) 
          ? (json['price'] is int ? json['price'].toDouble() : json['price'])
          : 0.0, 
      jumlah: json['jumlah'] ?? 0, 
      deskripsi: json['deskripsi'] ?? 'Tidak ada deskripsi', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'jumlah': jumlah,
      'deskripsi': deskripsi,
    };
  }
}
