import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../DataModel/GlobalDataModel.dart';
import '../main.dart';


class AddPhoto extends StatefulWidget {
  final CameraDescription? camera;
  AddPhoto({Key? key,required this.camera}) : super(key: key);

  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  late XFile photoFile;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera as CameraDescription,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    photoFile = XFile('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Album'),
        ),
        //add a return button
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(10) ,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                photoFile.path.isNotEmpty ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Image.file(File(XFile(photoFile.path).path))) :
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: CameraPreview(_controller),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }, ),
                GestureDetector(
                    onTap: () async  {
                      final file = await takePicture();
                      photoFile = file as XFile;
                      setState(() {});
                      // if (!context.mounted) return;
                      // Navigator.of(context).pop(file?.path);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xff084470), Color(0xff0c7b93)])),
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      padding: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Center(
                        child: Text("Take Photo",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffffffff)),
                        ),
                      ),
                    )
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Photo Title',
                  ),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Photo Description',
                  ),
                ),
                Expanded(child: Container(),),
                GestureDetector(
                  onTap: (){
                    addPhoto(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff084470), Color(0xff0c7b93)])),
                    child: const Center(
                      child: Text(
                        'Add Album',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      );
  }

  Future<XFile?> takePicture() async {
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      XFile file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> addPhoto(context) async {
    String title = titleController.text;
    String description = descriptionController.text;
    print(title + description);
    print(photoFile.path);
    Map<String, dynamic> result = await httpApi.uploadPhotos(
        title: title,
        description: description,
        photoPath: photoFile.path
    );
    print(result);
    if (result['id'] != null) {
      showToast('Photo Added', duration: const Duration(seconds: 2), onDismiss: () {
        Navigator.pop(context, true);
      });
    }
  }
}
