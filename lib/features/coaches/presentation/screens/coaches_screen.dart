import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../data/repositories/coach_repository.dart';
import '../cubit/coaches_cubit.dart';
import '../cubit/coaches_state.dart';
import '../widgets/coach_card.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoachesCubit(getIt<CoachRepository>())..loadCoaches(),
      child: const _CoachesView(),
    );
  }
}

class _CoachesView extends StatelessWidget {
  const _CoachesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CoachesCubit, CoachesState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              if (state.status == CoachesStatus.loading ||
                  state.status == CoachesStatus.initial)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                )
              else if (state.status == CoachesStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.errorMessage ?? 'Something went wrong',
                      style: const TextStyle(color: AppColors.creamMuted),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final coach = state.coaches[index];
                        return CoachCard(
                          coach: coach,
                          onTap: () => context.pushNamed(
                            RouteNames.newChat,
                            pathParameters: {'coachId': coach.id},
                            extra: coach,
                          ),
                        );
                      },
                      childCount: state.coaches.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(24, top + 20, 24, 28),
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
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Wellness',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gold,
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
                  text: 'Your\n',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 46,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.cream,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: 'Coaches',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose your guide for today',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.sageDim,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
