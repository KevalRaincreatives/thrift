class CreateProModel {
  int? id;
  String? name;


  CreateProModel(
      {this.id,
        this.name});

  factory CreateProModel.fromJson(Map<String, dynamic> json) {
    return CreateProModel(
      id: json['id'].toInt(),

      name: json['name'],
  );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;

    data['name'] = this.name;
    return data;
  }
}