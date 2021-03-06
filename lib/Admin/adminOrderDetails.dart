import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reklama_master/Admin/adminShiftOrders.dart';
import 'package:reklama_master/Config/config.dart';
import 'package:reklama_master/Widgets/loadingWidget.dart';
import 'package:reklama_master/Widgets/orderCard.dart';
import 'package:reklama_master/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Address/address.dart';
import '../Widgets/orderServiceCard.dart';
import '../main.dart';

String getOrderId = "";

class AdminOrderDetails extends StatelessWidget {

  final String orderID;
  final String addressID;
  final String orderBy;

  AdminOrderDetails({Key? key, required this.orderID, required this.addressID, required this.orderBy}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    getOrderId = orderID;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: EcommerceApp.firestore!
                .collection(EcommerceApp.collectionOrders)
                .doc(getOrderId).get(),

            builder: (c, snapshot) {
              Map? dataMap;
              if (snapshot.hasData) {
                dataMap = snapshot.data!.data() as Map<String, dynamic>;
              }
              return snapshot.hasData
                  ? Container(
                child: Column(
                  children: [
                    AdminStatusBanner(
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
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("Buyurtma IDsi: " + getOrderId),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("Buyurtma berilgan sana: " +
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
                          .doc(orderBy)
                          .collection(EcommerceApp.subCollectionAddress)
                          .doc(addressID)
                          .get(),
                      builder: (c, snap){
                        return snap.hasData
                            ? AdminShippingDetails(model: AddressModel.fromJson(snap.data!.data() as Map<String, dynamic>),)
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

class AdminStatusBanner extends StatelessWidget {
  final bool status;

  AdminStatusBanner({Key? key, required this.status});

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Muvaffaqiyatli" : msg = "Muvaffaqiyatsiz";

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
            "Order Shipped" + msg,
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

class AdminShippingDetails extends StatelessWidget {
  final AddressModel model;

  AdminShippingDetails({Key? key, required this.model}) : super(key: key);

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
            "Shipment Details:",
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
                  msg: "Ism",
                ),
                Text(model.name.toString())
              ]),
              TableRow(children: [
                KeyText(msg: "Telefon raqam"),
                Text(model.phoneNumber.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Viloyat"),
                Text(model.city.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Shahar / Tuman"),
                Text(model.state.toString()),
              ]),
              TableRow(children: [
                KeyText(msg: "Uy manzili"),
                Text(model.flatNumber.toString()),
              ]),

              TableRow(children: [
                KeyText(msg: "Shahar pin kodi"),
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
                  confirmParcelShifted(context, getOrderId);
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
                      "Tasdiqlash || Buyurtma yetkazildi",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                )),
          ),
        )
      ],
    );
  }

  confirmParcelShifted(BuildContext context, String mOrderId) {
    EcommerceApp.firestore!
        .collection(EcommerceApp.collectionOrders)
        .doc(mOrderId).delete();

    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => AdminShiftOrders());
    Navigator.pushReplacement(context, route);

    Fluttertoast.showToast(msg: "Buyurtma yetkazilgani tasdiqlandi");
  }
}
