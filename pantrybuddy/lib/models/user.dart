class User {
  final String userId; //final as unchangeable, UID & username are separate
  final String email;
  String? pantry;

  User({required this.userId, required this.email, this.pantry});

  // Convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email, "pantry": pantry};
  }

  // Create a User object from a JSON map
  static User fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'], email: json['email'], pantry: json['pantry']);
  }
}
