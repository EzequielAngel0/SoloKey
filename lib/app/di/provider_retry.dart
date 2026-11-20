/// Riverpod 3 reintenta solo un provider que falla; la v1 no lo hacía y una
/// bóveda que no se descifra no mejora reintentando. Se pasa como `retry` a
/// cada `ProviderScope` (la app y las pruebas) para conservar ese comportamiento.
Duration? noProviderRetry(int retryCount, Object error) => null;
