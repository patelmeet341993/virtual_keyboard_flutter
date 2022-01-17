import 'package:flutter/material.dart';
import 'package:virtual_keyboard/screens/common/components/app_bar.dart';
import 'package:virtual_keyboard/utils/SizeConfig.dart';
import 'package:virtual_keyboard/utils/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirst = true;

  @override
  Widget build(BuildContext context) {
    if(isFirst) {
      isFirst = false;
    }

    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Virtual Keyboard", backbtnVisible: false, color: Colors.white,),
              Expanded(
                child: getMainBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget getMainBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySize.size10!, vertical: MySize.size5!),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: getMainText("Main Text")),
          Expanded(flex: 3, child: getStatusText("text")),
          Expanded(flex: 2, child: getButtonsRow()),
        ],
      ),
    );
  }
  
  Widget getMainText(String text) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MySize.size10!),
          border: Border.all(color: Styles.primaryColor, width: 1),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget getStatusText(String text) {
    return Center(child: Text(text));
  }

  Widget getButtonsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(onPressed: () {}, child: Text("On", style: TextStyle(color: Colors.white),), color: Styles.primaryColor,),
        SizedBox(width: MySize.size10!,),
        FlatButton(onPressed: () {}, child: Text("Off", style: TextStyle(color: Colors.white),), color: Styles.primaryColor),
      ],
    );
  }
}
