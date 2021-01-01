import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_post/src/resources/login_form.dart';
import 'package:insta_post/src/resources/register_form.dart';

class LoginRegistration extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login & Registration"),
        centerTitle: true,
      ),
      body: new GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: <Widget>[
                LoginForm(),
                const Divider(
                  color: Colors.grey,
                  height:5,
                  thickness: 2,
                ),
                RegisterForm()
              ],
            )
          ),
        )
      )
    );
  }
}