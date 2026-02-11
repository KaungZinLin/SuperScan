import 'package:flutter/material.dart';
import 'package:super_scan/constants.dart';
import 'dart:math' as math;

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key, required this.children, required this.distance});

  final List<Widget> children;
  final double distance;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this
    );

    _expandAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutExpo,
    );
  }

  void _toggle() {
    setState(() {
      _open = !_open;

      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // 1. Optional: Dark overlay to catch stray clicks (Tap to Close)
          if (_open)
            GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.transparent),
            ),

          // 2. The Close button (Hidden when closed)
          _tapToClose(),

          // 3. The Children (The menu items)
          ..._buildExpandableFabButton(),

          // 4. The Open button (Hidden when open)
          _tapToOpen(),
        ],
      ),
    );
  }

  Widget _tapToClose() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _open ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_open, // This is key: ignore touches when closed
        child: SizedBox(
          height: 56, // Match standard FAB size
          width: 56,
          child: Center(
            child: FloatingActionButton( // Use a FAB for consistent sizing
              elevation: 0,
              onPressed: _toggle,
              backgroundColor: Colors.white, // Or your kAccentColor
              child: Icon(Icons.close, color: kAccentColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tapToOpen() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      transformAlignment: Alignment.center,
      transform: Matrix4.diagonal3Values(_open ? 0.7 : 1.0, _open ? 0.7 : 1.0 , 1.0),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _open ? 0.0 : 1.0,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton(
          elevation: 0.0,
          onPressed: _toggle,
          child: Icon(Icons.add,),
        ),
      ),
    );
  }

  List<Widget> _buildExpandableFabButton() {
    final List<Widget> children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);

    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
      children.add(
        _ExpandableFab(
          directionDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: Listener(
            // behavior: opaque ensures it catches the tap even on transparent parts
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              if (_open) _toggle(); // Force collapse on finger touch
            },
            child: widget.children[i],
          ),
        ),
      );
    }
    return children;
  }
}

class _ExpandableFab extends StatelessWidget {
  const _ExpandableFab({super.key, required this.directionDegrees, required this.maxDistance, required this.progress, required this.child});

  final double directionDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionDegrees * (math.pi / 180),
          progress!.value * maxDistance
        );

        return Positioned(
          right: 4.0 * offset.dx,
          bottom: 4.0 * offset.dy,
          child: Transform.rotate(
              angle: (1.0 - progress!.value) * math.pi / 2,
                  child: child,
          ),
        );
      },

      child: FadeTransition(opacity: progress!, child: child,),
    );
  }
}
