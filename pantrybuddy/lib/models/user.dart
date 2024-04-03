class User {
  final String userId; //final as unchangeable, UID & username are separate
  final String? email;
  final String? inventoryId;

  User({
    required this.userId,
    required this.email,
    required this.inventoryId,
  });

  // Convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'inventoryId': inventoryId,
    };
  }

  // Create a User object from a JSON map
  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      inventoryId: json['inventoryId'],
    );
  }
}
