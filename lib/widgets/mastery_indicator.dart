import 'package:flutter/material.dart';

class MasteryIndicator extends StatelessWidget {
  final double mastery;

  const MasteryIndicator({super.key, required this.mastery});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: LinearProgressIndicator(
        value: mastery,
        backgroundColor: Colors.grey[800],
        color:
            mastery > 0.7
                ? Colors.green
                : mastery > 0.3
                ? Colors.orange
                : Colors.red,
      ),
    );
  }
}
