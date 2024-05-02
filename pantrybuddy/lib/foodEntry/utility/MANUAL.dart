Future<Map<String, dynamic>> prepareDropdownData(List<Map<String, dynamic>> csvData) async {
  Set<String> categoryNames = {};
  Map<String, List<String>> nameAllByCategory = {};

  for (var row in csvData) {
    String categoryName = row['Category_Name'].toString().trim(); // Ensuring to trim any whitespace
    String nameAll = row['NAME_all'].toString().trim(); // Ensuring to trim any whitespace

    categoryNames.add(categoryName);
    if (!nameAllByCategory.containsKey(categoryName)) {
      nameAllByCategory[categoryName] = ["N/A"];
    }
    nameAllByCategory[categoryName]?.add(nameAll);
  }

  return {
    'Category_Name': categoryNames.toList(),
    'Name_ALL': nameAllByCategory
  };
}



