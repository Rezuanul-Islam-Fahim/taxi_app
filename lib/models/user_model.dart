class User {
  final String? id;
  final String? userName;
  final String? email;

  const User({this.id, this.userName, this.email});

  Map<String, dynamic> toMap() => {
        'id': id,
        'userName': userName,
        'email': email,
      };
}
