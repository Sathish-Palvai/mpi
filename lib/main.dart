import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'l10n/app_localizations.dart';
import 'core/themes.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/settings/bloc/settings_bloc.dart';
import 'features/settings/bloc/settings_state.dart';
import 'features/language/bloc/language_bloc.dart';
import 'app/dashboard/bloc/dashboard_bloc.dart';
import 'app/dashboard/dashboard_screen.dart';
import 'app/home/home_screen.dart';
import 'app/login/login_screen.dart';
import 'app/interface/interface_screen.dart';
import 'app/switching/switching_screen.dart';
import 'app/reports/reports_screen.dart';
import 'app/settings/settings_screen.dart';
import 'app/dashboard/resource_detail_screen.dart';
import 'app/dashboard/forms/participant/participant_update_screen.dart';
import 'app/dashboard/forms/participant/participant_create_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ja'), Locale('es')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
    // Initialize centralized notification service once for the app
    // so WebSocket connection is created at startup.
    // This keeps notifications available across all pages.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // lazily init the notification connection
        // ignore: avoid_dynamic_calls
        NotificationService.instance.init();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => AuthBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (BuildContext context) => SettingsBloc(),
        ),
        BlocProvider<LanguageBloc>(
          create: (BuildContext context) => LanguageBloc(),
        ),
        BlocProvider<DashboardBloc>(
          create: (BuildContext context) => DashboardBloc(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          // Only rebuild when authentication status actually changes
          return (previous is AuthAuthenticated) !=
              (current is AuthAuthenticated);
        },
        builder: (context, authState) {
          return BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              // Update EasyLocalization when locale changes in SettingsBloc
              if (state is SettingsLoaded) {
                context.setLocale(state.locale);
              }
            },
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
                final fontSize = settingsState is SettingsLoaded
                    ? settingsState.fontSize
                    : FontSize.medium;
                final themeMode = settingsState is SettingsLoaded
                    ? settingsState.themeMode
                    : ThemeMode.system;

                return MaterialApp.router(
                  title: 'MPI',
                  theme: AppThemes.lightTheme,
                  darkTheme: AppThemes.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: [
                    ...context.localizationDelegates,
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  routerConfig: _router,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: fontSize.scaleFactor,
                      ),
                      child: child!,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isGoingToLogin = state.fullPath == '/login';

        // If not authenticated and not going to login, redirect to login
        if (!isAuthenticated && !isGoingToLogin) {
          return '/login';
        }

        // If authenticated and going to login, redirect to home
        if (isAuthenticated && isGoingToLogin) {
          return '/';
        }

        // No redirect needed
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/home',
          redirect: (context, state) => '/', // Redirect /home to /
        ),
        GoRoute(
          path: '/interface',
          builder: (BuildContext context, GoRouterState state) {
            return const InterfaceScreen();
          },
        ),
        GoRoute(
          path: '/switching',
          builder: (BuildContext context, GoRouterState state) {
            return const SwitchingScreen();
          },
        ),
        GoRoute(
          path: '/reports',
          builder: (BuildContext context, GoRouterState state) {
            return const ReportsScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: '/dashboard/add-participant',
          builder: (BuildContext context, GoRouterState state) {
            return const ParticipantCreateScreen();
          },
        ),
        GoRoute(
          path: '/participant-config',
          builder: (BuildContext context, GoRouterState state) {
            final participantData = state.extra as Map<String, dynamic>;
            return ParticipantUpdateScreen(participant: participantData);
          },
        ),
        GoRoute(
          path: '/resource-detail',
          builder: (BuildContext context, GoRouterState state) {
            final resourceData = state.extra as Map<String, dynamic>;
            return ResourceDetailScreen(resource: resourceData);
          },
        ),
      ],
    );
  }
}
