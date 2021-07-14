import 'package:cemfrontend/class/device_checker.dart';
import 'package:cemfrontend/providers/auth.dart';
import 'package:cemfrontend/providers/files.dart';
import 'package:cemfrontend/widgets/drawer.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchFileScreen extends StatefulWidget {
  const SearchFileScreen({Key? key}) : super(key: key);
  static const routeName = '/search_file';

  @override
  _SearchFileScreenState createState() => _SearchFileScreenState();
}

class _SearchFileScreenState extends State<SearchFileScreen> {
  final _formKey = GlobalKey<FormState>();
  var _usernameController = TextEditingController();
  var _isLoading = false;
  String? _fileNumber = '';

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
          .validateFile(_fileNumber!);

      if (response == false) {
        // setState(() {
        //   _isLoading = false;
        // });
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  content: Text(
                    'File not found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.all(15),
                          color: Theme.of(context).primaryColor,
                          child: Text('Search Again',
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
        Navigator.of(context).pushReplacementNamed('/details',
            arguments: _fileNumber!.toLowerCase());
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
    final screensize = MediaQuery.of(context).size;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    final userName = Provider.of<Auth>(context, listen: false).userName;
    String deviceType = MyChecker().checker(screensize.width.toInt());

    return Scaffold(
      appBar: AppBar(
          title: Text('Search for a file',
              style: TextStyle(
                  fontSize: deviceType == 'tab'
                      ? fontSize * 18
                      : deviceType == 'large'
                          ? fontSize * 25
                          : fontSize)),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                size: deviceType == 'tab'
                    ? fontSize * 18
                    : deviceType == 'large'
                        ? fontSize * 40
                        : fontSize,
              ),
            ),
            SizedBox(
              width: 10,
            )
          ]),
      drawer: DrawerMenu(userName),
      body: _isLoading
          ? Loading('Searching for File...')
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: TextFormField(
                            controller: _usernameController,
                            onTap: () async {},
                            style: TextStyle(fontSize: fontSize * 18),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.bookmark,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              labelText: 'Type File number',
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
                                      color:
                                          Theme.of(context).primaryColorDark)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            validator: (v) {
                              if (v!.isEmpty) {
                                return "File number can't be empty";
                              } else if (v.length != 8) {
                                return "File number must be 8 characters";
                              }
                            },
                            onSaved: (v) {
                              _fileNumber = v;
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
                                    elevation: 3,
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
                                          Icons.search,
                                          color: Colors.white,
                                          size: fontSize * 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Search username',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: fontSize * 20))
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
    );
  }
}
