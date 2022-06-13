import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reklama_master/Address/address.dart';
import 'package:reklama_master/Config/config.dart';
import 'package:reklama_master/Widgets/loadingWidget.dart';
import 'package:reklama_master/Widgets/orderCard.dart';
import 'package:reklama_master/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:reklama_master/Widgets/orderServiceCard.dart';
import 'package:reklama_master/main.dart';

String getOrderId = "";

class OrderDetails extends StatelessWidget {
  final String orderID;

  OrderDetails({Key? key, required this.orderID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getOrderId = orderID;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: EcommerceApp.firestore!
                .collection(EcommerceApp.collectionUser)
                .doc(EcommerceApp.sharedPreferences!
                    .getString(EcommerceApp.userUID))
                .collection(EcommerceApp.collectionOrders)
                .doc(orderID)
                .get(),
            builder: (c, snapshot) {
              Map? dataMap;
              if (snapshot.hasData) {
                dataMap = snapshot.data!.data() as Map<String, dynamic>;
              }
              return snapshot.hasData
                  ? Container(
                      child: Column(
                        children: [
                          StatusBanner(
                            status: dataMap![EcommerceApp.isSuccess],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                    dataMap[EcommerceApp.totalAmount]
                                        .toString() + " so'm",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text("Buyurtma berilgan vaqt: " +
                                DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(dataMap["orderTime"]))),
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                          ),
                          Divider(height: 2.0,),
                          FutureBuilder<QuerySnapshot>(
                            future: EcommerceApp.firestore!.collection("items").where("shortInfo", whereIn: dataMap[EcommerceApp.productID]).get(),
                            builder: (c, dataSnapshot){
                              return dataSnapshot.hasData
                                  ? OrderCard(itemCount: dataSnapshot.data!.docs.length, data: dataSnapshot.data!.docs, orderID: orderID)
                                  : Center(child: circularProgress(),);
                            },
                          ),
                          Divider(height: 2.0,),
                          FutureBuilder<QuerySnapshot>(
                            future: EcommerceApp.firestore!.collection("services").where("orderName", whereIn: dataMap[EcommerceApp.serviceID]).get(),
                            builder: (c, dataSnapshot){
                              return dataSnapshot.hasData
                                  ? OrderServiceCard(itemCount: dataSnapshot.data!.docs.length, data: dataSnapshot.data!.docs, orderID: orderID)
                                  : Center(child: circularProgress(),);
                            },
                          ),
                          Divider(height: 2.0,),
                          FutureBuilder<DocumentSnapshot>(
                            future: EcommerceApp.firestore!
                                .collection(EcommerceApp.collectionUser)
                                .doc(EcommerceApp.sharedPreferences!
                                .getString(EcommerceApp.userUID))
                                .collection(EcommerceApp.subCollectionAddress)
                                .doc(dataMap[EcommerceApp.addressID])
                                .get(),
                            builder: (c, snap){
                              return snap.hasData
                                  ? ShippingDetails(model: AddressModel.fromJson(snap.data!.data() as Map<String, dynamic>),)
                                  : Center(child: circularProgress(),);
                            },
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: circularProgress(),
                    );
            },
          ),
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;

  StatusBanner({Key? key, required this.status});

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Yetkazilgan" : msg = "Yetkazilmagan";

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp)),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              SystemNavigator.pop();
            },
            child: Container(
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            "Buyurtma holati" + msg,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 5.0,
          ),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.white,
                size: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ShippingDetails extends StatelessWidget {
  final AddressModel model;

  ShippingDetails({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Buyurtmachi ma'lumotlari:",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(children: [
                KeyText(
                  msg: "Ismi",
                ),
                Text(model.name.toString())
              ]),
              TableRow(children: [
                KeyText(msg: "Telefon raqami"),
                Text(model.phoneNumber.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Uy manzili"),
                Text(model.flatNumber.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Shahar / Qishloq"),
                Text(model.city.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Viloyat"),
                Text(model.state.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Shahar / qishlo kodi"),
                Text(model.pincode.toString()),
              ]),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
                onTap: () {
                  confirmedUserOrderReveived(context, getOrderId);
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.pink, Colors.lightGreenAccent],
                          begin: FractionalOffset(0.0, 0.0),
                          end: FractionalOffset(1.0, 0.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp)),
                  height: 50.0,
                  width: MediaQuery.of(context).size.width - 40.0,
                  child: Center(
                    child: Text(
                      "Buyurtma qabul qilindi",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                )),
          ),
        )
      ],
    );
  }

  confirmedUserOrderReveived(BuildContext context, String mOrderId) {
    EcommerceApp.firestore!
        .collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences!.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders)
        .doc(mOrderId)
        .delete();

    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => SplashScreen());
    Navigator.pushReplacement(context, route);

    Fluttertoast.showToast(msg: "Buyurtma muvaffaqiyatli bajarildi");
  }
}
