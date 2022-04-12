class AddProMetaModel2 {
  String? key;
  dynamic? value;


  AddProMetaModel2(
      {this.key,
        this.value});

  factory AddProMetaModel2.fromJson(Map<String, dynamic> json) {
    return AddProMetaModel2(
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