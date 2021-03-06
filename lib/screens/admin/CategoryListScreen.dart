import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/CategoryItemWidget.dart';
import 'package:quizeapp/screens/admin/components/NewCategoryDialog.dart';
import 'package:quizeapp/utils/Colors.dart';

import '../../main.dart';

class CategoryListScreen extends StatefulWidget {
  static String tag = '/CategoryListScreen';

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: boldTextStyle(size: 22)),
              AppButton(
                padding: EdgeInsets.all(16),
                child: Text('Add Category', style: primaryTextStyle(color: white)),
                color: colorPrimary,
                onTap: () {
                  showInDialog(context, child: NewCategoryDialog());
                },
              )
            ],
          ).paddingOnly(left: 16),
          8.height,
          StreamBuilder<List<CategoryData>>(
            stream: categoryService.categories(),
            builder: (_, snap) {
              if (snap.hasData) {
                if (snap.data!.isEmpty) return noDataWidget();
                return Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 16,
                  runSpacing: 8,
                  children: snap.data.validate().map((e) {
                    return CategoryItemWidget(data: e);
                  }).toList(),
                );
              } else {
                return snapWidgetHelper(snap);
              }
            },
          ),
        ],
      ),
    );
  }
}
