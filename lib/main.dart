import 'package:duas_pwa/bloc/dua_bloc.dart';
import 'package:duas_pwa/cubit/theme_cubit.dart';
import 'package:duas_pwa/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:duas_pwa/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_html/js.dart' as js;

void main() {
  // make sure they are initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  /// theme repository to get stored theme value if any
  final ThemeRepository _themeRepository = ThemeRepository();

  /// dua repository to get duas
  final DuaRepository _duaRepository = DuaRepository();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // the purpose of future builder is to set the initial
    // theme of the webapp in corresopondence with the data
    // stored in local storage using [ThemeRepository]
    return FutureBuilder<String>(
        future: _themeRepository.getTheme(),
        builder: (context, snapshot) {
          // load the native theme data based on localstorage data
          if (snapshot.hasData) {
            js.context.callMethod('toggleTheme', [snapshot.data == "dark"]);
          }
          // show a page loader until we get data from our local
          // storage
          return (snapshot.hasData)
              // As we have multiple blocs therefore using MultiBlocProvider
              // to provide both ThemeBloc and DuaBloc to the application
              ? MultiBlocProvider(
                  providers: [
                    // theme bloc
                    BlocProvider<ThemeCubit>(
                      create: (context) =>
                          ThemeCubit(initialTheme: snapshot.data == "dark"),
                    ),
                    // dua bloc
                    BlocProvider<DuaBloc>(
                      create: (context) =>
                          DuaBloc(duaRepository: _duaRepository)
                            ..add(DuaFetched()),
                    ),
                  ],
                  // rebuild the entire material widget on theme changes
                  child: BlocBuilder<ThemeCubit, bool>(
                    builder: (context, isThemeDark) => MaterialApp(
                      title: titleEnglish,
                      theme: isThemeDark ? kDuaDarkTheme : kDuaLightTheme,
                      initialRoute: initialRoute,
                      debugShowCheckedModeBanner: false,
                      onGenerateRoute: AppRouter.generateRoute,
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator());
        });
  }
}
