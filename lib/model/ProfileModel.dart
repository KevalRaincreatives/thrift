///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class ProfileModelAllcaps {
/*
{
  "read": true,
  "level_0": true,
  "subscriber": true
}
*/

  bool? read;
  bool? level_0;
  bool? subscriber;

  ProfileModelAllcaps({
    this.read,
    this.level_0,
    this.subscriber,
  });
  ProfileModelAllcaps.fromJson(Map<String, dynamic> json) {
    read = json["read"];
    level_0 = json["level_0"];
    subscriber = json["subscriber"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["read"] = read;
    data["level_0"] = level_0;
    data["subscriber"] = subscriber;
    return data;
  }
}

class ProfileModelCaps {
/*
{
  "subscriber": true
}
*/

  bool? subscriber;

  ProfileModelCaps({
    this.subscriber,
  });
  ProfileModelCaps.fromJson(Map<String, dynamic> json) {
    subscriber = json["subscriber"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["subscriber"] = subscriber;
    return data;
  }
}

class ProfileModelData {
/*
{
  "ID": "16123",
  "user_login": "keval.raincreatives@gmail.com",
  "user_pass": "$P$BSK1BiYBFJtidEg7ce6buCZ4..D6W61",
  "user_nicename": "keval-raincreativesgmail-com",
  "user_email": "keval.raincreatives@gmail.com",
  "user_url": "",
  "user_registered": "2021-10-04 09:31:58",
  "user_activation_key": "",
  "user_status": "0",
  "display_name": "keval.raincreatives@gmail.com",
  "first_name": "Keval",
  "last_name": "Panchal",
  "phone": "7878308210",
  "phone_code": "91"
}
*/

  String? ID;
  String? userLogin;
  String? userPass;
  String? userNicename;
  String? userEmail;
  String? userUrl;
  String? userRegistered;
  String? userActivationKey;
  String? userStatus;
  String? displayName;
  String? firstName;
  String? lastName;
  String? phone;
  String? phoneCode;

  ProfileModelData({
    this.ID,
    this.userLogin,
    this.userPass,
    this.userNicename,
    this.userEmail,
    this.userUrl,
    this.userRegistered,
    this.userActivationKey,
    this.userStatus,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phone,
    this.phoneCode,
  });
  ProfileModelData.fromJson(Map<String, dynamic> json) {
    ID = json["ID"]?.toString();
    userLogin = json["user_login"]?.toString();
    userPass = json["user_pass"]?.toString();
    userNicename = json["user_nicename"]?.toString();
    userEmail = json["user_email"]?.toString();
    userUrl = json["user_url"]?.toString();
    userRegistered = json["user_registered"]?.toString();
    userActivationKey = json["user_activation_key"]?.toString();
    userStatus = json["user_status"]?.toString();
    displayName = json["display_name"]?.toString();
    firstName = json["first_name"]?.toString();
    lastName = json["last_name"]?.toString();
    phone = json["phone"]?.toString();
    phoneCode = json["phone_code"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["ID"] = ID;
    data["user_login"] = userLogin;
    data["user_pass"] = userPass;
    data["user_nicename"] = userNicename;
    data["user_email"] = userEmail;
    data["user_url"] = userUrl;
    data["user_registered"] = userRegistered;
    data["user_activation_key"] = userActivationKey;
    data["user_status"] = userStatus;
    data["display_name"] = displayName;
    data["first_name"] = firstName;
    data["last_name"] = lastName;
    data["phone"] = phone;
    data["phone_code"] = phoneCode;
    return data;
  }
}

class ProfileModel {
/*
{
  "data": {
    "ID": "16123",
    "user_login": "keval.raincreatives@gmail.com",
    "user_pass": "$P$BSK1BiYBFJtidEg7ce6buCZ4..D6W61",
    "user_nicename": "keval-raincreativesgmail-com",
    "user_email": "keval.raincreatives@gmail.com",
    "user_url": "",
    "user_registered": "2021-10-04 09:31:58",
    "user_activation_key": "",
    "user_status": "0",
    "display_name": "keval.raincreatives@gmail.com",
    "first_name": "Keval",
    "last_name": "Panchal",
    "phone": "7878308210",
    "phone_code": "91"
  },
  "ID": 16123,
  "caps": {
    "subscriber": true
  },
  "cap_key": "encros_capabilities",
  "roles": [
    "subscriber"
  ],
  "allcaps": {
    "read": true,
    "level_0": true,
    "subscriber": true
  },
  "filter": null
}
*/

  ProfileModelData? data;
  int? ID;
  ProfileModelCaps? caps;
  String? capKey;
  List<String?>? roles;
  ProfileModelAllcaps? allcaps;
  String? filter;

  ProfileModel({
    this.data,
    this.ID,
    this.caps,
    this.capKey,
    this.roles,
    this.allcaps,
    this.filter,
  });
  ProfileModel.fromJson(Map<String, dynamic> json) {
    data = (json["data"] != null) ? ProfileModelData.fromJson(json["data"]) : null;
    ID = json["ID"]?.toInt();
    caps = (json["caps"] != null) ? ProfileModelCaps.fromJson(json["caps"]) : null;
    capKey = json["cap_key"]?.toString();
    if (json["roles"] != null) {
      final v = json["roles"];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      roles = arr0;
    }
    allcaps = (json["allcaps"] != null) ? ProfileModelAllcaps.fromJson(json["allcaps"]) : null;
    filter = json["filter"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (data != null) {
      data["data"] = this.data!.toJson();
    }
    data["ID"] = ID;
    if (caps != null) {
      data["caps"] = caps!.toJson();
    }
    data["cap_key"] = capKey;
    if (roles != null) {
      final v = roles;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data["roles"] = arr0;
    }
    if (allcaps != null) {
      data["allcaps"] = allcaps!.toJson();
    }
    data["filter"] = filter;
    return data;
  }
}
