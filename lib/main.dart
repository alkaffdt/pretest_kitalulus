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
                duration: Duration(milliseconds: 333), curve: Curves.bounceIn);
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
          child: data.isAlreadyFetched
              ? listViewCountries(data)
              : fetchQuery(data),
        ),
      ),
    );
  }

  Widget fetchQuery(MainProvider data) {
    String _query = """
          query{
          countries{
            code
            emoji
            name
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
          return const CircularProgressIndicator();
        }

        //
        debugPrint("isi data");
        debugPrint(result.data?.keys.toString());

        List? _countries = result.data!["countries"];

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
      itemCount: data.getCountries.length,
      // itemExtent: 100,
      itemBuilder: (context, index) {
        return countryItem(index);
      },
    );
  }

  Widget countryItem(int index) {
    //

    //
    return Consumer<MainProvider>(builder: ((context, data, child) {
      List _countries = List.from(data.getFavouritedCountries);
      //
      String code = data.getCountries[index]["code"];
      String name = data.getCountries[index]["name"];
      String flag = data.getCountries[index]["emoji"];
      bool isFavourited = _countries.contains(data.getCountries[index]);
      //
      makeAsFavourite() {
        if (isFavourited) {
          data.removeFromFavourite(data.getCountries[index]);
          //

        } else {
          data.setAsFavourite(data.getCountries[index]);
          //
          final snackBar = SnackBar(
            content: Text("$flag $name added to favourites"),
            action: SnackBarAction(
                label: "see favourites",
                onPressed: () {
                  widget.pageController.animateToPage(1,
                      duration: Duration(milliseconds: 333),
                      curve: Curves.easeIn);
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
                            data.getCountries[index]["code"]);

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
