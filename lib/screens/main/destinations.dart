part of 'main.dart';

class _Destination {
  const _Destination(this.index, this.title, this.icon, this.color, this.page);
  final int index;
  final String title;
  final IconData icon;
  final MaterialColor color;
  final Widget page;
}

const List<_Destination> _allDestinations = <_Destination>[
  _Destination(0, 'Home', Icons.home, Colors.teal, HomeScreen()),
  _Destination(1, 'Log', Icons.event_note, Colors.cyan, Text('data')),
];
