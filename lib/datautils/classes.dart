import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../database.dart';

class ClassesPage extends StatefulWidget {
  final String code;
  final String title;
  final int crn;
  final double av;
  const ClassesPage({Key? key, required this.code, required this.title, required this.crn, required this.av}) : super(key: key);

  @override
  _ClassesPageState createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  List professors = [];
  String stdDev = "";
  String perc = "";
  bool render_courses = false;
  bool render_stats = false;
  bool render_profs = false;
  String goodProf = "";
  String badProf = "";

  @override
  void initState() {
    super.initState();
    pop();
  }

  void pop() async {
    await newGetData("profs");
    await newGetData("stats");
    await newGetData("best");
  }

  Future newGetData(String Cat) async {
    if (Cat == "profs") {
      var response = await http.post(
        Uri.parse(flaskPath + "/classes"),
        headers: {"Accept": "application/json", "Access-Control-Allow-Origin": "*"},
        body: {
          "cat": Cat,
          "crn": widget.crn.toString(),
        },
      );
      var datafromJSON = json.decode(response.body) as List<dynamic>;
      professors = datafromJSON;
      setState(() {
        render_courses = true;
      });
    }
    if (Cat == "stats") {
      var response = await http.post(
        Uri.parse(flaskPath + "/classes"),
        headers: {"Accept": "application/json", "Access-Control-Allow-Origin": "*"},
        body: {
          "cat": Cat,
          "crn": widget.crn.toString(),
        },
      );
      var datafromJSON = json.decode(response.body) as List<dynamic>;
      stdDev = datafromJSON[0]['std'].toString();
      perc = datafromJSON[0]['perc'].toString();
      setState(() {
        render_stats = true;
      });
    }
    if (Cat == "best") {
      var response = await http.post(
        Uri.parse(flaskPath + "/classes"),
        headers: {"Accept": "application/json", "Access-Control-Allow-Origin": "*"},
        body: {
          "cat": Cat,
          "crn": widget.code,
        },
      );
      var datafromJSON = json.decode(response.body);
      goodProf = datafromJSON['b1']['firstName'] != null ? datafromJSON['b1']['firstName'] + ' ' + datafromJSON['b1']['lastName'] : "None";
      badProf = datafromJSON['b2']['firstName'] + ' ' + datafromJSON['b2']['lastName'];
      setState(() {
        render_profs = true;
      });
    }
    return "successful";
  }

  @override
  Widget build(BuildContext context) {
    DataRow _getDataRow(data) {
      return DataRow(
        cells: <DataCell>[
          DataCell(Text(data["firstName"] + " " + data["lastName"])),
          DataCell(Text(data["semester"])),
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_left),
          ),
          Column(
            children: <Widget>[
              Align(
                child: Container(
                  child: Text("Course Title : " + widget.title),
                ),
              ),
              Align(
                child: Container(
                  child: Text("Course Code : " + widget.code),
                ),
              ),
              Align(
                child: Container(
                  child: Text("CRN: " + widget.crn.toString()),
                ),
              ),
              Align(
                child: Container(
                  child: Text("Average Score : " + widget.av.toString()),
                ),
              ),
              Align(
                child: Container(
                  child: render_stats ? Text("Standard Deviation : " + stdDev) : Text(""),
                ),
              ),
              Align(
                child: Container(
                  child: render_stats ? Text("Percentage of 4.0's achieved : " + perc) : Text(""),
                ),
              ),
              Align(
                child: Container(
                  child: render_profs ? Text("Best professor teaching Course with >=4.0 rating : " + goodProf) : Text(""),
                ),
              ),
              Align(
                child: Container(
                  child: render_profs ? Text("Best professor teaching Course with <4.0 rating : " + badProf) : Text(""),
                ),
              ),
              Align(
                child: Container(
                  child: render_courses
                      ? SingleChildScrollView(
                          child: DataTable(
                            columns: [
                              DataColumn(
                                  label: Container(
                                child: Text(
                                  "Professor Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataColumn(
                                  label: Container(
                                child: Text(
                                  "Semester taught",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                            rows: List.generate(professors.length, (index) => (_getDataRow(professors[index]))),
                          ),
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
