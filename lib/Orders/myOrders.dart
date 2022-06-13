
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/serviceOrders.dart';
import '../Widgets/storeOrders.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Mahsulotlar",
              ),
              Tab(
                text: "Xizmatlar",
              )
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 5,
            labelStyle: TextStyle(fontSize: 18),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.pink, Colors.lightGreenAccent],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp)),
          ),
          centerTitle: true,
          title: Text(
            "Buyurtmalarim",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink,
                  Colors.lightGreenAccent
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
          ),
          child: TabBarView(
            children: [
              StoreOrders(),
              ServiceOrders()
            ],
          ),
        ),
      ),
    );
  }
}

