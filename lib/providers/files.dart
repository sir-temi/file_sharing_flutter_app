import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:filesize/filesize.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

class FileItem {
  String? identifier;
  String? mimeType;
  String? sizeMb;
  DateTime? uploadedDate;
  String? title;
  String? link;
  int? downloaded;
  String? thumbnail;

  FileItem({
    this.identifier,
    this.mimeType,
    this.sizeMb,
    this.uploadedDate,
    this.title,
    this.link,
    this.downloaded,
    this.thumbnail,
  });
}

class FileDetailItem {
  String? file;
  Map? fileOwner = {'userName': '', 'firstName': ''};
  String? identifier;
  String? mimeType;
  String? sizeMb;
  DateTime? uploadedDate;
  String? title;
  int? downloaded;
  String? description;
  bool? restrictedUser;
  bool? restrictedCounty;
  String? authorisedUser;
  String? thumbnail;
  String? location;

  FileDetailItem({
    this.identifier,
    this.mimeType,
    this.sizeMb,
    this.uploadedDate,
    this.title,
    this.downloaded,
    this.description,
    this.fileOwner,
    this.file,
    this.restrictedUser,
    this.restrictedCounty,
    this.authorisedUser,
    this.thumbnail,
    this.location,
  });
}

class Response {
  bool? message;
  bool? isUser;
  Map? data;

  Response({this.message, this.isUser, this.data});
}

class Files with ChangeNotifier {
  final authToken;
  final userName;

  // Response get singleResponse {
  //   return _singleResponse;
  // }

  // double? _progress = 0;

  // get uploadProgress => _progress;

  Files(this.authToken, this.userName);

  List<FileItem> _userFiles = [];

  List<FileItem> get userFiles {
    return [..._userFiles.reversed];
  }

  List<Response> _results = [];

  int get totalUploads {
    return _userFiles.length;
  }

  Future<Map> getFileDetails(String identifier, String? userAccessing) async {
    final res = await http.get(Uri.parse('http://ip-api.com/json'));
    final country = json.decode(res.body)['country'].toString();
    String identity = identifier + '-' + country;
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/$identity/');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $authToken',
    });

    final file = json.decode(response.body)[0];
    if (response.statusCode == 200) {
      if (userAccessing == file['owner']['username']) {
        return {
          'message': true,
          'isUser': true,
          'alert': 'null',
          'data': {
            'authorisedUser': file['authorised_user'],
            'description': file['description'],
            'downloaded': file['downloaded'],
            'file': 'http://10.0.2.2:8000' + file['file'],
            'fileOwner': file['owner'],
            'identifier': file['identifier'],
            'location': file['location'],
            'mimeType': file['mime_type'],
            'restrictedCountry': file['restricted_by_country'],
            'restrictedUser': file['restricted_by_user'],
            'size_mb': file['size_mb'],
            'thumbnail': 'http://10.0.2.2:8000' + file['thumbnail'],
            'title': file['title'],
            'uploadedDate': DateTime.parse(file['uploaded_date'])
          }
        };
      } else {
        Map file = json.decode(response.body)[0];
        return {
          'message': true,
          'isUser': false,
          'data': {
            'authorisedUser': file['authorised_user'],
            'description': file['description'],
            'downloaded': file['downloaded'],
            'file': 'http://10.0.2.2:8000' + file['file'],
            'fileOwner': file['owner'],
            'identifier': file['identifier'],
            'location': file['location'],
            'mimeType': file['mime_type'],
            'restrictedCountry': file['restricted_by_country'],
            'restrictedUser': file['restricted_by_user'],
            'size_mb': file['size_mb'],
            'thumbnail': 'http://10.0.2.2:8000' + file['thumbnail'],
            'title': file['title'],
            'uploadedDate': DateTime.parse(file['uploaded_date'])
          },
          'alert': 'null'
        };
      }
    } else if (response.statusCode == 401) {
      print(json.decode(response.body)[0]['message'].split(" ")[1]);
      return {
        'message': false,
        'isUser': false,
        'alert': json.decode(response.body)[0]['message'].split(" ")[1],
        'data': {
          'restrictedCountry': true,
          'restrictedUser': true,
          'title': 'Restricted file'
        }
      };
    }
    throw ('ERROR');
  }

  Future<void> fetchAndSetFiles() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});
      if (response.statusCode == 401) {
        throw ('This file is not available.');
      } else if (response.statusCode == 200) {
        List<dynamic> files = json.decode(response.body);
        if (files.length < 1) {
          return;
        }

        List<FileItem> userfiles = [];

        files.forEach((file) {
          userfiles.add(FileItem(
            identifier: file['identifier'],
            downloaded: file['downloaded'],
            link: file['link']['url'],
            mimeType: file['mime_type'],
            sizeMb: file['size_mb'],
            thumbnail: 'http://10.0.2.2:8000${file['thumbnail']}',
            title: file['title'],
            uploadedDate: DateTime.parse(file['uploaded_date']),
          ));
        });

        _userFiles = userfiles;
        notifyListeners();
      } else {
        throw ('Server error, please try again');
      }
    } catch (e) {
      throw (e);
    }
  }

  Future<void> setRestrictedUser(category, identifier) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/$identifier/');

    try {
      final response = await http.put(url,
          headers: {'Authorization': 'Bearer $authToken'},
          body: {'category': category});
      if (response.statusCode != 200) {
        throw ('ERROR');
      }

      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  Future<void> deleteFile(identifier) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/$identifier/');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );
      if (response.statusCode != 200) {
        throw ('ERROR');
      }
      _userFiles.removeWhere((e) => e.identifier == identifier);
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  Future<void> downloadFile(String identifier, String mimeType) async {
    final res = await http.get(Uri.parse('http://ip-api.com/json'));
    final country = json.decode(res.body)['country'].toString();
    String identity = identifier + '-' + country;

    final dirs = await getExternalStorageDirectories();
    final path = dirs![0].path;
    final file = File('$path/yuy87.png');
    print(dirs);
    print(path);
    print(file.path);
    final status = await Permission.storage.status;
    print('Status $status');

    final url = 'http://10.0.2.2:8000/api/v1/files/download/$identity/';

    try {
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {'Authorization': 'Bearer $authToken'},
        savedDir: path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      notifyListeners();
    } catch (e) {
      throw (e);
    }
  }

  Future<List> validateUser(String username) async {
    final url = 'http://10.0.2.2:8000/api/v1/validateuser/$username/';

    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode == 404) {
      return [false];
    }

    return [true, json.decode(response.body)['first_name']];
  }

  Future<bool> validateFile(String identifier) async {
    print(identifier);
    final url = 'http://10.0.2.2:8000/api/v1/files/validatefile/$identifier/';

    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode == 404) {
      return false;
    }

    return true;
  }

  Future<bool> uploadFile(Map data, File? file, String name) async {
    // Make api call to get user location
    final res = await http.get(Uri.parse('http://ip-api.com/json'));
    final country = json.decode(res.body)['country'].toString();

    // make a post request to upload file to server
    try {
      var uri = Uri.parse('http://10.0.2.2:8000/api/v1/files/');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $authToken';
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));
      request.fields['title'] = data['title'];
      request.fields['description'] = data['description'];
      request.fields['authorised_user'] = data['username'];
      request.fields['file_name'] = name;
      request.fields['mb'] = filesize(file.lengthSync(), 1);
      request.fields['bytes'] = file.lengthSync().toString();
      request.fields['location'] = country;
      request.fields['restricted_by_user'] =
          data['restrictedUser'] ? "true" : "false";
      request.fields['restricted_by_country'] =
          data['restrictedCountry'] ? "true" : "false";

      final StreamedResponse response = await Client().send(request);

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      throw (e);
    }
    return false;
  }

  Future<void> shareFile(String username, String identifier) async {
    final url =
        'http://10.0.2.2:8000/api/v1/files/share_file/$username/$identifier/';

    await http
        .post(Uri.parse(url), headers: {'Authorization': 'Bearer $authToken'});
  }
}
