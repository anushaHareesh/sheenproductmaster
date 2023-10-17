class ProductModel {
  int? prodId;
  String? prodName;
  int? flgExists;

  ProductModel({this.prodId, this.prodName, this.flgExists});

  ProductModel.fromJson(Map<String, dynamic> json) {
    prodId = json['prodId'];
    prodName = json['prodName'];
    flgExists = json['flgExists'];
  }
  static List<ProductModel> fromJsonList(List list) {
    if (list == null) return [];
    return list.map((item) => ProductModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['prodName'] = this.prodName;
    data['prodId'] = this.prodId;
    data['flgExists'] = this.flgExists;
    return data;
  }
}
