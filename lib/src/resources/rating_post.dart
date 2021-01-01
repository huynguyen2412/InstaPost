import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

/* Display the rating scale and rating average of a post. */

class RatingPost extends StatefulWidget{
  final int postId;
  final String ratingAvg;
  final Function(int) getRate;
  RatingPost(this.postId, this.ratingAvg, this.getRate);

  @override
  _RatingPost createState() => _RatingPost();
}

class _RatingPost extends State<RatingPost>{
  final String _urlAuthority = "bismarck.sdsu.edu";
  final String _path = "/api/instapost-upload/rating";
  final Map<String,String> headerParams = {
    HttpHeaders.contentTypeHeader : "application/json"
  };
  int _ratingScore = 0;

  Widget ratingScale(){
    return Container(
      child: RatingBar(
        initialRating: 0,
        minRating: 0,
        direction: Axis.horizontal,
        itemCount: 5,
        itemSize: 30.0,
        ratingWidget: RatingWidget(
          full: Icon(Icons.star, color: Colors.amber),
          empty: Icon(Icons.star_border, color: Colors.amber)
        ),
        onRatingUpdate: (rating){
          _ratingScore = rating.round();
          widget.getRate(_ratingScore);
        },
      ),
    );
  }

  Future<String> submitRate(int postId) async{
    final uri = Uri.https(_urlAuthority, _path);
    final Map<String,dynamic> queryParms = {
      "email" : Provider.of<UserStateModel>(context).userInfo.email,
      "password" : Provider.of<UserStateModel>(context).userInfo.password,
      "rating" : _ratingScore,
      "post-id" : postId
    };
    final response = await http.post(
      uri,
      headers: headerParams,
      body: jsonEncode(queryParms)
    );

    if(response.statusCode != 200){
      throw Exception("Failed to submit the rate to server\n"
          "Error ${response.statusCode}\n"
          "${response.body.toString()}");
    }

    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ratingScale(),
          Text(" -- Rating Average: ${widget.ratingAvg}")
        ],
      ),
    );
  }
}