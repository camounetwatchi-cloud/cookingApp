import 'package:flutter/material.dart';

class DislikesPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(int) onUpdateSpice;
  final Function(Set<String>) onUpdateDislikes;
  final int initialSpiceLevel;
  final Set<String> initialDislikedItems;
  
  const DislikesPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onUpdateSpice,
    required this.onUpdateDislikes,
    required this.initialSpiceLevel,
    required this.initialDislikedItems,
  });

  @override
  State<DislikesPage> createState() => _DislikesPageState();
}

class _DislikesPageState extends State<DislikesPage> {
  late int _spiceLevel;
  late Set<String> _dislikedItems;
  late TextEditingController _searchController;
  
  final List<String> _spiceLevels = ['Pas epice', 'Un peu epice', 'Tres epice'];

  @override
  void initState() {
    super.initState();
    _spiceLevel = widget.initialSpiceLevel;
    _dislikedItems = Set.from(widget.initialDislikedItems);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addDislike(String item) {
    if (item.isNotEmpty && !_dislikedItems.contains(item)) {
      setState(() {
        _dislikedItems.add(item);
        _searchController.clear();
      });
      widget.onUpdateDislikes(_dislikedItems);
    }
  }

  void _removeDislike(String item) {
    setState(() {
      _dislikedItems.remove(item);
    });
    widget.onUpdateDislikes(_dislikedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Derniere etape !\nCe que tu n\'aimes pas',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'On personnalisera tes recettes\nselon tes gouts',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final isSelected = _spiceLevel == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _spiceLevel = index;
                      });
                      widget.onUpdateSpice(_spiceLevel);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4A9FFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF4A9FFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        _spiceLevels[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE0E0E0),
              inactiveTrackColor: const Color(0xFFE0E0E0),
              trackHeight: 6,
              thumbColor: Colors.white,
              thumbShape: const CustomThumbShape(),
              overlayColor: const Color(0xFF4A9FFF).withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _spiceLevel.toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (value) {
                setState(() {
                  _spiceLevel = value.round();
                });
                widget.onUpdateSpice(_spiceLevel);
              },
            ),
          ),
          const Spacer(),
          Text(
            'Si tu veux indiques simplement ce\nque tu n\'aimes pas',
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF4A9FFF),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400], size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: _addDislike,
                  ),
                ),
                Icon(Icons.mic, color: Colors.grey[400], size: 22),
              ],
            ),
          ),
          if (_dislikedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _dislikedItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeDislike(item),
                          child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9FFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  const CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final borderPaint = Paint()
      ..color = const Color(0xFF4A9FFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center + const Offset(0, 2), 12, shadowPaint);
    canvas.drawCircle(center, 12, fillPaint);
    canvas.drawCircle(center, 12, borderPaint);
  }
}
