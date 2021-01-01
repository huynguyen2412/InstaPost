import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:insta_post/src/resources/post_form.dart';
import 'package:insta_post/src/resources/preview_post_list.dart';
import 'package:insta_post/src/ui/hashtag_list.dart';
import 'package:insta_post/src/ui/nickname_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MyInstaPost extends StatefulWidget{

  @override
  _MyInstaPost createState() => _MyInstaPost();
}

class _MyInstaPost extends State<MyInstaPost>{

  final String title = "-";
  final String urlAuthority = "bismarck.sdsu.edu";
  final String postIdsPath = "/api/instapost-query/nickname-post-ids"; //path to get all ids of a hashtag or a nickname
  final String listNameKey = "nicknames"; //key name map to a list of item from json body
                                        //api/instapost-query/nicknames or instapost-query/hashtags
  final String paramValue = ""; //value is used to query response//user-nickname
  final String paramKey = "nickname";
  Future<String> _nickName;
  Future<bool> newPost;

  @override
  void initState(){
    _nickName = getNickname();
    super.initState();
  }

  //return a random nickname if the nickname not exist in SharedPref
  Future<String> getNickname() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = Provider.of<UserStateModel>(context, listen: false).getUserInfo().email;
    final String nickname = prefs.getString(email);
    if(nickname != null)
      return nickname;

    final String path = "/api/instapost-query/nicknames";
    final uri = Uri.https(urlAuthority, path);
    final response = await http.get(uri,
        headers: {
          HttpHeaders.contentTypeHeader : "application/json"
        }
    );
    final jsonResBody = jsonDecode(response.body);
    final List<dynamic> nickNames = jsonResBody['nicknames'];
    var rand = new Random();
    final randNum = rand.nextInt(nickNames.length);
    return nickNames[randNum].toString();
  }

  _createAPost(BuildContext context) async{
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostForm())
    );
  }

  Widget hashtagPage(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.alternate_email),
      title: Text("Members' Hashtags"),
      onTap: () async{
        Navigator.pop(context);
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HashtagListViewer()
            )
        );
      }
    );
  }

  Widget nicknamePage(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person_pin_rounded),
      title: Text("Members' Nicknames"),
      onTap: () async{
        Navigator.pop(context);
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NicknameListViewer()
            )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("InstaPost Homepage"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text(
                  "My InstaPost",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24
                  )
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
              ),
            ),
            nicknamePage(context),//nicknames drawer
            hashtagPage(context)//hashtags drawer
          ],
        ),
      ),
      body: new FutureBuilder<String>(
        future: _nickName,
        builder: (context, AsyncSnapshot<String> snapshot){
          if(snapshot.hasError){
            return Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                )
            );
          }else if(snapshot.hasData){
            return Center(
              child: PreviewPostList(
                urlAuthority: urlAuthority,
                postIdsPath: postIdsPath,
                paramKey: paramKey,
                listNameKey: listNameKey,
                paramValue: snapshot.data.toString(),
                title: snapshot.data.toString(),
              )
            );
          }else{
           return Container(
             child: CircularProgressIndicator(),
           );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_circle),
        onPressed: () async{
          final postStatus = await _createAPost(context);
        },
      )
    );
  }
}
