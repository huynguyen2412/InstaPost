import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main() async{
  hashTag();
}

void _httpRequest() async{
  // final url = "https://bismarck.sdsu.edu/api/instapost-upload/newuser";
  // final response = await http.post(url,
  //     headers: {
  //       HttpHeaders.contentTypeHeader: "application/json"
  //     },
  //     body: jsonEncode(<String, String>{
  //       "firstname": "fooHa",
  //       "lastname": "barLa",
  //       "nickname": "fooBarHala",
  //       "email": "okfoo@gmail.com",
  //       "password": "abcde"
  //     }),
  // );
  //
  // if(response.statusCode == 200){
  //   print("Member has created");
  // }
  // else{
  //   final res = jsonDecode(response.body);
  //   print("${res['result']} create a member. ${res['errors']}");
  // }

  // final url = "bismarck.sdsu.edu";
  // final Map<String,String> queryParams = {
  //   "firstname": "fooHa",
  //   "lastname": "barLa",
  //   "nickname": "fooBarHala",
  //   "email": "okfoo@gmail.com",
  //   "password": "abcde"
  // };
  //
  // var uri = Uri.https(url, "/api/instapost-upload/newuser");
  // var response = await http.post(
  //   uri,
  //   headers: {HttpHeaders.contentTypeHeader : "application/json"},
  //   body: jsonEncode(<String,String>{
  //     "firstname": "fooLA",
  //     "lastname": "barCA",
  //     "nickname": "fooBarCALA",
  //     "email": "cala@gmail.com",
  //     "password": "abcde"
  //   })
  // );
  // if(response.statusCode == 200){
  //   print("Member has created");
  // }
  // else{
  //   final res = jsonDecode(response.body);
  //   print("${res['result']} create a member. ${res['errors']}");
  // }

  // final String _url = 'bismarck.sdsu.edu';
  // final Map<String, String> queryParams = {
  //   'nickname' : "fooBarCALA"
  // };
  //
  // final _uri = Uri.https(_url, "/api/instapost-query/nickname-exists", queryParams);
  // //async validation
  // final response = await http.get(_uri,
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json'
  //     }
  // );
  // if(response.statusCode == 200){
  //   Map<String,dynamic> _resBody = jsonDecode(response.body);
  //   print(_resBody['result'] ?  "Nickname already taken." : null);
  // }
  // else
  //   throw Exception("Failed to validate Nickname from server");
}

void hashTag(){
  String tagText = "wwew #Hello#ilove#flutter #so #much";
  List<String> hashtags = tagText.split(RegExp(r"#"));

  List<String> tags = hashtags.getRange(1, hashtags.length).fold([], (prev, e){
          var tag = e.split(" ").first;
          return List.from(prev)..add("#$tag");
        }
  );

  // RegExp regEx = new RegExp(r"^[\w\s$&+,:;=?@|'<>.^*()%!-]*");
  // String foo = "qiofhqihfdiqhi dhqdihwqidhqiwhdioqhwdoiqh 312313i!!dhqpiwdhiqwhdiqhdi #hello #world";
  // final splitText = regEx.allMatches(foo).first.group(0);
  print(tags);
}

