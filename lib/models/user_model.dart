import '../config/api.dart'; // 🔥 WAJIB IMPORT INI UNTUK MENGAMBIL BASE URL

class UserModel {
  String? id;
  String name;
  String username;
  String email;
  String? password;
  String? phone;
  String? address;
  String? photo;
  String? role;

  UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.photo,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Ambil data foto mentah dari JSON
    String? rawPhoto =
        json['photo']?.toString() ?? json['photo_url']?.toString();

    // 2. 🔥 LOGIKA ANTI URL BUNTUNG:
    // Jika foto ada tapi tidak diawali dengan 'http' (berarti cuma path lokasi folder)
    if (rawPhoto != null && !rawPhoto.startsWith('http')) {
      // Kita sulap URL API (http://192.../api) menjadi URL Storage (http://192.../storage/)
      String storageBaseUrl = Api.baseUrl.replaceAll('/api', '/storage/');
      rawPhoto = "$storageBaseUrl$rawPhoto";
    }

    return UserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? "Pengguna",
      username: json['username']?.toString() ?? "GUEST",
      email: json['email']?.toString() ?? "no-email",
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      role: json['role']?.toString() ?? "customer",
      photo: rawPhoto, // Masukkan URL yang sudah disempurnakan
    );
  }

  Map<String, String> toJson() {
    return {
      "name": name,
      "username": username,
      "email": email,
      "password": password ?? "",
      "role": role ?? "customer",
    };
  }
}
