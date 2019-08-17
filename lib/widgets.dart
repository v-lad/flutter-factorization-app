import 'package:flutter/material.dart';
import 'package:rts_factorization/styles.dart';


class PageInfo extends StatelessWidget {

  PageInfo({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              "${'\t'*4}" + this.text,
              style: Styles.infoText,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}