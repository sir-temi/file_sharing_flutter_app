import 'dart:io';
import 'package:cemfrontend/class/device_checker.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart' as pt;

import 'package:cemfrontend/providers/auth.dart';
import 'package:cemfrontend/providers/files.dart';
import 'package:cemfrontend/widgets/drawer.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

// import 'package:flutter_sound/flutter_sound.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({Key? key}) : super(key: key);
  static const routeName = '/upload_file';

  @override
  _UploadFileScreenState createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  final _formKey = GlobalKey<FormState>();
  var _usernameController = TextEditingController();
  var _discriptionController = TextEditingController();
  var _titleController = TextEditingController();
  var _isLoading = false;
  bool isRecording = false;
  File? file;
  RecordPlatform recorder = Record();
  var audioFile;

  Map data = {
    'username': '',
    'restrictedUser': false,
    'restrictedCountry': false,
    'description': '',
    'title': ''
    // 'file': 'No file selected'
  };

  Future _selectFileWithPicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    // if(result == null){
    //   File file = File(result.files.single.path);
    // }
    if (result == null) return;
    final upload = result.files.single.path;

    if (File(upload!).lengthSync() > 1000000000) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('OOPS',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold)),
                content: Text(
                  'File is more than 1 Gigabytes, please choose another file.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor,
                        child: Text('GO BACK',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ],
                  )
                ],
              ));
    } else {
      setState(() => file = File(upload));
    }
  }

  Future _selectFromCamera(method) async {
    final _picker = ImagePicker();
    final PickedFile? result = method == 'image'
        ? await _picker.getImage(source: ImageSource.camera)
        : await _picker.getVideo(source: ImageSource.camera);

    if (result == null) return;
    final pickedFile = result;

    if (File(pickedFile.path).lengthSync() > 1000000000) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('OOPS',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold)),
                content: Text(
                  'File is more than 1 Gigabytes, please choose another file.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor,
                        child: Text('GO BACK',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ],
                  )
                ],
              ));
    } else {
      setState(() => file = File(pickedFile.path));
    }
  }

  Future _selectFromMicrophone() async {
    setState(() => file = File(audioFile));
    print(audioFile);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Provider.of<Files>(context, listen: false)
          .uploadFile(data, file, pt.basename(file!.path));

      if (response == false) {
        // setState(() {
        //   _isLoading = false;
        // });
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('NETWORK ERROR',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  content: Text(
                    'There was an error, please try again.',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    Row(
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.all(10),
                          color: Theme.of(context).primaryColor,
                          child: Text('Try Again',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white)),
                          onPressed: () => Navigator.of(context).pop(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ],
                    )
                  ],
                ));
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/dashboard', (Route<dynamic> route) => false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 8.0,
            content: Text(
              'File uploaded successfully.',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )));
      }
    } catch (error) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('OOPS',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold)),
                content: Text(
                  error.toString().contains('SocketException')
                      ? 'Network problem, please try again.'
                      : error.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                actions: <Widget>[
                  Row(
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor,
                        child: Text('GO BACK',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onPressed: () => Navigator.of(context).pop(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ],
                  )
                ],
              ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    final userName = Provider.of<Auth>(context, listen: false).userName;
    final screensize = MediaQuery.of(context).size;
    String deviceType = MyChecker().checker(screensize.width.toInt());

    return Scaffold(
      appBar: AppBar(
          title: Text('Upload File',
              style: TextStyle(
                  fontSize: deviceType == 'tab'
                      ? fontSize * 18
                      : deviceType == 'large'
                          ? fontSize * 25
                          : fontSize)),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/dashboard', (Route<dynamic> route) => false),
              icon: Icon(
                Icons.arrow_back,
                size: deviceType == 'tab'
                    ? fontSize * 18
                    : deviceType == 'large'
                        ? fontSize * 40
                        : fontSize,
              ),
            )
          ]),
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('Uploading your file...')
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(
                        top: 30,
                        left: deviceType == 'tab'
                            ? screensize.width * 0.20
                            : deviceType == 'large'
                                ? screensize.width * 0.25
                                : 30,
                        right: deviceType == 'tab'
                            ? screensize.width * 0.20
                            : deviceType == 'large'
                                ? screensize.width * 0.25
                                : 30),
                    padding: EdgeInsets.only(bottom: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: screensize.width * .6,
                            child: RaisedButton(
                                padding: EdgeInsets.all(10),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                color: Theme.of(context).primaryColorDark,
                                child:
                                    // ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.share_rounded, color: Colors.white, size: fontSize *30,), SizedBox(width: 10,), Text('Send to ${data['username']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: fontSize * 20))],)
                                    Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.attach_file_sharp,
                                      color: Colors.white,
                                      size: fontSize * 30,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Select File',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: deviceType == 'tab'
                                                ? fontSize * 25
                                                : deviceType == 'large'
                                                    ? fontSize * 28
                                                    : fontSize * 20))
                                  ],
                                ),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => SimpleDialog(
                                          // title: const Text('Share File',),
                                          children: <Widget>[
                                            SimpleDialogOption(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _selectFileWithPicker();
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width:
                                                        screensize.width * .08,
                                                    child: FaIcon(
                                                      FontAwesomeIcons
                                                          .folderOpen,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: fontSize * 28,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(' Library',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: fontSize * 18,
                                                      ))
                                                ],
                                              ),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () {
                                                // Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (ctx) => SimpleDialog(
                                                              // title: const Text('Share File',),
                                                              children: <
                                                                  Widget>[
                                                                SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil(
                                                                            ModalRoute.withName('/upload_file'));
                                                                    _selectFromCamera(
                                                                        'image');
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        width: screensize.width *
                                                                            .08,
                                                                        child:
                                                                            FaIcon(
                                                                          FontAwesomeIcons
                                                                              .images,
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                          size: fontSize *
                                                                              28,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                          ' Take a Picture',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                fontSize * 18,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                                SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil(
                                                                            ModalRoute.withName('/upload_file'));
                                                                    _selectFromCamera(
                                                                        'video');
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                          width: screensize.width *
                                                                              .08,
                                                                          alignment: Alignment
                                                                              .center,
                                                                          child: FaIcon(
                                                                              FontAwesomeIcons.video,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: fontSize * 25)),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        ' Record a video',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              fontSize * 18,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ));
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width:
                                                        screensize.width * .08,
                                                    child: FaIcon(
                                                      FontAwesomeIcons.camera,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: fontSize * 28,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(' Camera',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: fontSize * 18,
                                                      ))
                                                ],
                                              ),
                                            ),
                                            SimpleDialogOption(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                bool result = await recorder
                                                    .hasPermission();
                                                if (!result) return;
                                                showDialog(
                                                    context: context,
                                                    builder: (ctx) {
                                                      bool isReco = false;
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                                setState) =>
                                                            SimpleDialog(
                                                          // title: const Text('Share File',),
                                                          children: <Widget>[
                                                            Row(
                                                              children: [
                                                                SimpleDialogOption(
                                                                  onPressed:
                                                                      () async {
                                                                    final dirs =
                                                                        await getExternalStorageDirectories();
                                                                    final path =
                                                                        dirs![0]
                                                                            .path;
                                                                    audioFile =
                                                                        '$path/audiofile.aac';
                                                                    setState(
                                                                        () {
                                                                      isReco =
                                                                          !isReco;
                                                                    });
                                                                    if (isReco) {
                                                                      await recorder
                                                                          .start(
                                                                        path:
                                                                            audioFile, // required
                                                                        encoder:
                                                                            AudioEncoder.AAC,
                                                                      );
                                                                    } else {
                                                                      await recorder
                                                                          .stop();
                                                                    }
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        width: screensize.width *
                                                                            .08,
                                                                        child:
                                                                            FaIcon(
                                                                          isReco
                                                                              ? FontAwesomeIcons.stop
                                                                              : FontAwesomeIcons.microphoneAlt,
                                                                          color: isReco
                                                                              ? Colors.red
                                                                              : Theme.of(context).primaryColor,
                                                                          size: fontSize *
                                                                              28,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                          isReco
                                                                              ? 'Stop'
                                                                              : 'Start',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                fontSize * 18,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                                SimpleDialogOption(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .popUntil(
                                                                            ModalRoute.withName('/upload_file'));
                                                                    _selectFromMicrophone();
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        width: screensize.width *
                                                                            .08,
                                                                        child:
                                                                            FaIcon(
                                                                          FontAwesomeIcons
                                                                              .check,
                                                                          color:
                                                                              Theme.of(context).primaryColor,
                                                                          size: fontSize *
                                                                              32,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                          'DONE',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                fontSize * 18,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                      width: screensize.width *
                                                          .08,
                                                      alignment: Alignment
                                                          .center,
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .microphone,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: fontSize * 25)),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    ' Microphone',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: fontSize * 18,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          file == null
                              ? Text('')
                              : Text(
                                  pt.basename(file!.path),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: TextFormField(
                              maxLength: 20,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              controller: _titleController,
                              onTap: () async {},
                              style: TextStyle(
                                  fontSize: deviceType == 'tab'
                                      ? fontSize * 22
                                      : deviceType == 'large'
                                          ? fontSize * 25
                                          : fontSize * 18),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.bookmark_add,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                labelText: 'Discriptive name',
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) {
                                  return "Username can't be empty";
                                } else if (v.length < 4) {
                                  return "Username can't be lesser than 4";
                                } else if (v.split(" ").length > 5) {
                                  return "Name is too long, please make it at most 5 words";
                                }
                              },
                              onSaved: (v) {
                                data['title'] = v;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: TextFormField(
                              maxLength: 70,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              minLines: 2,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              controller: _discriptionController,
                              onTap: () async {},
                              style: TextStyle(
                                  fontSize: deviceType == 'tab'
                                      ? fontSize * 22
                                      : deviceType == 'large'
                                          ? fontSize * 25
                                          : fontSize * 18),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.library_books,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                labelText: 'File description',
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .primaryColorDark)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              validator: (v) {
                                if (v!.length > 100) {
                                  return "Discription can't me more than 100 characters.";
                                }
                              },
                              onSaved: (v) {
                                data['description'] = v;
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: Text(
                                'Restrict by country',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: deviceType == 'tab'
                                        ? fontSize * 22
                                        : deviceType == 'large'
                                            ? fontSize * 25
                                            : fontSize * 18,
                                    fontWeight: FontWeight.bold),
                              ))),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Transform.scale(
                                  scale: deviceType == 'tab'
                                      ? 1.2
                                      : deviceType == 'large'
                                          ? 1.5
                                          : 1,
                                  child: Switch(
                                      value: data['restrictedCountry'],
                                      activeColor:
                                          Theme.of(context).primaryColorDark,
                                      onChanged: (value) {
                                        setState(() {
                                          data['restrictedCountry'] = value;
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      child: Text(
                                'Restrict by username',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: deviceType == 'tab'
                                        ? fontSize * 22
                                        : deviceType == 'large'
                                            ? fontSize * 25
                                            : fontSize * 18,
                                    fontWeight: FontWeight.bold),
                              ))),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Transform.scale(
                                  scale: deviceType == 'tab'
                                      ? 1.2
                                      : deviceType == 'large'
                                          ? 1.5
                                          : 1,
                                  child: Switch(
                                      value: data['restrictedUser'],
                                      activeColor:
                                          Theme.of(context).primaryColorDark,
                                      onChanged: (value) {
                                        setState(() {
                                          data['restrictedUser'] = value;
                                        });
                                      }),
                                ),
                              ),
                            ],
                          ),
                          !data['restrictedUser']
                              ? Container()
                              : Container(
                                  child: TextFormField(
                                    controller: _usernameController,
                                    onTap: () async {},
                                    style: TextStyle(
                                        fontSize: deviceType == 'tab'
                                            ? fontSize * 22
                                            : deviceType == 'large'
                                                ? fontSize * 25
                                                : fontSize * 18),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      labelText: 'Authorised username',
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v!.isEmpty) {
                                        return "Username can't be empty";
                                      } else if (v.length < 4) {
                                        return "Username can't be lesser than 4";
                                      }
                                    },
                                    onSaved: (v) {
                                      data['username'] = v;
                                    },
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                      padding: EdgeInsets.all(10),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      color: Theme.of(context).primaryColorDark,
                                      child:
                                          // ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.share_rounded, color: Colors.white, size: fontSize *30,), SizedBox(width: 10,), Text('Send to ${data['username']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: fontSize * 20))],)
                                          Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_rounded,
                                            color: Colors.white,
                                            size: fontSize * 30,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('Upload File',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: deviceType == 'tab'
                                                      ? fontSize * 25
                                                      : deviceType == 'large'
                                                          ? fontSize * 28
                                                          : fontSize * 20))
                                        ],
                                      ),
                                      onPressed: _submit),
                                  flex: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
