class CustomerModel {
  CustomerModel(
      {required this.email,
      required this.userName,
      required this.password,
      this.firstName,
      this.lastName,
      this.billing});
  String email;
  String userName;
  String password;
  String? firstName;
  String? lastName;
  Map<String, dynamic>? billing;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map.addAll({
      'email': email,
      'username': userName,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'billing': billing,
    });
    return map;
  }
}
