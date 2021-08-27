import 'dart:convert';

import 'package:http/http.dart';

class Etablissement {
  String nom;
  String url;

  Etablissement({this.nom, this.url});

  factory Etablissement.fromJSON(Map<String, dynamic> json) => Etablissement(
        nom: json['name'],
        url: json['flop_url'],
      );

  ///Crée une [Map] à partir de l'objet.
  Map<String, dynamic> get toMap => {
        'nom': this.nom,
        'url': this.url,
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
      res.add(Etablissement(
        nom: eta['name'],
        url: eta['flop_url'],
      ));
    }
    return res;
  }
}