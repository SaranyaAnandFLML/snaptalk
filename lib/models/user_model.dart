import 'package:hive_ce_flutter/adapters.dart';

class UserModel extends HiveObject{
  String name;
  String phone;
  String email;
  String password;
  String userId;
  String image;

  UserModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.userId,
    required this.image,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? password,
    String? userId,
    String? image,
  }) =>
      UserModel(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        password: password ?? this.password,
        userId: userId ?? this.userId,
        image: image ?? this.image,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    password: json["password"],
    userId: json["userId"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "email": email,
    "password": password,
    "userId": userId,
    "image": image,
  };
}


class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i=0; i<numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String,
      phone: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      userId: fields[4] as String,
      image: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6)  // number of fields
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator==(Object other) =>
      identical(this, other) ||
          other is UserModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}