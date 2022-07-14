import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  List _masterCountries = [];
  List _masterContinents = [];
  List _countries = [];
  List _favouritedCountries = [];
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
    await connectToGraphql();

    fetchFavouritedCountries();

    _masterContinents.forEach((countries) {
      countries["countries"].forEach((nation) {
        nation["continent"] = nation["continent"]["name"];
        _masterCountries.add(nation);
      });
    });

    _countries = List.from(_masterCountries);
    graphqlStatus = GraphqlStatus.completed;
    //
    notifyListeners();
  }

  connectToGraphql() async {
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

    _masterContinents = result.data!["continents"] as List<dynamic>;
  }

  List get getFavouritedCountries {
    return _favouritedCountries;
  }

  List get getCountries {
    List _sortedData = List.from(_countries);
    _sortedData.sort((a, b) => a["name"].compareTo(b["name"]));
    return _sortedData;
  }

  Map get sortedCountries {
    Map<String, List> _sortedByLetter = {};
    //
    getCountries.forEach((item) {
      String firstLetter = item["name"].substring(0, 1);

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

  List get getContinents {
    return _masterContinents;
  }

  List get filterByContinents {
    List _filtered = [];
    //
    Map _cont = _masterContinents
        .firstWhere((continent) => continent["code"] == _filteredContinentCode);

    _filtered = _cont["countries"];

    return _filtered;
  }

  fetchFavouritedCountries() async {
    // Obtain stored datas.
    final prefs = await SharedPreferences.getInstance();
    String? storedData = await prefs.getString("storedCountries");

    if (storedData != null) {
      _favouritedCountries =
          jsonDecode(prefs.getString("storedCountries").toString()) as List;
    }
  }

  findCountry(keyword) {
    //
    viewStatus = ViewStatus.sort;
    //
    _countries = _masterCountries
        .where((item) => item["name"].toLowerCase().contains(keyword))
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

  setAsFavourite(code) async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    //
    _favouritedCountries.add(code);
    //
    prefs.setString("storedCountries", jsonEncode(_favouritedCountries));
    notifyListeners();
  }

  removeFromFavourite(Map country) async {
    //
    final prefs = await SharedPreferences.getInstance();

    _favouritedCountries
        .removeWhere((element) => element["code"] == country["code"]);
    prefs.setString("storedCountries", jsonEncode(_favouritedCountries));
    notifyListeners();
  }
}

enum ViewStatus { sort, filter }

enum Continents { asia, africa, europe, america, australia, all }

enum GraphqlStatus { completed, error, isLoading }
