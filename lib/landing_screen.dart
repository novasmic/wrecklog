import 'package:flutter/material.dart';
import 'main.dart' show AppShell;

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B07),
      body: Stack(
        children: [
          // ── Hero background ─────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/hero_dismantled_car.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xDD0F0B07),
                    Color(0xBB1A1008),
                    Color(0xEE0F0B07),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _NoisePainter())),

          // ── Content: LayoutBuilder so it always fits without scrolling ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  // Only scrolls if screen is genuinely tiny; on Note 10+ fits perfectly
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ── Top section ──────────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WreckLog',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w700)),

                              const SizedBox(height: 18),

                              const Text('STOP',
                                  style: TextStyle(
                                      color: Color(0xFFE8700A),
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      height: 1.0)),
                              const Text('losing track of parts.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2)),

                              const SizedBox(height: 14),

                              const Text(
                                'Track removals.\nManage listings.\nKnow what\'s for sale.',
                                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.6),
                              ),

                              const SizedBox(height: 20),

                              // CTA button
                              GestureDetector(
                                onTap: () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const AppShell(allowEmpty: true))),
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4620A),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE8700A).withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Start Logging',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3)),
                                ),
                              ),

                              const SizedBox(height: 12),

                              _checkRow('Free: 1 vehicle + 5 parts'),
                              const SizedBox(height: 6),
                              _checkRow('No account required'),
                            ],
                          ),

                          // ── Bottom section: cards + mockup ───────────
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 4),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: sw * 0.44,
                                      child: const Column(
                                        children: [
                                          _StatCard(
                                              icon: Icons.build_rounded,
                                              label: 'For Sale',
                                              sub: '6 parts'),
                                          SizedBox(height: 8),
                                          _StatCard(
                                              icon: Icons.inventory_2_rounded,
                                              label: 'In Stock',
                                              sub: '14 parts'),
                                          SizedBox(height: 8),
                                          _StatCard(
                                              icon: Icons.attach_money_rounded,
                                              label: 'Sold',
                                              sub: '9 parts'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: _AppPreviewMockup(width: sw * 0.44)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String text) => Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      );
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _StatCard({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE8700A), size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              Text(sub,
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Phone mockup ───────────────────────────────────────────────────────────────
class _AppPreviewMockup extends StatelessWidget {
  final double width;
  const _AppPreviewMockup({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 24,
              offset: const Offset(4, 8)),
          BoxShadow(
              color: const Color(0xFFE8700A).withValues(alpha: 0.12),
              blurRadius: 30,
              spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          children: [
            // Status bar
            Container(
              color: const Color(0xFF0A0A0A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1:55',
                      style: TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  Icon(Icons.wifi, color: Colors.white, size: 10),
                ],
              ),
            ),
            // App bar
            Container(
              color: const Color(0xFF0A0A0A),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('WreckLog',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Icon(Icons.notifications_none_rounded, color: Colors.white54, size: 13),
                ],
              ),
            ),
            // Tabs
            Container(
              color: const Color(0xFF141414),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                children: [
                  _tab('Inventory', true),
                  const SizedBox(width: 8),
                  _tab('For Sale', false),
                  const SizedBox(width: 8),
                  _tab('Sold', false),
                ],
              ),
            ),
            // Vehicle card
            Container(
              margin: const EdgeInsets.all(7),
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/hero_dismantled_car.png',
                        fit: BoxFit.cover, alignment: Alignment.center),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 5,
                      left: 7,
                      child: Text('2020 BMW X5 · Black',
                          style: TextStyle(
                              color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
            _partRow('Alternator', '\$65.00', 'In Stock'),
            _partRow('Passenger Door', '\$175.00', 'For Sale'),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              height: 26,
              decoration: BoxDecoration(
                  color: const Color(0xFFD4620A),
                  borderRadius: BorderRadius.circular(7)),
              child: const Center(
                child: Text('+ Add Part',
                    style: TextStyle(
                        color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              color: const Color(0xFF0A0A0A),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavIco(Icons.inventory_2_outlined, 'Inventory', true),
                  _NavIco(Icons.search, 'Search', false),
                  _NavIco(Icons.directions_car_outlined, 'Vehicles', false),
                  _NavIco(Icons.settings_outlined, 'Settings', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tab(String label, bool sel) => Text(label,
      style: TextStyle(
          color: sel ? const Color(0xFFE8700A) : Colors.white30,
          fontSize: 8,
          fontWeight: sel ? FontWeight.bold : FontWeight.normal));

  static Widget _partRow(String name, String price, String status) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
              Text(status,
                  style: const TextStyle(color: Colors.white38, fontSize: 7)),
            ]),
            Text(price,
                style: const TextStyle(
                    color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _NavIco extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavIco(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    final c = active ? const Color(0xFFE8700A) : Colors.white30;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: c, size: 11),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: c, fontSize: 6)),
    ]);
  }
}

// ── Noise texture ──────────────────────────────────────────────────────────────
class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.015);
    const s = 4.0;
    for (double x = 0; x < size.width; x += s) {
      for (double y = 0; y < size.height; y += s) {
        if (((x * 13 + y * 7) % 5) < 1.5) canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
