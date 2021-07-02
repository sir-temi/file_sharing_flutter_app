import 'package:cemfrontend/screens/file_detail_screen.dart';
import 'package:cemfrontend/widgets/drawer.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/drawer.dart';
import '../providers/auth.dart';
import '../providers/files.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Files>(context, listen: false)
          .fetchAndSetFiles()
          .catchError((error) {
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = AppBar(
      title: Text('My Dashboard'),
    );
    final screensize = MediaQuery.of(context).size;
    final fontsize = MediaQuery.of(context).textScaleFactor;
    final appBarheight = appBar.preferredSize.height;
    final batterybar = MediaQuery.of(context).padding.top;
    final screenSize = screensize.height - (appBarheight + batterybar);
    final userName = Provider.of<Auth>(context, listen: false).userName;
    List files = Provider.of<Files>(context, listen: false).userFiles;
    final uploads = Provider.of<Files>(context, listen: false).totalUploads;

    return Scaffold(
      appBar: appBar,
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('')
          : SingleChildScrollView(
              child: Container(
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
                      margin: EdgeInsets.only(top: 10),
                      height: screenSize * 0.88,
                      child: ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (ctx, i) {
                            return Dismissible(
                              key: Key(files[i].identifier),
                              onDismissed: (direction) {
                                // Remove the item from the data source.
                                // setState(() {
                                //   items.removeAt(index);
                                // });
                                print('The file has been removed.');
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Dismissed')));
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
                                
                                onTap: () => Navigator.of(context).pushNamed(FileDetailScreen.routeName, arguments: files[i].identifier),
                                child: Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        child: ListTile(
                                          leading: Image.network(
                                            files[i].thumbnail,
                                            fit: BoxFit.contain,
                                          ),
                                          title: Text(
                                            files[i].title,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: fontsize * 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  '${files[i].mimeType.split("/")[0][0].toUpperCase()}${files[i].mimeType.split("/")[0].substring(1)}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: fontsize * 16),
                                                )),
                                                Expanded(
                                                    child: Text(
                                                  files[i].sizeMb,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: fontsize * 17),
                                                )),
                                                Expanded(
                                                    child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.download_rounded,
                                                      color: Theme.of(context)
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              fontsize * 18),
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
            onPressed: () => print('Clocked')),
      ),
    );
  }
}
