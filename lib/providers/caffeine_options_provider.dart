import 'package:tapermind/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

class MedicationOption {
  final int? id;
  final String name;
  final String emoji;
  final double doseAmount;
  final int order;
  final bool enabled;

  MedicationOption({
    this.id,
    required this.name,
    required this.emoji,
    required this.doseAmount,
    this.order = 0,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'doseAmount': doseAmount,
      'order': order,
      'enabled': enabled,
    };
  }

  static MedicationOption fromMap(Map<String, dynamic> map, int id) {
    return MedicationOption(
      id: id,
      name: map['name'],
      emoji: map['emoji'],
      // Migration: support old 'caffeineAmount' key from previous DB records
      doseAmount: (map['doseAmount'] ?? map['caffeineAmount'] as num).toDouble(),
      order: map['order'] ?? 0,
      enabled: map['enabled'] ?? true,
    );
  }

  MedicationOption copyWith({
    int? id,
    String? name,
    String? emoji,
    double? doseAmount,
    int? order,
    bool? enabled,
  }) {
    return MedicationOption(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      doseAmount: doseAmount ?? this.doseAmount,
      order: order ?? this.order,
      enabled: enabled ?? this.enabled,
    );
  }
}

final medicationOptionsProvider = StateNotifierProvider<
  MedicationOptionsNotifier,
  AsyncValue<List<MedicationOption>>
>((ref) {
  return MedicationOptionsNotifier(ref.watch(databaseProvider));
});

class MedicationOptionsNotifier
    extends StateNotifier<AsyncValue<List<MedicationOption>>> {
  final store = intMapStoreFactory.store('caffeine_options');
  AsyncValue<Database> db;

  MedicationOptionsNotifier(this.db) : super(const AsyncValue.loading()) {
    _getOptions();
    _seedDatabase();
  }

  Future<void> _seedDatabase() async {
    await db.whenData((db) async {
      final count = await store.count(db);
      if (count == 0) {
        await store.addAll(db, [
          // Amphetamine-based stimulants (enabled by default)
          MedicationOption(name: 'Adderall 5mg IR', emoji: '💊', doseAmount: 5.0, order: 0, enabled: true).toMap(),
          MedicationOption(name: 'Adderall 10mg IR', emoji: '💊', doseAmount: 10.0, order: 1, enabled: true).toMap(),
          MedicationOption(name: 'Adderall 20mg IR', emoji: '💊', doseAmount: 20.0, order: 2, enabled: true).toMap(),
          MedicationOption(name: 'Adderall XR 10mg', emoji: '💊', doseAmount: 10.0, order: 3, enabled: true).toMap(),
          MedicationOption(name: 'Adderall XR 20mg', emoji: '💊', doseAmount: 20.0, order: 4, enabled: true).toMap(),
          MedicationOption(name: 'Adderall XR 30mg', emoji: '💊', doseAmount: 30.0, order: 5, enabled: true).toMap(),
          MedicationOption(name: 'Vyvanse 20mg', emoji: '💊', doseAmount: 20.0, order: 6, enabled: true).toMap(),
          MedicationOption(name: 'Vyvanse 30mg', emoji: '💊', doseAmount: 30.0, order: 7, enabled: true).toMap(),
          MedicationOption(name: 'Vyvanse 50mg', emoji: '💊', doseAmount: 50.0, order: 8, enabled: true).toMap(),
          MedicationOption(name: 'Dexedrine 5mg', emoji: '💊', doseAmount: 5.0, order: 9, enabled: false).toMap(),
          MedicationOption(name: 'Dexedrine 10mg', emoji: '💊', doseAmount: 10.0, order: 10, enabled: false).toMap(),
          MedicationOption(name: 'Zenzedi 5mg', emoji: '💊', doseAmount: 5.0, order: 11, enabled: false).toMap(),

          // Methylphenidate-based stimulants (enabled by default)
          MedicationOption(name: 'Ritalin 5mg IR', emoji: '💊', doseAmount: 5.0, order: 12, enabled: true).toMap(),
          MedicationOption(name: 'Ritalin 10mg IR', emoji: '💊', doseAmount: 10.0, order: 13, enabled: true).toMap(),
          MedicationOption(name: 'Ritalin 20mg IR', emoji: '💊', doseAmount: 20.0, order: 14, enabled: true).toMap(),
          MedicationOption(name: 'Concerta 18mg', emoji: '💊', doseAmount: 18.0, order: 15, enabled: true).toMap(),
          MedicationOption(name: 'Concerta 27mg', emoji: '💊', doseAmount: 27.0, order: 16, enabled: true).toMap(),
          MedicationOption(name: 'Concerta 36mg', emoji: '💊', doseAmount: 36.0, order: 17, enabled: true).toMap(),
          MedicationOption(name: 'Concerta 54mg', emoji: '💊', doseAmount: 54.0, order: 18, enabled: true).toMap(),
          MedicationOption(name: 'Focalin 5mg IR', emoji: '💊', doseAmount: 5.0, order: 19, enabled: false).toMap(),
          MedicationOption(name: 'Focalin 10mg IR', emoji: '💊', doseAmount: 10.0, order: 20, enabled: false).toMap(),
          MedicationOption(name: 'Focalin XR 10mg', emoji: '💊', doseAmount: 10.0, order: 21, enabled: false).toMap(),
          MedicationOption(name: 'Focalin XR 20mg', emoji: '💊', doseAmount: 20.0, order: 22, enabled: false).toMap(),

          // Non-stimulants (disabled by default)
          MedicationOption(name: 'Strattera 10mg', emoji: '💊', doseAmount: 10.0, order: 23, enabled: false).toMap(),
          MedicationOption(name: 'Strattera 18mg', emoji: '💊', doseAmount: 18.0, order: 24, enabled: false).toMap(),
          MedicationOption(name: 'Strattera 25mg', emoji: '💊', doseAmount: 25.0, order: 25, enabled: false).toMap(),
          MedicationOption(name: 'Strattera 40mg', emoji: '💊', doseAmount: 40.0, order: 26, enabled: false).toMap(),
          MedicationOption(name: 'Strattera 60mg', emoji: '💊', doseAmount: 60.0, order: 27, enabled: false).toMap(),
          MedicationOption(name: 'Qelbree 100mg', emoji: '💊', doseAmount: 100.0, order: 28, enabled: false).toMap(),
          MedicationOption(name: 'Qelbree 150mg', emoji: '💊', doseAmount: 150.0, order: 29, enabled: false).toMap(),
          MedicationOption(name: 'Qelbree 200mg', emoji: '💊', doseAmount: 200.0, order: 30, enabled: false).toMap(),
          MedicationOption(name: 'Intuniv 1mg', emoji: '💊', doseAmount: 1.0, order: 31, enabled: false).toMap(),
          MedicationOption(name: 'Intuniv 2mg', emoji: '💊', doseAmount: 2.0, order: 32, enabled: false).toMap(),
          MedicationOption(name: 'Kapvay 0.1mg', emoji: '💊', doseAmount: 0.1, order: 33, enabled: false).toMap(),
          MedicationOption(name: 'Kapvay 0.2mg', emoji: '💊', doseAmount: 0.2, order: 34, enabled: false).toMap(),
          MedicationOption(name: 'Wellbutrin SR 100mg', emoji: '💊', doseAmount: 100.0, order: 35, enabled: false).toMap(),
          MedicationOption(name: 'Wellbutrin SR 150mg', emoji: '💊', doseAmount: 150.0, order: 36, enabled: false).toMap(),
          MedicationOption(name: 'Wellbutrin XL 150mg', emoji: '💊', doseAmount: 150.0, order: 37, enabled: false).toMap(),
          MedicationOption(name: 'Wellbutrin XL 300mg', emoji: '💊', doseAmount: 300.0, order: 38, enabled: false).toMap(),
        ]);
        _getOptions();
      }
    });
  }

  Future<void> _getOptions() async {
    db.whenData((db) async {
      final snapshots = await store.find(db);
      final options =
          snapshots.map((snapshot) {
            return MedicationOption.fromMap(snapshot.value, snapshot.key);
          }).toList();
      options.sort((a, b) => a.order.compareTo(b.order));
      state = AsyncValue.data(options);
    });
  }

  Future<void> addOption(MedicationOption option) async {
    await db.whenData((db) async {
      await store.add(db, option.toMap());
      _getOptions();
    });
  }

  Future<void> updateOption(MedicationOption option) async {
    await db.whenData((db) async {
      await store.record(option.id!).update(db, option.toMap());
      _getOptions();
    });
  }

  Future<void> deleteOption(int id) async {
    await db.whenData((db) async {
      await store.record(id).delete(db);
      _getOptions();
    });
  }

  Future<void> reorderOptions(List<MedicationOption> reorderedOptions) async {
    await db.whenData((db) async {
      for (int i = 0; i < reorderedOptions.length; i++) {
        final option = reorderedOptions[i].copyWith(order: i);
        await store.record(option.id!).update(db, option.toMap());
      }
      _getOptions();
    });
  }

  Future<void> toggleOption(int id, bool enabled) async {
    await db.whenData((db) async {
      final snapshot = await store.record(id).get(db);
      if (snapshot != null) {
        final option = MedicationOption.fromMap(snapshot, id);
        final updatedOption = option.copyWith(enabled: enabled);
        await store.record(id).update(db, updatedOption.toMap());
        _getOptions();
      }
    });
  }

  Future<void> resetToDefaults() async {
    await db.whenData((db) async {
      await store.drop(db);
      await _seedDatabase();
    });
  }
}
