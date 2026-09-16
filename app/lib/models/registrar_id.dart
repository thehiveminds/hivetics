enum RegistrarId {
  godaddy('godaddy', 'GoDaddy'),
  porkbun('porkbun', 'Porkbun'),
  cloudflareregistrar('cloudflareregistrar', 'Cloudflare Registrar');

  const RegistrarId(this.id, this.displayName);
  final String id;
  final String displayName;

  static RegistrarId fromId(String id) =>
      RegistrarId.values.firstWhere((r) => r.id == id);
}
