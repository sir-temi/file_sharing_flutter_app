import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final info;

  Loading(this.info);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator.adaptive(
              strokeWidth: fontSize * 10,
            ),
            Text(
              info,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: fontSize * 20,
                  fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
    );
  }
}
