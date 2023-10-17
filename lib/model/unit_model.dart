class UnitModel {
  int? unitId;
  String? unitName;
  UnitModel({
    this.unitId,
    this.unitName,
  });

  UnitModel.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId'];
    unitName = json['unitName'];
  }

  bool? get isEmpty => null;
  static List<UnitModel> fromJsonList(List list) {
    if (list == null) return [];
    return list.map((item) => UnitModel.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unitName'] = this.unitName;
    data['unitId'] = this.unitId;
    return data;
  }
}
