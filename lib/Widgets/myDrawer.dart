
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Address/addAddress.dart';
import '../Authentication/authenication.dart';
import '../Config/config.dart';
import '../Orders/myOrders.dart';
import '../Store/Search.dart';
import '../Store/cart.dart';
import '../Store/serviceStore.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
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
            child: Column(
              children: [
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(80.0)),
                  elevation: 8.0,
                  child: Container(
                    height: 160.0,
                    width: 160.0,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(EcommerceApp.sharedPreferences!.get(EcommerceApp.userAvatarUrl).toString()),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Text(
                  EcommerceApp.sharedPreferences!.get(EcommerceApp.userName).toString(),
                  style: TextStyle(color: Colors.white, fontSize: 35.0, fontFamily: "Signatra "),
                )
              ],
            ),
          ),
          SizedBox(height: 12.0,),
          Container(
            padding: EdgeInsets.only(top: 1.0),
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
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white,),
                  title: Text("Asosiy", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    Route route  = MaterialPageRoute(builder: (c) => ServiceStore());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
                ListTile(
                  leading: Icon(Icons.reorder, color: Colors.white,),
                  title: Text("Buyurtmalar", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    Route route  = MaterialPageRoute(builder: (c) => MyOrders());
                    Navigator.push(context, route);
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
                ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.white,),
                  title: Text("Savatcha", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    Route route  = MaterialPageRoute(builder: (c) => CartPage());
                    Navigator.push(context, route);
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
                ListTile(
                  leading: Icon(Icons.search, color: Colors.white,),
                  title: Text("Qidiruv", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    Route route  = MaterialPageRoute(builder: (c) => SearchProduct());
                    Navigator.push(context, route);
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
                ListTile(
                  leading: Icon(Icons.add_location, color: Colors.white,),
                  title: Text("Manzil qo'shish", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    Route route  = MaterialPageRoute(builder: (c) => AddAddress());
                    Navigator.push(context, route);
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.white,),
                  title: Text("Chiqish", style: TextStyle(color: Colors.white),),
                  onTap: (){
                    EcommerceApp.auth?.signOut().then((c){
                      Route route  = MaterialPageRoute(builder: (c) => AuthenticScreen());
                      Navigator.pushReplacement(context, route);
                    });
                  },
                ),
                Divider(height: 10.0, color: Colors.white, thickness: 6.0,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
