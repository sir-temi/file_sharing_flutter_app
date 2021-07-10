import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cemfrontend/widgets/drawer.dart';
import 'package:cemfrontend/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/auth.dart';


class DownloadScreen extends StatefulWidget {
  const DownloadScreen({ Key? key }) : super(key: key);

  static const routeName = '/download';

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String _fileFullPath = '';
  bool _isLoading = false;
  bool _isInit = false;
  List<dynamic> data = [];
  String directoryType = '';
  String progress = '0';

  ReceivePort _port = ReceivePort();

@override
void initState() {
	super.initState();

	IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
	_port.listen((dynamic data) {
		String id = data[0];
		DownloadTaskStatus status = data[1];
		int progress = data[2];
		setState((){ });
	});

	FlutterDownloader.registerCallback(downloadCallback);
}

@override
void dispose() {
	IsolateNameServer.removePortNameMapping('downloader_send_port');
	super.dispose();
}

static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
	final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
	send!.send([id, status, progress]);
}
  @override
  Widget build(BuildContext context) {
    final identifier = ModalRoute.of(context)?.settings.arguments as String;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded'),
        actions: [
        BackButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/details', arguments: identifier))
      ]
      ),
      drawer: DrawerMenu(Provider.of<Auth>(context, listen: false).userName),
      body: Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: fontSize * 100,
                        ),
                        Text(
                        'Thanks for downloading...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: fontSize * 20,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}