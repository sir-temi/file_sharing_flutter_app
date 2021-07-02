import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/files.dart';

class FileDetailScreen extends StatelessWidget {
  const FileDetailScreen({ Key? key }) : super(key: key);

  static const routeName = '/details';

  @override
  Widget build(BuildContext context) {
    final identifier = ModalRoute.of(context)?.settings.arguments as String;
    final userAccessing = Provider.of<Auth>(context, listen: false).userName;
    final response = Provider.of<Files>(context, listen: false)
    .getFileDetails(identifier, userAccessing);

    return Container(
      
    );
  }
}