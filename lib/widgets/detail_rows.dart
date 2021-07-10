import 'package:flutter/material.dart';

class DetailRows extends StatelessWidget {
  // const DetailRows({ Key? key }) : super(key: key);

  final fontSize;
  final value;
  final icon;

  DetailRows(this.fontSize, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      child: Row(
                                        children: [
                                          Icon(
                                            icon[0],
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: fontSize * 30,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            value[0]
                                                .toString(),
                                            style: TextStyle(
                                                // color: Colors.grey,
                                                fontSize: fontSize * 24,
                                                fontWeight: FontWeight.bold
                                                ),
                                          )
                                        ],
                                      ),
                                    )),
                                    Expanded(
                                        child: Container(
                                      child: Row(
                                        children: [
                                          Icon(
                                            icon[1],
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: fontSize * 30,
                                          ),
                                          SizedBox(width: 5),
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              value[1],
                                              style: TextStyle(
                                                  // color: Colors.grey,
                                                  fontSize: fontSize * 24,
                                                  fontWeight: FontWeight.bold
                                                  ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                                    
                                  ],
                                );
  }
}