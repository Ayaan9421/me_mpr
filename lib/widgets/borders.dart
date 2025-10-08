import 'package:flutter/material.dart';

final focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(
    width: 1.0,
    style: BorderStyle.solid,
    strokeAlign: BorderSide.strokeAlignInside,
  ),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

final errorBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.red,
    width: 1.0,
    style: BorderStyle.solid,
    strokeAlign: BorderSide.strokeAlignInside,
  ),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

final enabledBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.grey,
    width: 1.0,
    style: BorderStyle.solid,
    strokeAlign: BorderSide.strokeAlignInside,
  ),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

final focusedEnabledBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.red,
    width: 1.0,
    style: BorderStyle.solid,
    strokeAlign: BorderSide.strokeAlignInside,
  ),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);
