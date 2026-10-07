import 'package:shared/shared.dart';

const securityChapter = ChapterInfo(
  number: 11,
  slug: 'security',
  track: ChapterTrack.production,
  title: 'Mobile Security',
  summary:
      'Harden the app against OWASP MASVS: secure storage, certificate pinning, obfuscation and tamper checks.',
  learningGoals: [
    'OWASP MASVS / mobile top 10',
    'Keychain / Keystore and biometrics',
    'Certificate pinning',
    'Obfuscation and reverse-engineering your own APK',
    'Threat modelling',
  ],
);
