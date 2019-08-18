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
    this.isSizeMin,
  });

  final String text;
  final TextStyle style;
  final double paddingLeft;
  final double paddingRight;
  final TextAlign align;
  final bool isSizeMin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: this.paddingLeft ?? 6.0, right: this.paddingRight ?? 6.0),
      child: Row(
        mainAxisSize: (this.isSizeMin ?? false) ? MainAxisSize.min : MainAxisSize.max,
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


class ActionRoundedButton extends StatelessWidget {

  ActionRoundedButton({
    @required this.name,
    @required this.onPressed,
    this.style,
    this.paddingVer,
    this.paddingHor,
    this.marginVer,
    this.marginHor,
    this.icon,
    this.disabledColor,
  });

  final String name;
  final GestureTapCallback onPressed;
  final TextStyle style;
  final double paddingVer;
  final double paddingHor;
  final double marginVer;
  final double marginHor;
  final Icon icon;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    bool isIcon = icon != null;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: this.marginVer ?? 20, horizontal: this.marginHor ?? 0),
      child: RaisedButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            this.icon ?? Container(color: Colors.white), 
            isIcon ? SizedBox(width: 8) : Container(color: Colors.white),
            Text(
              this.name,
              style: this.style ?? TextStyle(fontSize: 20),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: this.paddingVer ?? 16, horizontal: this.paddingHor ?? 24),
        color: Theme.of(context).accentColor,
        elevation: 1.0,
        splashColor: Colors.limeAccent,
        shape: StadiumBorder(),
        onPressed: this.onPressed,
        disabledColor: Color(0xff777777),
      ),
    );
  }
}


class CustomTextInput extends StatelessWidget {

  CustomTextInput({
    @required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.alignLabel,
    this.autofocus,
    this.keyboardType,
    this.style,
    this.wFactor,
    this.helperStyle,
    this.labelStyle,
    this.align,
    this.enabled,
    this.controller,
    this.hintStyle,
  });

  final Function onChanged;
  final String label;
  final String hint;
  final String helperText;
  final bool alignLabel;
  final double wFactor;
  final TextStyle style;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextStyle helperStyle;
  final TextStyle labelStyle;
  final TextAlign align;
  final bool enabled;
  final TextEditingController controller;
  final TextStyle hintStyle;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: this.wFactor ?? 0.9,
      child: TextField(
        autofocus: this.autofocus ?? false,
        keyboardType: this.keyboardType ?? TextInputType.number,
        onChanged: this.onChanged,

        decoration: InputDecoration(
          labelText: this.label,
          labelStyle: this.labelStyle ?? Styles.labelTextStyle,
          hintText: this.hint,
          hintStyle: this.hintStyle ?? Styles.hintTextStyle,
          alignLabelWithHint: this.alignLabel ?? false,
          helperText: this.helperText,
          helperStyle: Styles.helperTextStyle ?? this.helperStyle,
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffcccccc)))
        ),

        style: this.style ?? Styles.inputTextStyle,
        textAlign: this.align ?? TextAlign.start,
        enabled: this.enabled ?? true,
        controller: this.controller,
      ),
    );
  }
}