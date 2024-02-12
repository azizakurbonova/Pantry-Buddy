enum ItemIdType { EAN, UPC, PLU, Manual }

class GroceryItem {
  String itemId;
  String name;
  String category;
  int quantity;
  DateTime expirationDate;
  String? nutriScore;
  String? ecoScore;
  ItemIdType itemIdType; // Assuming this is a String that can be either 'EAN', 'UPC', or 'PLU', or 'Manual'
  String? nutritionalInfo;

  //Need to enforce that itemIdType has to be either "EAN","UPC","PLU", or "Manual"
  GroceryItem({
    required this.itemId,
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.expirationDate,
    this.nutriScore, //optional, only for products from the Open Food Facts DB
    this.ecoScore, //optional, only for products from the Open Food Facts DB
    required this.itemIdType,
    this.nutritionalInfo, //optional, only for products from the Open Food Facts DB
  });

  // Method to display nutritional score
  String? viewNutriScore() {
    // Assuming this method just returns the nutriScore for now
    return nutriScore;
  }

  // Method to display eco score
  String? viewEcoScore() {
    // Assuming this method just returns the ecoScore for now
    return ecoScore;
  }

  // Method to display nutritional information
  String? viewNutritionalInfo() {
    // Assuming this method just returns the nutritionalInfo for now
    return nutritionalInfo;
  }

  void setQuantity(int newQuantity) {
    if (newQuantity > 0) {
      quantity = newQuantity;
    } else {
      // Handle the case where the new quantity is less than 1.
      // This might involve setting the quantity to 0, throwing an error, etc.
      // For this example, we'll just print a message and not change the quantity.
      print('Invalid quantity. The quantity must be greater than 0.');
    }
  }

  // Convert a GroceryItem object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'category': category,
      'expirationDate': expirationDate.toIso8601String(),
      'nutriScore': nutriScore,
      'ecoScore': ecoScore,
      'itemIdType': itemIdType,
      'nutritionalInfo': nutritionalInfo,
    };
  }

  // Create a GroceryItem object from a JSON map
  static GroceryItem fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      itemId: json['itemId'],
      name: json['name'],
      category: json['category'],
      expirationDate: DateTime.parse(json['expirationDate']),
      nutriScore: json['nutriScore'],
      ecoScore: json['ecoScore'],
      itemIdType: json['itemIdType'],
      nutritionalInfo: json['nutritionalInfo'],
    );
  }
}
