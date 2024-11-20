enum UserType { client, distributor }

class UserModel {
  final String? id;
  final String email;
  final String phoneNumber;
  final String? fullName;
  final String? agentCode;
  final UserType userType;
  double balance;

  UserModel({
    this.id,
    required this.email,
    required this.phoneNumber,
    this.fullName,
    this.agentCode,
    required this.userType,
    this.balance = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'agentCode': agentCode,
        'userType': userType.toString().split('.').last,
        'balance': balance,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id']?.toString(),
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        fullName: json['fullName']?.toString(),
        agentCode: json['agentCode']?.toString(),
        userType: _parseUserType(json['userType']?.toString()),
        balance: (json['balance'] is num)
            ? (json['balance'] as num).toDouble()
            : double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static UserType _parseUserType(String? type) {
    switch (type?.toLowerCase()) {
      case 'distributor':
        return UserType.distributor;
      case 'client':
        return UserType.client;
      default:
        return UserType.client;
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, phoneNumber: $phoneNumber, '
        'fullName: $fullName, agentCode: $agentCode, userType: $userType, '
        'balance: $balance)';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? agentCode,
    UserType? userType,
    double? balance,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      agentCode: agentCode ?? this.agentCode,
      userType: userType ?? this.userType,
      balance: balance ?? this.balance,
    );
  }
}

/* enum UserType {
  client,
  distributor
}

class UserModel {
  final String? id;
  final String email;
  final String? phoneNumber;
  final String? fullName;
  final String? photoUrl;
  final UserType userType;
  final double balance;

  UserModel({
    this.id,
    required this.email,
    this.phoneNumber,
    this.fullName,
    this.photoUrl,
    this.userType = UserType.client,
    this.balance = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'] ?? json['name'],
      photoUrl: json['photoUrl'],
      userType: _parseUserType(json['userType']),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'userType': userType.toString().split('.').last,
      'balance': balance,
    };
  }

  static UserType _parseUserType(String? typeString) {
    switch (typeString) {
      case 'distributor':
        return UserType.distributor;
      case 'client':
      default:
        return UserType.client;
    }
  }
} */