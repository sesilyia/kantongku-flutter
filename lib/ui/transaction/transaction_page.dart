import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kantongku/component/color.dart';
import 'package:kantongku/component/text_style.dart';
import 'package:kantongku/model/transaction_model.dart';
import 'package:kantongku/repository/balance_repository.dart';
import 'package:kantongku/repository/transaction_repository.dart';
import 'package:kantongku/repository/user_repository.dart';
import 'package:kantongku/ui/transaction/add_transaction_page.dart';
import 'package:kantongku/ui/transaction/detail_transaction_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String userId = '';

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                modalLogout(deviceWidth);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ))
        ],
        title: const Text(
          'KantongKu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const AddTransactionPage();
          })).then((value) {
            setState(() {});
          });
        },
        child: const Icon(
          FontAwesomeIcons.plus,
          color: Colors.black,
        ),
      ),
      body: RefreshIndicator(
          onRefresh: refreshData, child: transactWidgets(deviceWidth)),
    );
  }

  Widget transactWidgets(deviceWidth) {
    return ListView(
      children: [
        SizedBox(
          height: deviceWidth / 20,
        ),
        balanceWidget(deviceWidth),
        titlePage(deviceWidth),
        transactionPageWidgets(deviceWidth),
      ],
    );
  }

  Widget balanceWidget(deviceWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          deviceWidth / 20, 0, deviceWidth / 20, deviceWidth / 20),
      child: Container(
        padding: EdgeInsets.all(deviceWidth / 20),
        decoration: BoxDecoration(
            color: GlobalColors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(deviceWidth / 50))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dompet Kamu 💰',
              style: TextStyleComp.mediumBoldText(context),
            ),
            FutureBuilder(
                future: BalanceRepository.getData(userId),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Rp ${NumberFormat('#,##0', 'ID').format(snapshot.data!.balance)}',
                      style: TextStyleComp.bigText(context),
                    );
                  } else {
                    return SpinKitFadingCube(
                      color: Theme.of(context).primaryColor,
                      size: deviceWidth / 15,
                    );
                  }
                }))
          ],
        ),
      ),
    );
  }

  Widget titlePage(deviceWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: deviceWidth / 20),
      child: Text(
        'Transaksi',
        style: TextStyleComp.bigBoldPrimaryColorText(context),
      ),
    );
  }

  Widget transactionPageWidgets(deviceWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: deviceWidth / 20),
      child: FutureBuilder(
          future: TransactionRepository.getAllData(userId),
          builder: ((context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Transaction> transItems = snapshot.data!;
              return Padding(
                padding: EdgeInsets.only(bottom: deviceWidth / 5),
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: transItems.length,
                    itemBuilder: (context, index) {
                      return card(context, deviceWidth, index, transItems);
                    }),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitFadingCube(
                  color: Theme.of(context).primaryColor,
                  size: deviceWidth / 15,
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyleComp.smallBoldText(context),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyleComp.smallBoldText(context),
                ),
              );
            } else {
              return Center(
                child: SpinKitFadingCube(
                  color: Theme.of(context).primaryColor,
                  size: deviceWidth / 15,
                ),
              );
            }
          })),
    );
  }

  Widget card(context, deviceWidth, index, data) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        deviceWidth / 20,
        0,
        deviceWidth / 20,
        deviceWidth / 20,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return DetailTransactionPage(
                id: data[index].id,
                savingId: data[index].savingId,
                budgetId: data[index].budgetId,
                category: data[index].category,
                amount: data[index].amount,
                dateTime: data[index].dateTime,
                description: data[index].description);
          })).then((value) {
            setState(() {});
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(deviceWidth / 40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 0,
                blurRadius: 0,
                offset: const Offset(3, 5),
              ),
            ],
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(deviceWidth / 40),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth / 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: deviceWidth / 1.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data[index].category,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyleComp.mediumBoldPrimaryColorText(
                                  context),
                            ),
                            Text(
                              data[index].category == 'Pengeluaran'
                                  ? '- Rp ${NumberFormat('#,##0', 'ID').format(data[index].amount)}'
                                  : 'Rp ${NumberFormat('#,##0', 'ID').format(data[index].amount)}',
                              overflow: TextOverflow.ellipsis,
                              style: data[index].category == 'Pengeluaran'
                                  ? TextStyleComp.mediumRedText(context)
                                  : TextStyleComp.mediumGreenText(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: deviceWidth / 1.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            Text(
                              data[index].dateTime,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyleComp.smallItalicText(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future refreshData() async {
    setState(() {});
  }

  void modalLogout(deviceWidth) {
    showModalBottomSheet(
        isDismissible: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(deviceWidth / 20),
              topRight: Radius.circular(deviceWidth / 20)),
        ),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(deviceWidth / 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Apakah anda yakin ingin logout?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: deviceWidth / 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: deviceWidth / 3,
                          padding: EdgeInsets.only(
                              top: deviceWidth / 20, bottom: deviceWidth / 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(deviceWidth / 40),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceWidth / 30),
                              child: Text(
                                "BATAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: deviceWidth / 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: deviceWidth / 3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius:
                                    BorderRadius.circular(deviceWidth / 40),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              UserRepository.logOut(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceWidth / 30),
                              child: Text(
                                "LOGOUT",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: deviceWidth / 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('id')!;
    });
  }
}
