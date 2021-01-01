class UserPostPODO{
  List<dynamic> comments;
  int ratingCount = 0;
  dynamic ratingsAverage = -1;
  int id;
  int imageId;
  List<dynamic> hashtags;
  String text;

  UserPostPODO({
    this.comments, this.ratingCount, this.ratingsAverage,
    this.id, this.imageId, this.hashtags, this.text});

  UserPostPODO.fromJson(Map<String,dynamic> json):
      comments = json['comments'],
      ratingCount = json['rating-count'],
      ratingsAverage = json['ratings-average'],
      id = json['id'],
      imageId = json['image'],
      hashtags = json['hashtags'],
      text = json['text'];
}