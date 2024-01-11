import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantongku/component/modal.dart';
import 'package:kantongku/component/snackbar.dart';
import 'package:kantongku/component/text_style.dart';
import 'package:kantongku/repository/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool isBudget = false, isBill = false;
  String userId = '',
      getDateNow = '',
      selectedDate = '',
      selectedCategory = '',
      selectedBudget = '',
      selectedBill = '',
      selectedSaving = '';
  TextEditingController amountCtl = TextEditingController();
  TextEditingController descCtl = TextEditingController();
  final CurrencyTextInputFormatter amountFormatter = CurrencyTextInputFormatter(
    locale: 'id',
    decimalDigits: 0,
    symbol: 'Rp ',
  );
  final addTransactFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    getDateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
    selectedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    getUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tambah Transaksi',
          style: TextStyleComp.mediumBoldPrimaryColorText(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(deviceWidth / 20),
        child: addTransactionForm(deviceWidth),
      ),
    );
  }

  Widget addTransactionForm(deviceWidth) {
    return Form(
      key: addTransactFormKey,
      child: ListView(
        children: [
          categoryDropDown(deviceWidth),
          amountTransTextFormField(deviceWidth),
          descTransTextFormField(deviceWidth),
          sendButton(deviceWidth),
        ],
      ),
    );
  }

  Widget categoryDropDown(deviceWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: deviceWidth / 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Transaksi',
            style: TextStyleComp.mediumText(context),
          ),
          ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField(
              isExpanded: false,
              items: [
                'Pendapatan',
                'Pengeluaran',
              ]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromRGBO(238, 238, 238, 1),
                hintText: 'Pilih kategori transaksi',
                hintStyle: TextStyleComp.mediumText(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(deviceWidth / 50)),
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(deviceWidth / 50)),
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value.toString();
                  isBudget = false;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Harus dipilih';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget amountTransTextFormField(deviceWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: deviceWidth / 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nominal Transaksi',
            style: TextStyleComp.mediumText(context),
          ),
          TextFormField(
            controller: amountCtl,
            autofocus: false,
            keyboardType: TextInputType.number,
            inputFormatters: [amountFormatter],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              hintText: 'Masukkan nominal transaksi',
              hintStyle: TextStyleComp.mediumText(context),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(deviceWidth / 50)),
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(deviceWidth / 50)),
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget descTransTextFormField(deviceWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: deviceWidth / 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: TextStyleComp.mediumText(context),
          ),
          TextFormField(
            controller: descCtl,
            maxLines: 3,
            autofocus: false,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              hintText: 'Masukkan deskripsi',
              hintStyle: TextStyleComp.mediumText(context),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(deviceWidth / 50)),
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(deviceWidth / 50)),
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Harus diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget sendButton(deviceWidth) {
    return ElevatedButton(
        onPressed: () async {
          if (addTransactFormKey.currentState!.validate()) {
            GlobalModal.loadingModal(deviceWidth, context);
            TransactionRepository.addData(
              context,
              userId,
              selectedCategory,
              amountFormatter.getUnformattedValue().toString(),
              selectedDate,
              descCtl.text,
            );
          } else {
            GlobalSnackBar.show(context, 'Ada form yang belum diisi!');
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: deviceWidth / 50),
          child: Text(
            'Simpan',
            style: TextStyleComp.mediumBoldText(context),
          ),
        ));
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getString('id')!;
    });
  }
}
