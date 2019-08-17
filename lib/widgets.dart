import 'package:flutter/material.dart';
import 'package:rts_factorization/styles.dart';


class PageTitle extends StatelessWidget {

  PageTitle({@required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        this.title,
        style: Styles.titleTextStyle
      ),
    );
  }
}


class PageSubtitle extends StatelessWidget {

  const PageSubtitle({@required this.text, this.marginTop, this.marginBottom});

  final String text;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: this.marginTop ?? 0, bottom: this.marginBottom ?? 0),
      child: Text(
        this.text,
        style: Styles.subtitleTextStyle
      ),
    );
  }
}


class PageInfo extends StatelessWidget {

  PageInfo({
    @required this.text, 
    this.style, 
    this.paddingLeft, 
    this.paddingRight, 
    this.align,
  });

  final String text;
  final TextStyle style;
  final double paddingLeft;
  final double paddingRight;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: this.paddingLeft ?? 6.0, right: this.paddingRight ?? 6.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              this.text,
              style: this.style ?? Styles.infoTextStyle,
              textAlign: this.align ?? TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}


class SupportFlatButtonText extends StatelessWidget {

  SupportFlatButtonText({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FlatButton(
        child: Text(
          this.text,
          style: Styles.flatButtonStyle,
        ),
        onPressed: null,
        padding: EdgeInsets.all(0),
      ),
      width: 20.0,
    );
  }
}