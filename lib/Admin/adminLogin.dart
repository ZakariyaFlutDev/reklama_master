import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reklama_master/Admin/uploadItems.dart';
import 'package:reklama_master/Authentication/authenication.dart';
import 'package:reklama_master/Widgets/customTextField.dart';
import 'package:reklama_master/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.pink,
                    Colors.lightGreenAccent
                  ],
                  begin: FractionalOffset(0.0,0.0),
                  end: FractionalOffset(1.0,0.0),
                  stops: [0.0,1.0],
                  tileMode: TileMode.clamp
              )
          ),
        ),
        title: Text("Reklama Master", style: TextStyle(fontSize: 55, color: Colors.white, fontFamily: "Signatra"),),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{

  final TextEditingController _adminIDTextEditingController =
  TextEditingController();
  final TextEditingController _passwordTextEditingController =
  TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;


    return SingleChildScrollView(
      child: Container(
        height: _screenHeight,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Colors.pink,
                  Colors.lightGreenAccent
                ],
                begin: FractionalOffset(0.0,0.0),
                end: FractionalOffset(1.0,0.0),
                stops: [0.0,1.0],
                tileMode: TileMode.clamp
            )
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/admin.png",
                height: 240.0,
                width: 240.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin",
                style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                      controller: _adminIDTextEditingController,
                      data: Icons.person,
                      hintText: "Maxsus nom",
                      isObscure: false),
                  CustomTextField(
                      controller: _passwordTextEditingController,
                      data: Icons.lock,
                      hintText: "Parol",
                      isObscure: true),
                ],
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            ElevatedButton(
              onPressed: () {
                // _uploadAndSaveImage();
                _adminIDTextEditingController.text.isNotEmpty &&
                    _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(
                          message: "Iltimos ma'lumotlarni kiriting");
                    });
              },
              child: Text(
                  "Kirish",
                  style: TextStyle(color: Colors.white),
                ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AuthenticScreen())),
                icon: Icon(
                  Icons.nature_people,
                  color: Colors.pink,
                ),
                label: Text(
                  "Admin emasman",
                  style: TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.bold),
                )
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }

  loginAdmin(){
    FirebaseFirestore.instance.collection("admins").get().then((snapshot){
      snapshot.docs.forEach((result) {
        if(result.data()["id"] != _adminIDTextEditingController.text.trim()){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your id is not correct.")));
        }
        else if(result.data()["password"] != _passwordTextEditingController.text.trim()){
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your password is not correct.")));
        }
        else{
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Welcome Dear Admin" + result.data()["name"])));

          setState(() {
            _adminIDTextEditingController.text = "";
            _passwordTextEditingController.text = "";

          });

          Route route = MaterialPageRoute(builder: (context){
            return UploadPage();
          });
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
