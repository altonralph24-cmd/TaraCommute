class DcBusRoute {
  final String code;
  final String title;
  final List<String> amStops;

  const DcBusRoute({
    required this.code,
    required this.title,
    required this.amStops,
  });

  List<String> stopsFor(String direction) {
    if (direction == 'PM') return amStops.reversed.toList(growable: false);
    return amStops;
  }
}

const List<DcBusRoute> dcBusRoutes = [
  DcBusRoute(code: 'R102', title: 'Toril District Hall ↔ GE Torres (Sandawa)', amStops: [
    'Toril District Hall', 'Toril Proper', 'Sirawan', 'Daliao', 'Bago Aplaya',
    'Sasa', 'Panacan Church', 'Panacan Market', 'Bangoy Junction',
    'Roxas Avenue', 'Rizal Street', 'CM Recto', 'Uyanguren',
    'Bolton Cor Quirino', 'Ponciano', 'Monteverde', 'GE Torres (Sandawa)',
  ]),
  DcBusRoute(code: 'R103', title: 'Toril ↔ Roxas Avenue', amStops: [
    'Toril District Hall', 'Toril Public Market', 'Sirawan', 'Daliao',
    'Bago Aplaya', 'Sasa', 'Panacan', 'Bangoy', 'Red Cross Roxas',
  ]),
  DcBusRoute(code: 'R402', title: 'Mintal Public Market ↔ GE Torres', amStops: [
    'Mintal Public Market', 'Mintal Proper', 'Catalunan Grande',
    'Catalunan Pequeno', 'Tigatto', 'GSIS Matina', 'Matina Pangi',
    'Ecoland', 'Bankerohan', 'CM Recto', 'Uyanguren', 'Bolton Cor Quirino',
    'Ponciano', 'Monteverde', 'GE Torres (Sandawa)',
  ]),
  DcBusRoute(code: 'R403', title: 'Mintal ↔ Roxas Avenue (Davao Light)', amStops: [
    'Mintal Public Market', 'Mintal Proper', 'Catalunan Grande',
    'Catalunan Pequeno', 'Tigatto', 'GSIS Matina', 'Matina Pangi',
    'Ecoland', 'Bankerohan', 'Rizal Street', 'CM Recto', 'Uyanguren',
    'Bolton Bridge', 'Quirino Avenue', 'Ponciano', 'C. Bangoy', 'Davao Light',
  ]),
  DcBusRoute(code: 'R503', title: 'Bangkal ↔ Roxas', amStops: [
    'Hope Ave. Bangkal', 'Bangkal Proper', 'Ma-a', 'Shrine Hills',
    'Matina Crossing', 'Ecoland', 'Bankerohan', 'Rizal Street', 'CM Recto',
    'Uyanguren', 'Bolton Bridge', 'Quirino Avenue', 'C. Bangoy', 'Davao Light',
  ]),
  DcBusRoute(code: 'R603', title: 'Buhangin ↔ Roxas', amStops: [
    'Citymall Northtown', 'Buhangin Proper', 'Agdao', 'Panacan',
    'Quirino Avenue', 'Bolton Bridge', 'Uyanguren', 'CM Recto',
    'Red Cross Roxas',
  ]),
  DcBusRoute(code: 'R763', title: 'Panacan via Buhangin ↔ Roxas', amStops: [
    'Panacan Depot', 'Panacan Church', 'Buhangin Proper', 'Agdao Market',
    'Bankerohan', 'Rizal Street', 'CM Recto', 'Uyanguren', 'Bolton Bridge',
    'Quirino Avenue', 'Ponciano', 'C. Bangoy', 'Red Cross Roxas',
  ]),
  DcBusRoute(code: 'R783', title: 'Panacan via Angliongto ↔ Roxas', amStops: [
    'Panacan Depot', 'R. Castillo', 'Angliongto Ave', 'Lanang', 'JP Laurel',
    'Bajada', 'Bankerohan', 'Rizal Street', 'CM Recto', 'Uyanguren',
    'Bolton Bridge', 'Quirino Avenue', 'Ponciano', 'C. Bangoy',
    'Red Cross Roxas',
  ]),
  DcBusRoute(code: 'R793', title: 'Panacan via R. Castillo ↔ Roxas', amStops: [
    'NCCC Panacan', 'R. Castillo', 'Panacan Proper', 'McArthur Highway',
    'Agdao', 'Buhangin', 'Bankerohan', 'Rizal Street', 'CM Recto',
    'Uyanguren', 'Bolton Bridge', 'Quirino Avenue', 'Ponciano', 'C. Bangoy',
    'Obrero', 'Red Cross Roxas',
  ]),
];

const String dcBusServiceHours = 'AM: 6:00 AM–10:00 AM  •  PM: 4:00 PM–9:00 PM';
