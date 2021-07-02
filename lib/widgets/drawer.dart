import 'package:flutter/material.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

class DrawerMenu extends StatelessWidget {
  final userName;

  DrawerMenu(this.userName);
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    Widget buildListTile(String title, IconData icon, VoidCallback todo) {
      return ListTile(
        onTap: todo,
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      );
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: deviceSize.height * .1,
            child: DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColor,
                    // Color.fromRGBO(138, 48, 127, 1)
                  ], begin: Alignment.bottomLeft, end: Alignment.topRight),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: Image.asset("assets/images/dp.png"),
                        // height: 0.1,
                        // width: 0.1,
                        // fit: BoxFit.cover,
                      
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${userName[0].toUpperCase()}${userName.substring(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: fontSize *20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),
          buildListTile(
              'My Profile',
              Icons.dashboard,
              () => Navigator.of(context).pushReplacementNamed('/dashboard'),
          ),
          buildListTile(
              'My Files',
              Icons.list,
              // () => Navigator.of(context).pushReplacementNamed('/Orders'),
              () async {
              print(Provider.of<Auth>(context, listen: false).token);
                }
              ),
          buildListTile(
            'Log Out',
            Icons.exit_to_app,
            () async {
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
