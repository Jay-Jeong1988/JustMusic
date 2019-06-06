class User {
  final String id;
  final String accountId;
  final String password;
  final String nickname;
  final ContactInfo contactInfo;
  final Profile profile;

  User({
    this.id,
    this.accountId,
    this.password,
    this.nickname,
    this.contactInfo,
    this.profile,
  }){
    print("new user instance is created");
  }

  factory User.fromJson(Map<String, dynamic> json) {
    var user = json["user"];
    return User(
      id: user['_id'],
      accountId: user['accountId'],
      password: user['password'],
      nickname: user['nickname'],
      contactInfo: new ContactInfo(
        id: user['contactInfo']['_id'],
        email: user['contactInfo']['email'],
        phoneNumber: user['contactInfo']['phoneNumber']),
      profile: new Profile(
        id: user['profile']['_id'],
        firstName: user['profile']['firstName'],
        lastName: user['profile']['lastName'],
        birthDay: user['profile']['birthDay']
      )
    );
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
  }){print("new contactInfo intance is created");}
}

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String birthDay;

  Profile({
    this.id,
    this.firstName,
    this.lastName,
    this.birthDay,
  }){print("new Profile intance is created");}
}