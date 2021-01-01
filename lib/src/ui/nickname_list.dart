import 'package:flutter/material.dart';
import 'package:insta_post/src/resources/textview_list.dart';

class NicknameListViewer extends StatelessWidget{
  final String urlAuthority = "bismarck.sdsu.edu";
  final String path = "/api/instapost-query/nicknames";
  final String listNameKey = "nicknames"; //key name map to a list of item from json body
                                          //api/instapost-query/nicknames or instapost-query/hashtags
  final String postIdsPath = "/api/instapost-query/nickname-post-ids";
  final Icon icon = Icon(Icons.person_pin);
  final String title = "Nicknames";
  final String paramKey = "nickname"; //the key name parameter is used to query all ids of a nickname
                                      //nickname-post-ids?paramKey=

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: TextViewList(
        urlAuthority : urlAuthority,
        path : path,
        listNameKey : listNameKey,
        postIdsPath : postIdsPath,
        paramKey: paramKey,
        itemListIcon : icon,
        title: title,
      ),
    );
  }
}