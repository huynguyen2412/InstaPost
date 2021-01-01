import 'package:flutter/cupertino.dart';
import 'package:insta_post/src/models/user_info.dart';

class UserStateModel extends ChangeNotifier{
  bool isSignIn = false;
  UserInfoPODO userInfo;
  Map<String, UserInfoPODO> userEmails = {}; //store user's email to look up for their nickname

  void setUserInfo(UserInfoPODO userInfoModel) => userInfo = userInfoModel;
  UserInfoPODO getUserInfo() => userInfo;

  void toggleLoginState(){
    isSignIn = !isSignIn;
    notifyListeners();
  }

  Map<String, UserInfoPODO> getUserEmail() => this.userEmails;

  bool signOut(){
    isSignIn = false;
    userInfo = null;
  }

}