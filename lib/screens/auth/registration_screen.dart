import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_statuses/model/user_model.dart';
import 'package:my_statuses/screens/home_screen.dart';
import 'package:my_statuses/screens/auth/login_screen.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _email, _password, _name, _mobile;

  var _formkey = GlobalKey<FormState>();

  bool autoValidate = false;

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Registratiom"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Form(
                    key: _formkey,
                    autovalidate: autoValidate,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          validator: (item) {
                            return item.length > 0
                                ? null
                                : "Ingresa un nombre valido";
                          },
                          onChanged: (item) {
                            setState(() {
                              _name = item;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: "Ingresa un nombre",
                              labelText: "Nombre",
                              border: OutlineInputBorder()),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: (item) {
                            return item.length < 10
                                ? "Ingresa un numero de telefono valido"
                                : null;
                          },
                          onChanged: (item) {
                            setState(() {
                              _mobile = item;
                            });
                          },
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              hintText: "Ingresa un numero de telefono",
                              labelText: "Numero de telefono",
                              border: OutlineInputBorder()),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (item) {
                            return item.contains("@")
                                ? null
                                : "Ingresa un correo valido";
                          },
                          onChanged: (item) {
                            setState(() {
                              _email = item;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: "Ingresa tu correo",
                              labelText: "Correo",
                              border: OutlineInputBorder()),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          validator: (item) {
                            return item.length > 6
                                ? null
                                : "La contraseña debe tener al menos 6 caracteres.";
                          },
                          onChanged: (item) {
                            setState(() {
                              _password = item;
                            });
                          },
                          decoration: InputDecoration(
                              hintText: "Ingresa tu contraseña",
                              labelText: "Contraseña",
                              border: OutlineInputBorder()),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              signup();
                            },
                            child: Text(
                              "Registrarse",
                            ),
                            textColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginScreen()));
                              },
                              child: Text("Registrarse")),
                          alignment: Alignment.centerRight,
                        )
                      ],
                    )),
              ),
            ),
    );
  }

  void signup() {
    if (_formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      setState(() {
        autoValidate = false;
      });
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password)
          .then((user) {
        postUserDataToDb();
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "error " + onError.toString());
      });
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }

  void postUserDataToDb() async {
    setState(() {
      isLoading = true;
    });
    //FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    User firebaseUser = FirebaseAuth.instance.currentUser;
    UserModel userModel = new UserModel();
    userModel.email = _email;
    userModel.name = _name;
    userModel.mobileNumber = _mobile;
    userModel.uid = firebaseUser.uid;
    // await FireStore.instance
    //     .collection("user")
    //     .document(firebaseUser.uid)
    //     .setData(userModel.toMap());
    await FirebaseFirestore.instance
        .collection("user")
        .doc(firebaseUser.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(msg: "Register Success");
    await FirebaseUtils.updateFirebaseToken();
    //sendVerificationEmail();
    setState(() {
      isLoading = false;
    });
  }

  void sendVerificationEmail() async {
    //FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    User firebaseUser = FirebaseAuth.instance.currentUser;
    await firebaseUser.sendEmailVerification();

    Fluttertoast.showToast(
        msg: "email verifcation link has sent to your email.");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (Route<dynamic> route) => false);
  }
}
