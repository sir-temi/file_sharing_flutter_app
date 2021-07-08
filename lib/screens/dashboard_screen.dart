import 'package:cemfrontend/classes/search_bar.dart';
import 'package:cemfrontend/screens/file_detail_screen.dart';
import 'package:cemfrontend/widgets/drawer.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../widgets/drawer.dart';
import '../providers/auth.dart';
import '../providers/files.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  bool _isInit = false;
  final FirebaseMessaging fbm = FirebaseMessaging.instance;

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null && initialMessage.data['type'] == 'shared') {
      Navigator.of(context)
          .pushNamed('/details', arguments: initialMessage.data['identifier']);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('${message.data} ======= ${message.notification}');
      Navigator.of(context)
          .pushNamed('/details', arguments: message.data['identifier']);
    });
  }

  @override
  void initState() {
    super.initState();

    setupInteractedMessage();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('${message.data} ======= ${message.notification}');
      Navigator.of(context)
          .pushNamed('/details', arguments: message.data['identifier']);
    });
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Files>(context, listen: false)
          .fetchAndSetFiles()
          .catchError((error) {
        // setState(() {
        //   _isLoading = false;
        // });
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
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  var _formKey;
  var _fileNumber;

  _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final res = await Provider.of<Files>(context, listen: false)
        .validateFile(_fileNumber);
    if (res) {
      Navigator.of(context).pushNamed('/details', arguments: _fileNumber);
    } else {
      showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
                // title: const Text('File number',),
                children: <Widget>[
                  Container(
                    child: Text(
                      'File not found.',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontsize = MediaQuery.of(context).textScaleFactor;
    final PreferredSizeWidget appBar = AppBar(
      title: Text('My Dashboard'),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/search_file'),
            icon: Icon(Icons.search))
          // icon: AnimatedIcon(icon: ,progress: ),
      ],
    );
    final screensize = MediaQuery.of(context).size;
    final appBarheight = appBar.preferredSize.height;
    final batterybar = MediaQuery.of(context).padding.top;
    final paddingButtom = MediaQuery.of(context).padding.bottom;
    final screenSize =
        screensize.height - (appBarheight + batterybar + paddingButtom);
    final userName = Provider.of<Auth>(context, listen: false).userName;
    List files = Provider.of<Files>(context, listen: false).userFiles;
    final uploads = Provider.of<Files>(context, listen: false).totalUploads;

    return Scaffold(
      appBar: appBar,
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('')
          : files.length < 1
              ? Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screensize.width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.exclamationTriangle,
                          size: fontsize * 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                            'You have not uploaded any file. Upload by clicking on the bottom right button',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: fontsize * 20,
                                fontWeight: FontWeight.w900))
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    // height: screenSize,
                    padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Column(
                      children: [
                        Container(
                            height: screenSize * 0.12,
                            width: double.infinity,
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Text('Shared files'),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: fontsize * 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      uploads.toString(),
                                      style: TextStyle(
                                          fontSize: fontsize * 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        Container(
                          // padding: EdgeInsets.only(top: 2),
                          height: screenSize * 0.86,
                          child: ListView.builder(
                              itemCount: files.length,
                              itemBuilder: (ctx, i) {
                                return Dismissible(
                                  key: Key(files[i].identifier),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                              title: Text('Please Confirm',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              content: Text(
                                                'Are you sure you want to delete this file?',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    RaisedButton(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      child: Text('No',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                      onPressed: () => Navigator
                                                              .of(context)
                                                          .pushReplacementNamed(
                                                              '/dashboard'),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                    ),
                                                    SizedBox(width: 5),
                                                    RaisedButton(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      color: Colors.red,
                                                      child: Text('Delete',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                      onPressed: () {
                                                        setState(() {
                                                          _isLoading = true;
                                                        });

                                                        Provider.of<Files>(
                                                                context,
                                                                listen: false)
                                                            .deleteFile(files[i]
                                                                .identifier)
                                                            .then((value) {
                                                          setState(() {
                                                            _isLoading = false;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                          ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                                      backgroundColor: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      elevation:
                                                                          8.0,
                                                                      content:
                                                                          Text(
                                                                        'Your file has been uploaded',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      )));
                                                        });
                                                      },
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ));
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    color: Colors.red,
                                    child: Icon(
                                      Icons.delete_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          '/details',
                                          arguments: files[i].identifier);
                                    },
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            // padding:
                                            //     EdgeInsets.symmetric(vertical: 2),
                                            child: ListTile(
                                              leading: Container(
                                                width: screenSize * .11,
                                                child: Image.network(
                                                  files[i].thumbnail,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              title: Text(
                                                files[i].title,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: fontsize * 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Container(
                                                width: double.infinity,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                      '${files[i].mimeType.split("/")[0][0].toUpperCase()}${files[i].mimeType.split("/")[0].substring(1)}',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              fontsize * 16),
                                                    )),
                                                    Expanded(
                                                        child: Text(
                                                      files[i].sizeMb,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              fontsize * 17),
                                                    )),
                                                    Expanded(
                                                        child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .download_rounded,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Text(
                                                          files[i]
                                                              .downloaded
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize:
                                                                  fontsize *
                                                                      18),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
            focusColor: Theme.of(context).primaryColorDark,
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.upload_sharp,
              size: fontsize * 35,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pushNamed('/upload_file')),
      ),
    );
  }
}
