import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WidgetAudio extends StatefulWidget {
  final TextEditingController controller;

  const WidgetAudio({
    super.key,
    required this.controller,
  });

  @override
  State<WidgetAudio> createState() => _WidgetAudioState();
}

class _WidgetAudioState extends State<WidgetAudio> {
  final SpeechToText _speech = SpeechToText();

  bool _disponible = false;
  bool _ecoute = false;
  String _statut = 'Appuyez sur Démarrer pour dicter';
  String _texteAvantEcoute = '';
  String? _localeId;

  Future<void> _initialiser() async {
    final disponible = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );

    if (!mounted) return;

    if (disponible) {
      final locales = await _speech.locales();
      final localeFr = locales.where((locale) {
        return locale.localeId.toLowerCase().startsWith('fr');
      }).toList();

      _localeId = localeFr.isNotEmpty ? localeFr.first.localeId : null;
    }

    setState(() {
      _disponible = disponible;
      _statut = disponible
          ? 'Micro prêt'
          : 'Reconnaissance vocale indisponible';
    });
  }

  Future<void> _demarrer() async {
    if (!_disponible) {
      await _initialiser();
    }

    if (!_disponible) return;

    _texteAvantEcoute = widget.controller.text.trim();
    if (_texteAvantEcoute.isNotEmpty) {
      _texteAvantEcoute = '$_texteAvantEcoute ';
    }

    setState(() {
      _ecoute = true;
      _statut = 'Écoute en cours...';
    });

    await _speech.listen(
      onResult: (result) {
        final texteReconnu = result.recognizedWords.trim();
        final nouveauTexte = '$_texteAvantEcoute$texteReconnu'.trim();

        widget.controller.text = nouveauTexte;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );

        if (result.finalResult) {
          _texteAvantEcoute = '${widget.controller.text.trim()} ';
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ).copyWith(
        localeId: _localeId,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _arreter() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _ecoute = false;
      _statut = 'Écoute arrêtée';
    });
  }

  void _onStatus(String status) {
    if (!mounted) return;

    if (status == 'done' || status == 'notListening') {
      setState(() {
        _ecoute = false;
        _statut = 'Écoute terminée';
      });
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) return;

    setState(() {
      _ecoute = false;
      _statut = 'Erreur micro : ${error.errorMsg}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _ecoute ? Colors.red.withOpacity(0.08) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _ecoute ? null : _demarrer,
                    icon: const Icon(Icons.mic),
                    label: const Text('Démarrer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ecoute ? _arreter : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Arrêter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _statut,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}