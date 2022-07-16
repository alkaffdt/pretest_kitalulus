import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/pages/favourites_page.dart';
import 'package:pretest_kitalulus_2/pages/home_page.dart';
import 'package:pretest_kitalulus_2/providers/root_provider.dart';
import 'package:pretest_kitalulus_2/widgets/bottomnavigationbar.dart';
import 'package:provider/provider.dart';

import '../providers/main_provider.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  var searchTextFieldController = TextEditingController();
  //
  var pageController = PageController(
    initialPage: 0,
  );
  //
  Widget appbarTitle = Text("Countries App");
  bool clickedSearchButton = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDatas();
  }

  Future fetchDatas() async {
    Provider.of<MainProvider>(context, listen: false).fetchCountries();
    Provider.of<MainProvider>(context, listen: false)
        .fetchFavouritedCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: appbarTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: searchIcon(),
          )
        ],
      ),
      body: Consumer<RootProvider>(builder: (context, root, child) {
        return PageView(
          controller: root.pageController,
          scrollDirection: Axis.horizontal,
          children: [HomePage(pageController), FavouritesPage()],
          onPageChanged: (int index) {
            root.setIndexPage(index);
          },
        );
      }),
      bottomNavigationBar: Navbar(),
    );
  }

  searchIcon() {
    Widget _textField = Container(
      color: Colors.white,
      child: TextField(
        controller: searchTextFieldController,
        autofocus: true,
        onChanged: (text) {
          Provider.of<MainProvider>(context, listen: false).findCountry(text);
        },
        decoration: const InputDecoration(
            fillColor: Colors.white, contentPadding: EdgeInsets.only(left: 25)),
      ),
    );

    Widget _appBarTitle = const Text("Country App");

    return Consumer<MainProvider>(builder: (context, MainProvider data, _) {
      if (clickedSearchButton) {
        return IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            //whenever user click close searchbar
            setState(() {
              clickedSearchButton = false;
              appbarTitle = _appBarTitle;
              searchTextFieldController.text = "";
              //
              data.resetCountries();
            });
          },
        );
      } else {
        return IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              clickedSearchButton = true;
              appbarTitle = _textField;
            });
          },
        );
      }
    });
  }
}
