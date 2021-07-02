
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FileItem{
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


class FileDetailItem{
  String? file;
  Map? fileOwner = {
    'userName': '',
    'firstName': ''
  };
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


class Files with ChangeNotifier{
  final authToken;
  final userName;
  
  Files(this.authToken, this.userName);

  List<FileItem> _userFiles = [];

  List<FileItem> get userFiles{
    return [..._userFiles.reversed];
  }

  int get totalUploads{
    return _userFiles.length;
  }
  
  getCountry() async{
    try {

          final response = await http.get(Uri.parse('http://ip-api.com/json'));
          return json.decode(response.body)['country'].toString();

        } catch (err) {

          throw('Network error, please try again');

      }
  }

  getFileDetails(String identifier, String? userAccessing) async{
    
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/$identifier');

    try{
        if (userAccessing == userName){
          
          final response = await http.get(url,
            headers: {
              'Authorization': 'Bearer $authToken',
            }
          );
          if( response.statusCode == 404){
            throw('This file is not available.');
          }else if(response.statusCode == 200){
            Map<String, dynamic> file = json.decode(response.body)['data'];

            return {
              'message': 'success',
              'isUser': true,
              'data' :FileDetailItem(
              description: file['description'],
              downloaded: file['downloaded'],
              file: 'http://10.0.2.2:8000${file['file']}',
              fileOwner: {
                'userName': file['owner']['username'],
                'firstName': file['owner']['first_name'],
              },
              identifier: file['identifier'],
              mimeType: file['mime_type'],
              sizeMb: file['size_mb'],
              title: file['title'],
              uploadedDate: file['uploaded_date'],
              authorisedUser: file['authorised_user'],
              restrictedCounty: file['restricted_by_country'],
              restrictedUser: file['restricted_by_user'],
              thumbnail: 'http://10.0.2.2:8000${file['thumbnail']}',
            )}
            ;
          }
        }else{
          
          final response = await http.get(url,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Country': getCountry(),
            }
          );

          if(response.statusCode == 401){

            return {
              'message': 'failed',
              'data': json.decode(response.body)['message'].split(" ")[1]
              };

          }else if (response.statusCode == 200){

            Map<String, dynamic> file = json.decode(response.body)['data'];
            return {
              'message': 'success',
              'isUser': false,
              'data' :FileDetailItem(
              description: file['description'],
              downloaded: file['downloaded'],
              file: 'http://10.0.2.2:8000${file['file']}',
              fileOwner: {
                'userName': file['owner']['username'],
                'firstName': file['owner']['first_name'],
              },
              identifier: file['identifier'],
              mimeType: file['mime_type'],
              sizeMb: file['size_mb'],
              title: file['title'],
              uploadedDate: file['uploaded_date'],
              authorisedUser: file['authorised_user'],
              restrictedCounty: file['restricted_by_country'],
              restrictedUser: file['restricted_by_user'],
              thumbnail: 'http://10.0.2.2:8000${file['thumbnail']}',
              )
            }; 

          }
        }

        

    }catch(e){

      throw(e);

    }
  }

  Future<void> fetchAndSetFiles() async{
    final url = Uri.parse('http://10.0.2.2:8000/api/v1/files/');

    try{

        final response = await http.get(url,
            headers: {
              'Authorization': 'Bearer $authToken'
            }
        );
        if( response.statusCode == 401){

          throw('This file is not available.');

        }else if(response.statusCode == 200){

          List<dynamic> files = json.decode(response.body)['data'];
          if(files.length < 1){
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
        } else{
          throw('Server error, please try again');
        }
    }catch(e){

      throw(e);

    }
  }


}