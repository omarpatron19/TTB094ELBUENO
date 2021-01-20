import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_statuses/model/user_model.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';

class ActualizarScreen extends StatefulWidget {
  @override
  _ActualizarScreenState createState() => _ActualizarScreenState();
}

class _ActualizarScreenState extends State<ActualizarScreen> {
  String _name = "", _mobile = "";
  User usuarioFirebase = FirebaseAuth.instance.currentUser;
  var _formkey = GlobalKey<FormState>();
  bool autoValidate = false;
  bool isLoading = false;
  @override
  void initState() {
    datos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Actualizar datos"),
      ),
      body: _name == "" && _mobile == ""
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
                          initialValue: _name,
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
                          initialValue: _mobile,
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
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              actualizar();
                            },
                            child: Text(
                              "Actualizar",
                            ),
                            textColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    )),
              ),
            ),
    );
  }

  void datos() async {
    UserModel usuario = await FirebaseUtils.datosPadre(usuarioFirebase.uid);
    setState(() {
      _name = usuario.name;
      _mobile = usuario.mobileNumber;
    });
  }

  void actualizar() {
    if (_formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      setState(() {
        autoValidate = false;
      });
      FirebaseUtils.actualizarDatos(_name, _mobile);
      Fluttertoast.showToast(
        msg: "Datos actualizados.",
      );
      Navigator.pop(context);
    } else {
      setState(() {
        autoValidate = true;
      });
    }
  }
}
