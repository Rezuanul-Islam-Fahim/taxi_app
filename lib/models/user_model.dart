class User {
  final String? id;
  final String? username;
  final String? email;
  final String? userType;
  final double? userLatitude;
  final double? userLongitude;

  const User({
    this.id,
    this.username,
    this.email,
    this.userType = 'user',
    this.userLatitude,
    this.userLongitude,
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      userType: data['userType'],
      userLatitude: data['userLatitude'],
      userLongitude: data['userLongitude'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'userType': userType,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
      };
}
