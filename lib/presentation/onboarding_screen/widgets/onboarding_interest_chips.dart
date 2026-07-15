import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/onboarding_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class OnboardingMultiSelectChips<T> extends StatelessWidget {
  const OnboardingMultiSelectChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: [
        for (final option in options)
          _ChipPill(
            label: labelOf(option),
            selected: selected.contains(option),
            onTap: () => onToggle(option),
          ),
      ],
    );
  }
}

class OnboardingSingleSelectChips<T> extends StatelessWidget {
  const OnboardingSingleSelectChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: [
        for (final option in options)
          _ChipPill(
            label: labelOf(option),
            selected: selected == option,
            onTap: () => onSelect(option),
          ),
      ],
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: AppTypography.fontSubtitle.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppTheme.surface : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Convenience wrapper for interest chips (keeps file name from plan).
class OnboardingInterestChips extends StatelessWidget {
  const OnboardingInterestChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<OnboardingInterest> selected;
  final ValueChanged<OnboardingInterest> onToggle;

  @override
  Widget build(BuildContext context) {
    return OnboardingMultiSelectChips<OnboardingInterest>(
      options: OnboardingInterest.values,
      selected: selected,
      labelOf: (e) => e.label,
      onToggle: onToggle,
    );
  }
}
