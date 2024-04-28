class Spoonacular {
  final String id;
  final String name;

  Spoonacular({required this.id, required this.name});

  factory Spoonacular.fromJson(Map<String, dynamic> json) {
    String name = json['title'] ?? json['title']; // ingredients endpoint does not have title
    return Spoonacular(
      id: json['id'].toString(),
      name: name,
    );
  }
}
