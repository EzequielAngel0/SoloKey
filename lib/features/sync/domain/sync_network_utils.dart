// Pure, dependency-free helpers extracted from `SyncService` so the fiddly
// network-address logic (which IP to advertise in the pairing QR, how to split
// a stored endpoint) can be unit-tested WITHOUT opening sockets or standing up
// the whole sync engine. Behavior here mirrors the original inline code exactly.

/// Name fragments of typical virtual adapters (WSL, VMs, Docker, Hyper-V, VPNs).
/// Their IPs are usually unreachable from the phone, so an address on one of
/// these is only used as a last resort when picking the pairing-QR IP.
const List<String> kVirtualAdapterHints = [
  'vethernet', 'wsl', 'virtualbox', 'vmware', 'hyper-v', 'docker',
  'loopback', 'bluetooth', 'tailscale', 'zerotier', 'tunnel', 'vpn', 'radmin',
];

/// True when [ip] is in a private IPv4 range (RFC 1918-ish, matching the
/// historical prefix check used for the pairing QR).
bool isPrivateIpv4(String ip) =>
    ip.startsWith('192.168.') || ip.startsWith('10.') || ip.startsWith('172.');

/// True when [adapterName] looks like a virtual/tunnel adapter (see
/// [kVirtualAdapterHints]). Case-insensitive substring match.
bool isVirtualAdapter(String adapterName) {
  final n = adapterName.toLowerCase();
  return kVirtualAdapterHints.any(n.contains);
}

/// A network adapter reduced to just what the IP-selection needs: its name and
/// its non-loopback IPv4 addresses. Lets [selectPairingIp] stay pure (no
/// `dart:io`), so tests can feed synthetic adapter lists.
class NetworkAdapter {
  const NetworkAdapter({required this.name, required this.ipv4Addresses});

  final String name;
  final List<String> ipv4Addresses;
}

/// Chooses the best IPv4 address to advertise in the pairing QR. Preference:
///   1. a private IP on a NON-virtual adapter (real Wi-Fi/Ethernet);
///   2. any private IP, even on a virtual adapter;
///   3. the first address of the FIRST adapter (last resort);
///   4. `127.0.0.1` when there is nothing else.
///
/// This is exactly the order the original `SyncService._getLocalIp` used.
String selectPairingIp(List<NetworkAdapter> adapters) {
  // 1) Private IPv4 on a non-virtual adapter.
  for (final adapter in adapters) {
    if (isVirtualAdapter(adapter.name)) continue;
    for (final ip in adapter.ipv4Addresses) {
      if (isPrivateIpv4(ip)) return ip;
    }
  }
  // 2) Any private IPv4, even on a virtual adapter.
  for (final adapter in adapters) {
    for (final ip in adapter.ipv4Addresses) {
      if (isPrivateIpv4(ip)) return ip;
    }
  }
  // 3) First address of the first adapter (mirrors the historical fallback).
  if (adapters.isNotEmpty && adapters.first.ipv4Addresses.isNotEmpty) {
    return adapters.first.ipv4Addresses.first;
  }
  // 4) Loopback.
  return '127.0.0.1';
}

/// A "host:port" endpoint split on its LAST colon (so an IPv4 host and an
/// explicit port survive). [port] is 0 when the suffix isn't a number, matching
/// the original behavior where the connection then simply fails.
class SyncEndpoint {
  const SyncEndpoint(this.host, this.port);

  final String host;
  final int port;
}

/// Parses a stored `host:port` endpoint. Returns null only when there is no
/// colon at all (mirrors the original `!endpoint.contains(':')` guard).
SyncEndpoint? parseEndpoint(String endpoint) {
  if (!endpoint.contains(':')) return null;
  final sep = endpoint.lastIndexOf(':');
  final host = endpoint.substring(0, sep);
  final port = int.tryParse(endpoint.substring(sep + 1)) ?? 0;
  return SyncEndpoint(host, port);
}
