### Language: 
[English](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README.md)
|[中文简体](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README-CN.md)

# flutter_swipe_action_cell

A package that can give you a cell that can be swiped ,effect is like iOS native

## Get started

##### pub home page click here: [pub](https://pub.dev/packages/flutter_swipe_action_cell)

##### install:
```yaml
flutter_swipe_action_cell: ^1.0.6
```  

## Preview：

Simple delete  | Perform first action when full swipe | 
-------- | -----
<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/1.gif?raw=true" width="250"  alt=""/> |<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/2.gif?raw=true" width="250"  alt=""/>
  


Delete with animation | More than one action | 
-------- | -----
 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/3.gif?raw=true" width="250"  alt=""/> | <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/4.gif?raw=true" width="250"  alt=""/>

Effect like WeChat(confirm delete) | Automatically adjust the button width
-------- | -----
<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/6.gif?raw=true" width="250"  alt=""/> | <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/7.gif?raw=true" width="250"  alt=""/>
 
 Effect like WeChat collection Page:Customize your button shape | 
-------- |
<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/9.gif?raw=true" width="300"  alt=""/>



Edit mode | 
-------- |
<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/8.GIF?raw=true" width="200"  alt=""/> |   
 

## Example

 - ##  Example 1:Simple delete the item in ListView

 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/1.gif?raw=true" width="250"  alt=""/>
  
 - #### Tip:put the code in the itemBuilder of your ListView
 
```dart
 SwipeActionCell(
      key: ObjectKey(list[index]),///this key is necessary
      actions: <SwipeAction>[
        SwipeAction(
            title: "delete",
            onTap: (CompletionHandler handler) async {
              list.removeAt(index);
              setState(() {});
            },
            color: Colors.red),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("this is index of ${list[index]}",
            style: TextStyle(fontSize: 40)),
      ),
    );
```

 - ##  Example 2:Perform first action when full swipe
 
  <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/2.gif?raw=true" width="250"  alt=""/>


 ```dart
 SwipeActionCell(
       ///this key is necessary
       key: ObjectKey(list[index]),
 
       ///this is the same as iOS native
       performsFirstActionWithFullSwipe: true,
       actions: <SwipeAction>[
         SwipeAction(
             title: "delete",
             onTap: (CompletionHandler handler) async {
               list.removeAt(index);
               setState(() {});
             },
             color: Colors.red),
       ],
       child: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Text("this is index of ${list[index]}",
             style: TextStyle(fontSize: 40)),
       ),
     );
 ```

 - ## Example 3:Delete with animation 
 
  
   <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/3.gif?raw=true" width="250"  alt=""/>


 ```dart
SwipeActionCell(
      key: ObjectKey(list[index]),
      performsFirstActionWithFullSwipe: true,
      actions: <SwipeAction>[
        SwipeAction(
            title: "delete",
            onTap: (CompletionHandler handler) async {
              
              /// await handler(true) : will delete this row
              ///And after delete animation,setState will called to 
              /// sync your data source with your UI

              await handler(true);
              list.removeAt(index);
              setState(() {});
            },
            color: Colors.red),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("this is index of ${list[index]}",
            style: TextStyle(fontSize: 40)),
      ),
    );
 ```

  - ## Example 4:More than one action: 
 
  
   <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/4.gif?raw=true" width="250"  alt=""/>


 ```dart
SwipeActionCell(
      key: ObjectKey(list[index]),

      performsFirstActionWithFullSwipe: true,
      actions: <SwipeAction>[
        SwipeAction(
            title: "delete",
            onTap: (CompletionHandler handler) async {
              await handler(true);
              list.removeAt(index);
              setState(() {});
            },
            color: Colors.red),

        SwipeAction(
            widthSpace: 120,
            title: "popAlert",
            onTap: (CompletionHandler handler) async {
              ///false means that you just do nothing,it will close
              /// action buttons by default
              handler(false);
              showCupertinoDialog(
                  context: context,
                  builder: (c) {
                    return CupertinoAlertDialog(
                      title: Text('ok'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text('confirm'),
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
            color: Colors.orange),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            "this is index of ${list[index]}",
            style: TextStyle(fontSize: 40)),
      ),
    );
 ```

  - ## Example 5:Delete like WeChat message page(need to confirm it:
    
    
   <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/6.gif?raw=true" width="250"  alt=""/>


    
```dart
return SwipeActionCell(
      key: ValueKey(list[index]),
      performsFirstActionWithFullSwipe: true,
      actions: <SwipeAction>[
        SwipeAction(
          ///
          ///This attr should be passed to first action
          ///
          nestedAction: SwipeNestedAction(title: "确认删除"),
          title: "删除",
          onTap: (CompletionHandler handler) async {
            await handler(true);
            list.removeAt(index);
            setState(() {});
          },
          color: Colors.red,
        ),
        SwipeAction(
            title: "置顶",
            onTap: (CompletionHandler handler) async {
              ///false means that you just do nothing,it will close
              /// action buttons by default
              handler(false);
            },
            color: Colors.grey),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("this is index of ${list[index]}",
            style: TextStyle(fontSize: 40)),
      ),
    );
```

- ## Example 6：Edit mode（just like iOS native effect）

<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/8.GIF?raw=true" width="200"  alt=""/>

```dart
/// To controller edit mode
 SwipeActionEditController controller;

///在initState
@override
  void initState() {
    super.initState();
    controller = SwipeActionController();
  }
///To get the selected rows index
List<int> selectedIndexes = controller.getSelectedIndexes();

///toggleEditingMode
controller.toggleEditingMode()

///startEditMode
controller.startEditingMode()

///stopEditMode
controller.stopEditingMode()


ListView.builder(
        itemBuilder: (c, index) {
          return _item(index);
        },
        itemCount: list.length,
      );


 Widget _item(int index) {
     return SwipeActionCell(
       ///controller
       controller: controller,
       ///index is required if you want to enter edit mode
       index: index,
       performsFirstActionWithFullSwipe: true,
       key: ValueKey(list[index]),
       actions: [
         SwipeAction(
             onTap: (handler) async {
               await handler(true);
               list.removeAt(index);
               setState(() {});
             },
             title: "delete"),
       ],
       child: Padding(
         padding: const EdgeInsets.all(15.0),
         child: Text("This is index of ${list[index]}",
             style: TextStyle(fontSize: 35)),
       ),
     );
   }

```


- ## Example 7：customize shape 
<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/9.gif?raw=true" width="250"  alt=""/>

```dart

Widget _item(int index) {
    return SwipeActionCell(
      key: ValueKey(list[index]),
      actions: [
        SwipeAction(
            nestedAction: SwipeNestedAction(
              ///customize your nested action content

              content: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.red,
                ),
                width: 130,
                height: 60,
                child: OverflowBox(
                  maxWidth: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Text('确认删除',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ),

            ///you should set the default  bg color to transparent
            color: Colors.transparent,

            ///set content instead of title of icon
            content: _getIconButton(Colors.red, Icons.delete),
            onTap: (handler) async {
              list.removeAt(index);
              setState(() {});
            }),
        SwipeAction(
            content: _getIconButton(Colors.grey, Icons.vertical_align_top),
            color: Colors.transparent,
            onTap: (handler) {}),
      ],
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
            "This is index of ${list[index]},Awesome Swipe Action Cell!! I like it very much!",
            style: TextStyle(fontSize: 25)),
      ),
    );
  }

  Widget _getIconButton(color, icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),

        ///set you real bg color in your content
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }

```


# About CompletionHandler in onTap function of SwipeAction
it means how you want control this cell after you tap it.
If you don't want any animation,just don't call it and update your data and UI with setState()

If you want some animation:
- handler(true) : Means this row will be deleted(You should call setState after it)

- await handler(true) : Means that you will await the animation to complete(you should call setState after it so that you will get an animation)

- handler(false) : means it will not delete this row.By default,it just close this cell's action buttons.

- await handler(false) : means it will wait the close animation to complete.

# About all parameter:
I wrote them in my code with dart doc comments.You can read them in
source code.

 


