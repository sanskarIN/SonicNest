import 'package:flutter_test/flutter_test.dart';
import 'package:sonic_nest/core/constants.dart';

void main() {
  test('Gumroad storefront URL is the canonical HTTPS destination', () {
    expect(AppConstants.gumroadStoreUrl, 'https://ramsandesh.gumroad.com');

    final uri = Uri.parse(AppConstants.gumroadStoreUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'ramsandesh.gumroad.com');
    expect(uri.path, isEmpty);
    expect(uri.query, isEmpty);
    expect(uri.fragment, isEmpty);
  });
}
