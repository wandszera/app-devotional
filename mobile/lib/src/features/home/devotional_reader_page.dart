import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/devotional_models.dart';
import '../../services/local_db_service.dart';
import 'content_cards.dart';
import 'retention_support.dart';

class DevotionalReaderPage extends StatefulWidget {
  const DevotionalReaderPage({
    required this.devotional,
    required this.streak,
    required this.onComplete,
    this.ownerKey = 'guest',
    super.key,
  });

  final DevotionalCardModel devotional;
  final StreakModel streak;
  final Future<DevotionalCompletionResultModel?> Function()? onComplete;
  final String ownerKey;

  @override
  State<DevotionalReaderPage> createState() => _DevotionalReaderPageState();
}

class _GospelReferenceCard extends StatelessWidget {
  const _GospelReferenceCard({
    required this.reference,
    required this.hasOfficialSource,
  });

  final String reference;
  final bool hasOfficialSource;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3CBA4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evangelho',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            reference.isEmpty ? 'Referência ainda não disponível' : reference,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (hasOfficialSource) ...[
            const SizedBox(height: 8),
            const Text('Fonte litúrgica: Igreja em Oração — Edições CNBB.'),
          ],
        ],
      ),
    );
  }
}

class _PersonalReflectionEditor extends StatelessWidget {
  const _PersonalReflectionEditor({
    required this.homilyController,
    required this.noteController,
    required this.loaded,
    required this.onChanged,
  });

  final TextEditingController homilyController;
  final TextEditingController noteController;
  final bool loaded;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meu espaço de oração',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          const Text('Salvo somente neste aparelho e nesta conta.'),
          const SizedBox(height: 16),
          TextField(
            controller: homilyController,
            enabled: loaded,
            minLines: 3,
            maxLines: 7,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Minha homilia / reflexão',
              hintText: 'Escreva a reflexão que deseja guardar.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            enabled: loaded,
            minLines: 2,
            maxLines: 5,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Anotação pessoal',
              hintText: 'Registre uma intenção, aprendizado ou oração.',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevotionalReaderPageState extends State<DevotionalReaderPage> {
  bool _immersiveMode = false;
  bool _personalContentLoaded = false;
  final _homilyController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersonalContent();
  }

  Future<void> _loadPersonalContent() async {
    final content = await LocalDbService().getPersonalReflection(
      widget.ownerKey,
      widget.devotional.date,
    );
    if (!mounted) return;
    setState(() {
      _homilyController.text = content.homily;
      _noteController.text = content.note;
      _personalContentLoaded = true;
    });
  }

  void _savePersonalContent() {
    LocalDbService().savePersonalReflection(
      widget.ownerKey,
      widget.devotional.date,
      homily: _homilyController.text,
      note: _noteController.text,
    );
  }

  void _toggleImmersive() {
    setState(() {
      _immersiveMode = !_immersiveMode;
    });
    if (_immersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    _savePersonalContent();
    _homilyController.dispose();
    _noteController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextMilestone =
        RetentionSupport.nextMilestone(widget.streak.currentStreak);

    return Scaffold(
      appBar: _immersiveMode
          ? null
          : AppBar(
              title: const Text('Evangelho do dia'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Modo Imersivo',
                  onPressed: _toggleImmersive,
                ),
              ],
            ),
      floatingActionButton: _immersiveMode
          ? FloatingActionButton.small(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              onPressed: _toggleImmersive,
              child: const Icon(Icons.fullscreen_exit, color: Colors.black87),
            )
          : null,
      body: GestureDetector(
        onDoubleTap: _toggleImmersive,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          children: [
            Text(
              widget.devotional.date,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8B6F56),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.devotional.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF382315),
                    height: 1.2,
                  ),
            ),
            if (widget.devotional.liturgicalTitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.devotional.liturgicalTitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6B5140),
                    ),
              ),
            ],
            const SizedBox(height: 24),
            _GospelReferenceCard(
              reference: widget.devotional.gospelReference,
              hasOfficialSource: widget.devotional.sourceUrl.isNotEmpty,
            ),
            const SizedBox(height: 16),
            Container(
              padding: _immersiveMode
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _immersiveMode ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _immersiveMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_immersiveMode) ...[
                    Text(
                      'Reflexão para rezar',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    widget.devotional.content,
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      height: 1.8,
                      color: const Color(0xFF2C241B),
                    ),
                  ),
                ],
              ),
            ),
            if (!_immersiveMode) ...[
              const SizedBox(height: 24),
              _PersonalReflectionEditor(
                homilyController: _homilyController,
                noteController: _noteController,
                loaded: _personalContentLoaded,
                onChanged: _savePersonalContent,
              ),
              const SizedBox(height: 16),
            ],
            if (!_immersiveMode) ...[
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Streak atual',
                      value: '${widget.streak.currentStreak}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Melhor streak',
                      value: '${widget.streak.longestStreak}',
                    ),
                  ),
                ],
              ),
              if (nextMilestone != null) ...[
                const SizedBox(height: 16),
                MilestoneBanner(
                  currentStreak: widget.streak.currentStreak,
                  nextMilestone: nextMilestone,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: widget.onComplete == null
                    ? null
                    : () async {
                        await widget.onComplete!.call();
                      },
                child: Text(
                  widget.onComplete == null
                      ? 'Concluído hoje'
                      : 'Concluir leitura',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              const SizedBox(
                  height: 80), // Espaço extra no fim do modo imersivo
            ]
          ],
        ),
      ),
    );
  }
}
