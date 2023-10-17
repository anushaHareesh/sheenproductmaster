class CatModel {
  int? catId;
  String? catName;

  CatModel({
    this.catId,
    this.catName,
  });

  CatModel.fromJson(Map<String, dynamic> json) {
    catId = json['catId'];
    catName = json['catName'];
  }
  static List<CatModel> fromJsonList(List list) {
    print("list-------$list");
    if (list == null) return [];
    return list.map((item) => CatModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['catName'] = this.catName;
    data['catId'] = this.catId;

    return data;
  }
}
