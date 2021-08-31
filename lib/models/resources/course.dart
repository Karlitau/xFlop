import 'dart:convert';
import 'dart:ffi';

import 'package:flop_edt_app/models/resources/tutor.dart';
import 'package:flop_edt_app/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'day.dart';

///Classe [Cours] permettant de représenter en objet
///un cours retourné par l'API.
class Cours {
  final int id;
  Tutor enseignant;
  final String enseignantInitial;
  final String groupe;
  final String promo;
  final String module;
  final String name;
  final String type;
  final String salle;
  final Color backgroundColor;
  final Color textColor;
  final int startTimeFromMidnight;
  final int duration;
  final int indexInWeek;
  final DateTime dateEtHeureDebut;
  final DateTime dateEtHeureFin;

  @override
  String toString() {
    var formatted = DateFormat.yMd().add_jm().format(dateEtHeureDebut);
    return '<$type $module : $enseignant à $formatted>';
  }

  Cours(
      {this.id,
      this.enseignant,
      this.enseignantInitial,
      this.groupe,
      this.promo,
      this.module,
      this.name,
      this.type,
      this.salle,
      this.backgroundColor,
      this.textColor,
      this.startTimeFromMidnight,
      this.duration,
      this.indexInWeek,
      this.dateEtHeureDebut,
      this.dateEtHeureFin});
/*
  factory Cours.fromJSON(Map<String, dynamic> json) => Cours(
        id: json['id'],
        enseignant: json['enseignant'],
        module: json['module'],
        groupe: json['group'],
        promo: json['promo'],
        type: json['type'],
        salle: json['salle'],
        backgroundColor: ColorUtils.fromHex(json['background']),
        textColor: ColorUtils.fromHex(json['text']),
        startTimeFromMidnight: int.parse(json['start']),
        duration: json['duration'],
        indexInWeek: json['index_in_week'],
        dateEtHeureDebut: DateTime.parse(json['date']),
        dateEtHeureFin: DateTime.parse(json['date'])
            .add(Duration(minutes: json['duration'])),
      );
*/
  factory Cours.fromJSON(Map<String, dynamic> json, year, week) => Cours(
        id: json['id'],
        enseignantInitial: json['tutor'] ?? "??",
        module: json['course']['module']['abbrev'] ?? "??",
        name: json['course']['module']['name'] ?? "??",
        groupe: json['course']['groups'][0]['name'],
        promo: json['course']['groups'][0]['train_prog'],
        type: json['course']['type'],
        salle: json['room'] != null
            ? json['room']
            : (json['is_visio'] != null ? "??" : "visio"),
        backgroundColor:
            ColorUtils.fromHex(json['course']['module']['display']['color_bg']),
        textColor: ColorUtils.fromHex(
            json['course']['module']['display']['color_txt']),
        startTimeFromMidnight: json['start_time'],
        duration: 90,
        indexInWeek: ["m", "tu", "w", "th", "f"].indexOf(json['day']),
        dateEtHeureDebut: Day.getCompleteWeek(
                year: year,
                week: week)[["m", "tu", "w", "th", "f"].indexOf(json['day'])]
            .date
            .add(Duration(minutes: json['start_time'])),
        dateEtHeureFin: Day.getCompleteWeek(
                year: year,
                week: week)[["m", "tu", "w", "th", "f"].indexOf(json['day'])]
            .date
            .add(Duration(minutes: json['start_time'] + 90)),
      );

  ///Crée une liste de [Cours] à partir de la réponse API.
  static List<Cours> createListFromResponse(Response response, year, week) {
    var courses = jsonDecode(response.body);
    var toReturn = <Cours>[];
    courses.forEach(
        (dynamic json) => toReturn.add(Cours.fromJSON(json, year, week)));
    return toReturn;
  }

  ///Crée une liste de [Cours] à partir de la réponse API.
  static List<Cours> createListFromResponses(
      Response response, Response responseTutors, year, week) {
    var courses = jsonDecode(utf8.decode(response.bodyBytes));
    var toReturn = <Cours>[];
    courses.forEach(
        (dynamic json) => toReturn.add(Cours.fromJSON(json, year, week)));

    var tutors = Tutor.createListFromResponse(responseTutors);
    toReturn.forEach((cours) {
      tutors.forEach((tutor) {
        if (cours.enseignantInitial == tutor.initiales) {
          cours.enseignant = tutor;
        }
        if (cours.enseignantInitial == '??') {
          cours.enseignant = Tutor(
              initiales: cours.enseignantInitial,
              nom: '??',
              prenom: '??',
              mail: '??');
        }
      });
    });
    toReturn.forEach((element) {
      if (element.enseignant == null) {
        element.enseignant = Tutor(
            initiales: element.enseignantInitial,
            nom: '??',
            prenom: '??',
            mail: '??');
      }
    });
    return toReturn;
  }

  ///Retourne vrai si le cours est un examen, faux sinon
  bool get isExam =>
      this.type == 'DS' ||
      this.type == 'Examen' ||
      this.type == 'Exam' ||
      this.type == 'CTRL' ||
      this.type == 'CTRLP';

  void displayInformations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: this.backgroundColor,
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(2)),
              Text(this.module,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: this.textColor,
                  )),
              Text(
                this.name,
                style: TextStyle(
                  fontSize: 16,
                  color: this.textColor,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        IconData(58330, fontFamily: 'MaterialIcons'),
                        color: Colors.black,
                      ),
                      Text(
                        'Salle',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ]),
                    Text(
                      this.type,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Center(
                      child: Text(
                        this.salle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ])),
              SizedBox(
                height: 16,
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      IconData(62753, fontFamily: 'MaterialIcons'),
                      color: Colors.black,
                    ),
                    Text(
                      'Enseignant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ]),
                  Text(
                    this.enseignant.initiales,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    this.enseignant.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    this.enseignant.mail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  _contactButton(context, this.enseignant.mail),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _contactButton(BuildContext context, String recipient) => Container(
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            primary: this.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            padding: EdgeInsets.all(10),
          ),
          onPressed: () {
            send(recipient, context);
          },
          icon: Icon(
            IconData(63081, fontFamily: 'MaterialIcons'),
            color: this.textColor,
          ),
          label: Text(
            'Contacter l\'enseignant',
            style: TextStyle(color: this.textColor, fontSize: 16),
          ),
        ),
      );

  Future<void> send(String recipient, BuildContext context) async {
    final Email email = Email(
      recipients: [recipient],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    // if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }
}
