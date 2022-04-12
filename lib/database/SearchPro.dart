


import 'package:thrift/database/database_hepler2.dart';

class SearchPro {
  int? id;
  String? search_name;

  SearchPro(
      this.id,
      this.search_name);

  SearchPro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    search_name = json['search_name'];
  }

  Map<String, dynamic> toJson() {
    return {
      DatabaseHelper2.columnId: id,
      DatabaseHelper2.columnSearchName: search_name,

    };
  }

}