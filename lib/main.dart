import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favourites = <WordPair>[]; // This initializes a list in the app state.

  void toggleFavourite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var navigationMenuTextStyle = GoogleFonts.poppins(
        textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0));

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            extended: constraints.maxWidth >= 600,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text(
                    'Home',
                    style: navigationMenuTextStyle,
                  )),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text(
                    'Favourites',
                    style: navigationMenuTextStyle,
                  )),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          )
        ],
      ));
    });
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favourites.isEmpty) {
      return Center(
        child: Text(
          'No favourites yet.',
          style: GoogleFonts.poppins(
              textStyle:
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('You have '
              '${appState.favourites.length} favourites.'),
        ),
        for (var pair in appState.favourites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          )
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    var buttonTextStyle = GoogleFonts.poppins(
        textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0));

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        BigCard(pair: pair),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                },
                icon: Icon(icon),
                label: Text(
                  'Like',
                  style: buttonTextStyle,
                )),
            SizedBox(
              width: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text(
                  'Next',
                  style: buttonTextStyle,
                )),
          ],
        )
      ]),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = GoogleFonts.poppins(
        textStyle: TextStyle(
      color: theme.colorScheme.onPrimary,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
    ));

    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
