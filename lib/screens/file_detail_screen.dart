import 'dart:isolate';
import 'dart:ui';

import 'package:cemfrontend/class/device_checker.dart';
import 'package:cemfrontend/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_share/social_share.dart';

import '../providers/auth.dart';
import '../providers/files.dart';
import '../widgets/loading.dart';
import '../widgets/detail_rows.dart';
import 'package:flutter/services.dart';

class FileDetailScreen extends StatefulWidget {
  const FileDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/details';

  @override
  _FileDetailScreenState createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> {
  bool _isLoading = false;
  bool _isInit = false;
  bool byCountry = false;
  bool byUser = false;

  Map result = new Map();

  var isUser = false;
  var title = '';

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      final identifier = ModalRoute.of(context)?.settings.arguments as String;

      final userAccessing = Provider.of<Auth>(context, listen: false).userName;

      Provider.of<Files>(context, listen: false)
          .getFileDetails(identifier, userAccessing)
          .catchError((e) {
        throw (e);
      }).then((response) {
        result = response;
        byCountry = response['data']['restrictedCountry'];
        byUser = response['data']['restrictedUser'];
        isUser = response['isUser'];
        title = response['data']['title'];

        setState(() {
          _isLoading = false;
        });
      });

      // _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    final screensize = MediaQuery.of(context).size;
    String deviceType = MyChecker().checker(screensize.width.toInt());
    final PreferredSizeWidget appBar = AppBar(
      title: Text(
        title,
        style: TextStyle(
            fontSize: deviceType == 'tab'
                ? fontSize * 18
                : deviceType == 'large'
                    ? fontSize * 25
                    : fontSize),
      ),
      actions: isUser
          ? [
              GestureDetector(
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                            title: const Text(
                              'File number',
                            ),
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: result['data']['identifier']
                                          .toUpperCase()));
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          elevation: 8.0,
                                          content: Text(
                                            'Copied to clipboard',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        result['data']['identifier']
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSize * 26,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: FaIcon(
                                        FontAwesomeIcons.solidCopy,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        size: fontSize * 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                  child: Icon(
                    Icons.info_outlined,
                    size: deviceType == 'tab'
                        ? fontSize * 18
                        : deviceType == 'large'
                            ? fontSize * 40
                            : 30,
                  )),
              IconButton(
                icon: Icon(
                  Icons.share_rounded,
                  size: deviceType == 'tab'
                      ? fontSize * 18
                      : deviceType == 'large'
                          ? fontSize * 40
                          : 30,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                            title: const Text(
                              'Share File',
                            ),
                            children: <Widget>[
                              SimpleDialogOption(
                                onPressed: () {
                                  SocialShare.shareWhatsapp(
                                      "Download this file from TemiShare \n ${result['data']['file']}");
                                },
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.whatsapp,
                                        color: Color.fromRGBO(37, 211, 102, 1),
                                        size: deviceType == 'tab'
                                            ? fontSize * 25
                                            : deviceType == 'large'
                                                ? fontSize * 30
                                                : fontSize * 18),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(' Share via WhatsApp',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: deviceType == 'tab'
                                              ? fontSize * 25
                                              : deviceType == 'large'
                                                  ? fontSize * 30
                                                  : fontSize * 18,
                                        ))
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  SocialShare.shareTwitter(
                                      "Download this file from TemiShare",
                                      url: result['data']['file']);
                                },
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.twitter,
                                        color: Color.fromRGBO(29, 161, 242, 1),
                                        size: deviceType == 'tab'
                                            ? fontSize * 25
                                            : deviceType == 'large'
                                                ? fontSize * 30
                                                : fontSize * 18),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(' Share via Twitter',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: deviceType == 'tab'
                                              ? fontSize * 25
                                              : deviceType == 'large'
                                                  ? fontSize * 30
                                                  : fontSize * 18,
                                        ))
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed(
                                      '/search_user',
                                      arguments: result['data']['identifier']);
                                },
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.userAlt,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        size: deviceType == 'tab'
                                            ? fontSize * 25
                                            : deviceType == 'large'
                                                ? fontSize * 30
                                                : fontSize * 18),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      ' Share via Username',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: deviceType == 'tab'
                                            ? fontSize * 25
                                            : deviceType == 'large'
                                                ? fontSize * 30
                                                : fontSize * 18,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ));
                },
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/dashboard', (Route<dynamic> route) => false),
                icon: Icon(
                  Icons.arrow_back,
                  size: deviceType == 'tab'
                      ? fontSize * 25
                      : deviceType == 'large'
                          ? fontSize * 40
                          : 30,
                ),
              ),
              SizedBox(
                width: 30,
              )
            ]
          : [
              IconButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    '/dashboard', (Route<dynamic> route) => false),
                icon: Icon(
                  Icons.arrow_back,
                  size: deviceType == 'tab'
                      ? fontSize * 35
                      : deviceType == 'large'
                          ? fontSize * 40
                          : 30,
                ),
              ),
            ],
    );
    final appBarheight = appBar.preferredSize.height;
    final batterybar = MediaQuery.of(context).padding.top;
    final screenSize = screensize.height - (appBarheight + batterybar);
    final userName = Provider.of<Auth>(context, listen: false).userName;

    return Scaffold(
      appBar: appBar,
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('Loading...')
          : result['message'] == false
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_outlined,
                          color: Colors.red,
                          size: fontSize * 100,
                        ),
                        Text(
                          result['alert'].contains('user')
                              ? 'This file is only accessible to a particular user'
                              : 'Your country is restricted from this file',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: fontSize * 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: 10, left: 15, right: 15, bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: deviceType == 'tab'
                              ? screensize.width * 0.4
                              : deviceType == 'large'
                                  ? screenSize * .5
                                  : screenSize * .20,
                          alignment: Alignment.center,
                          child: Image.network(
                            result['data']['thumbnail'],
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          result['data']['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: deviceType == 'tab'
                                  ? fontSize * 38
                                  : deviceType == 'large'
                                      ? fontSize * 40
                                      : fontSize * 30,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: 7),
                        Container(
                          child: Text(result['data']['description'],
                              style: TextStyle(
                                fontSize: deviceType == 'tab'
                                    ? fontSize * 22
                                    : deviceType == 'large'
                                        ? fontSize * 25
                                        : fontSize * 16,
                                fontWeight: FontWeight.w800,
                                // color: Theme.of(context).primaryColor
                              )),
                        ),
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: deviceType == 'tab'
                                  ? screensize.width * 0.05
                                  : deviceType == 'large'
                                      ? screensize.width * 0.06
                                      : 0),
                          width: double.infinity,
                          child: Card(
                              elevation: 7,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Column(children: [
                                  DetailRows(deviceType, fontSize, [
                                    result['data']['downloaded'],
                                    '${result['data']['mimeType'].split("/")[0][0].toUpperCase()}${result['data']['mimeType'].split("/")[0].substring(1)}'
                                  ], [
                                    Icons.download_rounded,
                                    Icons.category_outlined
                                  ]),
                                  SizedBox(height: screenSize * .05),
                                  DetailRows(deviceType, fontSize, [
                                    result['data']['size_mb'],
                                    result['data']['fileOwner']['username']
                                  ], [
                                    Icons.line_weight_sharp,
                                    Icons.person
                                  ]),
                                  SizedBox(height: screenSize * .05),
                                  Wrap(
                                    // mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.date_range_rounded,
                                        color: Theme.of(context).primaryColor,
                                        size: deviceType == 'tab'
                                            ? fontSize * 35
                                            : deviceType == 'large'
                                                ? fontSize * 40
                                                : fontSize * 24,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        DateFormat.yMMMd().format(
                                            result['data']['uploadedDate']),
                                        style: TextStyle(
                                            // color: Colors.grey,
                                            fontSize: deviceType == 'tab'
                                                ? fontSize * 35
                                                : deviceType == 'large'
                                                    ? fontSize * 38
                                                    : fontSize * 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  result['isUser']
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: screenSize * .03),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Restricted by country',
                                                    style: TextStyle(
                                                        // color: Colors.grey,
                                                        fontSize: deviceType ==
                                                                'tab'
                                                            ? fontSize * 26
                                                            : deviceType ==
                                                                    'large'
                                                                ? fontSize * 32
                                                                : fontSize * 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Transform.scale(
                                                    scale: deviceType == 'tab'
                                                        ? 1.2
                                                        : deviceType == 'large'
                                                            ? 1.5
                                                            : 1,
                                                    child: Switch(
                                                        value: byCountry,
                                                        activeColor: Theme.of(
                                                                context)
                                                            .primaryColorDark,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            Provider.of<Files>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .setRestrictedUser(
                                                                    'by_country',
                                                                    result['data']
                                                                        [
                                                                        'identifier']);
                                                            byCountry = value;
                                                          });
                                                        }),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                  height: screenSize * .03),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Restricted by user',
                                                        style: TextStyle(
                                                            // color: Colors.grey,
                                                            fontSize: deviceType ==
                                                                    'tab'
                                                                ? fontSize * 26
                                                                : deviceType ==
                                                                        'large'
                                                                    ? fontSize *
                                                                        32
                                                                    : fontSize *
                                                                        20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      result['data']
                                                              ['restrictedUser']
                                                          ? Tooltip(
                                                              message: result[
                                                                      'data'][
                                                                  'authorisedUser'],
                                                              child: Icon(Icons
                                                                  .info_outline_rounded),
                                                            )
                                                          : Container()
                                                    ],
                                                  ),
                                                  SizedBox(width: 5),
                                                  Transform.scale(
                                                    scale: deviceType == 'tab'
                                                        ? 1.2
                                                        : deviceType == 'large'
                                                            ? 1.5
                                                            : 1,
                                                    child: Switch(
                                                        value: byUser,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            Provider.of<Files>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .setRestrictedUser(
                                                                    'by_user',
                                                                    result['data']
                                                                        [
                                                                        'identifier']);
                                                            byUser = value;
                                                          });
                                                        },
                                                        // activeTrackColor: Colors.yellow,
                                                        activeColor: Theme.of(
                                                                context)
                                                            .primaryColorDark),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container()
                                ]),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
      floatingActionButton: isUser
          ? Container(
              margin: EdgeInsets.only(bottom: 40),
              child: FloatingActionButton(
                  focusColor: Theme.of(context).primaryColorDark,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.delete,
                    size: deviceType == 'tab'
                        ? fontSize * 40
                        : deviceType == 'large'
                            ? fontSize * 45
                            : fontSize * 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text('Please Confirm',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold)),
                              content: Text(
                                'Are you sure you want to delete this file?',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    RaisedButton(
                                      padding: EdgeInsets.all(10),
                                      color: Theme.of(context).primaryColor,
                                      child: Text('No',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                    SizedBox(width: 5),
                                    RaisedButton(
                                      padding: EdgeInsets.all(10),
                                      color: Colors.red,
                                      child: Text('Delete',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        Provider.of<Files>(context,
                                                listen: false)
                                            .deleteFile(
                                                result['data']['identifier'])
                                            .then((value) {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  '/dashboard');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  elevation: 8.0,
                                                  content: Text(
                                                    'File Deleted',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )));
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    ),
                                  ],
                                )
                              ],
                            ));
                  }),
            )
          : result['message'] == false
              ? Container()
              : Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: FloatingActionButton(
                      focusColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.download_sharp,
                        size: fontSize * 35,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final status = await Permission.storage.request();
                        if (status.isGranted) {
                          setState(() {
                            _isLoading = true;

                            Provider.of<Files>(context, listen: false)
                                .downloadFile(result['data']['identifier'],
                                    result['data']['mimeType']);
                            _isLoading = false;
                            Navigator.of(context).pushNamed('/download',
                                arguments: result['data']['identifier']);
                          });
                        } else {
                          print('Permission denied');
                          Navigator.of(context).pop();
                        }
                        // setState(() {
                        //   _isLoading = true;
                        // });
                        // final taskId = await FlutterDownloader.enqueue(
                        //   url: result['data']['file'],
                        //   savedDir: 'the path of directory where you want to save downloaded files',
                        //   showNotification: true, // show download progress in status bar (for Android)
                        //   openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                        // );
                      }),
                ),
    );
  }
}
