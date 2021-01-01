import 'dart:convert';
import 'dart:io' ;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/painting.dart';
import 'package:insta_post/src/models/user_state_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PostForm extends StatefulWidget{
  PostForm({Key postFormKey}):super(key: postFormKey);

  @override
  _PostForm createState() => _PostForm();
}

class _PostForm extends State<PostForm>{
  String _email, _password;
  GlobalKey _postFormKey = GlobalKey<FormState>();
  // String _formError = "";
  // bool _isFormErrorExist = false;
  final _tweetController = TextEditingController();
  final imgPicker = ImagePicker();
  File _postImage;
  final _urlAuthority = "bismarck.sdsu.edu";
  final headerParams = {
    HttpHeaders.contentTypeHeader : "application/json"
  };

  @override
  void initState() {
   _email = Provider.of<UserStateModel>(context, listen: false).userInfo.email;
   _password = Provider.of<UserStateModel>(context, listen: false).userInfo.password;
    super.initState();
  }

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  Widget postTextField(TextEditingController tweetController){
    return Container(
      height: 150,
      // margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
          width: 3
        ),
        borderRadius: BorderRadius.circular(12)
      ),
      child: TextFormField(
        validator: (value) {
          //validate hashtags if exist
          final hashTags = _getHashTagList(_tweetController.text);
          if(hashTags.length > 0){
            final isTagsValid = _validateHashTags(hashTags);
            return isTagsValid ? null : "A hashtag must be at least 2 characters";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.disabled,
        decoration: InputDecoration(
            hintText: "Tweet here",
            counterText: "",
            border: InputBorder.none,
            focusedBorder: InputBorder.none
        ),
        controller: tweetController,
        maxLength: 144,
        maxLengthEnforced: true,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ),
    );
  }

  //A hashtag need to be at least 2 characters include the hashtag
  //return false if requirement doesn't meet
  bool _validateHashTags(List<String> hashTags){
    for(String hTag in hashTags){
      if(hTag.length < 3)
        return false;
    }
    return true;
  }

  //return the list of hash tag from a post of the user
  //remove trailing space after each hashtag
  List<String> _getHashTagList(String textPost){
    final splitTags = textPost.split(RegExp(r'#'));
    List<String> hashTags = splitTags.getRange(1, splitTags.length).fold([], (prev, e){
        var tag = e.split(" ").first;
        return List.from(prev)..add("#$tag");
      }
    );
    return hashTags;
  }

  Future<String> _submitTextPost(String textPost) async{
    RegExp textPostRegex = new RegExp(r"^[\w\s$&+,:;=?@|'<>.^*()%!-]*");
    final hashTags = _getHashTagList(textPost);

    //extract the text of the post only
    final text = textPostRegex.allMatches(textPost).first.group(0);
    final path = "/api/instapost-upload/post";
    final Map<String, dynamic> queryParams = {
      "email" : _email,
      "password" : _password,
      "text" : text,
      "hashtags": hashTags
    };

    final uri = Uri.https(_urlAuthority, path);
    final response = await http.post(uri,
      headers: headerParams,
      body: jsonEncode(queryParams)
    );

    //server error exception
    if(response.statusCode != 200){
      throw Exception("Can't submit the text post. Error: ${response.statusCode}\n"
          "${response.body.toString()}");
    }
    return response.body;
  }

  Future<String> _submitImage(File imgFile, int id) async{
    String _imgString;
    final path = "/api/instapost-upload/image";
    final uri = Uri.https(_urlAuthority, path);
    _imgString = await imgFile.readAsBytes().then((value) => base64Encode(value));
    final Map<String, dynamic> queryParams = {
      "email" : _email,
      "password" : _password,
      "image" : _imgString,
      "post-id": id
    };
    final response = await http.post(uri,
      headers: headerParams,
      body: jsonEncode(queryParams)
    );

    //server error exception
    if(response.statusCode != 200){
      throw Exception("Server failed to submit the image.\n"
          "Error: ${response.statusCode}\n"
          "${response.body.toString()}"
      );
    }
    return response.body;
  }

  //handle the submission of a post with/without image
  Future<bool> _submitHelper(BuildContext context) async{
    final res = await _submitTextPost(_tweetController.text);
    final textResBody = jsonDecode(res);
    final postId = textResBody['id'];
    SnackBar snackBar;

    //text post only
    if(postId == -1){
      // _isFormErrorExist = !_isFormErrorExist;
      // _formError = textResBody['errors'];
      snackBar = new SnackBar(
        content: Text(textResBody['errors']),
        duration: new Duration(seconds: 3),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return false;
    }

    //post with an image
    if(_postImage != null){
      final imageRes = await _submitImage(_postImage, postId);
      final imgResBody = jsonDecode(imageRes);
      if(imgResBody['result'] == 'fail'){
        // _isFormErrorExist = !_isFormErrorExist;
        // _formError = textResBody['errors'];
        snackBar = new SnackBar(
          content: Text(textResBody['errors']),
          duration: new Duration(seconds: 3),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        return false;
      }
      // return true;
    }

    return true;
  }

  Widget createPost(GlobalKey<FormState> textPostFormKey, BuildContext context){
    return ElevatedButton.icon(
        onPressed: ()async{
          if(textPostFormKey.currentState.validate()){
            final postStatus = await _submitHelper(context);
            if(postStatus){
              Navigator.pop(context, postStatus);
            }
          }
        },
        icon: Icon(
          Icons.send,
          textDirection: TextDirection.rtl,
        ),
        label: Text("")
    );
  }

  //load an image to cache
  Future _uploadAnImage() async{
    final PickedFile pickedFile = await imgPicker.getImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      if (pickedFile != null){
        _postImage = File(pickedFile.path);
      }
    });
  }

  //display a selected image on the post
  Widget previewImage(){
    return Stack(
      children: <Widget>[
        Container(
          child: Image.file(_postImage),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: (){
              setState(() {
                _postImage = null;
              });
            },
            child: Icon(
              Icons.highlight_remove,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  //button to add an IMG
  Widget addIMG(){
    return ElevatedButton.icon(
      onPressed: ()async {
        await _uploadAnImage();
      },
      icon: Icon(Icons.image),
      label: Text("IMG"),
    );
  }

  Widget postForm(GlobalKey<FormState> textPostFormKey, BuildContext context){
    return Container(
      margin: const EdgeInsets.all(20),
      child: Form(
        key: textPostFormKey,
        child: Column(
          children: <Widget>[
            Center(
              child: _postImage == null ? Text("") : previewImage(),
            ),
            postTextField(_tweetController), //tweetField
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: addIMG(),
                  ),
                ),
                Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: createPost(textPostFormKey, context),
                    )
                )
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a posta!"),
      ),
      body: Builder(
        builder: (context) =>
          SingleChildScrollView(
              child: postForm(_postFormKey, context),
          ),
      )
    );
  }
}