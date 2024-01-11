import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kantongku/component/snackbar.dart';
import 'package:kantongku/component/url_server.dart';
import 'package:kantongku/model/transaction_model.dart';

class TransactionRepository {
  static String urlServer = UrlServer.urlServer;

  static Future<List<Transaction>> getAllData(userId) async {
    Uri url = Uri.parse("$urlServer/transactions/user/$userId");

    var response = await get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as List;
      return jsonResponse.map((e) => Transaction.createFromJson(e)).toList();
    }
    return [];
  }

  static Future addData(
      context, userId, category, amount, dateTime, description) async {
    try {
      Response response = await post(
        Uri.parse("$urlServer/transactions"),
        body: {
          "user_id": userId,
          "category": category,
          "amount": amount,
          "date_time": dateTime,
          "description": description,
        },
      );
      if (response.statusCode == 201) {
        Navigator.pop(context);
        Navigator.pop(context);

        GlobalSnackBar.show(context, 'Transaksi berhasil ditambahkan.');
      } else {
        Navigator.pop(context);
        GlobalSnackBar.show(context, 'Transaksi gagal ditambahkan');
      }
    } catch (e) {
      Navigator.pop(context);
      GlobalSnackBar.show(context, e.toString());
    }
  }

  static Future updateData(context, transactionId, amount, description) async {
    try {
      Response response = await put(
        Uri.parse("$urlServer/transactions/$transactionId"),
        body: {
          "amount": amount,
          "description": description,
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        GlobalSnackBar.show(context, 'Transaksi berhasil diubah.');
      } else {
        Navigator.pop(context);
        GlobalSnackBar.show(context, 'Transaksi gagal diubah');
      }
    } catch (e) {
      Navigator.pop(context);
      GlobalSnackBar.show(context, e.toString());
    }
  }

  static Future deleteData(context, transactionId) async {
    try {
      Response response = await delete(
        Uri.parse("$urlServer/transactions/$transactionId"),
      );
      var jsonR = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        GlobalSnackBar.show(context, 'Transaksi berhasil dihapus.');
      } else {
        debugPrint(jsonR);
        Navigator.pop(context);
        Navigator.pop(context);
        GlobalSnackBar.show(context, 'Transaksi gagal dihapus.');
      }
    } catch (e) {
      debugPrint(e.toString());

      Navigator.pop(context);
      Navigator.pop(context);
      GlobalSnackBar.show(context, e.toString());
    }
  }
}
