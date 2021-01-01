import 'package:flutter/material.dart';
import 'package:insta_post/src/resources/textview_list.dart';

class HashtagListViewer extends StatelessWidget{
  final String urlAuthority = "bismarck.sdsu.edu";
  final String path = "api/instapost-query/hashtags";
  final String listNameKey = "hashtags"; //key name map to a list of item from json body
  final String postIdsPath = "/api/instapost-query/hashtags-post-ids";
  final Icon icon = Icon(Icons.title);
  final String title = "Hashtags";
  final String paramKey = "hashtag"; //the key name parameter is used to query all ids of a nickname
                                    //hashtags-post-ids?paramKey=

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hashtags"),
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