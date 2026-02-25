// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionEntityCollection on Isar {
  IsarCollection<SessionEntity> get sessionEntitys => this.collection();
}

const SessionEntitySchema = CollectionSchema(
  name: r'SessionEntity',
  id: 7472964409236372477,
  properties: {
    r'abandonmentReason': PropertySchema(
      id: 0,
      name: r'abandonmentReason',
      type: IsarType.string,
    ),
    r'endedAt': PropertySchema(
      id: 1,
      name: r'endedAt',
      type: IsarType.dateTime,
    ),
    r'expectedDurationMinutes': PropertySchema(
      id: 2,
      name: r'expectedDurationMinutes',
      type: IsarType.long,
    ),
    r'halfAlertShown': PropertySchema(
      id: 3,
      name: r'halfAlertShown',
      type: IsarType.bool,
    ),
    r'id': PropertySchema(id: 4, name: r'id', type: IsarType.string),
    r'kind': PropertySchema(id: 5, name: r'kind', type: IsarType.string),
    r'label': PropertySchema(id: 6, name: r'label', type: IsarType.string),
    r'parentId': PropertySchema(
      id: 7,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'plannedAlertShown': PropertySchema(
      id: 8,
      name: r'plannedAlertShown',
      type: IsarType.bool,
    ),
    r'schemaVersion': PropertySchema(
      id: 9,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'startedAt': PropertySchema(
      id: 10,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(id: 11, name: r'status', type: IsarType.string),
    r'transitionCategory': PropertySchema(
      id: 12,
      name: r'transitionCategory',
      type: IsarType.string,
    ),
  },
  estimateSize: _sessionEntityEstimateSize,
  serialize: _sessionEntitySerialize,
  deserialize: _sessionEntityDeserialize,
  deserializeProp: _sessionEntityDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'parentId': IndexSchema(
      id: -809199838039056779,
      name: r'parentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _sessionEntityGetId,
  getLinks: _sessionEntityGetLinks,
  attach: _sessionEntityAttach,
  version: '3.1.0+1',
);

int _sessionEntityEstimateSize(
  SessionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.abandonmentReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.label.length * 3;
  {
    final value = object.parentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.transitionCategory;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sessionEntitySerialize(
  SessionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.abandonmentReason);
  writer.writeDateTime(offsets[1], object.endedAt);
  writer.writeLong(offsets[2], object.expectedDurationMinutes);
  writer.writeBool(offsets[3], object.halfAlertShown);
  writer.writeString(offsets[4], object.id);
  writer.writeString(offsets[5], object.kind);
  writer.writeString(offsets[6], object.label);
  writer.writeString(offsets[7], object.parentId);
  writer.writeBool(offsets[8], object.plannedAlertShown);
  writer.writeLong(offsets[9], object.schemaVersion);
  writer.writeDateTime(offsets[10], object.startedAt);
  writer.writeString(offsets[11], object.status);
  writer.writeString(offsets[12], object.transitionCategory);
}

SessionEntity _sessionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionEntity();
  object.abandonmentReason = reader.readStringOrNull(offsets[0]);
  object.endedAt = reader.readDateTimeOrNull(offsets[1]);
  object.expectedDurationMinutes = reader.readLong(offsets[2]);
  object.halfAlertShown = reader.readBool(offsets[3]);
  object.id = reader.readString(offsets[4]);
  object.isarId = id;
  object.kind = reader.readString(offsets[5]);
  object.label = reader.readString(offsets[6]);
  object.parentId = reader.readStringOrNull(offsets[7]);
  object.plannedAlertShown = reader.readBool(offsets[8]);
  object.schemaVersion = reader.readLong(offsets[9]);
  object.startedAt = reader.readDateTime(offsets[10]);
  object.status = reader.readString(offsets[11]);
  object.transitionCategory = reader.readStringOrNull(offsets[12]);
  return object;
}

P _sessionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionEntityGetId(SessionEntity object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _sessionEntityGetLinks(SessionEntity object) {
  return [];
}

void _sessionEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SessionEntity object,
) {
  object.isarId = id;
}

extension SessionEntityByIndex on IsarCollection<SessionEntity> {
  Future<SessionEntity?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  SessionEntity? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<SessionEntity?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<SessionEntity?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(SessionEntity object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(SessionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<SessionEntity> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(
    List<SessionEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension SessionEntityQueryWhereSort
    on QueryBuilder<SessionEntity, SessionEntity, QWhere> {
  QueryBuilder<SessionEntity, SessionEntity, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionEntityQueryWhere
    on QueryBuilder<SessionEntity, SessionEntity, QWhereClause> {
  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> isarIdEqualTo(
    Id isarId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: isarId, upper: isarId),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> isarIdLessThan(
    Id isarId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerIsarId,
          includeLower: includeLower,
          upper: upperIsarId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> idEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'id', value: [id]),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> idNotEqualTo(
    String id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [id],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'id',
                lower: [],
                upper: [id],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> statusEqualTo(
    String status,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentId', value: [null]),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'parentId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause> parentIdEqualTo(
    String? parentId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentId', value: [parentId]),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterWhereClause>
  parentIdNotEqualTo(String? parentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [],
                upper: [parentId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [parentId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [parentId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [],
                upper: [parentId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SessionEntityQueryFilter
    on QueryBuilder<SessionEntity, SessionEntity, QFilterCondition> {
  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'abandonmentReason'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'abandonmentReason'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'abandonmentReason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'abandonmentReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'abandonmentReason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'abandonmentReason', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  abandonmentReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'abandonmentReason', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endedAt'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endedAt'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endedAt', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  endedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  expectedDurationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'expectedDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  expectedDurationMinutesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expectedDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  expectedDurationMinutesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expectedDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  expectedDurationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expectedDurationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  halfAlertShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'halfAlertShown', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'id',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'id',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'id', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isarId', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  isarIdGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  isarIdLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isarId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isarId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'kind',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'kind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition> kindMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'kind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'kind', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'parentId'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'parentId'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  plannedAlertShownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plannedAlertShown', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  schemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  schemaVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'transitionCategory'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'transitionCategory'),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transitionCategory',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transitionCategory',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transitionCategory',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transitionCategory', value: ''),
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterFilterCondition>
  transitionCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transitionCategory', value: ''),
      );
    });
  }
}

extension SessionEntityQueryObject
    on QueryBuilder<SessionEntity, SessionEntity, QFilterCondition> {}

extension SessionEntityQueryLinks
    on QueryBuilder<SessionEntity, SessionEntity, QFilterCondition> {}

extension SessionEntityQuerySortBy
    on QueryBuilder<SessionEntity, SessionEntity, QSortBy> {
  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByAbandonmentReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abandonmentReason', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByAbandonmentReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abandonmentReason', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByExpectedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByExpectedDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByHalfAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halfAlertShown', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByHalfAlertShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halfAlertShown', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByPlannedAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedAlertShown', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByPlannedAlertShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedAlertShown', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByTransitionCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionCategory', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  sortByTransitionCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionCategory', Sort.desc);
    });
  }
}

extension SessionEntityQuerySortThenBy
    on QueryBuilder<SessionEntity, SessionEntity, QSortThenBy> {
  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByAbandonmentReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abandonmentReason', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByAbandonmentReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'abandonmentReason', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByExpectedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByExpectedDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByHalfAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halfAlertShown', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByHalfAlertShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'halfAlertShown', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByPlannedAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedAlertShown', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByPlannedAlertShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedAlertShown', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByTransitionCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionCategory', Sort.asc);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QAfterSortBy>
  thenByTransitionCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transitionCategory', Sort.desc);
    });
  }
}

extension SessionEntityQueryWhereDistinct
    on QueryBuilder<SessionEntity, SessionEntity, QDistinct> {
  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctByAbandonmentReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'abandonmentReason',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctByExpectedDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedDurationMinutes');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctByHalfAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'halfAlertShown');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByKind({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByLabel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByParentId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctByPlannedAlertShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedAlertShown');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntity, SessionEntity, QDistinct>
  distinctByTransitionCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'transitionCategory',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SessionEntityQueryProperty
    on QueryBuilder<SessionEntity, SessionEntity, QQueryProperty> {
  QueryBuilder<SessionEntity, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SessionEntity, String?, QQueryOperations>
  abandonmentReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'abandonmentReason');
    });
  }

  QueryBuilder<SessionEntity, DateTime?, QQueryOperations> endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<SessionEntity, int, QQueryOperations>
  expectedDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedDurationMinutes');
    });
  }

  QueryBuilder<SessionEntity, bool, QQueryOperations> halfAlertShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'halfAlertShown');
    });
  }

  QueryBuilder<SessionEntity, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionEntity, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<SessionEntity, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<SessionEntity, String?, QQueryOperations> parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<SessionEntity, bool, QQueryOperations>
  plannedAlertShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedAlertShown');
    });
  }

  QueryBuilder<SessionEntity, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<SessionEntity, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<SessionEntity, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SessionEntity, String?, QQueryOperations>
  transitionCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transitionCategory');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppMetaEntityCollection on Isar {
  IsarCollection<AppMetaEntity> get appMetaEntitys => this.collection();
}

const AppMetaEntitySchema = CollectionSchema(
  name: r'AppMetaEntity',
  id: 4798171179488078482,
  properties: {
    r'schemaVersion': PropertySchema(
      id: 0,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'sharedPrefsImported': PropertySchema(
      id: 1,
      name: r'sharedPrefsImported',
      type: IsarType.bool,
    ),
  },
  estimateSize: _appMetaEntityEstimateSize,
  serialize: _appMetaEntitySerialize,
  deserialize: _appMetaEntityDeserialize,
  deserializeProp: _appMetaEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appMetaEntityGetId,
  getLinks: _appMetaEntityGetLinks,
  attach: _appMetaEntityAttach,
  version: '3.1.0+1',
);

int _appMetaEntityEstimateSize(
  AppMetaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appMetaEntitySerialize(
  AppMetaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.schemaVersion);
  writer.writeBool(offsets[1], object.sharedPrefsImported);
}

AppMetaEntity _appMetaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppMetaEntity();
  object.id = id;
  object.schemaVersion = reader.readLong(offsets[0]);
  object.sharedPrefsImported = reader.readBool(offsets[1]);
  return object;
}

P _appMetaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appMetaEntityGetId(AppMetaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appMetaEntityGetLinks(AppMetaEntity object) {
  return [];
}

void _appMetaEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppMetaEntity object,
) {
  object.id = id;
}

extension AppMetaEntityQueryWhereSort
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QWhere> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppMetaEntityQueryWhere
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QWhereClause> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AppMetaEntityQueryFilter
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QFilterCondition> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schemaVersion', value: value),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  schemaVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  schemaVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schemaVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schemaVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterFilterCondition>
  sharedPrefsImportedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sharedPrefsImported', value: value),
      );
    });
  }
}

extension AppMetaEntityQueryObject
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QFilterCondition> {}

extension AppMetaEntityQueryLinks
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QFilterCondition> {}

extension AppMetaEntityQuerySortBy
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QSortBy> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  sortBySharedPrefsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedPrefsImported', Sort.asc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  sortBySharedPrefsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedPrefsImported', Sort.desc);
    });
  }
}

extension AppMetaEntityQuerySortThenBy
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QSortThenBy> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  thenBySharedPrefsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedPrefsImported', Sort.asc);
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QAfterSortBy>
  thenBySharedPrefsImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedPrefsImported', Sort.desc);
    });
  }
}

extension AppMetaEntityQueryWhereDistinct
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QDistinct> {
  QueryBuilder<AppMetaEntity, AppMetaEntity, QDistinct>
  distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<AppMetaEntity, AppMetaEntity, QDistinct>
  distinctBySharedPrefsImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedPrefsImported');
    });
  }
}

extension AppMetaEntityQueryProperty
    on QueryBuilder<AppMetaEntity, AppMetaEntity, QQueryProperty> {
  QueryBuilder<AppMetaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppMetaEntity, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<AppMetaEntity, bool, QQueryOperations>
  sharedPrefsImportedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedPrefsImported');
    });
  }
}
