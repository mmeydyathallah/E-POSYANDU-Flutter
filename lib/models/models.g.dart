// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBalitaCollection on Isar {
  IsarCollection<Balita> get balitas => this.collection();
}

const BalitaSchema = CollectionSchema(
  name: r'Balita',
  id: -7793905177609335657,
  properties: {
    r'berat': PropertySchema(
      id: 0,
      name: r'berat',
      type: IsarType.double,
    ),
    r'displayStatus': PropertySchema(
      id: 1,
      name: r'displayStatus',
      type: IsarType.string,
    ),
    r'fotoProfile': PropertySchema(
      id: 2,
      name: r'fotoProfile',
      type: IsarType.string,
    ),
    r'jenisKelamin': PropertySchema(
      id: 3,
      name: r'jenisKelamin',
      type: IsarType.string,
    ),
    r'keterangan': PropertySchema(
      id: 4,
      name: r'keterangan',
      type: IsarType.string,
    ),
    r'lingkarKepala': PropertySchema(
      id: 5,
      name: r'lingkarKepala',
      type: IsarType.double,
    ),
    r'nama': PropertySchema(
      id: 6,
      name: r'nama',
      type: IsarType.string,
    ),
    r'namaAyah': PropertySchema(
      id: 7,
      name: r'namaAyah',
      type: IsarType.string,
    ),
    r'namaIbu': PropertySchema(
      id: 8,
      name: r'namaIbu',
      type: IsarType.string,
    ),
    r'riwayat': PropertySchema(
      id: 9,
      name: r'riwayat',
      type: IsarType.objectList,
      target: r'Riwayat',
    ),
    r'tanggalDaftar': PropertySchema(
      id: 10,
      name: r'tanggalDaftar',
      type: IsarType.string,
    ),
    r'tanggalLahir': PropertySchema(
      id: 11,
      name: r'tanggalLahir',
      type: IsarType.string,
    ),
    r'tinggi': PropertySchema(
      id: 12,
      name: r'tinggi',
      type: IsarType.double,
    ),
    r'uid': PropertySchema(
      id: 13,
      name: r'uid',
      type: IsarType.string,
    ),
    r'usia': PropertySchema(
      id: 14,
      name: r'usia',
      type: IsarType.long,
    )
  },
  estimateSize: _balitaEstimateSize,
  serialize: _balitaSerialize,
  deserialize: _balitaDeserialize,
  deserializeProp: _balitaDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'Riwayat': RiwayatSchema},
  getId: _balitaGetId,
  getLinks: _balitaGetLinks,
  attach: _balitaAttach,
  version: '3.1.0+1',
);

int _balitaEstimateSize(
  Balita object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayStatus.length * 3;
  {
    final value = object.fotoProfile;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.jenisKelamin;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.keterangan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nama;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.namaAyah;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.namaIbu;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.riwayat;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Riwayat]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += RiwayatSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.tanggalDaftar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tanggalLahir;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.uid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _balitaSerialize(
  Balita object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.berat);
  writer.writeString(offsets[1], object.displayStatus);
  writer.writeString(offsets[2], object.fotoProfile);
  writer.writeString(offsets[3], object.jenisKelamin);
  writer.writeString(offsets[4], object.keterangan);
  writer.writeDouble(offsets[5], object.lingkarKepala);
  writer.writeString(offsets[6], object.nama);
  writer.writeString(offsets[7], object.namaAyah);
  writer.writeString(offsets[8], object.namaIbu);
  writer.writeObjectList<Riwayat>(
    offsets[9],
    allOffsets,
    RiwayatSchema.serialize,
    object.riwayat,
  );
  writer.writeString(offsets[10], object.tanggalDaftar);
  writer.writeString(offsets[11], object.tanggalLahir);
  writer.writeDouble(offsets[12], object.tinggi);
  writer.writeString(offsets[13], object.uid);
  writer.writeLong(offsets[14], object.usia);
}

Balita _balitaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Balita(
    berat: reader.readDoubleOrNull(offsets[0]),
    fotoProfile: reader.readStringOrNull(offsets[2]),
    id: id,
    jenisKelamin: reader.readStringOrNull(offsets[3]),
    keterangan: reader.readStringOrNull(offsets[4]),
    lingkarKepala: reader.readDoubleOrNull(offsets[5]),
    nama: reader.readStringOrNull(offsets[6]),
    namaAyah: reader.readStringOrNull(offsets[7]),
    namaIbu: reader.readStringOrNull(offsets[8]),
    riwayat: reader.readObjectList<Riwayat>(
      offsets[9],
      RiwayatSchema.deserialize,
      allOffsets,
      Riwayat(),
    ),
    tanggalDaftar: reader.readStringOrNull(offsets[10]),
    tanggalLahir: reader.readStringOrNull(offsets[11]),
    tinggi: reader.readDoubleOrNull(offsets[12]),
    uid: reader.readStringOrNull(offsets[13]),
    usia: reader.readLongOrNull(offsets[14]),
  );
  return object;
}

P _balitaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readObjectList<Riwayat>(
        offset,
        RiwayatSchema.deserialize,
        allOffsets,
        Riwayat(),
      )) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _balitaGetId(Balita object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _balitaGetLinks(Balita object) {
  return [];
}

void _balitaAttach(IsarCollection<dynamic> col, Id id, Balita object) {
  object.id = id;
}

extension BalitaByIndex on IsarCollection<Balita> {
  Future<Balita?> getByUid(String? uid) {
    return getByIndex(r'uid', [uid]);
  }

  Balita? getByUidSync(String? uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String? uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String? uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<Balita?>> getAllByUid(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<Balita?> getAllByUidSync(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String?> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(Balita object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(Balita object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<Balita> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<Balita> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension BalitaQueryWhereSort on QueryBuilder<Balita, Balita, QWhere> {
  QueryBuilder<Balita, Balita, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BalitaQueryWhere on QueryBuilder<Balita, Balita, QWhereClause> {
  QueryBuilder<Balita, Balita, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [null],
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'uid',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> uidEqualTo(String? uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterWhereClause> uidNotEqualTo(String? uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BalitaQueryFilter on QueryBuilder<Balita, Balita, QFilterCondition> {
  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'berat',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'berat',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> beratBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'berat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> displayStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition>
      displayStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fotoProfile',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fotoProfile',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fotoProfile',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fotoProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fotoProfile',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoProfile',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> fotoProfileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fotoProfile',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jenisKelamin',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jenisKelamin',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jenisKelamin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jenisKelamin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jenisKelamin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jenisKelamin',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> jenisKelaminIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jenisKelamin',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'keterangan',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'keterangan',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keterangan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keterangan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keterangan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keterangan',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> keteranganIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keterangan',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lingkarKepala',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lingkarKepala',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> lingkarKepalaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lingkarKepala',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nama',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nama',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nama',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaAyah',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaAyah',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaAyah',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaAyah',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaAyah',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaAyah',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaAyahIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaAyah',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'namaIbu',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'namaIbu',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'namaIbu',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'namaIbu',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'namaIbu',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'namaIbu',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> namaIbuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'namaIbu',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'riwayat',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'riwayat',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'riwayat',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalDaftar',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalDaftar',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalDaftar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggalDaftar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggalDaftar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalDaftarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalDaftar',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition>
      tanggalDaftarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggalDaftar',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggalLahir',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggalLahir',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggalLahir',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggalLahir',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggalLahir',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggalLahir',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tanggalLahirIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggalLahir',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tinggi',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tinggi',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> tinggiBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tinggi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'uid',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usia',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usia',
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usia',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usia',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usia',
        value: value,
      ));
    });
  }

  QueryBuilder<Balita, Balita, QAfterFilterCondition> usiaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BalitaQueryObject on QueryBuilder<Balita, Balita, QFilterCondition> {
  QueryBuilder<Balita, Balita, QAfterFilterCondition> riwayatElement(
      FilterQuery<Riwayat> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'riwayat');
    });
  }
}

extension BalitaQueryLinks on QueryBuilder<Balita, Balita, QFilterCondition> {}

extension BalitaQuerySortBy on QueryBuilder<Balita, Balita, QSortBy> {
  QueryBuilder<Balita, Balita, QAfterSortBy> sortByBerat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'berat', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByBeratDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'berat', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByDisplayStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayStatus', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByDisplayStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayStatus', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByFotoProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoProfile', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByFotoProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoProfile', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByJenisKelamin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jenisKelamin', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByJenisKelaminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jenisKelamin', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByKeterangan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByKeteranganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByLingkarKepala() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lingkarKepala', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByLingkarKepalaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lingkarKepala', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNamaAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaAyah', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNamaAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaAyah', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNamaIbu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaIbu', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByNamaIbuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaIbu', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTanggalDaftar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDaftar', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTanggalDaftarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDaftar', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTanggalLahir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalLahir', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTanggalLahirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalLahir', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTinggi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tinggi', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByTinggiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tinggi', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByUsia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usia', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> sortByUsiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usia', Sort.desc);
    });
  }
}

extension BalitaQuerySortThenBy on QueryBuilder<Balita, Balita, QSortThenBy> {
  QueryBuilder<Balita, Balita, QAfterSortBy> thenByBerat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'berat', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByBeratDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'berat', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByDisplayStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayStatus', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByDisplayStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayStatus', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByFotoProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoProfile', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByFotoProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoProfile', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByJenisKelamin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jenisKelamin', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByJenisKelaminDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jenisKelamin', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByKeterangan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByKeteranganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keterangan', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByLingkarKepala() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lingkarKepala', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByLingkarKepalaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lingkarKepala', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNamaAyah() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaAyah', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNamaAyahDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaAyah', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNamaIbu() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaIbu', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByNamaIbuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'namaIbu', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTanggalDaftar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDaftar', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTanggalDaftarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalDaftar', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTanggalLahir() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalLahir', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTanggalLahirDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tanggalLahir', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTinggi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tinggi', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByTinggiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tinggi', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByUsia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usia', Sort.asc);
    });
  }

  QueryBuilder<Balita, Balita, QAfterSortBy> thenByUsiaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usia', Sort.desc);
    });
  }
}

extension BalitaQueryWhereDistinct on QueryBuilder<Balita, Balita, QDistinct> {
  QueryBuilder<Balita, Balita, QDistinct> distinctByBerat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'berat');
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByDisplayStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByFotoProfile(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fotoProfile', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByJenisKelamin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jenisKelamin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByKeterangan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keterangan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByLingkarKepala() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lingkarKepala');
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByNama(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByNamaAyah(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaAyah', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByNamaIbu(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'namaIbu', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByTanggalDaftar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalDaftar',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByTanggalLahir(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tanggalLahir', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByTinggi() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tinggi');
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Balita, Balita, QDistinct> distinctByUsia() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usia');
    });
  }
}

extension BalitaQueryProperty on QueryBuilder<Balita, Balita, QQueryProperty> {
  QueryBuilder<Balita, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Balita, double?, QQueryOperations> beratProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'berat');
    });
  }

  QueryBuilder<Balita, String, QQueryOperations> displayStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayStatus');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> fotoProfileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fotoProfile');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> jenisKelaminProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jenisKelamin');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> keteranganProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keterangan');
    });
  }

  QueryBuilder<Balita, double?, QQueryOperations> lingkarKepalaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lingkarKepala');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> namaAyahProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaAyah');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> namaIbuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'namaIbu');
    });
  }

  QueryBuilder<Balita, List<Riwayat>?, QQueryOperations> riwayatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'riwayat');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> tanggalDaftarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalDaftar');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> tanggalLahirProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tanggalLahir');
    });
  }

  QueryBuilder<Balita, double?, QQueryOperations> tinggiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tinggi');
    });
  }

  QueryBuilder<Balita, String?, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Balita, int?, QQueryOperations> usiaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usia');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppConfigCollection on Isar {
  IsarCollection<AppConfig> get appConfigs => this.collection();
}

const AppConfigSchema = CollectionSchema(
  name: r'AppConfig',
  id: -7085420701237142207,
  properties: {
    r'adminName': PropertySchema(
      id: 0,
      name: r'adminName',
      type: IsarType.string,
    ),
    r'adminPhoto': PropertySchema(
      id: 1,
      name: r'adminPhoto',
      type: IsarType.string,
    ),
    r'posyanduName': PropertySchema(
      id: 2,
      name: r'posyanduName',
      type: IsarType.string,
    )
  },
  estimateSize: _appConfigEstimateSize,
  serialize: _appConfigSerialize,
  deserialize: _appConfigDeserialize,
  deserializeProp: _appConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appConfigGetId,
  getLinks: _appConfigGetLinks,
  attach: _appConfigAttach,
  version: '3.1.0+1',
);

int _appConfigEstimateSize(
  AppConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.adminName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.adminPhoto;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.posyanduName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appConfigSerialize(
  AppConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.adminName);
  writer.writeString(offsets[1], object.adminPhoto);
  writer.writeString(offsets[2], object.posyanduName);
}

AppConfig _appConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppConfig(
    adminName: reader.readStringOrNull(offsets[0]),
    adminPhoto: reader.readStringOrNull(offsets[1]),
    posyanduName: reader.readStringOrNull(offsets[2]),
  );
  object.id = id;
  return object;
}

P _appConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appConfigGetId(AppConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appConfigGetLinks(AppConfig object) {
  return [];
}

void _appConfigAttach(IsarCollection<dynamic> col, Id id, AppConfig object) {
  object.id = id;
}

extension AppConfigQueryWhereSort
    on QueryBuilder<AppConfig, AppConfig, QWhere> {
  QueryBuilder<AppConfig, AppConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppConfigQueryWhere
    on QueryBuilder<AppConfig, AppConfig, QWhereClause> {
  QueryBuilder<AppConfig, AppConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppConfigQueryFilter
    on QueryBuilder<AppConfig, AppConfig, QFilterCondition> {
  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'adminName',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'adminName',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adminName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'adminName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'adminName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adminName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'adminName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'adminPhoto',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminPhotoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'adminPhoto',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminPhotoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'adminPhoto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminPhotoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'adminPhoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> adminPhotoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'adminPhoto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminPhotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'adminPhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      adminPhotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'adminPhoto',
        value: '',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'posyanduName',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'posyanduName',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> posyanduNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> posyanduNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'posyanduName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'posyanduName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition> posyanduNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'posyanduName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'posyanduName',
        value: '',
      ));
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterFilterCondition>
      posyanduNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'posyanduName',
        value: '',
      ));
    });
  }
}

extension AppConfigQueryObject
    on QueryBuilder<AppConfig, AppConfig, QFilterCondition> {}

extension AppConfigQueryLinks
    on QueryBuilder<AppConfig, AppConfig, QFilterCondition> {}

extension AppConfigQuerySortBy on QueryBuilder<AppConfig, AppConfig, QSortBy> {
  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByAdminName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminName', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByAdminNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminName', Sort.desc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByAdminPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminPhoto', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByAdminPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminPhoto', Sort.desc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByPosyanduName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posyanduName', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> sortByPosyanduNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posyanduName', Sort.desc);
    });
  }
}

extension AppConfigQuerySortThenBy
    on QueryBuilder<AppConfig, AppConfig, QSortThenBy> {
  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByAdminName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminName', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByAdminNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminName', Sort.desc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByAdminPhoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminPhoto', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByAdminPhotoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'adminPhoto', Sort.desc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByPosyanduName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posyanduName', Sort.asc);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QAfterSortBy> thenByPosyanduNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'posyanduName', Sort.desc);
    });
  }
}

extension AppConfigQueryWhereDistinct
    on QueryBuilder<AppConfig, AppConfig, QDistinct> {
  QueryBuilder<AppConfig, AppConfig, QDistinct> distinctByAdminName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adminName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QDistinct> distinctByAdminPhoto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'adminPhoto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppConfig, AppConfig, QDistinct> distinctByPosyanduName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'posyanduName', caseSensitive: caseSensitive);
    });
  }
}

extension AppConfigQueryProperty
    on QueryBuilder<AppConfig, AppConfig, QQueryProperty> {
  QueryBuilder<AppConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppConfig, String?, QQueryOperations> adminNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adminName');
    });
  }

  QueryBuilder<AppConfig, String?, QQueryOperations> adminPhotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'adminPhoto');
    });
  }

  QueryBuilder<AppConfig, String?, QQueryOperations> posyanduNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'posyanduName');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RiwayatSchema = Schema(
  name: r'Riwayat',
  id: -1499772530633941267,
  properties: {
    r'berat': PropertySchema(
      id: 0,
      name: r'berat',
      type: IsarType.double,
    ),
    r'lingkarKepala': PropertySchema(
      id: 1,
      name: r'lingkarKepala',
      type: IsarType.double,
    ),
    r'tanggal': PropertySchema(
      id: 2,
      name: r'tanggal',
      type: IsarType.string,
    ),
    r'tinggi': PropertySchema(
      id: 3,
      name: r'tinggi',
      type: IsarType.double,
    )
  },
  estimateSize: _riwayatEstimateSize,
  serialize: _riwayatSerialize,
  deserialize: _riwayatDeserialize,
  deserializeProp: _riwayatDeserializeProp,
);

int _riwayatEstimateSize(
  Riwayat object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.tanggal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _riwayatSerialize(
  Riwayat object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.berat);
  writer.writeDouble(offsets[1], object.lingkarKepala);
  writer.writeString(offsets[2], object.tanggal);
  writer.writeDouble(offsets[3], object.tinggi);
}

Riwayat _riwayatDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Riwayat(
    berat: reader.readDoubleOrNull(offsets[0]),
    lingkarKepala: reader.readDoubleOrNull(offsets[1]),
    tanggal: reader.readStringOrNull(offsets[2]),
    tinggi: reader.readDoubleOrNull(offsets[3]),
  );
  return object;
}

P _riwayatDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RiwayatQueryFilter
    on QueryBuilder<Riwayat, Riwayat, QFilterCondition> {
  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'berat',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'berat',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'berat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> beratBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'berat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> lingkarKepalaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lingkarKepala',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition>
      lingkarKepalaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lingkarKepala',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> lingkarKepalaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition>
      lingkarKepalaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> lingkarKepalaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lingkarKepala',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> lingkarKepalaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lingkarKepala',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tanggal',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tanggal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tanggal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tanggal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tanggalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tanggal',
        value: '',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tinggi',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tinggi',
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tinggi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Riwayat, Riwayat, QAfterFilterCondition> tinggiBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tinggi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension RiwayatQueryObject
    on QueryBuilder<Riwayat, Riwayat, QFilterCondition> {}
