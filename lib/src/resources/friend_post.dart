import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta_post/src/models/user_post.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:insta_post/src/resources/comment_view.dart';
import 'package:insta_post/src/resources/image_viewer.dart';
import 'package:insta_post/src/resources/rating_post.dart';
import 'package:provider/provider.dart';

class FriendPost extends StatefulWidget{
  final UserPostPODO userPostInfo;
  final String nickname;
  final String listNameKey = "ids";

  FriendPost({this.userPostInfo, this.nickname});

  @override
  _FriendPost createState() => _FriendPost();
}

class _FriendPost extends State<FriendPost>{
  final String urlAuthority = "bismarck.sdsu.edu";
  final _headersParams = {
    HttpHeaders.contentTypeHeader : "application/json"
  };
  TextEditingController _commentController = TextEditingController();
  Future<String> resBody;
  bool _isErrorExist = false;
  String _errorMessage = "";
  int _ratingScore = 0;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    _commentController.dispose();
    super.dispose();
  }

  Future<String> _postAComment(int postId) async{
    final commentPath = "/api/instapost-upload/comment";
    final Map<String, dynamic> queryParams = {
      "email": Provider.of<UserStateModel>(context, listen: false).userInfo.email,
      "password": Provider.of<UserStateModel>(context, listen: false).userInfo.password,
      "comment": _commentController.text,
      "post-id": postId
    };
    final uri = Uri.https(urlAuthority, commentPath);
    final response = await http.post(uri,
      headers: _headersParams,
      body: jsonEncode(queryParams)
    );

    if(response.statusCode != 200){
      throw Exception("Failed to send the comment\n"
          "Error ${response.statusCode}\n"
          "${response.body.toString()}");
    }
    return response.body;
  }

  Future<String> _submitRate(int postId, int rating) async{
    final commentPath = "/api/instapost-upload/rating";
    final Map<String, dynamic> queryParams = {
      "email": Provider.of<UserStateModel>(context, listen: false).userInfo.email,
      "password": Provider.of<UserStateModel>(context, listen: false).userInfo.password,
      "rating" : rating,
      "post-id": postId
    };
    final uri = Uri.https(urlAuthority, commentPath);
    final response = await http.post(uri,
      headers: _headersParams,
      body: jsonEncode(queryParams)
    );

    if(response.statusCode != 200){
      throw Exception("Failed to submit the rating\n"
          "Error ${response.statusCode}\n"
          "${response.body.toString()}");
    }
    return response.body;
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

  //the information get from "post" object of post-id
  Widget friendPost(UserPostPODO userPostInfo, BuildContext context){
    // final Map<String, dynamic> temp = {
    //   "post": {
    //     "comments": ["AAAAA", "BBBBB", "CCCCC","AAAAA", "BBBBB", "CCCCC","AAAAA", "BBBBB", "CCCCC","AAAAA", "BBBBB", "CCCCC", "EEEEE"],
    //     "ratings-count": 0,
    //     "ratings-average": -1,
    //     "id": 1915,
    //     "hashtags": [
    //       "#fe",
    //       "#rr",
    //       "#ar",
    //       "#ii"
    //     ],
    //     "image": 1915,
    //     "text": "new car blah blah "
    //   },
    // };
    // final postInfo = UserPostPODO.fromJson(temp['post']);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black38,
                width: 2
            )
        ),
        child: Column(
          children: <Widget>[
            (userPostInfo.imageId != -1 ?
            ImageViewer(userPostInfo.imageId) : Text("")
            ),//image
            Container(
              child: Text(
                  userPostInfo.text +
                      userPostInfo.hashtags.fold("", (prev, val) => prev + val).toString()
              ),
            ),//tweetpost
            Container(
              child: CommentView(userPostInfo.comments),
            ),
            Container(
              child: RatingPost(
                  userPostInfo.id,
                  userPostInfo.ratingsAverage < 0 ?
                    "0" : userPostInfo.ratingsAverage.toStringAsFixed(2).toString(),
                  (int rate) => _ratingScore = rate
              ),
            ),//rating
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black26,
                  ),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: TextField(
                controller: _commentController,
                autofocus: false,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none
                ),
              ),
            ),
            Container(
              child: Text(
                _isErrorExist ? _errorMessage : ""
              ),
            ),
            ElevatedButton(
              child: Icon(Icons.comment),
              onPressed: () async{
                final postId = widget.userPostInfo.id;
                final submitStatus = await _submitPost(postId, _ratingScore, context);
                final isCommentRatingValid = _validateCommentAndRating(this._ratingScore, _commentController.text);

                //validate user's comment and rating
                //update comments and rating average after submitting the post
                if(submitStatus && isCommentRatingValid){
                  _commentController.clear();
                  final postId = widget.userPostInfo.id;
                  final updatedUserPostInfo = await _getAPost(postId);

                  if(updatedUserPostInfo != null){
                    setState(() {
                      widget.userPostInfo.comments = updatedUserPostInfo.comments;
                      widget.userPostInfo.ratingsAverage = updatedUserPostInfo.ratingsAverage;
                    });
                  }else{
                    SnackBar snackBar = new SnackBar(
                      content: Text("Failed to reload the comments and rating."),
                      duration: new Duration(seconds: 3),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  }
                }else{
                  SnackBar snackBar = new SnackBar(
                    content: Text("Rate or Comment cannot be 0 or empty"),
                    duration: new Duration(seconds: 3),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }//validation and submit the post
              },
            )
          ],
        ),
      ),
    );
  }

  bool _validateCommentAndRating(int ratingScore, String comment){
    return (ratingScore > 0) && (comment.isNotEmpty);
  }

  Future<UserPostPODO> _getAPost(int postId) async{
    final postPath = "/api/instapost-query/post";
    final Map<String, String> queryParams = {
      "post-id" : postId.toString()
    };
    final response = await _getStreamData(urlAuthority, postPath, queryParams: queryParams);
    final jsonResBody = jsonDecode(response);

    if(jsonResBody['result'] == "fail")
      return null;

    return UserPostPODO.fromJson(jsonResBody['post']);
  }


  Future<bool> _submitPost(int postId, int rating, BuildContext context) async{
    final commentResBody = await _postAComment(postId);
    final commentJson = jsonDecode(commentResBody);
    final ratingResBody = await _submitRate(postId, rating);
    final ratingJson = jsonDecode(ratingResBody);

    if(commentJson['result'] == 'fail'){
      final snackBar = SnackBar(content: Text(
        "Failed to send the comment\n"),
        duration: new Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    if(ratingJson['result'] == 'fail'){
      final snackBar = SnackBar(content: Text(
          "Failed to submit the rate.\n"),
        duration: new Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nickname),
      ),
      body: Builder(
        builder: (context) => friendPost(widget.userPostInfo, context)
      )
    );
  }
}