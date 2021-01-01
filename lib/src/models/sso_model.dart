import 'package:flutter/cupertino.dart';
import 'package:insta_post/src/models/user_info.dart';

class SsoModel extends ChangeNotifier{
  UserInfoPODO _currUser;
  bool _isSignIn = false;
  Map<String, UserInfoPODO> userEmails = {}; //store user's email to look up for their nickname

  set userInfo(UserInfoPODO userInfo) => _currUser = userInfo;
  get userInfo => _currUser;

  get isSignIn => this._isSignIn;

  void setUserEmail(Map<String, UserInfoPODO> userEmails) => this.userEmails = userEmails;
  Map<String, UserInfoPODO> getUserEmail() => this.userEmails;

  bool signOut(){
    _isSignIn = false;
    _currUser = null;
  }

  void toggleLoginState(){
    _isSignIn = !_isSignIn;
    notifyListeners();
  }
}