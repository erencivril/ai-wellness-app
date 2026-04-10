import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: const Text('Your Coaches'),
      ),
      body: BlocBuilder<CoachesCubit, CoachesState>(
        builder: (context, state) {
          if (state.status == CoachesStatus.loading ||
              state.status == CoachesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CoachesStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: state.coaches.length,
            itemBuilder: (context, index) {
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
          );
        },
      ),
    );
  }
}
