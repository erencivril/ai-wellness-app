import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../coaches/data/repositories/coach_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/history_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(getIt<HistoryRepository>())..loadHistory(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(topPadding: top),
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state.status == HistoryStatus.loading ||
                    state.status == HistoryStatus.initial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.status == HistoryStatus.error) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'Something went wrong',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                if (state.sessions.isEmpty) {
                  return _EmptyHistory();
                }

                final coaches = getIt<CoachRepository>().loadCoaches();

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => context.read<HistoryCubit>().loadHistory(),
                  child: ListView.separated(
                    itemCount: state.sessions.length,
                    separatorBuilder: (_, __) => const Divider(
                      indent: 20,
                      endIndent: 20,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final coach = coaches.firstWhere(
                        (c) => c.id == session.coachId,
                        orElse: () => coaches.first,
                      );
                      return HistoryTile(
                        session: session,
                        onTap: () => context.pushNamed(
                          RouteNames.resumeChat,
                          pathParameters: {'sessionId': session.id},
                          extra: {'coach': coach, 'sessionId': session.id},
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.topPadding});
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Wellness',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Chat\n',
                  style: GoogleFonts.fraunces(
                    fontSize: 46,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'History',
                  style: GoogleFonts.fraunces(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
                color: AppColors.surfaceWarm,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 30,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No sessions yet',
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your coaching sessions will appear here after your first conversation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
