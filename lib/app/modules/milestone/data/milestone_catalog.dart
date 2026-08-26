/// DEPRECATED compatibility file.
///
/// Katalog milestone tidak lagi ditentukan oleh Flutter.
/// Source of truth berada pada Flask `services/milestone_service.py`
/// dan tabel `milestone_rewards`.
abstract final class MilestoneCatalog {
  static const bool backendIsSourceOfTruth = true;
}
