import 'package:flutter/material.dart';

import '../../models/gospel_models.dart';
import '../../services/gospel_store.dart';
import 'home_state_widgets.dart';

class GospelReaderPage extends StatefulWidget {
  const GospelReaderPage({
    required this.initialDate,
    required this.store,
    super.key,
  });

  final DateTime initialDate;
  final GospelLibraryRepository store;

  @override
  State<GospelReaderPage> createState() => _GospelReaderPageState();
}

class _GospelReaderPageState extends State<GospelReaderPage> {
  final _noteController = TextEditingController();
  List<GospelCalendarEntry> _entries = const [];
  int _currentIndex = -1;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load(widget.initialDate);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load(DateTime date) async {
    setState(() => _loading = true);
    final entries = await widget.store.loadMonth(date);
    final dateKey = _dateKey(date);
    final currentIndex = entries.indexWhere((entry) => entry.gospel.date == dateKey);
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _currentIndex = currentIndex;
      _loading = false;
      _noteController.text = currentIndex >= 0
          ? entries[currentIndex].personalState.note ?? ''
          : '';
    });
  }

  Future<void> _changeDate(int offset) async {
    final nextIndex = _currentIndex + offset;
    if (nextIndex < 0 || nextIndex >= _entries.length) {
      return;
    }
    final nextDate = DateTime.parse(_entries[nextIndex].gospel.date);
    await _load(nextDate);
  }

  Future<void> _toggleFavorite() async {
    final entry = _currentEntry;
    if (entry == null) {
      return;
    }
    final isFavorite = !entry.personalState.isFavorite;
    setState(() => _saving = true);
    try {
      await widget.store.setFavorite(entry.gospel.date, isFavorite);
      if (!mounted) {
        return;
      }
      setState(() {
        _entries = List.of(_entries)
          ..[_currentIndex] = GospelCalendarEntry(
            gospel: entry.gospel,
            personalState: GospelPersonalState(
              isFavorite: isFavorite,
              note: entry.personalState.note,
            ),
          );
        _saving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o favorito.')),
      );
    }
  }

  Future<void> _saveNote() async {
    final entry = _currentEntry;
    if (entry == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.store.saveNote(entry.gospel.date, _noteController.text);
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anotação salva neste dispositivo.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar a anotação.')),
      );
    }
  }

  GospelCalendarEntry? get _currentEntry {
    if (_currentIndex < 0 || _currentIndex >= _entries.length) {
      return null;
    }
    return _entries[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: HomeLoadingView());
    }
    final entry = _currentEntry;
    if (entry == null) {
      return const Scaffold(
        body: HomeEmptyView(
          message: 'Este Evangelho ainda não foi publicado.',
        ),
      );
    }
    final gospel = entry.gospel;
    final canGoPrevious = _currentIndex > 0;
    final canGoNext = _currentIndex < _entries.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evangelho do dia'),
        actions: [
          IconButton(
            tooltip: entry.personalState.isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: _saving ? null : _toggleFavorite,
            icon: Icon(
              entry.personalState.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: entry.personalState.isFavorite ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              _formatDate(gospel.date),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF8B6F56),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              gospel.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF382315),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              gospel.reference,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF6E4B2E),
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reflexão breve',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              gospel.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.75,
                    color: const Color(0xFF2C241B),
                  ),
            ),
            if (gospel.sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Referência litúrgica: ${gospel.sourceUrl}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6E5A47),
                    ),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Minha anotação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Privada e guardada somente neste dispositivo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('gospel-note-field'),
              controller: _noteController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Escreva sua reflexão ou homilia pessoal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saving ? null : _saveNote,
                child: const Text('Salvar anotação'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: canGoPrevious ? () => _changeDate(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Anterior'),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: canGoNext ? () => _changeDate(1) : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Próximo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

