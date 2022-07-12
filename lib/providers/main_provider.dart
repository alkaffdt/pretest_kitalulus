import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  List _masterCountries = [];
  List _masterContinents = [];
  List _countries = [];
  List _continents = [];
  List _favouritedCountries = [];
  //
  bool isAlreadyFetched = false;
  //
  //

  List get getFavouritedCountries {
    return _favouritedCountries;
  }

  List get getCountries {
    List _sortedData = List.from(_countries);
    _sortedData.sort((a, b) => a["name"].compareTo(b["name"]));
    return _sortedData;
  }

  List get getContinents {
    return _continents;
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

  set fetchCountries(List<Map> continents) {
    // Obtaincountries preferences.
    _masterContinents = List.from(continents);
    _continents = List.from(continents);

    continents.forEach((countries) {
      countries["countries"].forEach((nation) {
        nation["continent"] = nation["continent"]["name"];
        _masterCountries.add(nation);
      });
    });

    _countries = List.from(_masterCountries);
    isAlreadyFetched = true;
    //
    fetchFavouritedCountries();
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

  removeFromFavourite(code) {
    //

    _favouritedCountries.removeWhere((element) => element == code);
    notifyListeners();
  }
}
