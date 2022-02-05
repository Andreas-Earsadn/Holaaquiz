import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ListModel.dart';
import 'package:quizeapp/screens/admin/AddNewQuestionsScreen.dart';
import 'package:quizeapp/screens/admin/AdminSettingScreen.dart';
import 'package:quizeapp/screens/admin/CategoryListScreen.dart';
import 'package:quizeapp/screens/admin/CreateQuizScreen.dart';
import 'package:quizeapp/screens/admin/DailyQuizScreen.dart';
import 'package:quizeapp/screens/admin/UserListScreen.dart';
import 'package:quizeapp/screens/admin/components/AdminStatisticsWidget.dart';
import 'package:quizeapp/utils/Colors.dart';

import 'AllQuestionsListWidget.dart';
import 'QuizListScreen.dart';

class DrawerWidget extends StatefulWidget {
  static String tag = '/DrawerWidget';
  final Function(Widget?)? onWidgetSelected;

  DrawerWidget({this.onWidgetSelected});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  List<ListModel> list = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    list.add(ListModel(name: 'Dashboard', widget: AdminStatisticsWidget(), iconData: AntDesign.dashboard));
    list.add(ListModel(name: 'Category List', widget: CategoryListScreen(), imageAsset: 'assets/category.png'));
    list.add(ListModel(name: 'Add Question', widget: AddNewQuestionsScreen(), imageAsset: 'assets/addQuestion.png'));
    list.add(ListModel(name: 'Question List', widget: AllQuestionsListWidget(), imageAsset: 'assets/allquestion.png'));
    list.add(ListModel(name: 'Daily Quiz', widget: DailyQuizScreen(), imageAsset: 'assets/dailyQuiz.png'));
    list.add(ListModel(name: 'Quiz List', widget: QuizListScreen(), imageAsset: 'assets/allQuiz.png'));
    list.add(ListModel(name: 'Create Quiz', widget: CreateQuizScreen(), imageAsset: 'assets/createQuiz.png'));
    //list.add(ListModel(name: 'Import Question', widget: ImportQuestionScreen(), imageAsset: 'assets/import.png'));
    //list.add(ListModel(name: 'Notifications', widget: NotificationScreen(), iconData: AntDesign.bells));
    list.add(ListModel(name: 'Manage Users', widget: UserListScreen(), iconData: Feather.users));
    list.add(ListModel(name: 'Settings', widget: AdminSettingScreen(), iconData: Feather.settings));

    LiveStream().on('selectItem', (index) {
      this.index = index as int;

      widget.onWidgetSelected?.call(list[this.index].widget);

      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('selectItem');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Wrap(
          children: list.map(
            (e) {
              int cIndex = list.indexOf(e);

              return SettingItemWidget(
                title: e.name!,
                leading:
                    e.iconData != null ? Icon(e.iconData, color: cIndex == index ? colorPrimary : Colors.white, size: 24) : Image.asset(e.imageAsset!, color: cIndex == index ? colorPrimary : Colors.white, height: 24),
                titleTextColor: cIndex == index ? colorPrimary : Colors.white,
                decoration: BoxDecoration(
                  color: cIndex == index ? selectedDrawerItemColor : null,
                  //  border: Border.all(),
                  borderRadius: cIndex == index - 1
                      ? BorderRadius.only(bottomRight: Radius.circular(24), topLeft: Radius.circular(24), bottomLeft: Radius.circular(24))
                      : cIndex == index + 1
                          ? BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24), bottomLeft: Radius.circular(24))
                          : BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                ),
                onTap: () {
                  index = list.indexOf(e);
                  widget.onWidgetSelected?.call(e.widget);
                },
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
