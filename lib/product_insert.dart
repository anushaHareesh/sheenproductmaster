import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheenproductmaster/login.dart';
import 'package:sheenproductmaster/model/category_model.dart';
import 'package:sheenproductmaster/model/tax_model.dart';
import 'package:sheenproductmaster/model/unit_model.dart';
import 'package:sheenproductmaster/user_model.dart';
import 'package:sql_conn/sql_conn.dart';

import 'controller/controller.dart';

class ProductInsert extends StatefulWidget {
  const ProductInsert({super.key});

  @override
  State<ProductInsert> createState() => _ProductInsertState();
}

class _ProductInsertState extends State<ProductInsert> {
  final _formKey = GlobalKey<FormState>();
  // final _key1 = GlobalKey<FormFieldState>();

  int? tax_id;
  int? cat_id;
  int? unit_id;
  TextEditingController prod = TextEditingController();
  TextEditingController hsn = TextEditingController();
  TextEditingController ean = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController unitCon = TextEditingController();
  TextEditingController taxCon = TextEditingController();
  TextEditingController catCon = TextEditingController();

  Future<void> connect(BuildContext ctx) async {
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
      // await SqlConn.connect(
      //     ip: "103.177.225.245",
      //     port: "54321",
      //     databaseName: "SBK69715",
      //     username: "sa",
      //     password: "##v0e3g9a#");
      // debugPrint("Connected!");
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // connect(context);
      Provider.of<Controller>(context, listen: false).initDb(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_vert,
                  color: Colors.white), // add this line
              itemBuilder: (_) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                        child: Container(
                            width: 100,
                            // height: 30,
                            child: const Text(
                              "Logout",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 245, 87, 76),
                                  fontWeight: FontWeight.bold),
                            )),
                        value: 'logout'),
                  ],
              onSelected: (index) async {
                switch (index) {
                  case 'logout':
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('st_uname');
                    await prefs.remove('st_pwd');
                    // ignore: use_build_context_synchronously
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return LoginPage();
                        },
                      ),
                      (_) => false,
                    );
                    break;
                }
              })
        ],
        centerTitle: true,
        title: Text("Product Creation"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        // physics: ScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Consumer<Controller>(
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  /////////////////product name//////////////////
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus != true) {
                        Provider.of<Controller>(context, listen: false)
                            .getProduct(prod.text);
                      }
                    },
                    child: TextFormField(
                      // keyboardType: TextInputType.,
                      // inputFormatters: [
                      //   FilteringTextInputFormatter.digitsOnly,
                      // ],
                      // inputFormatters: [
                      //   FilteringTextInputFormatter(RegExp("[a-zA-Z]"),
                      //       allow: true),
                      // ],
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z ]")),
                      ],
                      controller: prod,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 13),
                        hintText: "Product Name *",
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Please Enter Product Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  value.flag
                      ? SizedBox(
                          height: size.height * 0.008,
                        )
                      : Container(),
                  value.flag
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "Product already Exist!!!",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red),
                            ),
                          ],
                        )
                      : Container(),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  ////////////category id///////////////////////
                  DropdownSearch<CatModel>(
                    validator: (text) {
                      if (text == null) {
                        return 'Please Select Category';
                      }
                      return null;
                    },
                    // key: _key1,
                    itemAsString: (item) => item.catName.toString(),
                    asyncItems: (filter) =>
                        Provider.of<Controller>(context, listen: false)
                            .getCategory(filter),
                    popupProps: PopupProps.menu(
                      isFilterOnline: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: catCon,
                        decoration: InputDecoration(
                            hintText: "Type Here",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ),
                    // items: ["anu", "shilpa", "danush"],
                    onChanged: (values) {
                      // print("valuee----${values!.catId}");
                      cat_id = values!.catId;
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Select Category *",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  /////////////////tax id///////////////////////////////
                  DropdownSearch<TaxModel>(
                    validator: (text) {
                      if (text == null) {
                        return 'Please Select Tax %';
                      }
                      return null;
                    },
                    itemAsString: (item) => item.taxType.toString(),
                    asyncItems: (filter) =>
                        Provider.of<Controller>(context, listen: false)
                            .getTaxType(filter),
                    popupProps: PopupProps.menu(
                      isFilterOnline: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: taxCon,
                        decoration: InputDecoration(
                            hintText: "Type Here",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ),
                    // items: ["anu", "shilpa", "danush"],
                    onChanged: (values) {
                      tax_id = values!.taxId;
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Select Tax % *",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  /////////////////hsn/////////////////////////
                  TextFormField(
                    controller: hsn,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 13),
                      hintText: "Hsn code",
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  ////////////////Ean ///////////////////////////////////////////
                  TextFormField(
                    controller: ean,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 104, 103, 103),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 13),
                      hintText: "Ean",
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  ///////////////////////unit////////////////
                  DropdownSearch<UnitModel>(
                    validator: (text) {
                      if (text == null) {
                        return 'Please Select Unit';
                      }
                      return null;
                    },
                    itemAsString: (item) => item.unitName.toString(),
                    asyncItems: (filter) =>
                        Provider.of<Controller>(context, listen: false)
                            .getUnit(filter),
                    popupProps: PopupProps.menu(
                      isFilterOnline: true,
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        controller: unitCon,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Type Here",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                      ),
                    ),
                    // items: ["anu", "shilpa", "danush"],
                    onChanged: (values) {
                      print("valuee----$values");
                      unit_id = values!.unitId;
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Select Unit *",
                            hintStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ))),
                  ),
                  // DropdownSearch<String>(
                  //   popupProps: PopupProps.menu(
                  //     showSelectedItems: true,
                  //     showSearchBox: true,
                  //     searchFieldProps: TextFieldProps(
                  //       decoration: InputDecoration(
                  //           hintText: "Type Here",
                  //           hintStyle: TextStyle(color: Colors.grey[500]),
                  //           enabledBorder: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //           )),
                  //     ),
                  //   ),
                  //   items: ["anu", "shilpa", "danush"],
                  //   onChanged: (value) {
                  //     print("valuee----$value");
                  //   },
                  //   dropdownDecoratorProps: DropDownDecoratorProps(
                  //       dropdownSearchDecoration: InputDecoration(
                  //           hintText: "Select Unit",
                  //           hintStyle: TextStyle(color: Colors.grey[500]),
                  //           enabledBorder: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //           ),
                  //           border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10.0),
                  //           ))),
                  // ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),

                  ///////////////sale rate///////
                  TextFormField(
                    controller: rate,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 13),
                      hintText: "Sales Rate *",
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please Enter Sale Rate';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.5,
                        height: size.height * 0.05,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: value.flag
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      print(
                                          "jnf-----$unit_id--$tax_id---$cat_id");
                                      Provider.of<Controller>(context,
                                              listen: false)
                                          .saveProduct(
                                              prod.text,
                                              tax_id!,
                                              cat_id!,
                                              unit_id!,
                                              hsn.text,
                                              ean.text,
                                              double.parse(rate.text));
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  super.widget));
                                    }
                                  },
                            child: Text(
                              "SAVE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                          onTap: () {
                            value.product_list.clear();
                            value.flag = false;
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        super.widget));
                          },
                          child: Icon(
                            Icons.refresh,
                            color: Colors.green,
                            size: 30,
                          ))
                    ],
                  ),
                  value.error
                      ? SizedBox(
                          height: size.height * 0.02,
                        )
                      : Container(),
                  value.error
                      ? Text(
                          "Insertion Failed , Please check the fields!!!",
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  value.product_list.length > 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "SIMILAR PRODUCT EXIST",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 153, 13, 3)),
                            )
                          ],
                        )
                      : Container(),
                  value.product_list.length > 0
                      ? Divider(thickness: 2, endIndent: 68, indent: 68)
                      : Container(),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: value.product_list.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Flexible(child: Text("sdbjsbdsd sdbjsbdjsd dsjdbjsbdsd dsjdbsjbd jsbdjds jhdjdghs hjbsdjhbddsdd"))
                            Flexible(
                                child: Text(
                              value.product_list[index].prodName.toString(),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent),
                            )),
                          ],
                        ),
                      );

                      // ListTile(
                      //   title:
                      //       Text(value.product_list[index].prodName.toString()),
                      // );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
//  Widget _customDropDownPrograms(BuildContext context, BootcampDetails? item) {
//     return Container(
//         child: (item == null)
//             ? const ListTile(
//                 contentPadding: EdgeInsets.all(0),
//                 title: Text("Search Programs",
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Color.fromARGB(235, 158, 158, 158))),
//               )
//             : ListTile(
//                 contentPadding: const EdgeInsets.all(0),
//                 title: Text(
//                   item.title,
//                   textAlign: TextAlign.left,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontSize: 13.5, color: Colors.black),
//                 )));
//   }

  Future<List<UserModel>> getData(filter) async {
    final queryParameters = {'filter': filter};
    List list = [];
    final uri = Uri.parse("https://63c1210999c0a15d28e1ec1d.mockapi.io/users")
        .replace(queryParameters: {'filter': filter});
    final response = await http.get(uri);

    var map = jsonDecode(response.body);
    print("response.data--${response.body}--");
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
}
