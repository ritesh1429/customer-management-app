import 'package:flutter/material.dart';

class AlphabetScrollBar extends StatefulWidget {
  final List<String> availableLetters;
  final ValueChanged<String> onLetterSelected;
  final ValueChanged<bool>? onDraggingChanged;

  const AlphabetScrollBar({
    super.key,
    required this.availableLetters,
    required this.onLetterSelected,
    this.onDraggingChanged,
  });

  @override
  State<AlphabetScrollBar> createState() => _AlphabetScrollBarState();
}

class _AlphabetScrollBarState extends State<AlphabetScrollBar> {
  static const List<String> _alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];

  String? _selectedLetter;
  bool _isDragging = false;

  void _handleTouch(Offset localPosition, double height) {
    if (height <= 0) return;
    final singleItemHeight = height / _alphabet.length;
    final index = (localPosition.dy / singleItemHeight).floor().clamp(0, _alphabet.length - 1);
    final letter = _alphabet[index];

    if (_selectedLetter != letter) {
      setState(() {
        _selectedLetter = letter;
      });
      widget.onLetterSelected(letter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;

        return Stack(
          alignment: Alignment.centerRight,
          children: [
            // Letter Bubble popup when dragging / selecting
            if (_isDragging && _selectedLetter != null)
              Positioned(
                right: 48,
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _selectedLetter!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Alphabet Bar Strip
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (details) {
                setState(() {
                  _isDragging = true;
                });
                widget.onDraggingChanged?.call(true);
                _handleTouch(details.localPosition, totalHeight);
              },
              onVerticalDragUpdate: (details) {
                _handleTouch(details.localPosition, totalHeight);
              },
              onVerticalDragEnd: (_) {
                setState(() {
                  _isDragging = false;
                  _selectedLetter = null;
                });
                widget.onDraggingChanged?.call(false);
              },
              onVerticalDragCancel: () {
                setState(() {
                  _isDragging = false;
                  _selectedLetter = null;
                });
                widget.onDraggingChanged?.call(false);
              },
              onTapDown: (details) {
                setState(() {
                  _isDragging = true;
                });
                widget.onDraggingChanged?.call(true);
                _handleTouch(details.localPosition, totalHeight);
              },
              onTapUp: (_) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() {
                      _isDragging = false;
                      _selectedLetter = null;
                    });
                    widget.onDraggingChanged?.call(false);
                  }
                });
              },
              onTapCancel: () {
                setState(() {
                  _isDragging = false;
                  _selectedLetter = null;
                });
                widget.onDraggingChanged?.call(false);
              },
              child: Container(
                width: 28,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(-1, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _alphabet.map((letter) {
                    final bool isAvailable = widget.availableLetters.contains(letter);
                    final bool isSelected = _selectedLetter == letter;

                    return Expanded(
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected || isAvailable
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.indigo.shade900
                                : isAvailable
                                    ? Colors.indigo.shade700
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
