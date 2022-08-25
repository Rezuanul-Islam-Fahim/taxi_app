class User {
  final String? id;
  final String? username;
  final String? email;
  final String? userType;

  const User({
    this.id,
    this.username,
    this.email,
    this.userType = 'user',
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      userType: data['userType'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'userType': userType,
      };
}
