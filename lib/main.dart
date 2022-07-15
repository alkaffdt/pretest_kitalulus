// import 'dart:html';
// import 'dart:io';
// import 'dart:html';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

class HomePage extends StatefulWidget {
  PageController pageController;
  HomePage(this.pageController);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  //
  Widget appbarTitle = const Text("Country App");
  //

  @override
  Widget build(BuildContext context) {
    //
    return Center(
      child: Consumer<MainProvider>(
        builder: (context, data, _) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [floatingButtons(), Expanded(child: datasView())],
          ),
        ),
      ),
    );
  }

  Widget datasView() {
    return Consumer<MainProvider>(builder: (context, data, child) {
      Widget widget = Container();

      switch (data.graphqlStatus) {
        case GraphqlStatus.isLoading:
          widget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                height: 15,
              ),
              const Text("Fetching data...")
            ],
          );
          break;

        case GraphqlStatus.completed:
          if (data.viewStatus == ViewStatus.sort) {
            widget = sortedlistViewCountries(data);
          } else {
            widget = filteredlistViewCountries(data);
          }
          break;

        default:
          widget = Text("error");
      }

      return Container(width: MediaQuery.of(context).size.width, child: widget);
    });
  }

  Widget floatingButtons() {
    Widget button(
        {required String label,
        required icon,
        required ontap,
        isRight = false}) {
      return SizedBox(
        height: 55,
        width: 175,
        child: TextButton.icon(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.lightBlue),
                // padding: MaterialStateProperty.all<EdgeInsets>(
                //     EdgeInsets.symmetric(horizontal: 55)),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: isRight
                            ? BorderRadius.only(
                                bottomRight: Radius.circular(15))
                            : BorderRadius.only(
                                bottomLeft: Radius.circular(15)),
                        side: BorderSide(color: Colors.blue)))),
            onPressed: ontap,
            icon: Icon(
              icon,
              color: Colors.white,
            ),
            label: Text(
              label,
              style: TextStyle(color: Colors.white),
            )),
      );
    }

    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        button(
            label: "filter",
            icon: Icons.filter_alt,
            ontap: () {
              var data = Provider.of<MainProvider>(context, listen: false);
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text("select a continent"),
                      content: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.71,
                        child: ListView.builder(
                            itemCount: data.getContinents.length,
                            // shrinkWrap: true,
                            itemBuilder: (context, index) {
                              String nameContinent =
                                  data.getContinents[index].name;
                              return ListTile(
                                leading: Icon(Icons.map),
                                title: Text(nameContinent),
                                onTap: () {
                                  data.setContinentCode(
                                      data.getContinents[index].code);
                                  //
                                  Navigator.pop(context);
                                },
                              );
                            }),
                      ),
                    );
                  });
            }),
        button(
            label: "sort",
            icon: Icons.sort,
            ontap: () {
              var data = Provider.of<MainProvider>(context, listen: false);
              data.sortCountries();
            },
            isRight: true),
      ]),
    );
  }

//   Widget fetchQuery(MainProvider data) {
//     String _query = """
//       query{
//   continents{
//     code
//     name
//     countries{
//     code
//     emoji
//     name
//     states{
//       name
//     }
//     languages{
//       name
//       native
//     }
//     continent{
//         name
//     }
//   }
//   }
// }
//     """;
//     //
//     return Query(
//       options: QueryOptions(document: gql(_query)),
//       builder: (QueryResult result,
//           {VoidCallback? refetch, FetchMore? fetchMore}) {
//         //
//         if (result.hasException) {
//           return Text(result.exception.toString());
//         }

//         if (result.isLoading) {
//           return Transform.scale(
//               scale: 0.1,
//               child: CircularProgressIndicator(
//                 strokeWidth: 55,
//               ));
//         }

//         //
//         debugPrint("isi data");
//         debugPrint(result.data?.keys.toString());

//         List? _countries = result.data!["continents"];

//         if (_countries == null || _countries.length < 1) {
//           return const Text("data not found");
//         }

//         updateData(data, _countries);

//         return sortedlistViewCountries(data);
//       },
//     );
//   }

  sortedlistViewCountries(MainProvider data) {
    return ListView.builder(
      itemCount: data.sortedCountries.length,
      // itemExtent: 100,
      itemBuilder: (context, indexLetter) {
        String firstLetter = data.sortedCountries.keys.elementAt(indexLetter);
        //

        return Container(
          child: Column(
            children: [
              Divider(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                // height: 25,
                width: MediaQuery.of(context).size.width,
                color: Color.fromARGB(255, 27, 133, 209),
                child: Text(
                  firstLetter.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 29),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ListView.builder(
                  itemCount:
                      data.sortedCountries.values.elementAt(indexLetter).length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, indexCountry) {
                    return countryItem(indexCountry,
                        firstLetter: firstLetter, isSorted: true);
                  }),
              Divider(),
            ],
          ),
        );
      },
    );
  }

  filteredlistViewCountries(MainProvider data) {
    //
    debugPrint("isi filterByContinents di widget");
    debugPrint(data.filterByContinents.toString());
    return ListView.builder(
      itemCount: data.filterByContinents.length,
      // itemExtent: 100,
      itemBuilder: (context, index) {
        debugPrint("masuk ke dalame cardItemmmmm");

        //
        return countryItem(index);
      },
    );
  }

  Widget countryItem(int index,
      {String firstLetter = "", bool isSorted = false}) {
    //

    //
    return Consumer<MainProvider>(builder: ((context, data, child) {
      //
      String code;
      String name;
      String flag;
      bool isFavourited = false;

      // debugPrint("isi data getFavviy saat ini:");
      // debugPrint(data.getFavouritedCountries.toString());

      if (isSorted) {
        code = data.sortedCountries[firstLetter][index].code;
        name = data.sortedCountries[firstLetter][index].name;
        flag = data.sortedCountries[firstLetter][index].emoji;
        isFavourited =
            data.getFavouritedCountries.any((element) => element.code == code);
      } else {
        code = data.filterByContinents[index].code;
        name = data.filterByContinents[index].name;
        flag = data.filterByContinents[index].emoji;
        isFavourited =
            data.getFavouritedCountries.any((element) => element.code == code);
      }

      //
      makeAsFavourite() {
        if (isFavourited) {
          if (isSorted) {
            data.removeFromFavourite(data.sortedCountries[firstLetter][index]);
          } else {
            data.removeFromFavourite(data.filterByContinents[index]);
          }
          //
        } else {
          if (isSorted) {
            data.setAsFavourite(data.sortedCountries[firstLetter][index]);
          } else {
            data.setAsFavourite(data.filterByContinents[index]);
          }
          //
          final snackBar = SnackBar(
            content: Text("$flag $name added to favourites"),
            action: SnackBarAction(
                label: "see favourites",
                onPressed: () {
                  widget.pageController.animateToPage(1,
                      duration: Duration(milliseconds: 333),
                      curve: Curves.linear);
                }),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }

      return Card(
        elevation: isFavourited ? 0 : 5,
        child: ListTile(
          leading: Text(
            flag,
            style: const TextStyle(fontSize: 51),
          ),
          title: Text(name),
          trailing: IconButton(
              onPressed: () {
                makeAsFavourite();
              },
              icon: Icon(
                isFavourited ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              )),
          onTap: () {
            makeAsFavourite();
          },
        ),
      );
    }));
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, data, _) {
      if (data.getFavouritedCountries.length < 1) {
        return Center(
          child: Text("There's no favourited country"),
        );
      } else {
        return ListView.builder(
            itemCount: data.getFavouritedCountries.length,
            itemExtent: 101,
            itemBuilder: ((context, index) {
              String code = data.getFavouritedCountries[index].code;
              String flag = data.getFavouritedCountries[index].emoji;
              String name = data.getFavouritedCountries[index].name;
              //
              return Card(
                child: ListTile(
                  visualDensity: VisualDensity(vertical: 3),
                  leading: Text(
                    flag,
                    style: const TextStyle(fontSize: 61),
                  ),
                  title: Text(data.getFavouritedCountries[index].name),
                  trailing: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: Text("REMOVE CONFIRMATION"),
                                content: Text("""
are you sure want to remove $flag $name ?
"""),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("NO"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      //
                                      data.removeFromFavourite(
                                          data.getFavouritedCountries[index]);
                                      Navigator.pop(context);
                                    },
                                    child: Text("YES"),
                                  ),
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ),
              );
            }));
      }
    });
  }
}
