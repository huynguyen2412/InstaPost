import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:insta_post/src/ui/my_instapost.dart';
import 'package:insta_post/src/ui/user_login_registration.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  LandingPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStateModel>(
      builder: (context, userState, child){
        return userState.isSignIn ? MyInstaPost() : LoginRegistration();
      },
    );
  }
}