import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/models/qa_check_catalog.dart';

// Persisted QA identifiers are part of the local-storage compatibility contract.
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

    test('persisted IDs use stable machine-readable snake case', () {
      final stableId = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');

      for (final category in QaCheckCatalog.categories) {
        expect(
          stableId.hasMatch(category.id),
          isTrue,
          reason: 'Invalid persisted category ID: ${category.id}',
        );
      }
      for (final check in QaCheckCatalog.checks) {
        expect(
          stableId.hasMatch(check.id),
          isTrue,
          reason: 'Invalid persisted check ID: ${check.id}',
        );
        expect(QaCheckCatalog.checkById(check.id), same(check));
      }
      expect(QaCheckCatalog.checkById('unknown_check'), isNull);
    });

    test('persisted check ID set is immutable', () {
      expect(
        () => QaCheckCatalog.checkIds.add('mutated_check'),
        throwsUnsupportedError,
      );
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
