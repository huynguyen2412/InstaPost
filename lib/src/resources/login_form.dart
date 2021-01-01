import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_post/src/models/user_info.dart';
import 'package:provider/provider.dart';
import 'package:insta_post/src/models/input_field.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:insta_post/src/resources/register_form.dart';
import 'package:http/http.dart' as http;

class LoginForm extends StatefulWidget{

  String title;

  @override
  _LoginForm createState() => _LoginForm();
}

class _LoginForm extends State<LoginForm>{
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final formError = "Email address or password incorrect";
  bool isFormErrorExist = false;
  final _urlAuthority = 'bismarck.sdsu.edu';

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _authenticateUser(String emailText, String password) async{
    final _path = "/api/instapost-query/authenticate";
    final Map<String, String> queryParams = {
      "email" : emailText,
      "password" : password
    };
    final _uri = Uri.https(_urlAuthority, _path, queryParams);
    final response = await http.get(
      _uri,
      headers: { HttpHeaders.contentTypeHeader : "application/json" }
    );

    if(response.statusCode != 200)
      throw Exception("Failed to authenticate user. Error ${response.statusCode}");

    final resPayLoad = jsonDecode(response.body);
    return resPayLoad["result"];
  }

  //Display login information
  Widget loginForm(GlobalKey<FormState> formKey){
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Login here if you're already registered",
            style: TextStyle(
              color: Colors.black
            )
          ),
          Visibility(
            child: Text(
              formError,
              style: TextStyle(
                color: Colors.red
              ),
            ),  //Display Text Error as username or password incorrect
            visible: isFormErrorExist
          ),
          InputField(
            labelTextField: "Email Address",
            obscureText: false,
            controller: _emailController,
            keyboardTextField: TextInputType.text,
          ),
          InputField(
            labelTextField: "Password",
            obscureText: true,
            controller: _passwordController,
            keyboardTextField: TextInputType.text,
          ),
          RaisedButton(
            onPressed: () async{
              final autStatus = await _authenticateUser(
                  _emailController.text, _passwordController.text
              );

              if(!autStatus){
                setState(() {
                  isFormErrorExist = true;
                });
              }else{
                Provider.of<UserStateModel>(context, listen: false)
                  ..setUserInfo(UserInfoPODO(
                    email: _emailController.text,
                    password: _passwordController.text
                  ))
                  ..toggleLoginState(); //enable SignIn mode
              }
            },
            child: const Text('Login', style: TextStyle(fontSize: 15)),
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
                width: 2.0,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(6.0)
              ),
            ),
            child: Center(
              child: loginForm(_formKey),
            ),
          )
        ],
      );
  }
}

