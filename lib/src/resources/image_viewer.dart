import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* Display an image from a post asynchronously
* the image get from server by using "id" parameter
* */

class ImageViewer extends StatefulWidget{
  final int imageId;

  ImageViewer(this.imageId);

  @override
  _ImageViewer createState() => _ImageViewer();
}

class _ImageViewer extends State<ImageViewer>{
  Future<String> _image;

  @override
  void initState(){
    _image = _getImageFromPost(widget.imageId);
    super.initState();
  }

  //request an image from server to display in a post
  Future<String> _getImageFromPost(int imageId) async{
    final String urlAuthority = "bismarck.sdsu.edu";
    final String path = "api/instapost-query/image";
    final Map<String,String> queryParams = {
      "id" : imageId.toString()
    };
    final uri = Uri.https(urlAuthority, path, queryParams);
    final headersParams = {
      HttpHeaders.contentTypeHeader : "application/json"
    };
    final response = await http.get(uri,
        headers: headersParams);

    if(response.statusCode != 200)
      throw Exception("Failed to request the image from server\n"
          "Error : ${response.statusCode}\n"
          "${response.body.toString()}");
    return response.body;
  }

  Widget displayImagePost(String response){
    final json = jsonDecode(response);

    if(json['result'] == 'fail'){
      return Center(
        child: Container(
          child: Column(
            children: <Widget>[
              Icon(Icons.error),
              Text(json["errors"])
            ],
          ),
        )     //image not found,
      );
    }else{
      final Uint8List decodeBytes = base64Decode(json["image"]);
      return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black
            ),
          ),
          width: 300,
          height: 200,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image.memory(decodeBytes),
          ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
      future: _image,
      builder: (context, AsyncSnapshot<String> snapshot){
        if(snapshot.hasError){
          return Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
          );
        }else if(snapshot.hasData){
          return displayImagePost(snapshot.data);
        }else{
          return Container(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}