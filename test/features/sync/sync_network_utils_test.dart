import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/sync/domain/sync_network_utils.dart';

void main() {
  group('isPrivateIpv4', () {
    test('accepts RFC1918-ish private ranges', () {
      expect(isPrivateIpv4('192.168.1.5'), isTrue);
      expect(isPrivateIpv4('10.0.0.2'), isTrue);
      expect(isPrivateIpv4('172.16.4.9'), isTrue);
    });

    test('rejects public and link-local addresses', () {
      expect(isPrivateIpv4('8.8.8.8'), isFalse);
      expect(isPrivateIpv4('169.254.1.1'), isFalse);
      expect(isPrivateIpv4('1.2.3.4'), isFalse);
    });
  });

  group('isVirtualAdapter', () {
    test('flags known virtual/tunnel adapter names (case-insensitive)', () {
      expect(isVirtualAdapter('vEthernet (WSL)'), isTrue);
      expect(isVirtualAdapter('VMware Network Adapter'), isTrue);
      expect(isVirtualAdapter('Hyper-V Virtual Ethernet'), isTrue);
      expect(isVirtualAdapter('Docker Desktop'), isTrue);
      expect(isVirtualAdapter('Tailscale'), isTrue);
    });

    test('leaves real Wi-Fi / Ethernet adapters alone', () {
      expect(isVirtualAdapter('Wi-Fi'), isFalse);
      expect(isVirtualAdapter('Ethernet'), isFalse);
      expect(isVirtualAdapter('wlan0'), isFalse);
      expect(isVirtualAdapter('eth0'), isFalse);
    });
  });

  group('selectPairingIp', () {
    test('prefers a private IP on a non-virtual adapter', () {
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'vEthernet (WSL)', ipv4Addresses: ['172.20.0.1']),
        NetworkAdapter(name: 'Wi-Fi', ipv4Addresses: ['192.168.1.42']),
      ]);
      expect(ip, '192.168.1.42');
    });

    test('skips a non-virtual adapter that only has a public IP', () {
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'Ethernet', ipv4Addresses: ['8.8.8.8']),
        NetworkAdapter(name: 'Wi-Fi', ipv4Addresses: ['10.0.0.7']),
      ]);
      expect(ip, '10.0.0.7');
    });

    test('falls back to a private IP on a virtual adapter when nothing else', () {
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'Ethernet', ipv4Addresses: ['203.0.113.5']),
        NetworkAdapter(name: 'Docker Desktop', ipv4Addresses: ['172.17.0.1']),
      ]);
      expect(ip, '172.17.0.1');
    });

    test('last resort: first address of the first adapter', () {
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'Ethernet', ipv4Addresses: ['203.0.113.9']),
        NetworkAdapter(name: 'Wi-Fi', ipv4Addresses: ['198.51.100.2']),
      ]);
      expect(ip, '203.0.113.9');
    });

    test('the first-adapter fallback only looks at the first adapter', () {
      // Mirrors the historical behavior: an empty first adapter falls through
      // to loopback rather than borrowing the second adapter's address.
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'Ethernet', ipv4Addresses: []),
        NetworkAdapter(name: 'Wi-Fi', ipv4Addresses: ['203.0.113.9']),
      ]);
      expect(ip, '127.0.0.1');
    });

    test('empty adapter list yields loopback', () {
      expect(selectPairingIp(const []), '127.0.0.1');
    });

    test('a virtual adapter with a private IP still beats a public non-virtual', () {
      final ip = selectPairingIp(const [
        NetworkAdapter(name: 'Wi-Fi', ipv4Addresses: ['8.8.4.4']),
        NetworkAdapter(name: 'vEthernet (WSL)', ipv4Addresses: ['192.168.99.1']),
      ]);
      expect(ip, '192.168.99.1');
    });
  });

  group('parseEndpoint', () {
    test('splits a normal host:port pair', () {
      final e = parseEndpoint('192.168.1.5:8283');
      expect(e, isNotNull);
      expect(e!.host, '192.168.1.5');
      expect(e.port, 8283);
    });

    test('returns null when there is no colon at all', () {
      expect(parseEndpoint('192.168.1.5'), isNull);
      expect(parseEndpoint(''), isNull);
    });

    test('port is 0 when the suffix is empty or non-numeric', () {
      expect(parseEndpoint('192.168.1.5:')!.port, 0);
      expect(parseEndpoint('192.168.1.5:abc')!.port, 0);
    });

    test('splits on the LAST colon so extra colons stay in the host', () {
      final e = parseEndpoint('a:b:1234');
      expect(e!.host, 'a:b');
      expect(e.port, 1234);
    });
  });
}
