import 'package:flutter/material.dart';

List<Color> backgroundColors = [

  const Color.fromARGB(255, 226, 124, 131),
  const Color.fromARGB(255, 240, 158, 158),
  const Color.fromARGB(255, 245, 183, 193),
  const Color.fromRGBO(174, 214, 232, 1),
  const Color.fromARGB(255, 98, 173, 211),
];

Map<String, int> categoryMap = {
  'Critical': 0,
  'Essential': 1,
  'Relevant': 2,
  'Routine': 3,
  'Trivial': 4,
};