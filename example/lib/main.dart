import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SwipeActionPage(
      ),
    );
  }
}

class Model {
  String id = UniqueKey().toString();
  int index;

  @override
  String toString() {
    return index.toString();
  }
}

class SwipeActionPage extends StatefulWidget {

  @override
  _SwipeActionPageState createState() => _SwipeActionPageState();
}

class _SwipeActionPageState extends State<SwipeActionPage> {
  List<Model> list = List.generate(15, (index) {
    return Model()..index = index;
  });

  SwipeActionEditController controller;

  @override
  void initState() {
    super.initState();
    controller = SwipeActionEditController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CupertinoButton.filled(
          child: Text('switch'),
          onPressed: () {
            controller.toggleEditingMode();
          }),
      appBar: CupertinoNavigationBar(
        leading: CupertinoButton.filled(
            padding: EdgeInsets.only(),
            minSize: 0,
            child: Text('delete cells', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ///获取选取的索引集合
              List<int> selectedIndexes = controller.getSelectedIndexPaths();

              List<String> idList = [];
              selectedIndexes.forEach((element) {
                idList.add(list[element].id);
              });

              ///遍历id集合，并且在原来的list中删除这些id所对应的数据
              idList.forEach((itemId) {
                list.removeWhere((element) {
                  return element.id == itemId;
                });
              });

              ///更新内部数据，这句话一定要写哦
              controller.deleteCellAt(indexPaths: selectedIndexes);
              setState(() {});
            }),
        trailing: CupertinoButton.filled(
            minSize: 0,
            padding: EdgeInsets.all(10),
            child: Text('select all'),
            onPressed: () {
              controller.selectAll(dataLength: list.length);
            }),
      ),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _item(index);
        },
      ),
    );
  }

  Widget _item(int index) {
    return SwipeActionCell(
      controller: controller,
      index: index,
      key: ValueKey(list[index]),
      performsFirstActionWithFullSwipe: true,
      actions: [
        SwipeAction(
            title: "delete",
            nestedAction: SwipeNestedAction(title: "confirm"),
            onTap: (handler) async {
              await handler(true);
              list.removeAt(index);
              setState(() {});
            }),
        SwipeAction(title: "action2", color: Colors.grey, onTap: (handler) {}),
      ],
      leadingActions: [
        SwipeAction(
            title: "delete",
            onTap: (handler) async {
              await handler(true);
              list.removeAt(index);
              setState(() {});
            }),
        SwipeAction(
            title: "action3", color: Colors.orange, onTap: (handler) {}),
      ],
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("This is index of ${list[index]}",
              style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }
}