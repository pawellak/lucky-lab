import 'package:shared/shared.dart';

const aiAssistantChapter = ChapterInfo(
  number: 10,
  slug: 'ai-assistant',
  track: ChapterTrack.production,
  title: 'AI Device Assistant',
  summary:
      'An LLM assistant that reads your device data and controls devices through tool calling.',
  learningGoals: [
    'LLM API integration and streaming responses',
    'Tool calling to control real devices',
    'Model Context Protocol (MCP)',
    'On-device ML for anomaly detection (LiteRT)',
    'Safety, cost and latency limits',
  ],
);
