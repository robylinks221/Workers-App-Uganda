class UserModel {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final String? profilePhoto;
  final String? location;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    this.profilePhoto,
    this.location,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      fullName: json["full_name"],
      phone: json["phone"],
      email: json["email"],
      role: json["role"],
      profilePhoto: json["profile_photo"],
      location: json["location"],
      isVerified: json["is_verified"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "phone": phone,
      "email": email,
      "role": role,
      "profile_photo": profilePhoto,
      "location": location,
      "is_verified": isVerified,
    };
  }
}