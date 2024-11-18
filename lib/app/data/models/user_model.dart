enum UserType { client, distributor }

class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final UserType userType;
  double balance;

  UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    this.balance = 0.0
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phoneNumber': phoneNumber,
    'userType': userType.toString().split('.').last,
    'balance': balance
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    userType: UserType.values.firstWhere(
      (type) => type.toString().split('.').last == json['userType']
    ),
    balance: json['balance'] ?? 0.0
  );

  get fullName => null;
}