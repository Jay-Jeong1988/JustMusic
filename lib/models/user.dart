import 'dart:convert';

class User {
  final String id;
  final String accountId;
  final String password;
   String nickname;
  final ContactInfo contactInfo;
  final Profile profile;
  final followers;

  User({
    this.id,
    this.accountId,
    this.password,
    this.nickname,
    this.contactInfo,
    this.profile,
    this.followers
  }){
    print("new user instance is created");
  }

  factory User.fromDecodedJson(Map<String, dynamic> user) {
    return User(
      id: user['_id'],
      accountId: user['accountId'],
      password: user['password'],
      nickname: user['nickname'],
      followers: user['followers'],
      contactInfo: new ContactInfo(
        id: user['contactInfo']['_id'],
        email: user['contactInfo']['email'],
        phoneNumber: user['contactInfo']['phoneNumber']),
      profile: new Profile(
        id: user['profile']['_id'],
        firstName: user['profile']['firstName'],
        lastName: user['profile']['lastName'],
        birthDay: user['profile']['birthDay'],
        pictureUrl: user['profile']['pictureUrl'],
        bannerImageUrl: user['profile']['bannerImageUrl'],
      )
    );
  }

  static String toJson(User user){
    Map<String, dynamic> self = new Map<String, dynamic>();
    self["_id"] = user.id;
    self["accountId"] = user.accountId;
    self["password"] = user.password;
    self["nickname"] = user.nickname;

    self["contactInfo"] = Map<String, dynamic>();
    self["contactInfo"]['_id'] = user.contactInfo.id;
    self["contactInfo"]['email'] = user.contactInfo.email;
    self["contactInfo"]['phoneNumber'] = user.contactInfo.phoneNumber;

    self["profile"] = Map<String, dynamic>();
    self["profile"]["_id"] = user.profile.id;
    self["profile"]["firstName"] = user.profile.firstName;
    self["profile"]["lastName"] = user.profile.lastName;
    self["profile"]["birthDay"] = user.profile.birthDay;

    return jsonEncode(self);
  }
}

class ContactInfo {
  final String id;
  final String email;
  final String phoneNumber;

  ContactInfo({
    this.id,
    this.email,
    this.phoneNumber,
  });
}

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String birthDay;
   String pictureUrl;
   String bannerImageUrl;

  Profile({
    this.id,
    this.firstName,
    this.lastName,
    this.birthDay,
    this.pictureUrl,
    this.bannerImageUrl
  });
}