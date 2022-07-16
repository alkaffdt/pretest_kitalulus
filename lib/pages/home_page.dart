import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';
import 'package:pretest_kitalulus_2/providers/root_provider.dart';
import 'package:pretest_kitalulus_2/widgets/floating_filter_button.dart';
import 'package:provider/provider.dart';

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
  ScrollController scroll = ScrollController();
  double filterbarOpacity = 1;
  //

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //
    addScrollListener();
  }

  @override
  Widget build(BuildContext context) {
    //
    return Center(
      child: Consumer<MainProvider>(
        builder: (context, data, _) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Expanded(child: datasView()),
              Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Opacity(
                        opacity: filterbarOpacity,
                        child: FloatingSortFilterButton()),
                  )),
            ],
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
      controller: scroll,
      itemCount: data.sortedCountries.length,
      // itemExtent: 100,
      padding: EdgeInsets.only(top: 95),
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
      controller: scroll,
      padding: EdgeInsets.only(top: 95),
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
                  Provider.of<RootProvider>(context, listen: false)
                      .changeToPage(1);
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

  addScrollListener() {
    scroll.addListener(() {
      double _recentPosition = scroll.position.pixels;

      debugPrint("posisi scroll saat ini");
      debugPrint(_recentPosition.toString());
      //
      if (_recentPosition <= 100 && _recentPosition > 0) {
        setState(() {
          filterbarOpacity = 1 - (_recentPosition * 0.01);
        });
        debugPrint("posisi opacity sekarang = " + filterbarOpacity.toString());
      } else if (_recentPosition <= 0) {
        setState(() {
          filterbarOpacity = 1;
        });
      }
    });
  }
}
