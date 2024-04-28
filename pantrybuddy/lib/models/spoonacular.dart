class Spoonacular {
  final String id;
  final String name;

  Spoonacular({required this.id, required this.name});

  factory Spoonacular.fromJson(Map<String, dynamic> json) {
    return Spoonacular(
      id: json['id'].toString(), // Ensure this matches the key in the JSON response
      name: json['name'] // This should match the 'name' or 'title' key in the JSON response
    );
  }
}