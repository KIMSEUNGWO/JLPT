
import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  final Widget child;

  const ExpandableContainer({super.key, required this.child});

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  final GlobalKey _contentKey = GlobalKey();
  double? _height;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeight();
    });
  }

  void _updateHeight() {
    final RenderBox? contentBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox != null) {
      setState(() {
        _height = contentBox.size.height;
      });
    }
    print(_height);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _height,
      child: Container(
        key: _contentKey,
        child: widget.child,
      ),
    );
  }
}
