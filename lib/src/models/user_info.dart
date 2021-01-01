class UserInfoPODO {
  String firstName;
  String lastName;
  String nickname;
  String email;
  String password;


  UserInfoPODO({this.firstName, this.lastName, this.nickname, this.email, this.password});

  factory UserInfoPODO.fromJson(Map<String, dynamic> json) {
    return UserInfoPODO(
      firstName: json['firstname'],
      lastName: json['lastname'],
      nickname: json['nickname'],
      email: json['email'],
      password: json['password']
    );
  }
}