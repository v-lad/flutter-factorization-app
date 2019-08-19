import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class ChartXLabelStyle {

  ChartXLabelStyle({
    this.fontSize,
    this.color,
  });

  final num fontSize;
  final charts.MaterialPalette color;

  dynamic build() {
    return charts.OrdinalAxisSpec(
       renderSpec: charts.SmallTickRendererSpec(
        labelStyle: charts.TextStyleSpec(
          fontSize: this.fontSize ?? 13,
          color: this.color ?? charts.MaterialPalette.gray.shade400,
        )
      )
    );
  }
}


class ChartYLabelStyle {

  ChartYLabelStyle({
    this.fontSize,
    this.color,
  });

  final num fontSize;
  final charts.MaterialPalette color;

  dynamic build() {
    return charts.NumericAxisSpec(
       renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
          fontSize: this.fontSize ?? 13,
          color: this.color ?? charts.MaterialPalette.gray.shade400,
        )
      )
    );
  }
}
