import 'package:cemfrontend/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth.dart';
import '../providers/files.dart';
import '../widgets/loading.dart';
import '../widgets/detail_rows.dart';

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


  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      final identifier = ModalRoute.of(context)?.settings.arguments as String;

      final userAccessing = Provider.of<Auth>(context, listen: false).userName;

      Provider.of<Files>(context, listen: false)
          .getFileDetails(identifier, userAccessing)
          .catchError((e) {})
          .then((response) {
        result = response;
        byCountry = response['data']['restrictedCountry'];
        byUser = response['data']['restrictedUser'];
        isUser = result['isUser'];
        title = response['data']['title'];

        setState(() {
          _isLoading = false;
        });
      });

      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      title:
          Text(title),
      // actions: [
      //   IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.back)
      // ],
    );
    final screensize = MediaQuery.of(context).size;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    final appBarheight = appBar.preferredSize.height;
    final batterybar = MediaQuery.of(context).padding.top;
    final screenSize = screensize.height - (appBarheight + batterybar);
    final userName = Provider.of<Auth>(context, listen: false).userName;
    

    

    return Scaffold(
      appBar: appBar,
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('Loading')
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
                          !result['alert'].contains('user')
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
                    padding: EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: screenSize * .20,
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
                              fontSize: fontSize * 30,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(height: 7),
                        Container(
                          child: Text(
                            result['data']['description'],
                            style: TextStyle(
                              fontSize: fontSize * 16,
                              fontWeight: FontWeight.w800,
                              // color: Theme.of(context).primaryColor
                              )
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: Card(
                              elevation: 7,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                child: Column(children: [
                                  DetailRows(fontSize, [
                                    result['data']['downloaded'],
                                    '${result['data']['mimeType'].split("/")[0][0].toUpperCase()}${result['data']['mimeType'].split("/")[0].substring(1)}'
                                  ], [
                                    Icons.download_rounded,
                                    Icons.category_outlined
                                  ]),
                                  SizedBox(height: screenSize * .05),
                                  DetailRows(fontSize, [
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
                                        size: fontSize * 30,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        DateFormat.yMMMd()
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                            // color: Colors.grey,
                                            fontSize: fontSize * 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  result['isUser']
                                      ? Column(
                                          children: [
                                            SizedBox(height: screenSize * .03),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Restricted by country',
                                                  style: TextStyle(
                                                      // color: Colors.grey,
                                                      fontSize: fontSize * 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 5),
                                                Switch(
                                                  value: byCountry, 
                                                  activeColor: Theme.of(context).primaryColorDark,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      Provider.of<Files>(context, listen: false).setRestrictedUser('by_country', result['data']['identifier']);
                                                      byCountry = value;
                                                    });
                                                  }
                                                  )
                                              ],
                                            ),
                                            SizedBox(height: screenSize * .03),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Restricted by user',
                                                  style: TextStyle(
                                                      // color: Colors.grey,
                                                      fontSize: fontSize * 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(width: 5),
                                                Switch(
                                                  value: byUser, 
                                                  onChanged: (value) {
                                                    setState(() {
                                                      Provider.of<Files>(context, listen: false).setRestrictedUser('by_user', result['data']['identifier']);
                                                      byUser = value;
                                                    });
                                                  },
                                                  // activeTrackColor: Colors.yellow,
                                                  activeColor: Theme.of(context).primaryColorDark
                                                  )
                                              ],
                                            ),
                                          ],
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
                    size: fontSize * 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('Please Confirm',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
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
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                RaisedButton(
                                                  padding: EdgeInsets.all(10),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  child: Text('No',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                ),
                                                SizedBox(width: 5),
                                                RaisedButton(
                                                  padding: EdgeInsets.all(10),
                                                  color: Colors.red,
                                                  child: Text('Delete',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'File Deleted')));
                                                    });
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                ),
                                              ],
                                            )
                                          ],
                                        ));
                  }
                  ),
            )
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
                  onPressed: () => print('Clocked')),
            ),
    );
  }
}
