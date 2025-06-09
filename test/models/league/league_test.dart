import 'package:flutter_test/flutter_test.dart';
import 'package:opengoalz/models/league/league.dart';

void main() {
  group('League.getLeagueDescription', () {
    test('should return "First international league" for level 0 and number 1',
        () {
      final league = League(
        id: 1,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: null,
        level: 0,
        number: 1,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'International League',
      );

      expect(league.getLeagueDescription(), 'First international league');
    });

    test('should return "Second international league" for level 0 and number 2',
        () {
      final league = League(
        id: 2,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: null,
        level: 0,
        number: 2,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'International League',
      );

      expect(league.getLeagueDescription(), 'Second international league');
    });

    test('should return "Third international league" for level 0 and number 3',
        () {
      final league = League(
        id: 3,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: null,
        level: 0,
        number: 3,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'International League',
      );

      expect(league.getLeagueDescription(), 'Third international league');
    });

    test('should return "Unknown league" for level 0 and number greater than 3',
        () {
      final league = League(
        id: 4,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: null,
        level: 0,
        number: 4,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'International League',
      );

      expect(league.getLeagueDescription(), 'Unknown league');
    });

    test(
        'should return "First league of Europe" for level 1 and continent Europe',
        () {
      final league = League(
        id: 5,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: 'Europe',
        level: 1,
        number: 1,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'First League of Europe',
      );

      expect(league.getLeagueDescription(), 'First league of Europe');
    });

    test(
        'should return "Level 2 league of Asia [1st/2]" for level 2 and continent Asia',
        () {
      final league = League(
        id: 6,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: 'Asia',
        level: 2,
        number: 1,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'Second Level League of Asia',
      );

      expect(league.getLeagueDescription(), 'Level 2 league of Asia [1st/2]');
    });

    test(
        'should return "Level 3 league of Africa [2nd/4]" for level 3 and continent Africa',
        () {
      final league = League(
        id: 7,
        idMultiverse: 1,
        seasonNumber: 1,
        continent: 'Africa',
        level: 3,
        number: 2,
        idUpperLeague: null,
        idLowerLeague: null,
        isFinished: false,
        name: 'Third Level League of Africa',
      );

      expect(league.getLeagueDescription(), 'Level 3 league of Africa [2nd/4]');
    });
  });
}
