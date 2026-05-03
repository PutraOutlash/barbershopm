class UserModel {
  String? id;
  String name; // BARU: Nama Asli (Wajib)
  String username; // Nama Akun (Wajib)
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
    return UserModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? "Pengguna",
      username: json['username']?.toString() ?? "GUEST",
      email: json['email']?.toString() ?? "no-email",
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      photo: json['photo']?.toString(),
      role: json['role']?.toString() ?? "customer",
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
