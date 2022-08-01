import 'dart:convert';
import 'package:demo_app_flutter/apis/PeerToPeerQuestionsImage.dart';
import 'package:demo_app_flutter/apis/peer_to_peer_Questions.dart';
import 'package:demo_app_flutter/data_fields.dart';
import 'package:demo_app_flutter/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:photo_view/photo_view_gallery.dart';



//ID AnswerSheetID

//MarkID for UserMark ID

class PeerToPeerPhotoViewerScreen extends StatefulWidget {
  final String id;
  final String markID;

  final String realMark;
  final int receiver;

  const PeerToPeerPhotoViewerScreen(
      {Key? key,
      required this.realMark,
      required this.markID,
      required this.id,
      required this.receiver})
      : super(key: key);

  @override
  State<PeerToPeerPhotoViewerScreen> createState() =>
      _PeerToPeerPhotoViewerScreenState();
}

class _PeerToPeerPhotoViewerScreenState
    extends State<PeerToPeerPhotoViewerScreen> {
  String demo_text = "", question_text = "";

  int _current_index = 1;

  @override
  void initState() {
    PeerToPeerQuestionImageApi.fetchQuestionImage(widget.id);

    super.initState();
  }

  @override
  void dispose() {
    PeerToPeerQuestionImageApi.status.value = "Loading";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Obx(
        () => PeerToPeerQuestionImageApi.status.value == "Error"
            ? Scaffold(
                body: LoaderButton(
                  onTap: () {
                    if (DataFields.isInternetOn.value) {
                      PeerToPeerQuestionImageApi.status.value = "Loading";
                      PeerToPeerQuestionImageApi.fetchQuestionImage(widget.id);
                    } else {
                      Get.snackbar(
                          "Error", "Please Check your Internet Connection");
                    }
                  },
                ),
              )
            : PeerToPeerQuestionImageApi.status.value == "Loading"
                ? Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          iconTheme: const IconThemeData(color: Colors.black),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        bottomNavigationBar: SizedBox(
                          height: Get.height * 0.16,
                          child: Column(
                            children: [
                              Center(
                                  child: Text(
                                DataFields.teacherQuestionImage.length != 0
                                    ? "Page ${_current_index} / ${DataFields.teacherQuestionImage.length}"
                                    : "No Image Found",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18),
                              )),
                            ],
                          ),
                        ),
                        body: SafeArea(
                          child: DataFields.teacherQuestionImage.length != 0
                              ? PageView.builder(
                                  itemCount:
                                      DataFields.teacherQuestionImage.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                      child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.70,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: PhotoViewGallery.builder(
                                                itemCount: DataFields
                                                    .teacherQuestionImage
                                                    .length,
                                                builder: (BuildContext context,
                                                    int index) {
                                                  return PhotoViewGalleryPageOptions(
                                                    imageProvider: NetworkImage(
                                                        "${DataFields.teacherQuestionImage[index].image}"),
                                                  );
                                                },
                                                onPageChanged: (int index) {
                                                  setState(() {
                                                    _current_index = index + 1;
                                                  });
                                                },
                                              ))),
                                    );
                                  })
                              : Center(
                                  child: Text(
                                    "পরীক্ষার্থী এই প্রশ্নটির উত্তর করেননি।\nঅনুগ্রহ করে পূর্ববর্তী পেজ থেকে অন্যান্য উত্তরগুলো দেখুন।\nধন্যবাদ।",
                                    textAlign: TextAlign.center,
                                ),
                        )),
                  ),
    )
    );
  }
}
