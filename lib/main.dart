// import 'dart:html';
// import 'dart:io';
// import 'dart:html';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink("https://countries.trevorblades.com/");

    ValueNotifier<GraphQLClient> client =
        ValueNotifier(GraphQLClient(cache: GraphQLCache(), link: httpLink));

    return GraphQLProvider(
      client: client,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MainProvider())
        ],
        child: const MaterialApp(
          title: 'Country App',
          debugShowCheckedModeBanner: false,
          home: RootPage(),
        ),
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
  bool alreadyFetched = false;
  //
  Widget appbarTitle = const Text("Country App");
  final PageController pageController = PageController();
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
            children: [floatingButtons(), Expanded(child: datasView(data))],
          ),
        ),
      ),
    );
  }

  Widget filteredByContinents(String code) {
    return Consumer<MainProvider>(builder: (context, data, child) {
      return ListView.builder(itemBuilder: ((context, continent) {
        return Container(
            // bikin slider pake nama/gambar benua
            );
      }));
    });
  }

  Widget datasView(MainProvider data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: data.isAlreadyFetched ? listViewCountries(data) : fetchQuery(data),
    );
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
            onPressed: () {},
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
        button(label: "filter", icon: Icons.filter_alt, ontap: () {}),
        button(label: "sort", icon: Icons.sort, ontap: () {}, isRight: true),
      ]),
    );
  }

  Widget fetchQuery(MainProvider data) {
    String _query = """
      query{
  continents{
    name
    countries{
    code
    emoji
    name
    states{
      name
    }
    languages{
      name
      native
    }
    continent{
        name
    }
  }
  }
}
    """;
    //
    return Query(
      options: QueryOptions(document: gql(_query)),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        //
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return SizedBox(
            height: 51,
            width: 51,
            child: CircularProgressIndicator(),
          );
        }

        //
        debugPrint("isi data");
        debugPrint(result.data?.keys.toString());

        List? _countries = result.data!["continents"];

        if (_countries == null || _countries.length < 1) {
          return const Text("data not found");
        }

        updateData(data, _countries);

        return listViewCountries(data);
      },
    );
  }

  listViewCountries(MainProvider data) {
    return ListView.builder(
      itemCount: data.sortedCountries.length,
      // itemExtent: 100,
      itemBuilder: (context, indexLetter) {
        String firstLetter = data.sortedCountries.keys.elementAt(indexLetter);
        //
        debugPrint("isi countries per-huruf '${firstLetter}' :");
        debugPrint(data.sortedCountries[indexLetter].toString());

        return Container(
          child: Column(
            children: [
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
                    return countryItem(indexCountry, firstLetter);
                  }),
              Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget countryItem(int index, String firstLetter) {
    //

    //
    return Consumer<MainProvider>(builder: ((context, data, child) {
      List _countries = List.from(data.getFavouritedCountries);
      //
      String code = data.sortedCountries[firstLetter][index]["code"];
      String name = data.sortedCountries[firstLetter][index]["name"];
      String flag = data.sortedCountries[firstLetter][index]["emoji"];
      bool isFavourited = _countries.contains(data.getCountries[index]);
      //
      makeAsFavourite() {
        if (isFavourited) {
          data.removeFromFavourite(data.sortedCountries[firstLetter][index]);
          //

        } else {
          data.setAsFavourite(data.sortedCountries[firstLetter][index]);
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

  Future updateData(MainProvider data, List countries) async {
    data.fetchCountries = List.from(countries);
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
              String code = data.getFavouritedCountries[index]["code"];
              String flag = data.getFavouritedCountries[index]["emoji"];
              String name = data.getFavouritedCountries[index]["name"];
              //
              return Card(
                child: ListTile(
                  visualDensity: VisualDensity(vertical: 3),
                  leading: Text(
                    flag,
                    style: const TextStyle(fontSize: 61),
                  ),
                  title: Text(data.getFavouritedCountries[index]["name"]),
                  trailing: IconButton(
                      onPressed: () {
                        data.removeFromFavourite(
                            data.getFavouritedCountries[index]["code"]);

                        final snackBar = SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content:
                              Text("are you sure want to remove $flag $name ?"),
                          action: SnackBarAction(
                              label: "confirm",
                              onPressed: () {
                                // widget.pageController.animateToPage(1,
                                //     duration: Duration(milliseconds: 333),
                                //     curve: Curves.easeIn);
                                data.removeFromFavourite(
                                    data.getFavouritedCountries[index]);
                              }),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
