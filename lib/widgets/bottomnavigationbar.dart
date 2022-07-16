// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/providers/root_provider.dart';
import 'package:provider/provider.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    //
    return Consumer<RootProvider>(builder: (context, root, _) {
      return BottomNavigationBar(
        currentIndex: root.getIndexPage,
        selectedItemColor: Colors.blue,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          const BottomNavigationBarItem(
              icon: const Icon(Icons.flag), label: "countries"),
          const BottomNavigationBarItem(
              icon: const Icon(Icons.favorite), label: "favourites")
        ],
        onTap: (selected) {
          root.setIndexPage(selected);
        },
      );
    });
  }
}
