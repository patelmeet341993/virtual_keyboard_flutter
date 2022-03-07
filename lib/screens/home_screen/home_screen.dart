import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as image;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:virtual_keyboard/screens/common/components/app_bar.dart';
import 'package:virtual_keyboard/utils/SizeConfig.dart';
import 'package:virtual_keyboard/utils/my_print.dart';
import 'package:virtual_keyboard/utils/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirst = true, pageMounted = false;
  late DatabaseReference _deviceRef;
  late StreamSubscription<DatabaseEvent> _deviceSubscription;

  List<String> videos = [];

  bool status = false;
  String text = "";

  Future<void> initSync() async {
    _deviceRef = FirebaseDatabase.instance.ref('device');

    _deviceSubscription = _deviceRef.onValue.listen((DatabaseEvent event) {
      print("Value:${event.snapshot.value}");
      try {
        Map<String, dynamic> map = Map.castFrom(event.snapshot.value as Map);
        text = map['data'] ?? "";
        status = (map['status'] ?? "") == "on" ? true : false;
        if(pageMounted) setState(() {});
      }
      catch(e) {

      }
    });
  }

  @override
  void initState() {
    initSync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pageMounted = false;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      pageMounted = true;
    });

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: getMainText(text)),
          const SizedBox(height: 50,),
          getOnOffSwitch(),
          const SizedBox(height: 50,),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: videos.map<Widget>((e) {
                return Image.file(File(e), height: 100,);
              }).toList(),
            ),
          ),
          TextButton(
            onPressed: () async {
              List<XFile>? list = await ImagePicker().pickMultiImage();

              if(list?.isNotEmpty ?? false) {
                videos = list!.map((e) => e.path).toList();
                MyPrint.printOnConsole("Images:${videos}");
                setState(() {});
              }
            },
            child: Text("Get Videos"),
          ),
          TextButton(
            onPressed: () async {
              if(videos.isNotEmpty) {
                PermissionStatus manageStatus = await Permission.manageExternalStorage.request();
                PermissionStatus readWriteStatus = await Permission.storage.request();

                MyPrint.printOnConsole("Manage Status:${manageStatus.isGranted}");
                MyPrint.printOnConsole("Read/Write Status:${readWriteStatus.isGranted}");

                if(manageStatus.isGranted && readWriteStatus.isGranted) {
                  List<Uint8List> bytesList = [];
                  List<image.Image> imagesList = [];
                  int width = 0, height = 0;
                  for (String path in videos.reversed.toList()) {
                    File file = File(path);
                    Uint8List data = await file.readAsBytes();
                    bytesList.add(data);
                    MyPrint.printOnConsole("Data Length:${data.length}");

                    image.Image? decodedImage = image.decodeImage(data);
                    if(decodedImage != null) {
                      imagesList.add(decodedImage);

                      width += decodedImage.width;
                      height = height > decodedImage.height ? height : decodedImage.height;
                      print("Image Width:${decodedImage.width}, Height:${decodedImage.height}");
                    }
                  }
                  MyPrint.printOnConsole("Images Objects Length:${imagesList.length}");
                  MyPrint.printOnConsole("New Image Width:$width");
                  MyPrint.printOnConsole("New Image Heigth:$height");

                  image.Image mergedImage = image.Image(width + 1, height + 1);
                  for(int i = 0; i < imagesList.length; i++) {
                    MyPrint.printOnConsole("I:${i}");
                    image.Image imageObject = imagesList[i];

                    int offset = 0;
                    List<image.Image> previousImages = imagesList.where((element) => imagesList.indexOf(element) < i).toList();
                    previousImages.forEach((element) {
                      offset += element.width;
                    });

                    mergedImage = image.copyInto(
                      mergedImage,
                      imageObject,
                      blend: false,
                      dstX: i > 0
                        ? offset
                        : null,
                    );
                    MyPrint.printOnConsole("$i Merge Finished");
                  }
                  MyPrint.printOnConsole("Merge Finished");
                  MyPrint.printOnConsole("Bytes Length:${mergedImage.data.length}");

                  Directory? directory = await getExternalStorageDirectory();
                  if(directory != null) {
                    String destinationPath = directory.path;
                    destinationPath = destinationPath.substring(0, destinationPath.lastIndexOf("/"));
                    destinationPath = destinationPath.substring(0, destinationPath.lastIndexOf("/"));
                    destinationPath = destinationPath.substring(0, destinationPath.lastIndexOf("/"));
                    destinationPath = destinationPath.substring(0, destinationPath.lastIndexOf("/"));
                    destinationPath = destinationPath + "/My Combo Videos/video.png";
                    MyPrint.printOnConsole("Destination Path:${destinationPath}");

                    File file = File(destinationPath);
                    await file.create(recursive: true);
                    await file.writeAsBytes(image.encodeJpg(mergedImage), flush: true);

                    MyPrint.printOnConsole("File Saved");
                  }
                }
              }
            },
            child: Text("Get Videos"),
          ),
        ],
      ),
    );
  }
  
  Widget getMainText(String text) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
        border: Border.all(color: Styles.primaryColor, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget getOnOffSwitch() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Switch(value: status, onChanged: (bool? newValue) {
          print("On Changed Called:${newValue}");
          _deviceRef.update({"status" : (newValue ?? false) ? "on" : "off"});
        }),
        SizedBox(width: MySize.size10!,),
        Text(status ? "On" : "Off", style: const TextStyle(color: Colors.black),)
      ],
    );
  }
}
