import 'package:demo_app_flutter/apis/PeerToPeerQuestionsImage.dart';
import 'package:demo_app_flutter/apis/peer_to_peer_Questions.dart';
import 'package:demo_app_flutter/constants.dart';
import 'package:demo_app_flutter/data_fields.dart';
import 'package:demo_app_flutter/loader_button.dart';
import 'package:demo_app_flutter/peer_to_peer_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


//UserMark ID

class PeerToPeerQuestion extends StatefulWidget {
  final String id;
  int receiver;

  PeerToPeerQuestion({Key? key, required this.id, required this.receiver})
      : super(key: key);

  @override
  State<PeerToPeerQuestion> createState() => _PeerToPeerQuestionState();
}

class _PeerToPeerQuestionState extends State<PeerToPeerQuestion> {
  @override
  void initState() {
    PairToPairQuestionApi.fetchData(widget.id, widget.receiver);
    super.initState();
  }

  @override
  void dispose() {
    PairToPairQuestionApi.status.value = "Loading";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(DataFields.teacherQuestion.response?.questions?[0].isMarked);
    return Scaffold(
        body: Obx(
      () => PairToPairQuestionApi.status.value == "Error"
          ? LoaderButton(
              onTap: () {
                if (DataFields.isInternetOn.value) {
                  PairToPairQuestionApi.status.value = "Loading";
                  PairToPairQuestionApi.fetchData(widget.id, widget.receiver);
                } else {
                  Get.snackbar(
                      "Error", "Please Check your Internet Connection");
                }
              },
            )
          : PairToPairQuestionApi.status.value == "Loading"
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: DataFields
                            .teacherQuestion.response?.questions?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            child: Column(
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Center(
                                          child: Text(
                                            DataFields
                                                    .teacherQuestion
                                                    .response
                                                    ?.questions?[index]
                                                    .question ??
                                                "",
                                            style: TextStyle(
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DataFields
                                                          .teacherQuestion
                                                          .response
                                                          ?.questions?[index]
                                                          .isMarked ==
                                                      false
                                                  ? "Marks: -- / ${DataFields.teacherQuestion.response?.questions?[index].realMark}"
                                                  : "Marks: ${DataFields.teacherQuestion.response?.questions?[index].providedMarks} / ${DataFields.teacherQuestion.response?.questions?[index].realMark}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: FontColor.buttonPrimary,

                                              ),
                                            ),
                                            Text(
                                              "📷 ${DataFields.teacherQuestion.response?.questions?[index].image_count}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: FontColor.buttonPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2),
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                        onTap: (() {
                                          PeerToPeerQuestionImageApi
                                              .status.value = "Loading";


                                          Navigator.push(context, MaterialPageRoute(builder: (_) =>     PeerToPeerPhotoViewerScreen(
                                            markID: widget.id,
                                            id: "${DataFields.teacherQuestion.response?.questions?[index].id}",
                                            realMark:
                                            "${DataFields.teacherQuestion.response?.questions?[index].realMark}",
                                            receiver: widget.receiver,
                                          )));
                                          
                                        }),
                                        child: const EditButton())
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    ));
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.62,
        height: 30,
        decoration: BoxDecoration(
            color: const Color(0xff1AB67E),
            borderRadius: BorderRadius.circular(50)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(),
            Text(
              "Edit Mark or Comment",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,),
            ),
            Icon(
              Icons.arrow_forward,
              size: 15,
              color: Colors.white,
            ),
          ],
        ));
  }
}

class ExamineButton extends StatelessWidget {
  const ExamineButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 146,
        height: 30,
        decoration: BoxDecoration(
            color: FontColor.buttonPrimary,
            borderRadius: BorderRadius.circular(50)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "✎  Examine",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white),
            ),
            Icon(
              Icons.arrow_forward,
              size: 15,
              color: Colors.white,
            ),
          ],
        ));
  }
}
