import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rtptun_app/controllers/log/log_screen_controller.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          Selector<LogScreenController, String>(
            selector: (_, controller) => controller.byteIn,
            builder: (context, bytes, child) {
              return Row(
                children: [
                  Text(
                    bytes,
                  ),
                  const Icon(Icons.download)
                ],
              );
            },
          ),
          const SizedBox(
            width: 20,
          ),
          Selector<LogScreenController, String>(
            selector: (_, controller) => controller.byteOut,
            builder: (context, bytes, child) {
              return Row(
                children: [
                  Text(
                    bytes,
                  ),
                  const Icon(Icons.upload)
                ],
              );
            },
          )
        ],
      ),
      body: Selector<LogScreenController, int>(
        selector: (_, LogScreenController controller) => controller.len,
        builder: (context, value, child) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: value,
            itemBuilder: (context, index) {
              return _ListItem(
                key: ValueKey(context.read<LogScreenController>().logs[index]),
                index: index,
              );
            },
          );
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final int index;
  const _ListItem({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myData = Provider.of<LogScreenController>(context);
    final item = myData.logs[index];
    return ListTile(
      title: Text(
        item,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
