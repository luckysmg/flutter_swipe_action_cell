import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() {
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CupertinoButton.filled(
            child: Text('Enter new page'),
            onPressed: () {
              Navigator.push(context,
                  CupertinoPageRoute(builder: (c) => SwipeActionPage()));
            }),
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
  List<Model> list = List.generate(30, (index) {
    return Model()..index = index;
  });

  SwipeActionController controller;

  @override
  void initState() {
    super.initState();
    controller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      print(
          'cell at ${changedIndexPaths.toString()} is/are ${selected ? 'selected' : 'unselected'} ,current selected count is $currentCount');

      ///I just call setState() to update simply in this example.
      ///But the whole page will be rebuilt.
      ///So when you are developing,you'd better update a little piece
      ///of UI sub tree for best performance....

      setState(() {});
    });
  }

  Widget bottomBar() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: CupertinoButton.filled(
                  padding: EdgeInsets.only(),
                  child: Text('open cell at 2'),
                  onPressed: () {
                    controller.openCellAt(
                        index: 2, trailing: true, animated: true);
                  }),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: CupertinoButton.filled(
                  padding: EdgeInsets.only(),
                  child: Text('switch edit mode'),
                  onPressed: () {
                    controller.toggleEditingMode();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomBar(),
      appBar: CupertinoNavigationBar(
        middle: CupertinoButton.filled(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            minSize: 0,
            child: Text('deselect all', style: TextStyle(fontSize: 22)),
            onPressed: () {
              controller.deselectAll();
            }),
        leading: CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            minSize: 0,
            child: Text(
                'delete cells (${controller.getSelectedIndexPaths().length})',
                style: TextStyle(color: Colors.white)),
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
          return _item(context, index);
        },
      ),
    );
  }

  Widget _item(BuildContext ctx, int index) {
    return SwipeActionCell(
      controller: controller,
      index: index,
      key: ValueKey(list[index]),

      ///animation default value below...
      normalAnimationDuration: 500,
      deleteAnimationDuration: 400,
      performsFirstActionWithFullSwipe: true,
      trailingActions: [
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
      child: GestureDetector(
        onTap: () {
          Scaffold.of(ctx)
            ..showSnackBar(SnackBar(
              content: Text(
                'tap',
              ),
              duration: const Duration(seconds: 1),
            ));
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("This is index of ${list[index]}",
              style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }
}
