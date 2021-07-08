import 'package:cemfrontend/providers/files.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool _isLoading = false;

class SearchBar extends SearchDelegate<String>{
  @override
  List<Widget> buildActions(BuildContext context) {
      if(_isLoading) return [CircularProgressIndicator.adaptive()];
      return [
        IconButton(onPressed: ()=> query = '', icon: Icon(Icons.clear))
      ];
    }
  
    @override
    Widget buildLeading(BuildContext context) {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(), 
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_home,
          progress: transitionAnimation,
        ));
    }
  
    @override
    Widget buildResults(BuildContext context) {
      // TODO: implement buildResults
      Provider.of<Files>(context, listen: false).validateFile(query).then((value) {
        if(value == true){
          _isLoading = true;
          Navigator.of(context).pushReplacementNamed('/details', arguments: query);
        }else{
          
        }
      });
      
      return Card(

      );
    }
  
    @override
    Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final listSearch = [];
    return ListView.builder(itemBuilder: (ctx, index)=> ListTile());
  }

}
