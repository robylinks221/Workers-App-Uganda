import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../storage/token_storage.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF164D7A);

class ProtectedWorkerIdScreen extends StatelessWidget {
  const ProtectedWorkerIdScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  final int workerId;
  final String workerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(title: const Text('Verified ID')),
      body: FutureBuilder<String?>(
        future: TokenStorage.getToken(),
        builder: (context, snapshot) {
          final token = snapshot.data;

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (token == null || token.isEmpty) {
            return const Center(child: Text('Please sign in again.'));
          }

          final headers = {
            'Authorization': 'Bearer $token',
            'Accept': 'image/*',
          };

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline_rounded, color: _primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Private document. Use it only to confirm this worker’s identity while considering them for work. Access is temporary and every view is logged.',
                        style: TextStyle(
                          color: _navy,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ProtectedIdSide(
                title: 'FRONT OF ID',
                subtitle: workerName,
                url: ApiConfig.homeownerWorkerIdentityDocument(
                  workerId,
                  'front',
                ),
                headers: headers,
              ),
              const SizedBox(height: 18),
              _ProtectedIdSide(
                title: 'BACK OF ID',
                subtitle: workerName,
                url: ApiConfig.homeownerWorkerIdentityDocument(
                  workerId,
                  'back',
                ),
                headers: headers,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProtectedIdSide extends StatelessWidget {
  const _ProtectedIdSide({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.headers,
  });

  final String title;
  final String subtitle;
  final String url;
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _primary,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.58,
                  child: Image.network(
                    url,
                    headers: headers,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('Unable to display this ID image.'),
                          ),
                        ),
                  ),
                ),
                IgnorePointer(
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Opacity(
                      opacity: 0.16,
                      child: Text(
                        'MAIDS APP • VERIFIED VIEW',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
