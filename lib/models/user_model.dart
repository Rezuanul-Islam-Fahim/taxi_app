class User {
  final String? id;
  final String? username;
  final String? email;
  final String? userType;
  final double? userLatitude;
  final double? userLongitude;
  final double? heading;

  const User({
    this.id,
    this.username,
    this.email,
    this.userType = 'passenger',
    this.userLatitude,
    this.userLongitude,
    this.heading,
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      userType: data['userType'],
      userLatitude: data['userLatitude'],
      userLongitude: data['userLongitude'],
      heading: data['heading'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {};

    void addNonNull(String key, dynamic value) {
      if (value != null) {
        data[key] = value;
      }
    }

    addNonNull('id', id);
    addNonNull('username', username);
    addNonNull('email', email);
    addNonNull('userType', userType);
    addNonNull('userLatitude', userLatitude);
    addNonNull('userLongitude', userLongitude);
    addNonNull('heading', heading);

    return data;
  }
}
