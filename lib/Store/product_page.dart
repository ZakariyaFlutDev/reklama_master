import 'package:reklama_master/Widgets/customAppBar.dart';
import 'package:reklama_master/Widgets/myDrawer.dart';
import 'package:reklama_master/Models/item.dart';
import 'package:flutter/material.dart';
import 'package:reklama_master/Store/storehome.dart';


class ProductPage extends StatefulWidget {

  ProductPage({required this.itemModel});

  ItemModel itemModel;

  @override
  _ProductPageState createState() => _ProductPageState();
}


class _ProductPageState extends State<ProductPage> {

  int? quantityOfItems;

  @override
  void initState() {
    super.initState();
    quantityOfItems = widget.itemModel.quantity == null ? 0 : widget.itemModel.quantity;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery
        .of(context)
        .size;
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Image.network(widget.itemModel.thumbnailUrl
                              .toString(), fit: BoxFit.cover, width: double
                              .infinity, height: MediaQuery.of(context).size.width,),
                        ),
                      ),
                      Container(
                        color: Colors.grey.shade300,
                        child: SizedBox(height: 1.0, width: double.infinity,),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                height: 50,
                                child: Center(
                                  child: Text("Nomi : ",
                                      style: boldTextStyle),
                                ),
                              ),

                              SizedBox(height: 10.0,),

                              Container(
                                height: 50,
                                child: Center(
                                  child: Text("Tavsifi : "),
                                ),
                              ),

                              SizedBox(height: 10.0,),

                              Container(
                                height: 50,
                                child: Center(
                                  child: Text("Narxi : ",
                                      style: boldTextStyle),
                                ),
                              ),


                              SizedBox(height: 10.0,),

                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                height: 50,
                                child: Center(
                                  child: Text(widget.itemModel.title.toString(),
                                    style: boldTextStyle,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.justify,),
                                )
                              ),

                              SizedBox(height: 10.0,),

                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Center(
                                  child: Text(widget.itemModel.longDescription.toString(), textAlign: TextAlign.start,),
                                ),
                              ),


                              SizedBox(height: 10.0,),

                              Container(
                                height: 50,
                                child: Center(
                                  child: Text(widget.itemModel.price.toString() + " so'm",
                                      style: boldTextStyle),
                                ),
                              ),


                              SizedBox(height: 10.0,),

                            ],
                          ),

                        ],
                      )

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: InkWell(
                        onTap: () =>
                            checkItemInCart(widget.itemModel.shortInfo
                                .toString(),  context),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.pink,
                                    Colors.lightGreenAccent
                                  ],
                                  begin: FractionalOffset(0.0, 0.0),
                                  end: FractionalOffset(1.0, 0.0),
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp
                              )
                          ),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width - 40.0,
                          height: 50.0,
                          child: Center(
                            child: Text("Savatchaga qo'shish",
                              style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),

      ),
    );
  }

}

const boldTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const largeTextStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
