import 'dart:convert';

import 'package:http/http.dart';

class Etablissement {
  String nom;
  String url;
  String logo;

  Etablissement({this.nom, this.url, this.logo});

  factory Etablissement.fromJSON(Map<String, dynamic> json) => Etablissement(
        nom: json['name'] == null
            ? (json['nom'] == null ? null : json['nom'])
            : json['name'],
        url: json['flop_url'] == null
            ? (json['url'] == null ? null : json['url'])
            : json['name'],
        logo: json['logo'] == null
            ? 'null'
            : json['logo']['url'] == null
                ? json['logo']
                : json['logo']['url'],
      );

  ///Crée une [Map] à partir de l'objet.
  Map<String, dynamic> get toMap => {
        'nom': this.nom,
        'url': this.url,
        'logo': this.logo,
      };

  ///Retourne une chaîne JSON de l'objet.
  String get toJSON => jsonEncode(this.toMap);

  ///Méthode d'affichage de [Etablissement]
  @override
  String toString() {
    return this.toJSON;
  }

  ///Méthode statique créant une liste de [Etablissement] à partir d'une réponse HTTP.
  static Future<List<Etablissement>> createListFromResponse(
      Response response) async {
    var etablissements = jsonDecode(utf8.decode(response.bodyBytes));
    var res = <Etablissement>[];
    for (var eta in etablissements) {
      res.add(Etablissement.fromJSON(
        eta,
      ));
    }
    return res;
  }
}
