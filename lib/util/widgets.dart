import 'package:flutter/material.dart';

Widget loadingWidget() {
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
            ),
            width: 150.0,
            height: 150.0,
          ),
          Container(
            child:Text(
              "loading...",
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
              ),

            ),
            padding: EdgeInsets.only(top: 20),
          )
        ]
      )
  );
}