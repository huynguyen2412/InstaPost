import 'package:flutter/material.dart';
import 'package:insta_post/src/resources/friend_post.dart';

class FriendInstapost extends StatelessWidget{
  final int postId;
  final String _urlAuthority = "bismarck.sdsu.edu";
  final String _path = "/api/instapost-upload/";
  final String listNameKey = "ids";

  FriendInstapost(this.postId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FriendPost"),
      ),
      body: Text("")
    );
  }
}
