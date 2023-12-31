import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masoiree/core/widgets/layout.dart';
import 'package:masoiree/core/widgets/loading_overlay.dart';
import 'package:masoiree/features/authentication/authentication_page.dart';
import 'package:masoiree/features/authentication/models/group/group.dart';
import 'package:masoiree/features/games/game_cards_page/game_cards_page.dart';
import 'package:masoiree/features/games/game_modes_page/game_modes_page.dart';
import 'package:masoiree/features/games/game_play_page/game_play_page.dart';
import 'package:masoiree/features/games/games_page/games_page.dart';
import 'package:masoiree/features/home/home_page/home_page.dart';

CustomTransitionPage<dynamic> _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Change the opacity of the screen using a Curve based on the the animation's
      // value
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}

GoRouter router(Group? group) {
  return GoRouter(routes: [
    if (group == null)
      GoRoute(
        path: "/",
        builder: (context, state) => const AuthenticationPage(),
        pageBuilder: (context, state) =>
            _buildPageWithDefaultTransition(context: context, state: state, child: const LoadingOverlay(child: AuthenticationPage())),
      )
    else
      GoRoute(
          path: "/",
          builder: (context, state) => const PageLayout(child: LoadingOverlay(child: HomePage())),
          pageBuilder: (context, state) =>
              _buildPageWithDefaultTransition(context: context, state: state, child: const LoadingOverlay(child: PageLayout(child: HomePage()))),
          routes: [
            GoRoute(
                path: "games",
                builder: (context, state) => const PageLayout(
                        child: LoadingOverlay(
                            child: GamesPage(
                      mode: GamesPageMode.editing,
                    ))),
                pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                    context: context,
                    state: state,
                    child: const LoadingOverlay(
                        child: PageLayout(
                            child: GamesPage(
                      mode: GamesPageMode.editing,
                    )))),
                routes: [
                  GoRoute(
                      path: ":id",
                      builder: (context, state) => PageLayout(
                              child: LoadingOverlay(
                                  child: GameCardsPage(
                            gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                          ))),
                      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                          context: context,
                          state: state,
                          child: LoadingOverlay(
                              child: PageLayout(
                                  child: GameCardsPage(
                            gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                          )))),
                      routes: [
                        GoRoute(
                          path: "modes",
                          builder: (context, state) => PageLayout(
                              child: LoadingOverlay(
                                  child: GameModesPage(
                            gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                          ))),
                          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                              context: context,
                              state: state,
                              child: LoadingOverlay(
                                  child: PageLayout(
                                      child: GameModesPage(
                                gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                              )))),
                        )
                      ])
                ]),
            GoRoute(
                path: "play",
                builder: (context, state) => const PageLayout(
                        child: LoadingOverlay(
                            child: GamesPage(
                      mode: GamesPageMode.playing,
                    ))),
                pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                      context: context,
                      state: state,
                      child: const LoadingOverlay(
                          child: PageLayout(
                              child: GamesPage(
                        mode: GamesPageMode.playing,
                      ))),
                    ),
                routes: [
                  GoRoute(
                      path: ":id",
                      builder: (context, state) => PageLayout(
                              child: LoadingOverlay(
                                  child: GamePlayPage(
                            gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                            modeID: int.tryParse(state.uri.queryParameters["mode"] ?? ""),
                          ))),
                      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                          context: context,
                          state: state,
                          child: LoadingOverlay(
                              child: PageLayout(
                                  child: GamePlayPage(
                            gameID: int.tryParse(state.pathParameters["id"] as String) ?? 0,
                            modeID: int.tryParse(state.uri.queryParameters["mode"] ?? ""),
                          ))))),
                ]),
          ])
  ]);
}
