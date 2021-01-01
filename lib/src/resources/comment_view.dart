import 'package:flutter/material.dart';

/* Display the comments of a post
* */

class CommentView extends StatelessWidget{
  final List<dynamic> comments;
  CommentView(this.comments);

  Widget commentItem(String comment){
    return Container(
      width: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.black12
        )
      ),
      child: Text(
        comment,
        textAlign: TextAlign.left,
      )
    );
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            for(final e in comments) commentItem(e)
          ],
        ),
      )
    );
  }
}