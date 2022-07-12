import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  List _masterCountries = [];
  List _countries = [];
  List _favouritedCountries = [];
  //
  bool isAlreadyFetched = false;
  //
  //

  List get getFavouritedCountries {
    return _favouritedCountries;
  }

  List get getCountries {
    return _countries;
  }

  set fetchCountries(data) {
    // Obtain shared preferences.

    _countries = List.from(data);
    _masterCountries = List.from(data);
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

    debugPrint("isi _countries di provider");
    debugPrint(_countries.toString());

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
