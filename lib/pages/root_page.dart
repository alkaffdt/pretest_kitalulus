import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/pages/favourites_page.dart';
import 'package:pretest_kitalulus_2/pages/home_page.dart';
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
  int currentPage = 0;
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
      body: PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: [HomePage(pageController), FavouritesPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Shifting
          // selectedLabelStyle: TextStyle(color: Colors.grey),
          currentIndex: 0,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
            pageController.animateToPage(index,
                duration: Duration(milliseconds: 333), curve: Curves.linear);
          },
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.flag,
                color: currentPage == 0 ? Colors.blue : Colors.grey,
              ),
              label: "countries",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: currentPage == 1 ? Colors.red : Colors.grey,
              ),
              label: "favourite",
            )
          ]),
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
