class Country {
  late String code;
  late String name;
  late String flag;

  Country();

  Country.fromJson(Map<String, dynamic> json)
      : code = json["code"],
        name = json['name'],
        flag = json["emoji"];

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'flag': flag,
      };
}
