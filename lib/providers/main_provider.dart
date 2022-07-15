import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:pretest_kitalulus_2/models/country_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  List<Countries> _masterCountries = [];
  List<Continents> _masterContinents = [];
  List<Countries> _countries = [];
  List<Countries> _favouritedCountries = [];
  //
  GraphqlStatus graphqlStatus = GraphqlStatus.isLoading;
  //
  ViewStatus viewStatus = ViewStatus.sort;
  String _filteredContinentCode = "";
  //
  //
  //
  //
  //

  fetchCountries() async {
    _masterContinents = await connectToGraphql();
    debugPrint("isi _masterContinent model baru : ");
    debugPrint(_masterContinents[0].countries[0].name);

    await fetchFavouritedCountries();

    // _masterContinents.forEach((countries) {
    //   countries["countries"].forEach((nation) {
    //     nation["continent"] = nation["continent"]["name"];
    //     _masterCountries.add(nation);
    //   });
    // });

    _masterContinents.forEach((_continent) {
      _masterCountries.addAll(_continent.countries);
    });

    _countries = List.from(_masterCountries);
    graphqlStatus = GraphqlStatus.completed;
    //
    notifyListeners();
  }

  Future connectToGraphql() async {
    Future.delayed(Duration(seconds: 5));
    const String _query = """
      query{
  continents{
    code
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
        code
    }
  }
  }
}
    """;

    final _httpLink = HttpLink(
      "https://countries.trevorblades.com/",
    );

    final GraphQLClient client = GraphQLClient(

        /// **NOTE** The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(),
        link: _httpLink);

    final QueryOptions options = QueryOptions(document: gql(_query));

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
      graphqlStatus = GraphqlStatus.error;
    }

    if (result.isLoading) {
      graphqlStatus = GraphqlStatus.isLoading;
    }

    debugPrint("isi result.data['continents']");
    debugPrint(result.data!["continents"].runtimeType.toString());

    return Data.fromJson(result.data!).continents;

    // _masterContinents = result.data!["continents"] as List<dynamic>;
  }

  List<Countries> get getFavouritedCountries {
    return _favouritedCountries;
  }

  List<Countries> get getCountries {
    List<Countries> _sortedData = List.from(_countries);
    _sortedData.sort((a, b) => a.name.compareTo(b.name));
    return _sortedData;
  }

  Map get sortedCountries {
    Map<String, List> _sortedByLetter = {};
    //
    getCountries.forEach((item) {
      String firstLetter = item.name.substring(0, 1);

      if (_sortedByLetter.containsKey(firstLetter)) {
        _sortedByLetter[firstLetter]?.add(item);
      } else {
        _sortedByLetter[firstLetter] = [];
        _sortedByLetter[firstLetter]?.add(item);
      }
    });

    return _sortedByLetter;
  }

  setContinentCode(String code) {
    viewStatus = ViewStatus.filter;
    _filteredContinentCode = code;
    notifyListeners();
  }

  List<Continents> get getContinents {
    return _masterContinents;
  }

  List<Countries> get filterByContinents {
    List<Countries> _filtered = [];
    //
    Continents _cont = _masterContinents
        .firstWhere((continent) => continent.code == _filteredContinentCode);

    _filtered = _cont.countries;

    return _filtered;
  }

  findCountry(keyword) {
    //
    viewStatus = ViewStatus.sort;
    //
    _countries = _masterCountries
        .where((item) => item.name.toLowerCase().contains(keyword))
        .toList();

    notifyListeners();
  }

  //

  set updateCountries(countries) {
    _countries = List.from(countries);
  }

  resetCountries() {
    //
    _countries = _masterCountries;
    notifyListeners();
  }

  sortCountries() {
    //
    viewStatus = ViewStatus.sort;
    notifyListeners();
  }

  //

  fetchFavouritedCountries() async {
    // Obtain stored datas.
    final prefs = await SharedPreferences.getInstance();
    String? storedData = await prefs.getString("storedCountries4");
    debugPrint("isi storedData");
    debugPrint(storedData);
    List<dynamic> _temp = [];
    List<Countries> _convertedTemp = [];

    if (storedData != null) {
      _temp = jsonDecode(storedData);
      _temp.forEach((item) {
        debugPrint(
            "{jumlah = ${_temp.length}}isi item dari hasil konversi JSON :");
        debugPrint(item.toString());
        Countries _convertedToModel = Countries.fromJson(item);
        _convertedTemp.add(_convertedToModel);
      });
    }

    _favouritedCountries = List.from(_convertedTemp);

    // notifyListeners();
  }

  setAsFavourite(code) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    List _convertedList = [];
    //
    _favouritedCountries.add(code);
    _favouritedCountries.forEach((item) {
      _convertedList.add(Countries.toMap(item));
    });
    //
    prefs.setString("storedCountries4", jsonEncode(_convertedList));
    notifyListeners();
  }

  removeFromFavourite(Countries country) async {
    //
    final prefs = await SharedPreferences.getInstance();

    _favouritedCountries.removeWhere((element) => element.name == country.name);
    prefs.setString("storedCountries4", jsonEncode(_favouritedCountries));
    notifyListeners();
  }
}

enum ViewStatus { sort, filter }

// enum Continents { asia, africa, europe, america, australia, all }

enum GraphqlStatus { completed, error, isLoading }
