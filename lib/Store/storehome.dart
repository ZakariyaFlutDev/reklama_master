import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:reklama_master/Store/product_page.dart';
import 'package:reklama_master/Counters/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:reklama_master/Config/config.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/searchBox.dart';
import '../Models/item.dart';

double? width;
double? height;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                  pinned: true, delegate: SearchBoxDelegate()),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("items")
                    .limit(15)
                    .orderBy("publishedDate", descending: true)
                    .snapshots(),
                builder: (context, dataSnapshot) {
                  return !dataSnapshot.hasData
                      ? SliverToBoxAdapter(
                          child: circularProgress(),
                        )
                      : SliverStaggeredGrid.countBuilder(
                          crossAxisCount: 1,
                          staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                          itemCount: dataSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            ItemModel model = ItemModel.fromJson(
                                dataSnapshot.data?.docs[index].data()
                                    as Map<String, dynamic>);
                            return sourceInfo(model, context);
                          });
                },
              )
            ],
          )),
    );
  }
}

Widget sourceInfo(ItemModel model, BuildContext context,
    {Color background = Colors.green, removeCartFunction}) {
  int? orgPrice = model.price! * 2;
  return InkWell(
    onTap: () {
      Route route =
          MaterialPageRoute(builder: (c) => ProductPage(itemModel: model));
      Navigator.push(context, route);
    },
    splashColor: Colors.pink,
    child: Padding(
      padding: EdgeInsets.all(6.0),
      child: Container(
        height: height!*0.25,
        width: width,
        child: Row(
          children: [
            Image.network(
              model.thumbnailUrl.toString(),
              width: width! * 0.35,
              height: height! * 0.2,
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              model.title.toString(),
                              style:
                              TextStyle(color: Colors.black, fontSize: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              model.shortInfo.toString(),
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 0.0),
                              child: Row(
                                children: [
                                  Text(
                                    model.price.toString(),
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.black),
                                  ),
                                  Text(
                                    " so'm",
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.red),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),


                    //to implement the cart item remove//add feature
                    Align(
                      alignment: Alignment.centerRight,
                      child: removeCartFunction == null
                          ? IconButton(
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          checkItemInCart(
                              model.shortInfo.toString(), context);
                        },
                      )
                          : IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.pinkAccent,
                        ),
                        onPressed: () {
                          removeCartFunction();
                          Route route = MaterialPageRoute(builder: (c) => StoreHome());
                          Navigator.pushReplacement(context, route);
                        },
                      ),
                    ),
                    Divider(
                      height: 5.0,
                      color: Colors.pink,
                      thickness: 2,
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    ),
  );
}

Widget card({Color primaryColor = Colors.redAccent, required String imgPath}) {
  return Container(
    height: 150.0,
    width: width! * 0.34,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
      boxShadow: <BoxShadow>[
        BoxShadow(offset: Offset(0, 5), blurRadius: 10.0, color: Colors.grey.shade200)
      ]
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Image.network(
        imgPath,
        height: 150.0,
        width: width! * .34,
        fit: BoxFit.fill,
      ),
    ),
  );
}

void checkItemInCart(String shortInfoAsID, BuildContext context) {

  EcommerceApp.sharedPreferences
          !.getStringList(EcommerceApp.userCartList)!
          .contains(shortInfoAsID)
      ? Fluttertoast.showToast(msg: "ushbu mahsulot savatchada mavjud")
      : addItemToCart(shortInfoAsID, context);
}

addItemToCart(String shortInfoAsID, BuildContext context) {
  List<String> tempCartList = EcommerceApp.sharedPreferences!
      .getStringList(EcommerceApp.userCartList)!.cast<String>();
  tempCartList.add(shortInfoAsID);

  List<String> quantityCartList = EcommerceApp.sharedPreferences!
      .getStringList(EcommerceApp.productQuantities)!.cast<String>();
  quantityCartList.add("0");

    EcommerceApp.firestore!
        .collection(EcommerceApp.collectionUser)
        .doc(EcommerceApp.sharedPreferences!.getString(EcommerceApp.userUID))
        .update({
      EcommerceApp.userCartList: tempCartList,
      EcommerceApp.productQuantities: quantityCartList,
    }).then((v){
      Fluttertoast.showToast(msg: "Mahsulot savatchaga qo'shildi");
      EcommerceApp.sharedPreferences!.setStringList(EcommerceApp.userCartList, tempCartList);
      EcommerceApp.sharedPreferences!.setStringList(EcommerceApp.productQuantities, quantityCartList);

      Provider.of<CartItemCounter>(context, listen: false).displayResult();
    });

}
