import 'package:graphql/client.dart';
import 'package:pretest_kitalulus_2/models/country_model.dart';
import 'package:pretest_kitalulus_2/providers/main_provider.dart';

class ApiServices {
  //

  static final _httpLink = HttpLink(
    "https://countries.trevorblades.com/",
  );

  static const String _query = """
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

  static final QueryOptions options = QueryOptions(document: gql(_query));

  static Future connectToGraphql() async {
    print("masuk connectTographql");
    //

    final GraphQLClient client = GraphQLClient(

        /// **NOTE** The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(),
        link: _httpLink);

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
      // graphqlStatus = GraphqlStatus.error;
    }

    if (result.isLoading) {
      // graphqlStatus = GraphqlStatus.isLoading;
    }

    return Data.fromJson(result.data!).continents;

    // _masterContinents = result.data!["continents"] as List<dynamic>;
  }
}
