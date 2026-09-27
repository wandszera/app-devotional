import 'package:flutter/material.dart';

import '../../models/gospel_models.dart';
import '../../services/gospel_store.dart';
import 'gospel_reader_page.dart';
import 'home_state_widgets.dart';

class LiturgicalCalendarTab extends StatefulWidget {
  const LiturgicalCalendarTab({
    this.store,
    this.month,
    this.today,
    super.key,
  });

  final GospelLibraryRepository? store;
  final DateTime? month;
  final DateTime? today;

  @override
  State<LiturgicalCalendarTab> createState() => _LiturgicalCalendarTabState();
}

class _LiturgicalCalendarTabState extends State<LiturgicalCalendarTab> {
  late final GospelLibraryRepository _store =
      widget.store ?? GospelLibraryStore();
  List<GospelCalendarEntry> _entries = const [];
  bool _loading = true;
  String? _errorMessage;

  DateTime get _month => widget.month ?? DateTime(2026, 9);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final entries = await _store.loadMonth(_month);
      if (!mounted) {
        return;
      }
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Não foi possível abrir o calendário litúrgico.';
      });
    }
  }

  Future<void> _openGospel(GospelCalendarEntry entry) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GospelReaderPage(
          initialDate: DateTime.parse(entry.gospel.date),
          store: _store,
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const HomeLoadingView();
    }
    if (_errorMessage != null) {
      return HomeErrorView(message: _errorMessage!);
    }

    final entriesByDate = {for (final entry in _entries) entry.gospel.date: entry};
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final leadingDays = DateTime(_month.year, _month.month).weekday % 7;
    final today = widget.today ?? DateTime.now();
    final isCurrentMonth = today.year == _month.year && today.month == _month.month;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Calendário litúrgico',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF382315),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Setembro de 2026',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6E4B2E),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em uma data publicada para abrir o Evangelho. Coração e anotação indicam dados privados deste dispositivo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6E5A47),
                ),
          ),
          const SizedBox(height: 20),
          if (_entries.isEmpty) ...[
            const HomeEmptyCard(
              message: 'Nenhum Evangelho foi publicado para este mês ainda.',
            ),
            const SizedBox(height: 20),
          ],
          _WeekdayHeader(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.88,
            ),
            itemCount: leadingDays + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingDays) {
                return const SizedBox.shrink();
              }
              final day = index - leadingDays + 1;
              final date = DateTime(_month.year, _month.month, day);
              final entry = entriesByDate[_dateKey(date)];
              final isToday = isCurrentMonth && today.day == day;
              return _CalendarDay(
                key: Key('calendar-day-${_dateKey(date)}'),
                day: day,
                entry: entry,
                isToday: isToday,
                onTap: entry == null ? null : () => _openGospel(entry),
              );
            },
          ),
          const SizedBox(height: 20),
          if (_entries.isNotEmpty)
            Text(
              '${_entries.length} Evangelho${_entries.length == 1 ? '' : 's'} publicado${_entries.length == 1 ? '' : 's'} neste mês.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const weekdays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      children: weekdays
          .map(
            (weekday) => Expanded(
              child: Center(
                child: Text(
                  weekday,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.entry,
    required this.isToday,
    required this.onTap,
    super.key,
  });

  final int day;
  final GospelCalendarEntry? entry;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasGospel = entry != null;
    final personal = entry?.personalState;
    return Semantics(
      button: hasGospel,
      label: hasGospel
          ? 'Dia $day, Evangelho disponível'
          : 'Dia $day, Evangelho ainda não publicado',
      child: Material(
        color: hasGospel ? Colors.white : const Color(0xFFF0EAE2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday ? const Color(0xFFB88645) : const Color(0xFFE6DACE),
                width: isToday ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$day',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (hasGospel)
                  Wrap(
                    spacing: 2,
                    children: [
                      const Icon(Icons.menu_book, size: 14),
                      if (personal!.isFavorite)
                        const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                      if (personal.hasNote)
                        const Icon(Icons.sticky_note_2, size: 12),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

