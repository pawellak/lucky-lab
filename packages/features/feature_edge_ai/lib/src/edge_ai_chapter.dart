import 'package:shared/shared.dart';

const edgeAiChapter = ChapterInfo(
  number: 10,
  slug: 'edge-ai',
  tier: ChapterTier.differentiator,
  title: 'Edge AI',
  summary:
      'Detect unusual power draw on the device from energy meter data, plus an LLM assistant that explains it.',
  learningGoals: [
    'Collecting and labelling training data from the energy meter',
    'On-device anomaly detection with LiteRT',
    'LLM tool calling over your device data',
    'Safety, cost and latency limits',
  ],
  bonusGoals: ['TinyML on the microcontroller'],
  needsHardware: true,
);
