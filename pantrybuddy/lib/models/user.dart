class User {
  final String userId; //final as unchangeable, UID & username are separate
  final String? email;
  final String? inventoryID;

  User({required this.userId, required this.email, required this.inventoryID});

  // Convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'InventoryID': inventoryID
    };
  }

  // Create a User object from a JSON map
  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      inventoryID: json['inventoryID']
    );
  }
}
