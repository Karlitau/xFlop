import 'package:xFlop/components/cours_widget.dart';
import 'package:xFlop/utils.dart';
import 'package:flutter/material.dart';

class EDTViewer extends StatelessWidget {
  final Map coursesMap;

  const EDTViewer({Key key, this.coursesMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: true,
      children: buildCourses(context),
    );
  }

  List<Widget> buildCourses(BuildContext context) {
    List<Widget> grid = [];
    Map<dynamic, dynamic> map = coursesMap;
    var delay = 1.0;
    map.forEach((index, cours) {
      delay += 0.6;
      grid.add(
        Row(
          children: <Widget>[
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width - 30,
              margin: EdgeInsets.only(bottom: 5, top: 5),
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        heures[index][0],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        heures[index][1],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    child: (cours != null)
                        ? CoursWidget(
                            cours: cours,
                            delay: delay,
                          )
                        : Container(), //Vide s'il n'y a pas de cours
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
    return grid;
  }
}
