import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as VectorMath;


class ExpandableFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  final List<Widget> children;

  ExpandableFab({this.onPressed, this.tooltip, this.icon, this.children});

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.grey
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.add_event,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonAnimations = new List<Animation<double>>();
    for(var index = 0; index < widget.children.length; index++) {
      final animation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.5 - 0.1 * index,
          1.0 - 0.1 * index,
          curve: _curve,
        ),
      ));
      buttonAnimations.add(animation);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          widget.children.asMap().map((index, child) {
            return MapEntry<int, Widget>(index, Transform.scale(
              scale: buttonAnimations[index].value,
              child: child,
            ));
          }).values.toList()..add(toggle())
    );
  }
}