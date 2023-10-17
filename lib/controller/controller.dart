import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheenproductmaster/model/product_model.dart';
import 'package:sheenproductmaster/model/tax_model.dart';
import 'package:sheenproductmaster/model/unit_model.dart';
import 'package:sheenproductmaster/user_model.dart';
import 'package:sql_conn/sql_conn.dart';

import '../model/category_model.dart';

class Controller extends ChangeNotifier {
  List<ProductModel> product_list = [];
  bool flag = false;
  bool error = false;
  // Future<List<UserModel>> getData(filter) async {
  //   final queryParameters = {'filter': filter};
  //   List list = [];
  //   final uri = Uri.parse("http://192.168.18.168/clinic2/API/initialize.php");
  //   Map body = {"branch_id": "1"};
  //   final response = await http.post(uri, body: body);

  //   var map = jsonDecode(response.body);
  //   print("response.data--${response.body}--");
  //   // var map = jsonDecode(data);

  //   if (map != null) {
  //     list.clear();
  //     for (var item in map) {
  //       list.add(item);
  //     }
  //     return UserModel.fromJsonList(list);
  //     // return list;
  //   }

  //   return [];
  // }

  Future<List<UserModel>> getData(filter) async {
    final queryParameters = {'filter': filter};
    List list = [];
    final uri = Uri.parse("https://63c1210999c0a15d28e1ec1d.mockapi.io/users")
        .replace(queryParameters: {'filter': filter});
    final response = await http.get(uri);

    var map = jsonDecode(response.body);
    print("response.data--$map-----${map.runtimeType}--");
    // var map = jsonDecode(data);

    if (map != null) {
      list.clear();
      for (var item in map) {
        list.add(item);
      }
      return UserModel.fromJsonList(list);
      // return list;
    }

    return [];
  }

//////////////////////////////////////////////////////////////////////
  Future<List<CatModel>> getCategory(String filter) async {
    List<CatModel> list = [];
    print("filter----$filter");
    // var res = await SqlConn.readData(
    //     "SELECT fld0401 AS catId,fld0402 as catName FROM TAB04 WHERE  fld0402 LIKE '$filter%' ORDER BY FLD0402 ");
    String f = filter.trim();

    var res = await SqlConn.readData("Flt_Sp_Cat '$f'");
    var valueMap = json.decode(res);
    print("category qyery---${valueMap}");

    if (res != null) {
      list.clear();
      for (var item in valueMap) {
        list.add(CatModel.fromJson(item));
      }
      // for(int i=0;i<list.length;i++){
      //   if()
      // }
      print("cat model--------$list");
      return list;
      // return list;
    }

    return [];
  }

//////////////////////////////////////////////////////////////////
  Future<List<UnitModel>> getUnit(String filter) async {
    List<UnitModel> list = [];
    // var res = await SqlConn.readData(
    //     "SELECT fld8801 AS unitId,fld8802 as unitName FROM TAB88 WHERE  fld8802 LIKE '$filter%' ORDER BY fld8802");
    String f = filter.trim();

    var res = await SqlConn.readData("Flt_Sp_Unit '$f'");
    var valueMap = json.decode(res);

    if (res != null) {
      list.clear();
      for (var item in valueMap) {
        list.add(UnitModel.fromJson(item));
      }
      print("cat model--------$list");
      return list;
      // return list;
    }

    return [];
  }

//////////////////////////////////////////////////////////////////
  Future<List<TaxModel>> getTaxType(String filter) async {
    List<TaxModel> list = [];
    // var res = await SqlConn.readData(
    //     "SELECT fld1301 AS taxId,fld1302 as taxType FROM TAB13 WHERE  fld1302 LIKE '$filter%' ORDER BY fld1301");
    String f = filter.trim();
    var res = await SqlConn.readData("Flt_Sp_Tax '$f'");
    var valueMap = json.decode(res);
    print("tax map--------$res");
    if (res != null) {
      list.clear();
      for (var item in valueMap) {
        list.add(TaxModel.fromJson(item));
      }
      print("cat model--------$list");
      return list;
      // return list;
    }

    return [];
  }

  ///////////////////////////////////////////////
  getProduct(String filter) async {
    // var res = await SqlConn.readData(
    //     "SELECT fld1301 AS taxId,fld1302 as taxType FROM TAB13 WHERE  fld1302 LIKE '$filter%' ORDER BY fld1301");
    String f = filter.trim();
    var res = await SqlConn.readData("Flt_Sp_Product '$f'");
    var valueMap = json.decode(res);
    print("Product map--------$res");
    if (res != null) {
      product_list.clear();
      for (var item in valueMap) {
        product_list.add(ProductModel.fromJson(item));
      }
      if (product_list.length != 0) {
        if (product_list[0].flgExists! > 0) {
          flag = true;
          notifyListeners();
        } else {
          flag = false;
          notifyListeners();
        }
      }else{
        flag = false;
          notifyListeners();
      }

      print("product model--------$product_list");
      notifyListeners();
    }
    return [];
  }

///////////////////////////////////////////////////////////////////////
  saveProduct(String product_name, int tax_id, int cat_id, int unit_id,
      String hsn, String ean, double sales_rate) async {
    print(
        "datas----------------$product_name,$tax_id,$cat_id,$unit_id,$hsn,$ean,$sales_rate");
    try {
      var res = await SqlConn.readData(
          "Flt_Sp_Save_Item '$product_name','$tax_id','$cat_id','$unit_id','$hsn','$ean','$sales_rate'");
      print("response map--------$res");

      var valueMap = json.decode(res);
      print("response valueMap--------$valueMap");
      if (valueMap[0]["cnt"] > 0) {
        Fluttertoast.showToast(
          msg: 'Product Saved Successfully ',
          textColor: Colors.white,
          backgroundColor: Colors.green,
        );
        product_list.clear();
        notifyListeners();
      }
    } catch (e) {
      print("error-------${e}");
      error = true;
      notifyListeners();
    }

    return [];
  }

  initDb(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? db = prefs.getString("db_name");
    String? ip = prefs.getString("ip");
    String? port = prefs.getString("port");
    String? un = prefs.getString("usern");
    String? pw = prefs.getString("pass_w");
    debugPrint("Connecting...");
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Please wait",
                  style: TextStyle(fontSize: 13),
                ),
                SpinKitCircle(
                  color: Colors.green,
                )
              ],
            ),
          );
        },
      );
      await SqlConn.connect(
          ip: ip!,
          port: port!,
          databaseName: db!,
          username: un!,
          password: pw!);
      debugPrint("Connected!");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }
}
