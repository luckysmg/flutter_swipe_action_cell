import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///If you want the animation I support
///you should modify your data source first,then wait handler to execute,after that,
///you can call setState to update your UI.
///
///
///Code Example
///
///  initState(){
///    List list = [1,2,3,5];
///  }
///
/// onTap(handler)async {
///
///   list.removeAt(2);
///
///   await handler(true or false);
///   //true: will delete this row in ListView ,false: will not delete it
///   //Q:When to use "await"? A:The time when you want animation
///
///   setState((){});
/// }
///
typedef CompletionHandler = Function(bool);

class SwipeAction {
  ///title's text Style
  ///default value is :TextStyle(fontSize: 18,color: Colors.white)
  ///标题的字体样式,默认值在上面
  final TextStyle style;

  ///close the actions button after you tap it,default value is true
  ///点击这个按钮的时候，是否关闭actions 默认为true
  final bool closeOnTap;

  ///the distance between the title content and left boundary,default value is 15
  ///标题内容与action button左边界的距离，方便自定义，默认为15
  final double leftPadding;

  ///When There is one action button in menu,the alignment of content in button will be [Alignment.centerRight]
  ///If you don't want ,you can set this value to true to make it become [Alignment.centerLeft]
  ///This parameter only works when it is the first [SwipeAction]!!!!
  ///当只有一个按钮时，里面的内容会默认在右边（和iOS原生相同），但是你如果需要内容贴在左边，可以设置这个属性为true
  ///这个属性只对第一个  [SwipeAction]有用!!!!
  final bool forceAlignmentLeft;

  final Color color;
  final Function(CompletionHandler) onTap;
  final Widget icon;
  final String title;
  final double backgroundRadius;

  const SwipeAction({
    @required this.onTap,
    this.title,
    this.style = const TextStyle(fontSize: 18, color: Colors.white),
    this.color = Colors.red,
    this.leftPadding = 15,
    this.icon,
    this.closeOnTap = true,
    this.backgroundRadius = 0.0,
    this.forceAlignmentLeft = false,
  });
}
