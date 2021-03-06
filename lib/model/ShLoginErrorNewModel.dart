///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class ShLoginErrorNewModel {
/*
{
  "message": "<strong>Error</strong>: The password you entered for the email address <strong>keval.raincreatives@gmail.com</strong> is incorrect. <a href=\"https://encros.rcstaging.co.in/my-account/lost-password/\">Lost your password?</a>"
}
*/

  String? message;

  ShLoginErrorNewModel({
    this.message,
  });
  ShLoginErrorNewModel.fromJson(Map<String, dynamic> json) {
    message = json["message"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["message"] = message;
    return data;
  }
}
