import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta_post/src/resources/preview_post_list.dart';

/* Display the list of text items by GET from server*/
class TextViewList extends StatefulWidget{
  final String urlAuthority;
  final String path;
  final String listNameKey; //key name map to a list of item from json body
                            //api/instapost-query/nicknames or instapost-query/hashtags
  final String postIdsPath; //path of endpoint when user taps on an item from the list
  final Icon itemListIcon;
  final String title;
  final String paramKey; //the key name parameter is used to query all ids of a nickname
                        //nickname-post-ids?paramKey= or hashtags-post-ids?paramKey=

  TextViewList({this.urlAuthority, this.path, this.title,
    this.listNameKey, this.postIdsPath,this.itemListIcon, this.paramKey});

  @override
  _TextViewList createState() => _TextViewList();
}

class _TextViewList extends State<TextViewList>{
  Future<String> _dataStream;
  
  @override
  void initState(){
    _dataStream = _getStreamData(widget.urlAuthority, widget.path);
    super.initState();
  }

  //Get json response from an endpoint
  Future<String> _getStreamData(String urlAuthority, String path) async{
    final uri = Uri.https(urlAuthority, path);
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
  
  Widget textViewListDisplayer(List<dynamic> dataList, Icon itemListIcon){
    return ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index){
          return ListTile(
            onTap: () async{
              //open the preview page with list of posts from each of post-id
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(widget.title),
                      ),
                      body: PreviewPostList(
                        urlAuthority: widget.urlAuthority,
                        postIdsPath: widget.postIdsPath,
                        paramValue: dataList[index],
                        title: dataList[index],
                        paramKey: widget.paramKey,
                      ),
                    )
                )
              );
            },
            leading: itemListIcon,
            title: Text("${dataList[index]}"),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
          future: _dataStream,
          builder: (context, AsyncSnapshot<String> snapshot){
            if(snapshot.hasError){
              return Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              );
            }
            else if(snapshot.hasData){
              final res = jsonDecode(snapshot.data);
              final itemList = res[widget.listNameKey];
              return textViewListDisplayer(itemList, widget.itemListIcon);
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
      );
  }
}
