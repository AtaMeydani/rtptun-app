part of 'main.dart';

LogScreenController _logScreenController = LogScreenController();

List<Destination> _allDestinations = <Destination>[
  Destination(
    0,
    'Home',
    Icons.home,
    ChangeNotifierProvider<HomeScreenController>(
      create: (BuildContext context) => HomeScreenController(
        repository: context.read<Repository>(),
        logScreenController: _logScreenController,
      ),
      child: const HomeScreen(),
    ),
  ),
  Destination(
    1,
    'Log',
    Icons.event_note,
    ChangeNotifierProvider(
      create: (BuildContext context) => _logScreenController,
      child: const LogScreen(),
    ),
  ),
];
