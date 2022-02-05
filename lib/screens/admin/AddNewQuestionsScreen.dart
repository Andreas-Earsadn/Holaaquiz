import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class AddNewQuestionsScreen extends StatefulWidget {
  final QuestionData? data;

  AddNewQuestionsScreen({this.data});

  @override
  AddQuestionsScreenState createState() => AddQuestionsScreenState();
}

class AddQuestionsScreenState extends State<AddNewQuestionsScreen> {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();

  // SubCategoryServices subCategoryServices;

  List<String> options = [];

  String questionType = QuestionTypeOption;

  String? correctAnswer;

  String option1 = 'Answer 1 is empty';
  String option2 = 'Answer 2 is empty';
  String option3 = 'Answer 3 is empty';
  String option4 = 'Answer 4 is empty';
  String option5 = 'Answer 5 is empty';

  int? questionTypeGroupValue = 1;
  CategoryData? selectedCategory;
  // CategoryData selectedSubCategory;

  List<CategoryData> categories = [];

  bool isUpdate = false;

  TextEditingController questionCont = TextEditingController();
  TextEditingController option1Cont = TextEditingController();
  TextEditingController option2Cont = TextEditingController();
  TextEditingController option3Cont = TextEditingController();
  TextEditingController option4Cont = TextEditingController();
  TextEditingController option5Cont = TextEditingController();
  TextEditingController noteCont = TextEditingController();

  FocusNode option1Focus = FocusNode();
  FocusNode option2Focus = FocusNode();
  FocusNode option3Focus = FocusNode();
  FocusNode option4Focus = FocusNode();
  FocusNode option5Focus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      questionCont.text = widget.data!.questionTitle.validate();

      if (widget.data!.questionType == QuestionTypeOption) {
        questionTypeGroupValue = 1;
      } else if (widget.data!.questionType == QuestionTypeTrueFalse) {
        questionTypeGroupValue = 2;
      } else if (widget.data!.questionType == QuestionTypePuzzle) {
        questionTypeGroupValue = 3;
      } else if (widget.data!.questionType == QuestionTypePoll) {
        questionTypeGroupValue = 4;
      }

      if (widget.data!.optionList!.length > 0) option1Cont.text = widget.data!.optionList![0].validate();
      if (widget.data!.optionList!.length > 1) option2Cont.text = widget.data!.optionList![1].validate();
      if (widget.data!.optionList!.length > 2) option3Cont.text = widget.data!.optionList![2].validate();
      if (widget.data!.optionList!.length > 3) option4Cont.text = widget.data!.optionList![3].validate();
      if (widget.data!.optionList!.length > 4) option5Cont.text = widget.data!.optionList![4].validate();

      noteCont.text = widget.data!.note.validate();
      correctAnswer = widget.data!.correctAnswer.validate();

      if (widget.data!.optionList!.length > 0) option1 = widget.data!.optionList![0].validate();
      if (widget.data!.optionList!.length > 1) option2 = widget.data!.optionList![1].validate();
      if (widget.data!.optionList!.length > 2) option3 = widget.data!.optionList![2].validate();
      if (widget.data!.optionList!.length > 3) option4 = widget.data!.optionList![3].validate();
      if (widget.data!.optionList!.length > 4) option5 = widget.data!.optionList![4].validate();
    }

    /// Load categories
    categories = await categoryService.categoriesFuture();

    if (categories.isNotEmpty) {
      if (isUpdate) {
        try {
          selectedCategory = categories.firstWhere((element) => element.id == widget.data!.categoryRef!.id);
        } catch (e) {
          print(e);
        }
      } else {
        selectedCategory = categories.first;
      }
    }

    setState(() {});
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    if (correctAnswer == null) {
      return toast('Please Select Correct Answer');
    }
    if (selectedCategory == null) {
      return toast('Please Select Category');
    }

    if (formKey.currentState!.validate()) {
      QuestionData questionData = QuestionData();

      options.clear();

      if (questionType == QuestionTypeOption) {
        if (option1Cont.text.trim().isNotEmpty) options.add(option1Cont.text.trim());
        if (option2Cont.text.trim().isNotEmpty) options.add(option2Cont.text.trim());
        if (option3Cont.text.trim().isNotEmpty) options.add(option3Cont.text.trim());
        if (option4Cont.text.trim().isNotEmpty) options.add(option4Cont.text.trim());
        if (option5Cont.text.trim().isNotEmpty) options.add(option5Cont.text.trim());
      } else {
        if (option1Cont.text.trim().isNotEmpty) options.add(option1Cont.text.trim());
        if (option2Cont.text.trim().isNotEmpty) options.add(option2Cont.text.trim());
      }

      questionData.questionTitle = questionCont.text.trim();
      questionData.note = noteCont.text.trim();
      questionData.questionType = questionType;
      questionData.correctAnswer = correctAnswer;
      questionData.updatedAt = DateTime.now();
      questionData.optionList = options;

      if (selectedCategory != null) {
        questionData.categoryRef = categoryService.ref!.doc(selectedCategory!.id);
      }

      if (isUpdate) {
        questionData.id = widget.data!.id;
        questionData.createdAt = widget.data!.createdAt;

        await questionServices.updateDocument(questionData.toJson(), questionData.id).then((value) {
          toast('Update Successfully');
          finish(context);
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        questionData.createdAt = DateTime.now();

        questionServices.addDocument(questionData.toJson()).then((value) {
          toast('Add Question Successfully');

          options.clear();

          option1Cont.clear();
          option2Cont.clear();
          option3Cont.clear();
          option4Cont.clear();
          option5Cont.clear();
          questionCont.clear();
          noteCont.clear();

          setState(() {});
        }).catchError((e) {
          log(e);
        });
      }
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text('Do you want to delete this question?'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                finish(context);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

                questionServices.removeDocument(widget.data!.id).then((value) {
                  toast('Delete Successfully');
                  finish(context);
                  finish(context);
                }).catchError((e) {
                  toast(e.toString());
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    options.clear();
    if (questionType == QuestionTypeOption) {
      if (option1Cont.text.trim().isNotEmpty) options.add(option1Cont.text.trim());
      if (option2Cont.text.trim().isNotEmpty) options.add(option2Cont.text.trim());
      if (option3Cont.text.trim().isNotEmpty) options.add(option3Cont.text.trim());
      if (option4Cont.text.trim().isNotEmpty) options.add(option4Cont.text.trim());
      if (option5Cont.text.trim().isNotEmpty) options.add(option5Cont.text.trim());
    } else {
      if (option1Cont.text.trim().isNotEmpty) options.add(option1Cont.text.trim());
      if (option2Cont.text.trim().isNotEmpty) options.add(option2Cont.text.trim());
    }

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.0,
        leading: isUpdate
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: black),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        title: Row(
          children: [
            Text('Question for Quiz', style: boldTextStyle()),
            8.width,
            Text(!isUpdate ? 'Create New Question' : 'Update Question', style: secondaryTextStyle()),
          ],
        ),
        actions: [
          isUpdate
              ? IconButton(
                  icon: Icon(Icons.delete_forever, color: black),
                  onPressed: () {
                    _showMyDialog();
                  },
                ).paddingOnly(right: 8)
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (categories.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Category', style: boldTextStyle(size: 18)),
                    8.height,
                    Container(
                      width: context.width() * 0.45,
                      decoration: BoxDecoration(borderRadius: radius(), color: Colors.grey.shade200),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton(
                        underline: Offstage(),
                        items: categories.map((e) {
                          return DropdownMenuItem(child: Text(e.name.validate()), value: e);
                        }).toList(),
                        isExpanded: true,
                        value: selectedCategory,
                        onChanged: (dynamic c) {
                          selectedCategory = c;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              16.height,
              AppTextField(
                controller: questionCont,
                textFieldType: TextFieldType.NAME,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
                decoration: inputDecoration(labelText: 'Question'),
                validator: (s) {
                  if (s!.trim().isEmpty) return errorThisFieldRequired;
                  return null;
                },
              ),
              16.height,
              Row(
                children: [
                  Text('Question Type:', style: boldTextStyle()),
                  16.width,
                  Container(
                    child: RadioListTile(
                      value: 1,
                      groupValue: questionTypeGroupValue,
                      title: Text("Options", style: boldTextStyle(size: 18)),
                      onChanged: (dynamic newValue) {
                        questionTypeGroupValue = newValue;
                        option1Cont.text = '';
                        option2Cont.text = '';

                        questionType = QuestionTypeOption;

                        correctAnswer = null;
                        setState(() {});
                      },
                      activeColor: Colors.red,
                      selected: true,
                    ),
                  ).expand(),
                  16.width,
                  Container(
                    // width: context.width() * 0.15,
                    child: RadioListTile(
                      value: 2,
                      groupValue: questionTypeGroupValue,
                      title: Text("True/False", style: boldTextStyle(size: 18)),
                      onChanged: (dynamic newValue) {
                        questionTypeGroupValue = newValue;
                        option1Cont.text = 'true';
                        option2Cont.text = 'false';

                        questionType = QuestionTypeTrueFalse;
                        correctAnswer = null;

                        setState(() {});
                      },
                      activeColor: Colors.red,
                      selected: false,
                    ),
                  ).expand(),
                ],
              ),
              16.height,
              Row(
                children: [
                  Row(
                    children: [
                      Text('A', style: boldTextStyle()),
                      8.width,
                      AppTextField(
                        controller: option1Cont,
                        focus: option1Focus,
                        nextFocus: option2Focus,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(),
                        keyboardType: TextInputType.url,
                        enabled: questionTypeGroupValue == 1,
                        onChanged: (s) {
                          option1 = s;
                          setState(() {});
                        },
                        validator: (s) {
                          if (s!.trim().isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                      ).expand(),
                    ],
                  ).expand(),
                  16.width,
                  Row(
                    children: [
                      Text('B', style: boldTextStyle()),
                      8.width,
                      AppTextField(
                        controller: option2Cont,
                        focus: option2Focus,
                        nextFocus: option3Focus,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(),
                        keyboardType: TextInputType.url,
                        enabled: questionTypeGroupValue == 1,
                        onChanged: (s) {
                          option2 = s;
                          setState(() {});
                        },
                        validator: (s) {
                          if (s!.trim().isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                      ).expand(),
                    ],
                  ).expand(),
                ],
              ),
              16.height,
              Row(
                children: [
                  Row(
                    children: [
                      Text('C', style: boldTextStyle()),
                      8.width,
                      AppTextField(
                        controller: option3Cont,
                        focus: option3Focus,
                        nextFocus: option4Focus,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(),
                        keyboardType: TextInputType.url,
                        isValidationRequired: false,
                        onChanged: (s) {
                          option3 = s;
                          setState(() {});
                        },
                        validator: (s) {
                          if (s!.trim().isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                      ).expand(),
                    ],
                  ).expand(),
                  16.width,
                  Row(
                    children: [
                      Text('D', style: boldTextStyle()),
                      8.width,
                      AppTextField(
                        controller: option4Cont,
                        focus: option4Focus,
                        nextFocus: option5Focus,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(),
                        keyboardType: TextInputType.url,
                        isValidationRequired: false,
                        onChanged: (s) {
                          option4 = s;
                          setState(() {});
                        },
                        validator: (s) {
                          if (s!.trim().isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                      ).expand(),
                    ],
                  ).expand(),
                ],
              ).visible(questionTypeGroupValue != 2),
              16.height,
              Row(
                children: [
                  Row(
                    children: [
                      Text('E', style: boldTextStyle()),
                      8.width,
                      AppTextField(
                        controller: option5Cont,
                        focus: option5Focus,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: inputDecoration(),
                        keyboardType: TextInputType.url,
                        onChanged: (s) {
                          option5 = s;
                          setState(() {});
                        },
                        isValidationRequired: false,
                        validator: (s) {
                          return null;
                        },
                      ).expand(),
                    ],
                  ).expand(),
                  16.width,
                  SizedBox().expand()
                ],
              ).visible(questionTypeGroupValue != 2),
              16.height,
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Correct Answer', style: boldTextStyle()),
                      8.height,
                      Container(
                        decoration: BoxDecoration(borderRadius: radius(), color: Colors.grey.shade200),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: Offstage(),
                          hint: Text('Select Correct Answer'),
                          value: correctAnswer,
                          onChanged: (newValue) {
                            correctAnswer = newValue;

                            setState(() {});
                          },
                          items: options.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.validate(value: '')),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ).expand(),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Note (Optional)', style: boldTextStyle()),
                      8.height,
                      AppTextField(
                        controller: noteCont,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        minLines: 1,
                        decoration: inputDecoration(labelText: 'Note'),
                        isValidationRequired: false,
                      ),
                    ],
                  ).expand(),
                ],
              ),
              16.height,
              AppButton(
                padding: EdgeInsets.all(16),
                child: Text(isUpdate ? 'Save' : 'Create Now', style: primaryTextStyle(color: white)),
                color: colorPrimary,
                onTap: () {
                  save();
                },
              )
            ],
          ).paddingAll(16),
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
