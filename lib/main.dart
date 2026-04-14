import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF005A9C),
      ),
      home: const CashCounterHomePage(),
    );
  }
}

class CashCounterHomePage extends StatefulWidget {
  const CashCounterHomePage({super.key});

  @override
  State<CashCounterHomePage> createState() => _CashCounterHomePageState();
}

class _CashCounterHomePageState extends State<CashCounterHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List<GlobalKey>.generate(
    _categories.length,
    (_) => GlobalKey(),
  );

  final Map<String, int> _counts = <String, int>{};
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    for (final category in _categories) {
      for (final item in category.items) {
        _counts[item.id] = 0;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentSectionFromScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double get _totalValue {
    var total = 0.0;
    for (final category in _categories) {
      for (final item in category.items) {
        final count = _counts[item.id] ?? 0;
        total += item.value * count;
      }
    }
    return total;
  }

  void _changeCount(String itemId, int delta) {
    final current = _counts[itemId] ?? 0;
    final next = (current + delta).clamp(0, 99999);
    setState(() {
      _counts[itemId] = next;
    });
  }

  void _scrollToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) {
      return;
    }
    final context = _sectionKeys[index].currentContext;
    if (context == null) {
      return;
    }
    setState(() {
      _currentSection = index;
    });
    Scrollable.ensureVisible(
      context,
      alignment: 0.02,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _updateCurrentSectionFromScroll() {
    var bestIndex = _currentSection;
    var bestDistance = double.infinity;

    for (var i = 0; i < _sectionKeys.length; i++) {
      final sectionContext = _sectionKeys[i].currentContext;
      if (sectionContext == null) {
        continue;
      }
      final box = sectionContext.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) {
        continue;
      }

      final position = box.localToGlobal(Offset.zero);
      final distance = (position.dy - 130).abs();

      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    if (bestIndex != _currentSection) {
      setState(() {
        _currentSection = bestIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canGoUp = _currentSection > 0;
    final canGoDown = _currentSection < _categories.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TotalHeader(totalValue: _totalValue),
                Expanded(
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      _updateCurrentSectionFromScroll();
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 112),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _CategorySection(
                          key: _sectionKeys[index],
                          category: category,
                          counts: _counts,
                          onIncrement: (id) => _changeCount(id, 1),
                          onDecrement: (id) => _changeCount(id, -1),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 20,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'scroll-up',
                    onPressed: canGoUp
                        ? () => _scrollToSection(_currentSection - 1)
                        : null,
                    child: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'scroll-down',
                    onPressed: canGoDown
                        ? () => _scrollToSection(_currentSection + 1)
                        : null,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Bereich ${_currentSection + 1}/${_categories.length}: ${_categories[_currentSection].title}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalHeader extends StatelessWidget {
  const _TotalHeader({required this.totalValue});

  final double totalValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gesamt',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            _formatCurrency(totalValue),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    super.key,
    required this.category,
    required this.counts,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CashCategory category;
  final Map<String, int> counts;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in category.items)
            _CounterRow(
              title: item.label,
              value: item.value,
              count: counts[item.id] ?? 0,
              onIncrement: () => onIncrement(item.id),
              onDecrement: () => onDecrement(item.id),
            ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.title,
    required this.value,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String title;
  final double value;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rowSum = value * count;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Wert: ${_formatCurrency(value)}  |  Summe: ${_formatCurrency(rowSum)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove),
            tooltip: 'Verringern',
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: onIncrement,
            icon: const Icon(Icons.add),
            tooltip: 'Erhoehen',
          ),
        ],
      ),
    );
  }
}

class CashCategory {
  const CashCategory({
    required this.title,
    required this.backgroundColor,
    required this.items,
  });

  final String title;
  final Color backgroundColor;
  final List<CashItem> items;
}

class CashItem {
  const CashItem({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final double value;
}

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$fixed EUR';
}

const List<CashCategory> _categories = [
  CashCategory(
    title: 'Rollen',
    backgroundColor: Color(0xFFE7F4FF),
    items: [
      CashItem(id: 'rollen_2', label: '2 EUR Rolle', value: 100.0),
      CashItem(id: 'rollen_1', label: '1 EUR Rolle', value: 50.0),
      CashItem(id: 'rollen_50c', label: '50 Cent Rolle', value: 20.0),
      CashItem(id: 'rollen_20c', label: '20 Cent Rolle', value: 8.0),
      CashItem(id: 'rollen_10c', label: '10 Cent Rolle', value: 4.0),
      CashItem(id: 'rollen_5c', label: '5 Cent Rolle', value: 2.5),
      CashItem(id: 'rollen_2c', label: '2 Cent Rolle', value: 1.0),
      CashItem(id: 'rollen_1c', label: '1 Cent Rolle', value: 0.5),
    ],
  ),
  CashCategory(
    title: 'Scheine',
    backgroundColor: Color(0xFFFFF4E8),
    items: [
      CashItem(id: 'schein_500', label: '500 EUR Schein', value: 500.0),
      CashItem(id: 'schein_200', label: '200 EUR Schein', value: 200.0),
      CashItem(id: 'schein_100', label: '100 EUR Schein', value: 100.0),
      CashItem(id: 'schein_50', label: '50 EUR Schein', value: 50.0),
      CashItem(id: 'schein_20', label: '20 EUR Schein', value: 20.0),
      CashItem(id: 'schein_10', label: '10 EUR Schein', value: 10.0),
      CashItem(id: 'schein_5', label: '5 EUR Schein', value: 5.0),
    ],
  ),
  CashCategory(
    title: 'Muenzen',
    backgroundColor: Color(0xFFEEF9EC),
    items: [
      CashItem(id: 'muenze_2', label: '2 EUR Muenze', value: 2.0),
      CashItem(id: 'muenze_1', label: '1 EUR Muenze', value: 1.0),
      CashItem(id: 'muenze_50c', label: '50 Cent Muenze', value: 0.5),
      CashItem(id: 'muenze_20c', label: '20 Cent Muenze', value: 0.2),
      CashItem(id: 'muenze_10c', label: '10 Cent Muenze', value: 0.1),
      CashItem(id: 'muenze_5c', label: '5 Cent Muenze', value: 0.05),
      CashItem(id: 'muenze_2c', label: '2 Cent Muenze', value: 0.02),
      CashItem(id: 'muenze_1c', label: '1 Cent Muenze', value: 0.01),
    ],
  ),
];
