import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:junto_beta_mobile/app/bloc/app_bloc.dart';
import 'package:junto_beta_mobile/backend/backend.dart';
import 'package:junto_beta_mobile/backend/repositories/app_repo.dart';
import 'package:junto_beta_mobile/backend/repositories/onboarding_repo.dart';
import 'package:junto_beta_mobile/filters/bloc/channel_filtering_bloc.dart';
import 'package:junto_beta_mobile/models/expression_query_params.dart';
import 'package:junto_beta_mobile/screens/collective/bloc/collective_bloc.dart';
import 'package:junto_beta_mobile/screens/collective/perspectives/bloc/perspectives_bloc.dart';
import 'package:junto_beta_mobile/screens/groups/circles/bloc/circle_bloc.dart';
import 'package:junto_beta_mobile/screens/notifications/bloc/notification_bloc.dart';
import 'package:junto_beta_mobile/screens/welcome/bloc/bloc.dart';
import 'package:junto_beta_mobile/screens/global_search/relations_bloc/relation_bloc.dart';

class BlocProviders extends StatelessWidget {
  final Widget child;
  final Backend backend;
  const BlocProviders({
    Key key,
    @required this.backend,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (ctx) => AuthBloc(
            backend.client,
            ctx.read<AuthRepo>(),
            ctx.read<UserDataProvider>(),
            ctx.read<UserRepo>(),
            ctx.read<OnBoardingRepo>(),
            ctx.read<NotificationRepo>(),
          ),
        ),
        BlocProvider<NotificationSettingBloc>(
          create: (context) => NotificationSettingBloc(
            context.read<NotificationRepo>(),
          ),
        ),
        BlocProvider<PerspectivesBloc>(
          create: (ctx) => PerspectivesBloc(
            ctx.read<UserRepo>(),
            ctx.read<UserDataProvider>(),
          ),
        ),
        BlocProvider<CollectiveBloc>(
          create: (ctx) =>
              CollectiveBloc(RepositoryProvider.of<ExpressionRepo>(ctx)),
        ),
        BlocProvider<AppBloc>(
          create: (ctx) => AppBloc(RepositoryProvider.of<AppRepo>(context)),
        ),
        BlocProvider<RelationBloc>(
          create: (ctx) =>
              RelationBloc(ctx.read<UserRepo>(), ctx.read<UserDataProvider>()),
        ),
        BlocProvider<CircleBloc>(
          create: (ctx) => CircleBloc(
            RepositoryProvider.of<GroupRepo>(context),
            RepositoryProvider.of<UserRepo>(context),
            RepositoryProvider.of<UserDataProvider>(context),
            RepositoryProvider.of<NotificationRepo>(context),
          ),
        ),
        BlocProvider<ChannelFilteringBloc>(
          create: (ctx) => ChannelFilteringBloc(
            RepositoryProvider.of<SearchRepo>(ctx),
            (value) {
              BlocProvider.of<CollectiveBloc>(ctx).add(
                FetchCollective(
                  ExpressionQueryParams(
                    channels: value != null
                        ? value.map((e) => e.name).toList()
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
      child: child,
    );
  }
}
