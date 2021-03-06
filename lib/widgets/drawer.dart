import 'package:cemfrontend/class/device_checker.dart';
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
    String deviceType = MyChecker().checker(deviceSize.width.toInt());
    Widget buildListTile(String title, IconData icon, VoidCallback todo) {
      return ListTile(
        onTap: todo,
        leading: Icon(
          icon,
          size: deviceType == 'tab'
              ? fontSize * 36
              : deviceType == 'large'
                  ? fontSize * 40
                  : fontSize * 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: deviceType == 'tab'
                ? fontSize * 26
                : deviceType == 'large'
                    ? fontSize * 30
                    : fontSize * 22,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      );
    }

    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: deviceSize.height * .2,
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
                      height: deviceType == 'tab'
                          ? 70
                          : deviceType == 'large'
                              ? 80
                              : 50,
                      width: deviceType == 'tab'
                          ? 70
                          : deviceType == 'large'
                              ? 80
                              : 50,
                      child: Image.asset(
                        "assets/images/dp.png",
                        fit: BoxFit.fill,
                      ),
                      // height: 0.1,
                      // width: 0.1,
                    ),
                    SizedBox(width: 10),
                    Text(
                      userName != null ? '${userName.toUpperCase()}' : '',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: deviceType == 'tab'
                            ? fontSize * 23
                            : deviceType == 'large'
                                ? fontSize * 26
                                : fontSize * 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
          ),
          buildListTile(
            'My Dashboard',
            Icons.dashboard,
            () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/dashboard', (Route<dynamic> route) => false),
          ),
          // buildListTile(
          //     'My Files',
          //     Icons.list,
          //     // () => Navigator.of(context).pushReplacementNamed('/Orders'),
          //     () async {
          //     print(Provider.of<Auth>(context, listen: false).token);
          //       }
          //     ),
          buildListTile(
            'Log Out',
            Icons.power_settings_new_sharp,
            () async {
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
