import 'package:flutter/material.dart';

const _primary = Color(0xFF1FB8B3);
const _navy = Color(0xFF123F67);
const _slate = Color(0xFF17324D);
const _muted = Color(0xFF718396);

class ServicesSection extends StatelessWidget {
  const ServicesSection({
    super.key,
    required this.categories,
    required this.onViewAll,
    required this.onSelectService,
  });

  final List<Map<String, dynamic>> categories;
  final VoidCallback onViewAll;
  final ValueChanged<String> onSelectService;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FIND HELP',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 10,
                          letterSpacing: 1.45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'What help do you need?',
                        style: TextStyle(
                          color: _slate,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose a service to see workers who can help.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onViewAll, child: const Text('See All')),
              ],
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 103,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final c = categories[index];
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 5,
                  shadowColor: _navy.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(19),
                  child: InkWell(
                    onTap: () => onSelectService(c['slug']?.toString() ?? ''),
                    borderRadius: BorderRadius.circular(19),
                    child: SizedBox(
                      width: 108,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 11,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _iconFor(c['icon']?.toString()),
                              color: _primary,
                              size: 26,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              c['name']?.toString() ?? 'Service',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (c['workers_count'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${c['workers_count']} workers',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ],
                        ),
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
}

IconData _iconFor(String? icon) {
  switch (icon) {
    case 'cleaning_services':
      return Icons.cleaning_services_outlined;
    case 'local_laundry_service':
      return Icons.local_laundry_service_outlined;
    case 'child_care':
      return Icons.child_care_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'elderly':
      return Icons.elderly_outlined;
    case 'yard':
      return Icons.yard_outlined;
    case 'security':
      return Icons.security_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'business':
      return Icons.business_outlined;
    case 'hotel':
      return Icons.hotel_outlined;
    case 'volunteer_activism':
      return Icons.volunteer_activism_outlined;
    case 'family_restroom':
      return Icons.family_restroom_outlined;
    case 'agriculture':
      return Icons.agriculture_outlined;
    case 'pets':
      return Icons.pets_outlined;
    default:
      return Icons.work_outline_rounded;
  }
}
