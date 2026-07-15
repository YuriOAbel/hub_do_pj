import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:consulta_cnpj_new/core/utils/app_typography.dart';
import 'package:consulta_cnpj_new/domain/models/app_notification_model.dart';
import 'package:consulta_cnpj_new/theme/app_theme.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.item,
    required this.relativeTime,
    required this.onTap,
  });

  final AppNotificationModel item;
  final String relativeTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(3.5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.shadowLight.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 4.5.w,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontSubtitle.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      item.body,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontBody.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      relativeTime,
                      style: GoogleFonts.inter(
                        fontSize: AppTypography.fontBody.sp,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.read) ...[
                SizedBox(width: 2.w),
                Padding(
                  padding: EdgeInsets.only(top: 1.w),
                  child: Container(
                    width: 2.2.w,
                    height: 2.2.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
