///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class AttributeModelDataAttributesValues {
/*
{
  "term_id": 176,
  "name": "Black",
  "slug": "black",
  "term_group": 0,
  "term_taxonomy_id": 176,
  "taxonomy": "pa_color",
  "description": "",
  "parent": 0,
  "count": 0,
  "filter": "raw"
}
*/

  int? termId;
  String? name;
  String? slug;
  int? termGroup;
  int? termTaxonomyId;
  String? taxonomy;
  String? description;
  int? parent;
  int? count;
  String? filter;

  AttributeModelDataAttributesValues({
    this.termId,
    this.name,
    this.slug,
    this.termGroup,
    this.termTaxonomyId,
    this.taxonomy,
    this.description,
    this.parent,
    this.count,
    this.filter,
  });
  AttributeModelDataAttributesValues.fromJson(Map<String, dynamic> json) {
    termId = json['term_id']?.toInt();
    name = json['name']?.toString();
    slug = json['slug']?.toString();
    termGroup = json['term_group']?.toInt();
    termTaxonomyId = json['term_taxonomy_id']?.toInt();
    taxonomy = json['taxonomy']?.toString();
    description = json['description']?.toString();
    parent = json['parent']?.toInt();
    count = json['count']?.toInt();
    filter = json['filter']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['term_id'] = termId;
    data['name'] = name;
    data['slug'] = slug;
    data['term_group'] = termGroup;
    data['term_taxonomy_id'] = termTaxonomyId;
    data['taxonomy'] = taxonomy;
    data['description'] = description;
    data['parent'] = parent;
    data['count'] = count;
    data['filter'] = filter;
    return data;
  }
}

class AttributeModelDataAttributes {
/*
{
  "title": "color",
  "values": [
    {
      "term_id": 176,
      "name": "Black",
      "slug": "black",
      "term_group": 0,
      "term_taxonomy_id": 176,
      "taxonomy": "pa_color",
      "description": "",
      "parent": 0,
      "count": 0,
      "filter": "raw"
    }
  ]
}
*/

  String? title;
  List<AttributeModelDataAttributesValues?>? values;

  AttributeModelDataAttributes({
    this.title,
    this.values,
  });
  AttributeModelDataAttributes.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    if (json['values'] != null) {
      final v = json['values'];
      final arr0 = <AttributeModelDataAttributesValues>[];
      v.forEach((v) {
        arr0.add(AttributeModelDataAttributesValues.fromJson(v));
      });
      values = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    if (values != null) {
      final v = values;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['values'] = arr0;
    }
    return data;
  }
}

class AttributeModelData {
/*
{
  "attributes": [
    {
      "title": "color",
      "values": [
        {
          "term_id": 176,
          "name": "Black",
          "slug": "black",
          "term_group": 0,
          "term_taxonomy_id": 176,
          "taxonomy": "pa_color",
          "description": "",
          "parent": 0,
          "count": 0,
          "filter": "raw"
        }
      ]
    }
  ]
}
*/

  List<AttributeModelDataAttributes?>? attributes;

  AttributeModelData({
    this.attributes,
  });
  AttributeModelData.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      final v = json['attributes'];
      final arr0 = <AttributeModelDataAttributes>[];
      v.forEach((v) {
        arr0.add(AttributeModelDataAttributes.fromJson(v));
      });
      attributes = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (attributes != null) {
      final v = attributes;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['attributes'] = arr0;
    }
    return data;
  }
}

class AttributeModel {
/*
{
  "success": true,
  "data": {
    "attributes": [
      {
        "title": "color",
        "values": [
          {
            "term_id": 176,
            "name": "Black",
            "slug": "black",
            "term_group": 0,
            "term_taxonomy_id": 176,
            "taxonomy": "pa_color",
            "description": "",
            "parent": 0,
            "count": 0,
            "filter": "raw"
          }
        ]
      }
    ]
  }
}
*/

  bool? success;
  AttributeModelData? data;

  AttributeModel({
    this.success,
    this.data,
  });
  AttributeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = (json['data'] != null) ? AttributeModelData.fromJson(json['data']) : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    if (data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}