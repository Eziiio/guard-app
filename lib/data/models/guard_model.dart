class GuardModel {
  final String uid;
  final String name;
  final bool isOnline;

  GuardModel({required this.uid, required this.name, required this.isOnline});

  Map<String, dynamic> toMap() {
    return {"uid": uid, "name": name, "isOnline": isOnline};
  }

  factory GuardModel.fromMap(Map<String, dynamic> map) {
    return GuardModel(
      uid: map["uid"],
      name: map["name"],
      isOnline: map["isOnline"],
    );
  }
}
