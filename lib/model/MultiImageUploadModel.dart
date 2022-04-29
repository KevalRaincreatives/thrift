class MultiImageUploadModel {
  String? name;
  String? path;
  String? newImage;
  String? ImageId;

  MultiImageUploadModel(this.name,this.path,this.newImage,this.ImageId);

  MultiImageUploadModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    path = json['path'];
    newImage= json['newImage'];
    ImageId= json['ImageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['path'] = this.path;
    data['newImage']=this.newImage;
    data['ImageId']=this.ImageId;
    return data;
  }
}

