import 'dart:convert';
import 'package:demo_app_flutter/constants.dart';
import 'package:demo_app_flutter/data_fields.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


// UserMark ID


class PairToPairQuestionApi {
  static RxString status = "Loading".obs;
  static void fetchData(id, receiver) async {
    if (DataFields.isInternetOn.value) {
      var url = Uri.parse(Constants.baseApiUrl + "written/answer-view-peer-to-peer/$id/$receiver/");
      var response = await http.get(url,
          headers: {"Authorization": "Token " + DataFields.token});
      if (response.statusCode == 200) {
        DataFields.teacherQuestion =
            teacherQuestionFromJson(utf8.decode(response.bodyBytes));
        status.value = "Loaded";
      } else {
        status.value = "Error";
      }
    } else {
      status.value = "Error";
    }
  }
}

TeacherQuestion teacherQuestionFromJson(String str) =>
    TeacherQuestion.fromJson(json.decode(str));

String teacherQuestionToJson(TeacherQuestion data) =>
    json.encode(data.toJson());


class TeacherQuestion {
  TeacherQuestion({
    this.response,
  });

  Response? response;

  factory TeacherQuestion.fromJson(Map<String, dynamic> json) =>
      TeacherQuestion(
        response: Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
    "Response": response?.toJson(),
  };
}

class Response {
  Response({
    this.examReviewId,
    this.isTeacher,
    this.questions,
  });

  int? examReviewId;
  bool? isTeacher;
  List<Question>? questions;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    examReviewId: json["exam_review_id"],
    isTeacher: json["is_teacher"],
    questions: List<Question>.from(
        json["questions"].map((x) => Question.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "exam_review_id": examReviewId,
    "is_teacher": isTeacher,
    "questions": List<dynamic>.from(questions!.map((x) => x.toJson())),
  };
}

class Question {
  Question({
    this.id,
    this.providedMarks,
    this.image_count,
    this.question,
    this.realMark,
    this.isMarked,
  });

  int? id;
  dynamic providedMarks;
  String? question;
  int? image_count;
  dynamic realMark;
  bool? isMarked;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json["id"],
    providedMarks: json["provided_marks"].toDouble(),
    image_count: json["image_count"],
    question: json["question"],
    realMark: json["real_mark"],
    isMarked: json["is_marked"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provided_marks": providedMarks,
    "image_count": image_count,
    "question": question,
    "real_mark": realMark,
    "is_marked": isMarked,
  };
}
