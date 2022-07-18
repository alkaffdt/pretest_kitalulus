import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretest_kitalulus_2/models/country_model.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';
import 'package:pretest_kitalulus_2/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:graphql/client.dart' as graphql;

class ApiTest extends Mock implements graphql.GraphQLClient {}

void main() {
  MainProvider provider = MainProvider();
  List<Continents> masterContinents = [];
  //
  final client = ApiTest();

  setupProvider() async {
    MainProvider provider = MainProvider();
    masterContinents = await ApiServices.connectToGraphql();
  }

  setUp(() async {
    await setupProvider();
    WidgetsFlutterBinding.ensureInitialized();
  });
  //

  // group("fetching data using graphql", () {
  //   test("the request should complete", () async {
  //     when(client.query(ApiServices.options)).thenAnswer((_) async => );
  //   });
  // });

  group("country test", () {
    Countries country;
    //
    test("indonesia should be exist", () async {
      const countryName = "Indonesia";
      country = await findAcountry(masterContinents, "Indonesia");
      expect(country.name, "Indonesia");
    });

    test("check indonesia language", () async {
      country = await findAcountry(masterContinents, "Indonesia");
      Languages language = country.languages[0];
      //
      expect(language.native, "Bahasa Indonesia");
    });

    test("check an indonesia's region", () async {
      country = await findAcountry(masterContinents, "Indonesia");
      const region = "East Java";
      bool isExist = country.states
              .firstWhere((element) => element.name == region)
              .name
              .length >
          1;

      expect(isExist, true);
    });
  });
}

//
//
//

Future<Countries> findAcountry(
    List<Continents> _masterContinents, String keyword) async {
  Countries found = Countries(
      code: "kosong",
      emoji: "",
      name: "kosong",
      states: <States>[],
      languages: <Languages>[],
      continent: Continent(code: "", name: ""));

  _masterContinents.forEach((_cont) {
    _cont.countries.forEach((country) {
      if (country.name.toLowerCase() == keyword.toLowerCase()) {
        found = country;
      }
    });
  });

  return found;
}
