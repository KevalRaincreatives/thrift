class StaticPaymentModel {
  String? id;
  String? title;


  StaticPaymentModel(
      {this.id,
        this.title});

  factory StaticPaymentModel.fromJson(Map<String, dynamic> json) {
    return StaticPaymentModel(
        id: json['id'],
        title: json['title']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}