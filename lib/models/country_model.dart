class AutoGenerate {
  AutoGenerate({
    required this.data,
  });
  late final Data data;

  AutoGenerate.fromJson(Map<String, dynamic> json) {
    data = Data.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.toJson();
    return _data;
  }
}

class Data {
  Data({
    required this.continents,
  });
  late final List<Continents> continents;

  Data.fromJson(Map<String, dynamic> json) {
    continents = List.from(json['continents'])
        .map((e) => Continents.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['continents'] = continents.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Continents {
  Continents({
    required this.code,
    required this.name,
    required this.countries,
  });
  late final String code;
  late final String name;
  late final List<Countries> countries;

  Continents.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    countries =
        List.from(json['countries']).map((e) => Countries.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['name'] = name;
    _data['countries'] = countries.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Countries {
  Countries({
    required this.code,
    required this.emoji,
    required this.name,
    required this.states,
    required this.languages,
    required this.continent,
  });
  late final String code;
  late final String emoji;
  late final String name;
  late final List<States> states;
  late final List<Languages> languages;
  late final Continent continent;

  Countries.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    emoji = json['emoji'];
    name = json['name'];
    states = List.from(json['states']).map((e) => States.fromJson(e)).toList();
    languages =
        List.from(json['languages']).map((e) => Languages.fromJson(e)).toList();
    continent = Continent.fromJson(json['continent']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['emoji'] = emoji;
    _data['name'] = name;
    _data['states'] = states.map((e) => e.toJson()).toList();
    _data['languages'] = languages.map((e) => e.toJson()).toList();
    _data['continent'] = continent.toJson();
    return _data;
  }

  static Map<String, dynamic> toMap(Countries country) => {
        'code': country.code,
        'emoji': country.emoji,
        'name': country.name,
        'states': country.states,
        'languages': country.languages,
        'continent': country.continent
      };
}

class States {
  States({
    required this.name,
  });
  late final String name;

  States.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    return _data;
  }
}

class Languages {
  Languages({
    required this.name,
    required this.native,
  });
  late final String name;
  late final String native;

  Languages.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    native = json['native'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['native'] = native;
    return _data;
  }
}

class Continent {
  Continent({
    required this.code,
    required this.name,
  });
  late final String code;
  late final String name;

  Continent.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['name'] = name;
    return _data;
  }
}
