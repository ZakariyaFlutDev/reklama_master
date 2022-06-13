import 'package:reklama_master/Config/config.dart';
import 'package:reklama_master/Store/cart.dart';
import 'package:reklama_master/Widgets/customAppBar.dart';
import 'package:reklama_master/Models/address.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cFlatHomeNumber = TextEditingController();
  final cCity = TextEditingController();
  final cState = TextEditingController();
  final cPinCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldkey,
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final model = AddressModel(
                name: cName.text.trim(),
                state: cState.text.trim(),
                pincode: cPinCode.text,
                phoneNumber: cPhoneNumber.text,
                flatNumber: cFlatHomeNumber.text,
                city: cCity.text.trim(),
              ).toJson();

              //add to Firestore
              EcommerceApp.firestore
                  !.collection(EcommerceApp.collectionUser)
                  .doc(EcommerceApp.sharedPreferences
                      !.getString(EcommerceApp.userUID))
                  .collection(EcommerceApp.subCollectionAddress)
                  .doc(DateTime.now().millisecondsSinceEpoch.toString())
                  .set(model)
                  .then((value) {
                final snack =
                    SnackBar(content: Text("Yangi manzil muvaffaqiyatli qo'shildi"));
                scaffoldkey.currentState!.showSnackBar(snack);
                FocusScope.of(context).requestFocus(FocusNode());
                formKey.currentState!.reset();
              });
              Route route = MaterialPageRoute(builder: (c) => CartPage());
              Navigator.pushReplacement(context, route);
            }
          },
          label: Text("Keyingi"),
          backgroundColor: Colors.pink,
          icon: Icon(Icons.check),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Yangi manzil qo'shish",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(hint: "Ism", controller: cName),
                    MyTextField(hint: "Telefon raqam", controller: cPhoneNumber),
                    MyTextField(hint: "Viloyat", controller: cCity),
                    MyTextField(hint: "Shahar / Tuman", controller: cState),
                    MyTextField(
                        hint: "Ko'cha nomi, uy raqami",
                        controller: cFlatHomeNumber),
                    MyTextField(hint: "Shahar pin kodi", controller: cPinCode),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  MyTextField({Key? key, required this.hint, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val!.isEmpty ? "Iltimos ma'lumotlarni to'liq kiriting" : null,
      ),
    );
  }
}
