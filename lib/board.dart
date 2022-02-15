import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Board extends StatefulWidget {
  final int width, height, mineCount;

  const Board(
      {Key? key,
      required this.width,
      required this.height,
      required this.mineCount})
      : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  bool _isInit = false;
  bool _isGenerated = false;
  int _width = 0, _height = 0, _mineCount = 0;
  late List<List<bool>> _minesMap, _uncoveredMap;
  late List<List<int>> _counterMap;

  void _init() {
    if (!_isInit) {
      _isInit = true;
      _isGenerated = false;

      _width = widget.width;
      _height = widget.height;
      _mineCount = widget.mineCount;

      _minesMap = List.generate(_width, (index) => List.filled(_height, false));
      _uncoveredMap =
          List.generate(_width, (index) => List.filled(_height, false));
      _counterMap = List.generate(_width, (index) => List.filled(_height, 0));


    }
  }

  void _generate(int uncoveredX, int uncoveredY) {
    if (!_isGenerated) {
      _isGenerated = true;

      final random = Random();
      for (var i = 0; i < _mineCount; i++) {
        while (true) {
          final x = random.nextInt(_width);
          final y = random.nextInt(_height);
          if (!_minesMap[x][y] && (uncoveredX != x || uncoveredY != y)) {
            _minesMap[x][y] = true;
            for (int x2 = max(0, x - 1); x2 <= x + 1 && x2 < _width; x2++) {
              for (int y2 = max(0, y - 1); y2 <= y + 1 && y2 < _height; y2++) {
                _counterMap[x2][y2]++;
              }
            }
            break;
          }
        }
      }
    }
  }

  void _uncover(int x, int y) {
    _generate(x, y);

    if (!_uncoveredMap[x][y]) {
      _uncoveredMap[x][y] = true;
      if (_minesMap[x][y]) {
        // TODO lose
      } else if (_counterMap[x][y] == 0) {
        for (int x2 = max(0, x - 1); x2 <= x + 1 && x2 < _width; x2++) {
          for (int y2 = max(0, y - 1); y2 <= y + 1 && y2 < _height; y2++) {
            _uncoverUnchecked(x2, y2);
          }
        }
      }
    }
  }

  void _uncoverUnchecked(int x, int y) {
    if (!_uncoveredMap[x][y]) {
      _uncoveredMap[x][y] = true;
      if (_counterMap[x][y] == 0) {
        for (int x2 = max(0, x - 1); x2 <= x + 1 && x2 < _width; x2++) {
          for (int y2 = max(0, y - 1); y2 <= y + 1 && y2 < _height; y2++) {
            _uncoverUnchecked(x2, y2);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_width != widget.width ||
        _height != widget.height ||
        _mineCount != widget.mineCount) {
      _isInit = false;
      _init();
    }

    return Row(children: [
      for (var x = 0; x < _width; x++)
        Column(
          children: [
            for (var y = 0; y < _height; y++) _buildCell(x, y),
          ],
        )
    ]);
  }

  Widget _buildCell(int x, int y) {
    return Material(
      color: _uncoveredMap[x][y]
          ? Theme.of(context).colorScheme.primary.withOpacity(_counterMap[x][y].toDouble() / 16)
          : Theme.of(context).colorScheme.secondary,
      child: InkWell(
        onTap: () => setState(() => _uncover(x, y)),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
              child: Text(
            _uncoveredMap[x][y]
                ? _minesMap[x][y]
                    ? 'X'
                    : _counterMap[x][y].toString()
                : '',
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 36),
          )),
        ),
      ),
    );
  }
}
