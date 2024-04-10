Future<DateTime?> pickExpirationDate(BuildContext context) async {
  final DateTime now = DateTime.now();
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: now, // Initial date to show in picker
    firstDate: now, // Earliest selectable date
    lastDate: DateTime(now.year + 5), // Latest selectable date, assuming 5 years into the future
  );

  return pickedDate;
}