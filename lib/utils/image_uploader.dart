import 'dart:async';
import 'dart:io';

import 'package:JustMusic/global_components/singleton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class ImageCapture extends StatefulWidget {
  final String navigatedFrom;
  ImageCapture({Key key, @required this.navigatedFrom}) : super(key: key);
  ImageCaptureState createState() => ImageCaptureState();
}

class ImageCaptureState extends State<ImageCapture> {
  File _imageFile;
  var imageRatio = {
    "x": 1.0,
    "y": 1.0
  };

  @override
  void initState(){
    selectImageOnInitState();
    if(widget.navigatedFrom == "playlist") imageRatio = {"x": 4.0, "y": 6.0};
    else if(widget.navigatedFrom == "banner") imageRatio = {"x": 16.0, "y": 9.0};
  }


  Future<void> selectImageOnInitState() async{
    Future.delayed(Duration(milliseconds: 500), (){
      showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          actions: <Widget>[
            FlatButton(child: Text("Cancel"), onPressed: ()=>Navigator.of(context).pop())
          ],
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlatButton(
                      child: Text("Take a photo", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        _pickAndCropImage(ImageSource.camera);
                      }
                  ),
                  FlatButton(
                      child: Text("Select from Gallery", style: TextStyle(fontSize: 18)),
                      onPressed: (){
                        _pickAndCropImage(ImageSource.gallery);
                      }
                  ),
                  FlatButton(
                    child: Text("Default Images", style: TextStyle(fontSize: 18)),
                    onPressed: (){},
                  )
                ])
        );
      }).then((val){
        if(_imageFile == null) Navigator.pop(context);
      });
    });
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    var sizes = {
      "playlist": { "maxWidth": 700.0, "maxHeight": 933.0 },
      "profileImage" : { "maxWidth": 300.0, "maxHeight": 300.0 },
      "banner": { "maxWidth": 700.0, "maxHeight": 525.0 }
    };
    File selected = await ImagePicker.pickImage(
        source: source,
        maxWidth: sizes[widget.navigatedFrom]["maxWidth"],
        maxHeight: sizes[widget.navigatedFrom]["maxHeight"]
    );
    if (selected != null) {
      File cropped = await ImageCropper.cropImage(
          ratioX: imageRatio["x"],
          ratioY: imageRatio["y"],
          circleShape: widget.navigatedFrom == "profileImage",
          sourcePath: selected.path);
      if(cropped != null) {
        setState(() {
          _imageFile = cropped;
        });
      }
    }
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Color.fromRGBO(20, 23, 41, 1),
              Color.fromRGBO(50, 47, 61, 1),
              Color.fromRGBO(50, 67, 81, 1),
              Color.fromRGBO(50, 87, 101, 1),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            tileMode: TileMode.clamp)
      ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(icon: Icon(Icons.arrow_back_ios), color: Colors.white,
                onPressed: ()=>Navigator.pop(context)),
          ),
      body: _imageFile != null ? Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 30),
          child: ListView(
        children:
           [
           widget.navigatedFrom == "profileImage" ?
           Container(
               margin: EdgeInsets.only(bottom: 30),
               child: CircleAvatar(
             radius: MediaQuery.of(context).size.width * .4,
             backgroundImage:
             AssetImage(_imageFile.path),
             backgroundColor: Colors.transparent,
           ))
               : Container(
               width: MediaQuery.of(context).size.width * .8 * 4/6,
               height: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: .5),
              ),
              margin: EdgeInsets.only(bottom: 30),
                child: Image.file(_imageFile)),
            Container(
              margin: EdgeInsets.only(bottom: 30),
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: Colors.white)
                  ),
                    child:
                  RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Text("Pick Different Image", style: TextStyle(color: Colors.white)),
                    onPressed: (){
                      _clear();
                      selectImageOnInitState();
                    }
                ))
              ]
            )),
            Uploader(file: _imageFile, navigatedFrom: widget.navigatedFrom)
          ]
      )) : Container()
    ));
  }
}

class Uploader extends StatefulWidget {
  final file;
  final navigatedFrom;
  Uploader({Key key, this.file, this.navigatedFrom}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://unnamed-870e3.appspot.com');

  StorageUploadTask _uploadTask;
  String filePath;
  Singleton _singleton = Singleton();

  @override
  void initState() {
    super.initState();
    filePath = "users/${_singleton.user.accountId}/${widget.navigatedFrom}/${DateTime.now()}.jpg";
  }

  void _startUpload() {
    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
      _onUploadComplete();
    });
  }

  bool _isError = false;

  void _onUploadComplete () async {
    var onComplete = await _uploadTask.onComplete;
    if (_uploadTask.isSuccessful) Navigator.of(context).pop(onComplete.ref.getDownloadURL());
    else {
      setState((){
        _isError = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if(_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;
          double progressPercent = event != null
          ? event.bytesTransferred / event.totalByteCount
              : 0;

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _uploadTask.isComplete ?
                Padding(padding: EdgeInsets.all(10)
              ,child: Icon(Icons.done_outline,color:
                _uploadTask.isComplete ? Colors.white : Colors.white70)) :
              _uploadTask.isPaused ?
                FlatButton(padding: EdgeInsets.all(0),textColor: Colors.white,
                  child: Icon(Icons.play_arrow),
                  onPressed: _uploadTask.resume,
                ) :
              _uploadTask.isInProgress ?
                FlatButton(padding: EdgeInsets.all(0),textColor: Colors.white,
                  child: Icon(Icons.pause),
                  onPressed: _uploadTask.pause,
                ) :
                  _isError ?
                      Padding(padding: EdgeInsets.all(10),
                      child: Row(children: [
                        Icon(Icons.cancel, color: Colors.redAccent),
                        Text("Error: Please try another picture.", style: TextStyle(color: Colors.redAccent))
                      ])) :
                  Container(),
              LinearProgressIndicator(value: progressPercent),
              Text(
                '${(progressPercent * 100).toStringAsFixed(2)} %',
                style: TextStyle(
                  color:  _uploadTask.isComplete ? Colors.white : Colors.white70
                )
              )

            ]
          );
        }
      );
    }else {
      return Container(
          child: FlatButton.icon(textColor: Colors.white,
        icon: Icon(Icons.check, color: Colors.lightGreen),
        color: Colors.transparent,
        label: Text('Complete'),
        onPressed: _startUpload
      ));
    }
  }
}
