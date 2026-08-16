import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_check_catalog.dart';

void main() {
  group('QaCheckCatalog', () {
    test('category IDs and check IDs are unique', () {
      final categoryIds = QaCheckCatalog.categories
          .map((item) => item.id)
          .toList();
      final checkIds = QaCheckCatalog.checks.map((item) => item.id).toList();

      expect(categoryIds.toSet().length, categoryIds.length);
      expect(checkIds.toSet().length, checkIds.length);
      expect(QaCheckCatalog.checkIds.length, checkIds.length);
    });

    test('every check references an existing category', () {
      final categoryIds = QaCheckCatalog.categories
          .map((item) => item.id)
          .toSet();

      for (final check in QaCheckCatalog.checks) {
        expect(categoryIds, contains(check.categoryId), reason: check.id);
      }
    });

    test('every category contains at least one check', () {
      for (final category in QaCheckCatalog.categories) {
        expect(
          QaCheckCatalog.checksForCategory(category.id),
          isNotEmpty,
          reason: category.id,
        );
      }
    });

    test('evidence labels are non-empty technical descriptions', () {
      for (final category in QaCheckCatalog.categories) {
        expect(category.evidenceLabel.trim(), isNotEmpty);
      }
      for (final check in QaCheckCatalog.checks) {
        expect(check.evidenceLabel.trim(), isNotEmpty, reason: check.id);
      }
    });
  });
}
