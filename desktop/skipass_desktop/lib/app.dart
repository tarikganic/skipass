import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell.dart';
import 'services/auth_service.dart';
import 'services/benefit_service.dart';
import 'services/engagement_service.dart';
import 'services/reference_data_service.dart';
import 'services/report_service.dart';
import 'services/resort_service.dart';
import 'services/order_service.dart';
import 'services/user_service.dart';

/// Korijenski widget desktop aplikacije: registruje sve servise i providere,
/// te bira izmedju prijave i glavnog okvira prema stanju autentifikacije.
class SkiPassDesktopApp extends StatelessWidget {
  const SkiPassDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient(), dispose: (_, client) => client.dispose()),
        Provider<AuthService>(create: (context) => AuthService(context.read<ApiClient>())),
        Provider<ReferenceDataService>(create: (context) => ReferenceDataService(context.read<ApiClient>())),
        Provider<ResortService>(create: (context) => ResortService(context.read<ApiClient>())),
        Provider<OrderService>(create: (context) => OrderService(context.read<ApiClient>())),
        Provider<BenefitService>(create: (context) => BenefitService(context.read<ApiClient>())),
        Provider<EngagementService>(create: (context) => EngagementService(context.read<ApiClient>())),
        Provider<UserService>(create: (context) => UserService(context.read<ApiClient>())),
        Provider<ReportService>(create: (context) => ReportService(context.read<ApiClient>())),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(apiClient: context.read<ApiClient>(), authService: context.read<AuthService>())..restoreSession(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(context.read<EngagementService>()),
        ),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()..restore()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: 'SkiPass Administracija',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;

    return switch (status) {
      AuthStatus.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const MainShell(),
    };
  }
}
