import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/helpers/firebase_analytics_helper.dart';
import 'package:consulta_cnpj_new/presentation/shared/widgets/cnpj_primary_button.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class EvaluationScreen extends ConsumerStatefulWidget {
  const EvaluationScreen({super.key});

  @override
  ConsumerState<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends ConsumerState<EvaluationScreen> {
  double _rating = 0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await FirebaseAnalyticsHelper.instance.logAvaliou();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obrigado pelo feedback!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar app')),
      body: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            SvgPicture.asset('assets/images/evaluation_page.svg', width: 50.w),
            SizedBox(height: 3.h),
            Text(
              'Como você avalia o app?',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              itemBuilder: (_, __) =>
                  Icon(Icons.star, color: AppTheme.warning),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Deixe seu comentário (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 3.h),
            CnpjPrimaryButton(
              enabled: _rating > 0,
              onPressed: _submit,
              child: Text('Enviar',
                  style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
