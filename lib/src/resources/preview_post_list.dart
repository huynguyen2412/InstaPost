import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta_post/src/models/user_post.dart';
import 'package:insta_post/src/resources/image_viewer.dart';

import 'friend_post.dart';

/* Display the list of text items by GET from server*/
class PreviewPostList extends StatefulWidget{
  final String title;
  final String urlAuthority;
  final String postIdsPath; //path to get all ids of a hashtag or a nickname
  final String listNameKey; //key name map to a list of item from json body
                            //api/instapost-query/nicknames or instapost-query/hashtags
  final String paramValue; //value is used to query response
  final String paramKey; //the key name parameter is used to query all ids of a nickname
                        //nickname-post-ids?paramKey= or hashtags-post-ids?paramKey=

  PreviewPostList({this.urlAuthority, this.postIdsPath,
    this.listNameKey, this.title, this.paramValue, this.paramKey});

  @override
  _PreviewPostList createState() => _PreviewPostList();
}

class _PreviewPostList extends State<PreviewPostList>{
  final StreamController<List<UserPostPODO>> _userPostController = StreamController<List<UserPostPODO>>();
  Stream<List<UserPostPODO>> _userPostsStream;
  List<UserPostPODO> _userPosts = [];
  final String postPath = "/api/instapost-query/post";

  @override
  void initState(){
    _userPostsStream = _userPostController.stream;
    _loadUserPostList(widget.paramValue);
    super.initState();
  }

  //get a list of post-ids and create a list of userPosts' info
  void _loadUserPostList(String paramValue) async{
    final Map<String, String> queryParams = {
      widget.paramKey : paramValue
    };
    final response = await _getStreamData(widget.urlAuthority, widget.postIdsPath, queryParams: queryParams);
    final jsonRes = jsonDecode(response);
    final postIds = jsonRes['ids'];

    postIds.forEach((id) async{
      final Map<String, String> qParams = {
        "post-id" : id.toString()
      };
      final res = await _getStreamData(widget.urlAuthority, postPath, queryParams: qParams);
      final postJson = jsonDecode(res);
      final userPost = UserPostPODO.fromJson(postJson['post']);
      _userPosts.add(userPost);
      _userPostController.add(_userPosts);
    });
  }

  Future<String> _getStreamData(String urlAuthority, String path, {Map<String,String> queryParams}) async{
    final uri = Uri.https(urlAuthority, path, queryParams);
    final headerParams = {
      HttpHeaders.contentTypeHeader : "application/json"
    };
    final response = await http.get(uri, headers: headerParams);
    if(response.statusCode != 200)
      throw Exception("Failed to request server\n"
          "Error: ${response.statusCode}"
          "${response.body.toString()}");

    return response.body;
  }

  Widget previewListDisplayer(List<UserPostPODO> userPosts){
    return ListView.separated(
        itemCount: userPosts.length,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.black26,
        ),
        itemBuilder: (context, index){
          return singlePreviewPost(userPosts[index]);
        }
    );
  }

  //display a single preview post with a tweet and an image if the post has
  //open the post with full info page when tapping on it
  Widget singlePreviewPost(UserPostPODO userPost) {
    final tweet = Text(
        userPost.text + userPost.hashtags.fold("", (prev, e) => prev+e),
        style: TextStyle(fontSize: 20),
    );

    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12
        ),
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: InkWell(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                FriendPost(
                  userPostInfo: userPost,
                  nickname: widget.title,
                )
            )
          )
        },
        child: Column(
          children: <Widget>[
            userPost.imageId == -1 ? Text("") : ImageViewer(userPost.imageId),//display an image
            tweet
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new StreamBuilder<List<UserPostPODO>>(
          stream: _userPostsStream,
          initialData: _userPosts,
          builder: (context, AsyncSnapshot<List<UserPostPODO>> snapshot){
            if(snapshot.hasError){
              return Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              );
            }
            else if(snapshot.data != null){
              return previewListDisplayer(snapshot.data);
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
      ),
    );
  }
}
