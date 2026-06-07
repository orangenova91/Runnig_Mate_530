import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels = const [],
  });

  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primary : AppTheme.border,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: 24,
                    height: 2,
                    color: index < currentStep
                        ? AppTheme.primary
                        : AppTheme.border,
                  ),
              ],
            );
          }),
        ),
        if (labels.isNotEmpty && currentStep < labels.length) ...[
          const SizedBox(height: 12),
          Text(
            'Step ${currentStep + 1}/$totalSteps · ${labels[currentStep]}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
          ),
        ],
      ],
    );
  }
}
