class Spoonacular {
  final String id;
  final String name;

  Spoonacular({required this.id, required this.name});

  static Spoonacular fromJson(Map<String, dynamic> json) {
    String name = json['title'] ?? json['name']; // ingredients endpoint does not have title
    return Spoonacular(
      id: json['id'].toString(),
      name: name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

}
