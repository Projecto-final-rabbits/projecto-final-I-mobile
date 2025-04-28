import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart' as di;
import 'core/router/router.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = di.sl<AuthCubit>();
    final router = createRouter(authCubit);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => authCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'CPP App',
            theme: _getThemeData(Brightness.light, state.textSize),
            darkTheme: _getThemeData(Brightness.dark, state.textSize),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }

  ThemeData _getThemeData(Brightness brightness, TextSize textSize) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
    );

    // Apply text size factor
    // double textScaleFactor;
    // switch (textSize) {
    //   case TextSize.small:
    //     textScaleFactor = 0.85;
    //     break;
    //   case TextSize.large:
    //     textScaleFactor = 1.2;
    //     break;
    //   case TextSize.medium:
    //     textScaleFactor = 1.0;
    //     break;
    // }

    final defaultTextTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      textTheme: defaultTextTheme.apply(fontSizeFactor: 1),
    );
  }
}
