import 'dart:async';
import 'package:demo_app_flutter/apis/PeerToPeerQuestionsImage.dart';
import 'package:demo_app_flutter/apis/peer_to_peer_Questions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataFields {
  static Rx<bool> isHomeDataLoading = true.obs,
      isActivityDataLoading = true.obs,
      isInternetOn = true.obs;
  static bool isDone = false, showedNoticeBoard = false;

  static late StreamSubscription subscription;
  static String token = "95d152a0454da34deede82bf8b9a3dcc84e7bfe9";


  static List<int> notificationIds = [];
  //static List<String> subjectList = [];
  static ScrollController scrollController = ScrollController();

  static late TeacherQuestion teacherQuestion;
  static late List<QuestionsImage> teacherQuestionImage;

  static RxInt timeInSecond = 0.obs;

  static late Timer timer;
  static RxString subjSelected = "".obs,
      questionsSelected = "All".obs,
      formattedTime = "".obs;
}
