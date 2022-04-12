class AddProMetaModel {
  String? key;
  String? value;


  AddProMetaModel(
      {this.key,
        this.value});

  factory AddProMetaModel.fromJson(Map<String, dynamic> json) {
    return AddProMetaModel(
        key: json['key'],
        value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}