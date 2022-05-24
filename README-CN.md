 # flutter_swipe_action_cell
 一个强大的列表项侧滑库

### 如果你喜欢这个库，不要吝啬你的star😀，这个项目的star越多，说明这个库越受欢迎，使用的人越多，我也就会花更多的时间在这个库上。
 
 ### Language: 
 [English](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README.md)
 | [中文简体](https://github.com/luckysmg/flutter_swipe_action_cell/blob/master/README-CN.md)
 
 <br/>
 
 #### QQ交流群（估计还没什么人）：892912160 
 
 #### 从 3.0.0 版本开始支持flutter 3
 
 和框架有关问题,无论是新功能探索，开发，bug提出，还是有关建议都可以发群里交流，只要我有时间，我很乐意帮助大家(^▽^)
 

## 直接进入正题:

#### pub 仓库点这里： [pub](https://pub.dev/packages/flutter_swipe_action_cell)
#### 安装：
```yaml
flutter_swipe_action_cell: ^3.0.2
```

 <br/>
 

### 效果预览（gif可能比较大，稍微等一下）：

简单删除 | 拉满执行第一个action | 
-------- | -----
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/1.gif?raw=true" width="250"  alt=""/> | <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/2.gif?raw=true" width="250"  alt=""/>


伴随动画删除 | 多于一个action的样式 | 
-------- | -----
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/3.gif?raw=true" width="250"  alt=""/> | <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/4.gif?raw=true" width="250"  alt=""/>

仿微信确认删除交互 | 仿微信确认删除自动调整按钮大小 
-------- | -------- 
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/6.gif?raw=true" width="250"  alt=""/>|<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/7.gif?raw=true" width="250"  alt=""/>|

仿微信收藏页 自定义按钮形状交互 | 
-------- |
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/9.gif?raw=true" width="300"  alt=""/>

支持左侧按钮和右侧的按钮 | 
-------- |
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/10.gif?raw=true" width="300"  alt=""/> |



编辑模式 (GIF 较大） | 
-------- |
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/8.gif?raw=true" width="200"  alt=""/>|


###  目前已经实现的内容 ：
- [x] 支持左右两边拉出的按钮
- [x] 拉出按钮，顺滑的拉出动画和回弹动画
- [x] 支持iOS原生的弹出按钮触发第一个动作交互
- [x] 支持拉出另外一个按钮时关闭已经打开的按钮
- [x] 支持滚动时关闭已经打开的按钮
- [x] 支持删除时的折叠动画
- [x] 支持微信iOS端消息列表确认删除功能
- [x] 支持自定义按钮内容，形状，颜色等。
- [x] 支持仿iOS原生列表编辑模式交互，多选，全选，取消全选，获取选中项等多种操作
- [x] 支持只使用编辑模式，通过设置取消侧滑参数，防止和TabView或PageView手势冲突
- [x] 支持全局配置页面路由切换时关闭此时正打开的cell菜单


## 最完整的例子（几乎涵盖所有常用api）:
[完整效果预览 （西瓜视频）](https://v.ixigua.com/JAqWvNM/)
你可以点击 [example page](https://pub.dev/packages/flutter_swipe_action_cell/example) 来看实现full example的完整代码

<br/>

### 下面分隔出来的小例子

 - ## Example 1:最简单的例子---删除
 
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/1.gif?raw=true" width="300"  alt=""/>

 - ##### Tip：你把下面的放在你ListView的itemBuilder里面返回就行
```dart
 SwipeActionCell(
      ///这个key是必要的
      key: ValueKey(list[index]),
      trailingActions: <SwipeAction>[
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
     
 
 - ## Example 2:拉满将会执行第一个action
 
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/2.gif?raw=true" width="300"  alt=""/>

 ```dart
 SwipeActionCell(
       key: ValueKey(list[index]),
       trailingActions: <SwipeAction>[
         SwipeAction(
             ///参数名和iOS原生相同
             performsFirstActionWithFullSwipe: true,
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

 - ## Example 3:伴随动画的删除（按照iOS原生动画做的）
 
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/3.gif?raw=true" width="300"  alt=""/>
 
 ```dart
SwipeActionCell(
      key: ValueKey(list[index]),
      trailingActions: <SwipeAction>[
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

 - ## Example 4:多于一个action
 
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/4.gif?raw=true" width="200"  alt=""/>

 
 ```dart
SwipeActionCell(
      key: ValueKey(list[index]),
      trailingActions: <SwipeAction>[
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

- ## Example 5：仿微信iOS端消息删除效果
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/6.gif?raw=true" width="300"  alt=""/>

```dart
return SwipeActionCell(
      key: vValueKey(list[index]),
      trailingActions: <SwipeAction>[
        SwipeAction(

          ///这个参数只能给的第一个action设置哦
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



- ## Example 6：编辑模式（类似iOS原生效果）
<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/8.gif?raw=true" width="300"  alt=""/>

```dart
/// 控制器（目前就是控制编辑的）
 SwipeActionEditController controller;

///在init里面初始化
@override
  void initState() {
    super.initState();
    controller = SwipeActionController();
  }
///如果你想获取你选中的行，那么请调用以下API
List<int> selectedIndexes = controller.getSelectedIndexes();

///打开cell
controller.openCellAt(index: 2, trailing: true, animated: true);

///关闭 cell
controller.closeAllOpenCell();

///切换编辑模式
controller.toggleEditingMode()

///开始编辑模式
controller.startEditingMode()

///停止编辑模式
controller.stopEditingMode()


///在build中传入你的列表组件，这里用常用的ListView：
ListView.builder(
        itemBuilder: (c, index) {
          return _item(index);
        },
        itemCount: list.length,
      );


 Widget _item(int index) {
     return SwipeActionCell(
       ///在这传入controller
       controller: controller,
       ///这个index需要你传入，否则会报错
       index: index,
       key: ValueKey(list[index]),
       trailingActions: [
         SwipeAction(
             performsFirstActionWithFullSwipe:true
             onTap: (handler) async {
               await handler(true);
               list.removeAt(index);
               setState(() {});
             },
             title: "删除"),
       ],
       child: Padding(
         padding: const EdgeInsets.all(15.0),
         child: Text("This is index of ${list[index]}",
             style: TextStyle(fontSize: 35)),
       ),
     );
   }

```


 - ## Example 7：仿美团iOS端订单页删除效果
 
 <img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/5.gif?raw=true" width="250"  alt=""/>

 #### 根据gif图可以判断，删除逻辑应该是这样的：
 - 1.点击或者拉动到最后触发删除动作
 - 2.请求服务器删除，服务器返回删除成功
 - 3.触发删除动画，更新UI
 
 那么对应的例子如下：
 
```dart
Widget _item(int index) {
    return SwipeActionCell(
      key: ValueKey(list[index]),
      trailingActions: <SwipeAction>[
        SwipeAction(
            icon: Icon(Icons.add),
            title: "delete",
            onTap: (CompletionHandler handler) async {
              
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

- ## Example 8：仿微信ios端收藏列表效果（自定义形状按钮）

<img src="https://github.com/luckysmg/daily_images/blob/main/flutter_swipe_action_cell_images/9.gif?raw=true" width="250"  alt=""/>

```dart

Widget _item(int index) {
    return SwipeActionCell(
      key: ValueKey(list[index]),
      trailingActions: [
        SwipeAction(
            nestedAction: SwipeNestedAction(
  
              ///自定义你nestedAction 的内容
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
            ///将原本的背景设置为透明，因为要用你自己的背景
            color: Colors.transparent,

            ///设置了content就不要设置title和icon了
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

        ///设置你自己的背景
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }


```

- ## Example 9：页面切换时统一关闭打开的cell
只需要在App的路由观察者中加上一个`SwipeActionNavigatorObserver`即可
```dart
return MaterialApp(
  navigatorObservers: [SwipeActionNavigatorObserver()],
  ....
);

```


## 关于 CompletionHandler 
它代表你在点击action之后如何操纵这个cell，如果你不想要任何动画，那么就不执行handler，而是直接更新你的数据，然后setState就行

如果你想要动画:
- handler(true) :代表这一行将会被删除（虽然UI上看不到那一行了，但是你仍然应该更新你的数据并且setState)

- await handler(true) :代表你将会等待删除动画执行完毕，你应该在这一行之后去执行setState，否则看不到动画（适合同步删除，也就是删除这个cell在业务上不需要服务器的参与） 

- handler(false) : 点击后内部不会有删除这一行的动作，默认地，他只会关闭这个action button

- await handler(false) : 相比上面来说，他只会等待关闭动画结束

# 其他参数如下：
#### SwipeActionCell：
参数名 | 含义 | 是否必填
-------- | --- |-----
trailingActions | 这个cell下的所有右侧action|否
leadingActions | 这个cell下的所有左侧action|否
child| cell内容 | 是
closeWhenScrolling | 滚动时关闭打开的cell|否（def=true）
firstActionWillCoverAllSpaceOnDeleting|执行动画删除时是否让第一个覆盖cell|否（def=true)
editModeOffset|进入编辑模式的cell偏移|否（def=60)
backgroundColor|cell的背景颜色|否（def=Theme.of(context).scaffoldBackgroundColor)


#### SwipeAction：
参数名 | 含义 | 是否必填
-------- | --- |-----
onTap | 点击此action执行的动作|是
title | action的文字 |否（不填就不显示文字）
style | title的TextStyle|否（有一个默认样式）
color | action拉出的背景颜色|否（def=Color.red)
performsFirstActionWithFullSwipe|拉满时执行第一个action|否（def=false)
icon | action的图标|否（不填就不显示）
closeOnTap | 点击此action是否关闭cell|否（def=true）
backgroundRadius|拉出的button的左上和左下圆角大小|否（def=0.0）
forceAlignmentLeft|当只有一个按钮的时候，让内容持续贴在左边|否（def=false)
widthSpace|这个button在正常展开状态下的宽度大小|否（def=80）
content| 自定义的内容视图|否（如果你需要这个参数，请保持title和icon都为null


#### SwipeNestedAction：
参数名 | 含义 | 是否必填
-------- | --- |-----
icon | 弹出的action的图标|否
title | 弹出的action的标题 |否
nestedWidth | 弹出的action的宽度|否（一般不需要设置，此宽度可以调整弹出的宽度）
curve| 动画曲线|否
content| 自定义的内容视图|否（如果你需要这个参数，请保持title和icon都为null
impactWhenShowing|弹出的时候的震动（知乎app消息页面的删除效果）|否(def=false)


#### SwipeActionController：
参数名（方法名） | 含义 |
-------- | --- |
isEditing | 是否处于编辑模式
selectedIndexPathsChangeCallback|获取选择/取消选择cell的回调
openCellAt|打开特定位置的cell
closeAllOpenCell|关闭所有打开的cell
getSelectedIndexPaths() | 获取选中的行的索引集合
toggleEditingMode() | 切换编辑模式
stopEditingMode()|暂停编辑模式
startEditingMode()| 开始编辑
selectCellAt (indexPaths)|选中一些行
deselectCellAt (indexPaths)|取消选择一些行
selectAll (length)|全选（需要你提供你数据集合的长度
deselectAll()|取消全选
deleteCellAt(indexPaths)|删除所在index的cell（只是同步内部数据，并不会刷新UI）




# 之前遇到的bug（附上关联的issue）
-  [issue7](https://github.com/luckysmg/flutter_swipe_action_cell/issues/7) (SwipeActionEditController 不能正确的删除数据) --> fixed after v1.1.0

 
 


