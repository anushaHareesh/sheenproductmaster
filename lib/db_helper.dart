import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'model/registration_model.dart';

class SheenProductDB {
  static final SheenProductDB instance = SheenProductDB._init();
  static Database? _database;
  SheenProductDB._init();
  //////////////////////////////////////

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("sheenDB.db");
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(
      path,
      version: 1, onCreate: _createDB,
      // onUpgrade: _upgradeDB
    );
  }

  Future _createDB(Database db, int version) async {
    ///////////////barcode store table ////////////////

    await db.execute('''
          CREATE TABLE companyRegistrationTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cid TEXT NOT NULL,
            fp TEXT NOT NULL,
            os TEXT NOT NULL,
            type TEXT,
            app_type TEXT,
            cpre TEXT,
            ctype TEXT,
            cnme TEXT,
            ad1 TEXT,
            ad2 TEXT,
            ad3 TEXT,
            pcode TEXT,
            land TEXT,
            mob TEXT,
            em TEXT,
            gst TEXT,
            ccode TEXT,
            scode TEXT,
            msg TEXT
          )
          ''');

// ////////////// registration table ////////////
    await db.execute('''
          CREATE TABLE staffDetailsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sid TEXT NOT NULL,
            sname TEXT,
            uname TEXT,
            pwd TEXT,
            ad1 TEXT,
            ad2 TEXT,
            ad3 TEXT,
            ph TEXT,
            area TEXT    
          )
          ''');
    await db.execute('''
          CREATE TABLE settingsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            set_id INTEGER NOT NULL,
            set_code TEXT,
            set_value TEXT,
            set_type INTEGER  
          )
          ''');
    await db.execute('''
          CREATE TABLE enquiryTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemName TEXT NOT NULL,
            code TEXT,
            qty REAL,
            rate REAL,
            totalamount REAL,
            enqdate TEXT,
            enqtime TEXT,
            cartrowno INTEGER
          )
          ''');
  }

/////////////////////////////////////////////////////////////////////////
  Future insertRegistrationDetails(RegistrationData data) async {
    final db = await database;
    var query1 =
        'INSERT INTO companyRegistrationTable(cid, fp, os, type, app_type, cpre, ctype, cnme, ad1, ad2, ad3, pcode, land, mob, em, gst, ccode, scode, msg) VALUES("${data.cid}", "${data.fp}", "${data.os}","${data.type}","${data.apptype}","${data.c_d![0].cpre}", "${data.c_d![0].ctype}", "${data.c_d![0].cnme}", "${data.c_d![0].ad1}", "${data.c_d![0].ad2}", "${data.c_d![0].ad3}", "${data.c_d![0].pcode}", "${data.c_d![0].land}", "${data.c_d![0].mob}", "${data.c_d![0].em}", "${data.c_d![0].gst}", "${data.c_d![0].ccode}", "${data.c_d![0].scode}", "${data.msg}" )';
    var res = await db.rawInsert(query1);
    print(query1);
    print("registered ----$res");
    return res;
  }

  //////////////////////////////////////////////////////////////////////////////
  Future insertEnqTable(
    String itemName,
    String code,
    double qty,
    double rate,
    double totalamount,
    String enqdate,
    String enqtime,
    int cartrowno,
  ) async {
    print("qty--$qty");
    print("code...........$code");
    final db = await database;
    var res;

    List<Map<String, dynamic>> res1 =
        await db.rawQuery('SELECT  * FROM enquiryTable WHERE code="$code"');
    print("SELECT from ---$res1");

    if (res1.length == 1) {
      int qty1 = res1[0]["qty"];
      double updatedQty = qty1 + qty;
      double amount = res1[0]["totalamount"];
      double updatedAmount = amount + totalamount;
      var quer =
          'UPDATE enquiryTable SET qty=$updatedQty , totalamount="$updatedAmount" WHERE code="$code"';
      // ignore: avoid_print
      print("updateion query-------$quer");
      res = await db.rawUpdate(quer);
    } else {
      var query2 =
          'INSERT INTO enquiryTable (itemName, code, qty, rate, totalamount, cartdate, carttime ,cartrowno) VALUES ("$itemName","$code", $qty, $rate, $totalamount, "$enqdate}","$enqtime",  $cartrowno, )';
      res = await db.rawInsert(query2);
      // ignore: avoid_print
      print("updateion query-------$query2");
    }
    return res;
  }

////////////////////////////////////////////////////////////////////////////////
  deleteFromTableCommonQuery(String table, String? condition) async {
    // ignore: avoid_print
    print("table--condition -$table---$condition");
    Database db = await instance.database;
    if (condition == null || condition.isEmpty || condition == "") {
      // ignore: avoid_print
      print("no condition");
      await db.delete('$table');
    } else {
      // ignore: avoid_print
      print("condition");

      await db.rawDelete('DELETE FROM "$table" WHERE $condition');
    }
  }

///////////////////////////////////////////////////////////////////////////////
  selectCommonQuery(String table, String? condition, String fields) async {
    List<Map<String, dynamic>> result;
    Database db = await instance.database;
    var query = "SELECT $fields FROM '$table'";
    result = await db.rawQuery(query);
    print("naaknsdJK-----$result");
    return result;
  }

  ///////////////////////////////////////////////////////////////////////////
  updateCommonQuery(String table, String fields, String condition) async {
    Database db = await instance.database;
    var query = 'UPDATE $table SET $fields WHERE $condition ';
    var res = await db.rawUpdate(query);
    return res;
  }

  ///////////////////////////////////////////////////////////////////////////
  getMaxCommonQuery(String table, String field, String? condition) async {
    var res;
    int max;
    Database db = await instance.database;
    var result = await db.rawQuery("SELECT * FROM '$table'");
    if (result != null && result.isNotEmpty) {
      var query = "SELECT MAX($field) max_val FROM '$table'";

      res = await db.rawQuery(query);

      // int convertedMax = int.parse(res[0]["max_val"]);
      max = res[0]["max_val"] + 1;
    } else {
      max = 1;
    }

    return max;
  }
}
