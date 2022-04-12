class MyVariant {
  String? attr_name;
  String? attr_optn;


  MyVariant(
      {this.attr_name,
        this.attr_optn});

  factory MyVariant.fromJson(Map<String, dynamic> json) {
    return MyVariant(
        attr_name: json['attr_name'],
        attr_optn: json['attr_optn']);
  }

  Map<String, dynamic> toJson() {
    return {
      'attr_name': attr_name,
      'attr_optn': attr_optn,
    };
  }
}