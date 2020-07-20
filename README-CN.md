Language: 
[English](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README.md)
|[中文简体](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README-CN.md)

# flutter_swipe_action_cell

一个可以提供iOS原生效果的列表侧滑库

## 为什么我想要这个库？
我喜欢iOS原生的侧滑效果，很爽，但是flutter并没有提供官方的组件，所以我尝试写一个

## 开始

 - #### Example 1:最简单的例子---删除
 
 ### (友情提示：这里应该有gif显示，如果看不到去[HomePage](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README.md))


<img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/1.gif" width="200"  alt=""/>

Tip：你把下面的放在你ListView的itemBuilder里面返回就行
```dart
 SwipeActionCell(
      ///这个key是必要的
      key: ObjectKey(list[index]),
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
     
 
 - #### Example 2:拉满将会执行第一个action
 
 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/2.gif" width="200"  alt=""/>

 ```dart
 SwipeActionCell(
        ///这个key需要
       key: ObjectKey(list[index]),
 
       ///参数名和iOS原生相同
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

 - #### Example 3:伴随动画的删除（按照iOS原生动画做的）
 
 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/3.gif" width="200"  alt=""/>
 
 ```dart
SwipeActionCell(
      ///这个key是必要的
      key: ObjectKey(list[index]),
      performsFirstActionWithFullSwipe: true,
      actions: <SwipeAction>[
        SwipeAction(
            title: "delete",
            onTap: (CompletionHandler handler) async {
              
              /// await handler(true) : 代表将会删除这一行
             ///在删除动画结束后，setState函数才应该被调用来同步你的数据和UI

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

 - #### Example 4:多于一个action
 
 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/4.gif" width="200"  alt=""/>

 
 ```dart
SwipeActionCell(
      ///这个key是必要的
      key: ObjectKey(list[index]),

      ///这个参数名以及其含义和iOS 原生的相同
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
              ///false 代表他不会删除这一行，默认情况下会关闭这个action button
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

 - #### Example 5：仿美团iOS端订单页删除效果
 
 <img src="https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/images/5.gif?raw=true" width="300"  alt=""/>

 #### 根据gif图可以判断，删除逻辑应该是这样的：
 - 1.点击或者拉动到最后触发删除动作
 - 2.关闭cell的按钮
 - 3.请求服务器删除，服务器返回删除成功
 - 4.触发删除动画，更新UI
 
 那么对应的例子如下：
 
```dart
Widget _item(int index) {
    return SwipeActionCell(
      ///this key is necessary
      key: ObjectKey(list[index]),

      ///this name is the same as iOS native
      performsFirstActionWithFullSwipe: true,
      actions: <SwipeAction>[
        SwipeAction(
            icon: Icon(Icons.add),
            title: "delete",
            onTap: (CompletionHandler handler) async {
              ///先关闭cell
              await handler(false);

              ///利用延时模拟请求网络的过程
              await Future.delayed(Duration(seconds: 1));

              ///准备执行删除动画，更新UI
              ///可以把handler当做参数传到其他地方去调用
              _remove(index, handler);
            },
            color: Colors.red),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("this the index of ${list[index]}",
            style: TextStyle(fontSize: 40)),
      ),
    );
  }

  void _remove(int index, CompletionHandler handler) async {
    ///在这里删除，删除后更新UI
    await handler(true);
    list.removeAt(index);
    setState(() {});
  }
 ```



# 关于 CompletionHandler 
它代表你在点击action之后如何操纵这个cell，如果你不想要任何动画，那么就不执行handler，而是直接更新你的数据，然后setState就行

如果你想要动画:
- handler(true) :代表这一行将会被删除（虽然UI上看不到那一行了，但是你仍然应该更新你的数据并且setState)

- await handler(true) :代表你将会等待删除动画执行完毕，你应该在这一行之后去执行setState，否则看不到动画（适合同步删除，也就是删除这个cell在业务上不需要服务器的参与） 

- handler(false) : 点击后内部不会有删除这一行的动作，默认地，他只会关闭这个action button
means it will not delete this row.By default,it just close this cell's action buttons.

- await handler(false) : 相比上面来说，他只会等待关闭动画结束

# 关于其他参数：
我已经在源码中用dart doc写的很清楚了，如果具体不清楚的可以直接点进去源码看注释，很详细。

#关于hot reload后没有达到预期效果
由于参数比较多所以可能在hot reload下可能出现不同步的问题，解决：
关掉抽屉，重新拉出，若还不行，直接hot restart


 


