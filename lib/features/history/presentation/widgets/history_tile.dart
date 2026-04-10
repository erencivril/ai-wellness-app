import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../../chat/data/models/chat_session.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.session,
    required this.onTap,
  });

  final ChatSession session;
  final VoidCallback onTap;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return DateFormat('h:mm a').format(date);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.05),
        highlightColor: AppColors.surfaceWarm.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _CoachInitial(name: session.coachName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          session.coachName,
                          style: GoogleFonts.fraunces(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(session.updatedAt),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    if (session.lastMessage != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        session.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachInitial extends StatelessWidget {
  const _CoachInitial({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primaryContainer),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
