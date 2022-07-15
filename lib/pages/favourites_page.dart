import 'package:flutter/material.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';
import 'package:provider/provider.dart';

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
