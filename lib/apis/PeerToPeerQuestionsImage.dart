import 'dart:convert';

import 'package:demo_app_flutter/constants.dart';
import 'package:demo_app_flutter/data_fields.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class PeerToPeerQuestionImageApi {
  static RxString status = "Loading".obs;

  static void fetchQuestionImage(id) async {
    if (DataFields.isInternetOn.value) {
      var url = Uri.parse(Constants.baseApiUrl + "written/peer-to-peer-get-all-images/$id/");
      var response = await http.get(url,
          headers: {"Authorization": "Token " + DataFields.token});
      if (response.statusCode == 200) {
        DataFields.teacherQuestionImage = questionsImageFromJson(utf8.decode(response.bodyBytes));
        status.value = "Loaded";
      } else {
        status.value = "Error";
      }
    } else {
      status.value = "Error";
    }
  }





  static Future getTopicAnddemoData(id) async {
    if (DataFields.isInternetOn.value) {
      var url = Uri.parse(Constants.baseApiUrl + "written/get-topic-and-question-from-answersheet/$id/");
      var response = await http.get(url,
          headers: {"Authorization": "Token " + DataFields.token});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        Get.snackbar("Something Went Wrong", "${response.statusCode}");
        status.value = "Error";
        return "error";
      }
    } else {
      status.value = "Error";
      return "error";
    }
  }

}

List<QuestionsImage> questionsImageFromJson(String str) =>
    List<QuestionsImage>.from(
        json.decode(str).map((x) => QuestionsImage.fromJson(x)));

String questionsImageToJson(List<QuestionsImage> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuestionsImage {
  QuestionsImage({
    this.id,
    this.image,
    this.imageOrder,
  });

  int? id;
  String? image;
  int? imageOrder;

  factory QuestionsImage.fromJson(Map<String, dynamic> json) => QuestionsImage(
    id: json["id"],
    image: json["image"],
    imageOrder: json["image_order"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "image_order": imageOrder,
  };
}
