import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/screens/admin/AdminLoginScreen.dart';
import 'package:quizeapp/screens/admin/components/DrawerWidget.dart';
import 'package:quizeapp/services/AuthService.dart';
import 'package:quizeapp/utils/Colors.dart';

import 'components/AdminStatisticsWidget.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Widget currentWidget = AdminStatisticsWidget();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0.0,
        title: Image.asset('assets/app_logo.png', height: 40),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(4), backgroundColor: colorPrimary),
            width: 100,
            padding: EdgeInsets.only(bottom: 8, top: 8, left: 14),
            child: Row(
              children: [
                Text('Logout', style: primaryTextStyle(color: white)),
                8.width,
                Icon(Icons.logout, color: white, size: 18),
              ],
            ).onTap(() {
              showConfirmDialog(context, 'Do you want to logout?').then((value) {
                if (value ?? false) {
                  logout(context, onLogout: () {
                    AdminLoginScreen().launch(context, isNewTask: true);
                  });
                }
              });
            }),
          ).center(),
          16.width,
        ],
      ),
      body: Container(
        height: context.height(),
        child: Row(
          children: [
            Container(
              width: context.width() * 0.15,
              //   color: Colors.white,
              padding: EdgeInsets.only(left: 16),
              height: context.height(),
              child: DrawerWidget(
                onWidgetSelected: (w) {
                  currentWidget = w!;

                  setState(() {});
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(16), backgroundColor: selectedDrawerViewColor),
              width: context.width() * 0.84,
              height: context.height(),
              child: currentWidget,
            ),
          ],
        ),
      ),
    );
  }
}
