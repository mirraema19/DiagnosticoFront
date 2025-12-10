import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto/features/sentiment/data/models/sentiment_models.dart';
import 'package:proyecto/features/sentiment/presentation/bloc/sentiment_bloc.dart';

class SentimentAnalysisScreen extends StatefulWidget {
  const SentimentAnalysisScreen({super.key});

  @override
  State<SentimentAnalysisScreen> createState() => _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_controller.text.trim().isEmpty) return;
    context.read<SentimentBloc>().add(
          AnalyzeTextSentiment(text: _controller.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Reseñas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Analiza el sentimiento de las reseñas de tus clientes con IA.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texto de la reseña',
                border: OutlineInputBorder(),
                hintText: 'Pega aquí el comentario del cliente...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _analyze,
              icon: const Icon(Icons.analytics),
              label: const Text('ANALIZAR SENTIMIENTO'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<SentimentBloc, SentimentState>(
                builder: (context, state) {
                  if (state is SentimentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SentimentError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is SentimentAnalyzed) {
                    return _buildResult(state.result);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(SentimentAnalysisModel result) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resultado del Análisis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildSentimentIndicator(result.sentiment.label),
            const SizedBox(height: 16),
            _buildScoreRow('Positivo', result.sentiment.score.positive, Colors.green),
            _buildScoreRow('Neutral', result.sentiment.score.neutral, Colors.grey),
            _buildScoreRow('Negativo', result.sentiment.score.negative, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentIndicator(SentimentLabel label) {
    IconData icon;
    Color color;
    String text;

    switch (label) {
      case SentimentLabel.POSITIVE:
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
        text = 'POSITIVO';
        break;
      case SentimentLabel.NEUTRAL:
        icon = Icons.sentiment_neutral;
        color = Colors.amber;
        text = 'NEUTRAL';
        break;
      case SentimentLabel.NEGATIVE:
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        text = 'NEGATIVO';
        break;
    }

    return Column(
      children: [
        Icon(icon, size: 64, color: color),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: color.withOpacity(0.2),
              color: color,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 10),
          Text('${(score * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
