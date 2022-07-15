// import 'dart:html';
// import 'dart:io';
// import 'dart:html';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/pages/root_page.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => MainProvider())],
      child: const MaterialApp(
        title: 'Country App',
        debugShowCheckedModeBanner: false,
        home: RootPage(),
      ),
    );
  }
}
