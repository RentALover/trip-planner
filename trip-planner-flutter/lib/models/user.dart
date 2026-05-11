class UserInfo {
  final int id;
  final String username;
  final String nickname;
  final String? avatarUrl;

  UserInfo({required this.id, required this.username, required this.nickname, this.avatarUrl});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json['id'] as int,
    username: json['username'] as String,
    nickname: (json['nickname'] as String?) ?? json['username'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'username': username, 'nickname': nickname, 'avatarUrl': avatarUrl,
  };

  String get displayName => nickname.isNotEmpty ? nickname : username;
}

class UserProfile {
  final int id;
  final String username;
  final String nickname;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? createTime;

  UserProfile({
    required this.id, required this.username, required this.nickname,
    this.email, this.phone, this.avatarUrl, this.bio, this.createTime,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int,
    username: json['username'] as String,
    nickname: (json['nickname'] as String?) ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    bio: json['bio'] as String?,
    createTime: json['createTime'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'username': username, 'nickname': nickname,
    'email': email, 'phone': phone, 'avatarUrl': avatarUrl, 'bio': bio,
    'createTime': createTime,
  };
}

class LoginResponse {
  final String token;
  final UserInfo user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'] as String,
    user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class LoginReq {
  final String username;
  final String password;
  LoginReq({required this.username, required this.password});
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class RegisterReq {
  final String username;
  final String password;
  final String? nickname;
  final String? email;
  RegisterReq({required this.username, required this.password, this.nickname, this.email});
  Map<String, dynamic> toJson() => {
    'username': username, 'password': password,
    if (nickname != null) 'nickname': nickname,
    if (email != null) 'email': email,
  };
}

class UserUpdateReq {
  final String? nickname;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  UserUpdateReq({this.nickname, this.email, this.phone, this.avatarUrl, this.bio});
  Map<String, dynamic> toJson() => {
    if (nickname != null) 'nickname': nickname,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (bio != null) 'bio': bio,
  };
}

class PasswordChangeReq {
  final String oldPassword;
  final String newPassword;
  PasswordChangeReq({required this.oldPassword, required this.newPassword});
  Map<String, dynamic> toJson() => {'oldPassword': oldPassword, 'newPassword': newPassword};
}
