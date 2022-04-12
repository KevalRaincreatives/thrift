class UploadImageModel {
  String? name;
  String? file;


  UploadImageModel(
      {this.name,
        this.file});

  factory UploadImageModel.fromJson(Map<String, dynamic> json) {
    return UploadImageModel(
      name: json['name'],
        file: json['file'],
  );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['file'] = this.file;
    return data;
  }
}