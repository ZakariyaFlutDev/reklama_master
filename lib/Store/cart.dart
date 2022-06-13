import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reklama_master/Config/config.dart';
import 'package:reklama_master/Address/address.dart';
import 'package:reklama_master/Store/product_page.dart';
import 'package:reklama_master/Store/serviceStore.dart';
import 'package:reklama_master/Widgets/customAppBar.dart';
import 'package:reklama_master/Models/item.dart';
import 'package:reklama_master/Counters/cartitemcounter.dart';
import 'package:reklama_master/Counters/totalMoney.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reklama_master/Store/storehome.dart';
import 'package:provider/provider.dart';
import 'package:reklama_master/Widgets/myDrawer.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double? totalAmount;
  int? quantity;

  @override
  void initState() {
    super.initState();

    quantity = 0;
    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayResult(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if ((EcommerceApp.sharedPreferences!
                  .getStringList(EcommerceApp.userCartList)!
                  .length ==
              1 ) && (EcommerceApp.sharedPreferences!
              .getStringList(EcommerceApp.userServiceList)!
              .length ==
              1 ) ) {
            Fluttertoast.showToast(msg: "Sizning savatchangizda mahsulot yoki xizmat mavjud emas.");
          } else {
            Route route = MaterialPageRoute(
                builder: (c) => Address(totalAmount: totalAmount));
            Navigator.push(context, route);
          }
        },
        label: Text("Check Out"),
        backgroundColor: Colors.pinkAccent,
        icon: Icon(Icons.navigate_next),
      ),
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      body: Stack(
        children: [
          Container(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Consumer2<TotalAmount, CartItemCounter>(
                    builder: (context, amountProvider, cartProvider, c) {
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Mahsulotlar",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 32,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: EcommerceApp.firestore!
                      .collection("items")
                      .where("shortInfo",
                      whereIn: EcommerceApp.sharedPreferences!
                          .getStringList(EcommerceApp.userCartList))
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? SliverToBoxAdapter(
                      child: Center(
                          child: Text("Mahsulotlar mavjud emas")
                      ),
                    )
                        : snapshot.data!.docs.length == 0
                        ? beginbuildingCart()
                        : SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          ItemModel model = ItemModel.fromJson(
                              snapshot.data!.docs[index].data()
                              as Map<String, dynamic>);
                          if (index == 0) {
                            totalAmount = 0;
                          }
                          if (snapshot.data!.docs.length - 1 == index) {
                            WidgetsBinding.instance!
                                .addPostFrameCallback((t) {
                              Provider.of<TotalAmount>(context,
                                  listen: false)
                                  .displayResult(totalAmount!);
                            });
                          }
                          return sourceInfoCart(model, index, context,
                              removeCartFunction: () =>
                                  removeItemFromUserCart(
                                      model.shortInfo!, index));
                        },
                        childCount: snapshot.hasData
                            ? snapshot.data!.docs.length
                            : 0,
                      ),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Consumer2<TotalAmount, CartItemCounter?>(
                    builder: (context, amountProvider, cartProvider, c) {
                      return Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Center(
                          child:Text(
                            "Xizmatlar",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: EcommerceApp.firestore!
                      .collection("services")
                      .where("orderName",
                      whereIn: EcommerceApp.sharedPreferences!
                          .getStringList(EcommerceApp.userServiceList))
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? SliverToBoxAdapter(
                      child: Center(
                          child: Text("Xizmatlar mavjud emas")
                      ),
                    )
                        : snapshot.data!.docs.length == 0
                        ? beginbuildingService()
                        : SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          ServiceModel model = ServiceModel.fromJson(
                              snapshot.data!.docs[index].data()
                              as Map<String, dynamic>);
                          if (index == 0) {
                            totalAmount = 0;
                          }
                          if (snapshot.data!.docs.length - 1 == index) {
                            WidgetsBinding.instance!
                                .addPostFrameCallback((t) {
                              Provider.of<TotalAmount>(context,
                                  listen: false)
                                  .displayResult(totalAmount!);
                            });
                          }
                          return sourceInfoService(
                              model, index, context,
                              removeServiceCartFunction: () =>
                                  removeServiceFromUserCart(
                                      model.orderName!, index));
                        },
                        childCount: snapshot.hasData
                            ? snapshot.data!.docs.length
                            : 0,
                      ),
                    );
                  },
                )
              ],
            ),
            padding: EdgeInsets.only(bottom: 70),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.all(15.0),
                height: 50,
                width: 220,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.pink.shade400),
                child: Center(
                  child: Text(
                    "Summa : $totalAmount so'm",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget sourceInfoCart(ItemModel model, int index, BuildContext context,
      {Color background = Colors.green, removeCartFunction}) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        totalAmount = totalAmount! + model.price!.toDouble();
      });
    });

    return InkWell(
      onTap: () {
        Route route =
            MaterialPageRoute(builder: (c) => ProductPage(itemModel: model));
        Navigator.push(context, route);
      },
      splashColor: Colors.pink,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 8 / 5,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    model.thumbnailUrl.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mahsulot nomi : ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Mahsulot tavsifi : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Mahsulot narxi : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        model.shortInfo.toString(),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "${model.price.toString()} so'm",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () {
                    removeCartFunction();
                    Route route =
                        MaterialPageRoute(builder: (c) => ServiceStore());
                    Navigator.pushReplacement(context, route);
                  },
                ),
              ),
              Divider(
                height: 2.0,
                color: Colors.pink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sourceInfoService(ServiceModel model, int index, BuildContext context,
      {Color background = Colors.green, removeServiceCartFunction}) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        totalAmount = totalAmount! + model.totalPrice!.toDouble();
      });
    });

    return InkWell(
      onTap: () {
        // Route route =
        // MaterialPageRoute(builder: (c) => ProductPage(itemModel: model));
        // Navigator.pushReplacement(context, route);
      },
      splashColor: Colors.pink,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 8 / 5,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    model.thumbnailUrl.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buyurtma nomi : ",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Buyurtma eni : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Buyurtma bo'yi : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Buyurtma narxi : ",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.orderName.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        model.serviceWidth.toString(),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "${model.serviceHeight.toString()}",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "${model.totalPrice.toString()} so'm",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () {
                    removeServiceCartFunction();
                    Route route =
                        MaterialPageRoute(builder: (c) => ServiceStore());
                    Navigator.pushReplacement(context, route);
                  },
                ),
              ),
              Divider(
                height: 2.0,
                color: Colors.pink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  beginbuildingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_emoticon,
                color: Colors.white,
              ),
              Text("Savatchada mahsulotlar mavjud emas"),
              Text("Asosiy oynaga qaytib mahsulotlar qo'shing!")
            ],
          ),
        ),
      ),
    );
  }

  beginbuildingService() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_emoticon,
                color: Colors.white,
              ),
              Text("Savatchada xizmatlar mavjud emas"),
              Text("Asosiy oynaga qaytib xizmatlar qo'shing!")
            ],
          ),
        ),
      ),
    );
  }

  removeItemFromUserCart(String shortInfoAsId, int index) {
    List<String> tempCartList = EcommerceApp.sharedPreferences!
        .getStringList(EcommerceApp.userCartList)!
        .cast<String>();
    tempCartList.remove(shortInfoAsId);

    List<String> quantityList = EcommerceApp.sharedPreferences!
        .getStringList(EcommerceApp.productQuantities)!
        .cast<String>();
    quantityList.remove(index.toString());

    EcommerceApp.firestore!
        .collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences!.getString(EcommerceApp.userUID))
        .update({
      EcommerceApp.userCartList: tempCartList,
      EcommerceApp.productQuantities: quantityList,
    }).then((v) {
      Fluttertoast.showToast(msg: "Mahsulot o'chirildi.");
      EcommerceApp.sharedPreferences!
          .setStringList(EcommerceApp.userCartList, tempCartList);
      EcommerceApp.sharedPreferences!
          .setStringList(EcommerceApp.productQuantities, quantityList);

      Provider.of<CartItemCounter>(context, listen: false).displayResult();

      totalAmount = 0;
    });
  }

  removeServiceFromUserCart(String orderName, int index) {
    List<String> tempCartList = EcommerceApp.sharedPreferences!
        .getStringList(EcommerceApp.userServiceList)!
        .cast<String>();
    tempCartList.remove(orderName);

    EcommerceApp.firestore!
        .collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences!.getString(EcommerceApp.userUID))
        .update({
      EcommerceApp.userServiceList: tempCartList,
    }).then((v) {
      Fluttertoast.showToast(msg: "Xizmatlar o'chirildi.");
      EcommerceApp.sharedPreferences!
          .setStringList(EcommerceApp.userServiceList, tempCartList);

      Provider.of<CartItemCounter>(context, listen: false).displayResult();

      totalAmount = 0;
    });
  }
}
