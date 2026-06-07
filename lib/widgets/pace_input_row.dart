import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaceInputRow extends StatelessWidget {
  const PaceInputRow({
    super.key,
    required this.minutesController,
    required this.secondsController,
  });

  final TextEditingController minutesController;
  final TextEditingController secondsController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            decoration: const InputDecoration(
              hintText: '5',
              labelText: '분',
              counterText: '',
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("'", style: TextStyle(fontSize: 24)),
        ),
        Expanded(
          child: TextField(
            controller: secondsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            decoration: const InputDecoration(
              hintText: '42',
              labelText: '초',
              counterText: '',
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('/km', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
