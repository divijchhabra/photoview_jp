import 'dart:ui';

import 'package:demo_app_flutter/apis/PeerToPeerQuestionsImage.dart';
import 'package:demo_app_flutter/data_fields.dart';
import 'package:demo_app_flutter/edit_image.dart';
import 'package:demo_app_flutter/loader_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late double height, width;
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
    height = MediaQuery.of(context).size.height / 100;
    width = MediaQuery.of(context).size.width / 100;
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
                        PeerToPeerQuestionImageApi.fetchQuestionImage(
                            widget.id);
                      } else {
                        Get.snackbar(
                            "Error", "Please Check your Internet Connection");
                      }
                    },
                  ),
                )
              : PeerToPeerQuestionImageApi.status.value == "Loading"
                  ? const Scaffold(
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
                            Text(
                              DataFields.teacherQuestionImage.isNotEmpty
                                  ? "Page $_current_index / ${DataFields.teacherQuestionImage.length}"
                                  : "No Image Found",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: height * 3,
                                  left: width * 30,
                                  right: width * 30),
                              child: InkWell(
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => EditImage(
                                      imageUrl: DataFields
                                              .teacherQuestionImage[
                                                  _current_index - 1]
                                              .image ??
                                          ""),
                                )),
                                child: Container(
                                  height: height * 6,
                                  width: width * 35,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.circular(height * 7)),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: height * 3,
                                      ),
                                      SizedBox(
                                        width: width * 2,
                                      ),
                                      Text(
                                        "Edit Image",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: height * 1.7,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      body: SafeArea(
                          child: DataFields.teacherQuestionImage.isNotEmpty
                              ? PageView.builder(
                                  itemCount:
                                      DataFields.teacherQuestionImage.length,
                                  onPageChanged: (value) {
                                    setState(() => _current_index = value + 1);
                                  },
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
                                                image: DecorationImage(
                                                    image: NetworkImage(DataFields
                                                            .teacherQuestionImage[
                                                                0]
                                                            .image ??
                                                        ""),
                                                    fit: BoxFit.fill),
                                                border: Border.all(
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          )),
                                    );
                                  })
                              : const Center(
                                  child: Text(
                                    "পরীক্ষার্থী এই প্রশ্নটির উত্তর করেননি।\nঅনুগ্রহ করে পূর্ববর্তী পেজ থেকে অন্যান্য উত্তরগুলো দেখুন।\nধন্যবাদ।",
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                    ),
        ));
  }
}
