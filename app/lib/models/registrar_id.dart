enum RegistrarId {
  godaddy('godaddy', 'GoDaddy'),
  porkbun('porkbun', 'Porkbun'),
  cloudflareregistrar('cloudflareregistrar', 'Cloudflare Registrar'),
  spaceship('spaceship', 'Spaceship'),
  namecom('namecom', 'Name.com'),
  namesilo('namesilo', 'NameSilo'),
  gandi('gandi', 'Gandi'),
  dynadot('dynadot', 'Dynadot');

  const RegistrarId(this.id, this.displayName);
  final String id;
  final String displayName;

  static RegistrarId fromId(String id) =>
      RegistrarId.values.firstWhere((r) => r.id == id);
}
