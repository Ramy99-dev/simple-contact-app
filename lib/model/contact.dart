class ContactModel {
  final int id;
  final String username;
  final String number;

  const ContactModel(
      {required this.id, required this.username, required this.number});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json["id"],
      username: json["name"],
      number: json["phone"],
    );
  }
}
