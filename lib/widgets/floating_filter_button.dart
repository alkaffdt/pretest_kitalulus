import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/main_provider.dart';

class FloatingSortFilterButton extends StatelessWidget {
  const FloatingSortFilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return floatingButtons(context);
  }

  Widget button(
      {required String label, required icon, required ontap, isRight = false}) {
    return SizedBox(
      height: 55,
      width: 155,
      child: TextButton.icon(
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.lightBlue),
              // padding: MaterialStateProperty.all<EdgeInsets>(
              //     EdgeInsets.symmetric(horizontal: 55)),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 16, 105, 179)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: isRight
                    ? BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15))
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topLeft: Radius.circular(15)),
              ))),
          onPressed: ontap,
          icon: Icon(
            icon,
            color: Colors.white,
          ),
          label: Text(
            label,
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Widget floatingButtons(BuildContext context) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        button(
            label: "filter",
            icon: Icons.filter_alt,
            ontap: () {
              var data = Provider.of<MainProvider>(context, listen: false);
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text("select a continent"),
                      content: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.71,
                        child: ListView.builder(
                            itemCount: data.getContinents.length,
                            // shrinkWrap: true,
                            itemBuilder: (context, index) {
                              String nameContinent =
                                  data.getContinents[index].name;
                              return ListTile(
                                leading: Icon(Icons.map),
                                title: Text(nameContinent),
                                onTap: () {
                                  data.setContinentCode(
                                      data.getContinents[index].code);
                                  //
                                  Navigator.pop(context);
                                },
                              );
                            }),
                      ),
                    );
                  });
            }),
        Container(
          width: 1,
          height: 55,
          color: Colors.white,
        ),
        button(
            label: "sort",
            icon: Icons.sort,
            ontap: () {
              var data = Provider.of<MainProvider>(context, listen: false);
              data.sortCountries();
            },
            isRight: true),
      ]),
    );
  }
}
