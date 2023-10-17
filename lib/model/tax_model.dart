class TaxModel {
  int? taxId;
  String? taxType;

  TaxModel({
    this.taxId,
    this.taxType,
  });

  TaxModel.fromJson(Map<String, dynamic> json) {
    taxId = json['taxId'];
    taxType = json['taxType'];
  }
  static List<TaxModel> fromJsonList(List list) {
    if (list == null) return [];
    return list.map((item) => TaxModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['taxType'] = this.taxType;
    data['taxId'] = this.taxId;

    return data;
  }
}
