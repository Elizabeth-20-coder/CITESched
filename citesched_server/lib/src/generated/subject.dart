/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'subject_type.dart' as _i2;
import 'program.dart' as _i3;
import 'package:citesched_server/src/generated/protocol.dart' as _i4;

abstract class Subject
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Subject._({
    this.id,
    required this.code,
    required this.name,
    required this.units,
    this.hours,
    this.yearLevel,
    this.term,
    this.facultyId,
    required this.types,
    required this.program,
    required this.studentsCount,
    bool? isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : isActive = isActive ?? true;

  factory Subject({
    int? id,
    required String code,
    required String name,
    required int units,
    double? hours,
    int? yearLevel,
    int? term,
    int? facultyId,
    required List<_i2.SubjectType> types,
    required _i3.Program program,
    required int studentsCount,
    bool? isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubjectImpl;

  factory Subject.fromJson(Map<String, dynamic> jsonSerialization) {
    return Subject(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      units: jsonSerialization['units'] as int,
      hours: (jsonSerialization['hours'] as num?)?.toDouble(),
      yearLevel: jsonSerialization['yearLevel'] as int?,
      term: jsonSerialization['term'] as int?,
      facultyId: jsonSerialization['facultyId'] as int?,
      types: _i4.Protocol().deserialize<List<_i2.SubjectType>>(
        jsonSerialization['types'],
      ),
      program: _i3.Program.fromJson((jsonSerialization['program'] as String)),
      studentsCount: jsonSerialization['studentsCount'] as int,
      isActive: jsonSerialization['isActive'] as bool?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = SubjectTable();

  static const db = SubjectRepository._();

  @override
  int? id;

  String code;

  String name;

  int units;

  double? hours;

  int? yearLevel;

  int? term;

  int? facultyId;

  List<_i2.SubjectType> types;

  _i3.Program program;

  int studentsCount;

  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Subject]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Subject copyWith({
    int? id,
    String? code,
    String? name,
    int? units,
    double? hours,
    int? yearLevel,
    int? term,
    int? facultyId,
    List<_i2.SubjectType>? types,
    _i3.Program? program,
    int? studentsCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Subject',
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'units': units,
      if (hours != null) 'hours': hours,
      if (yearLevel != null) 'yearLevel': yearLevel,
      if (term != null) 'term': term,
      if (facultyId != null) 'facultyId': facultyId,
      'types': types.toJson(valueToJson: (v) => v.toJson()),
      'program': program.toJson(),
      'studentsCount': studentsCount,
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Subject',
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'units': units,
      if (hours != null) 'hours': hours,
      if (yearLevel != null) 'yearLevel': yearLevel,
      if (term != null) 'term': term,
      if (facultyId != null) 'facultyId': facultyId,
      'types': types.toJson(valueToJson: (v) => v.toJson()),
      'program': program.toJson(),
      'studentsCount': studentsCount,
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SubjectInclude include() {
    return SubjectInclude._();
  }

  static SubjectIncludeList includeList({
    _i1.WhereExpressionBuilder<SubjectTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubjectTable>? orderByList,
    SubjectInclude? include,
  }) {
    return SubjectIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subject.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Subject.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SubjectImpl extends Subject {
  _SubjectImpl({
    int? id,
    required String code,
    required String name,
    required int units,
    double? hours,
    int? yearLevel,
    int? term,
    int? facultyId,
    required List<_i2.SubjectType> types,
    required _i3.Program program,
    required int studentsCount,
    bool? isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         code: code,
         name: name,
         units: units,
         hours: hours,
         yearLevel: yearLevel,
         term: term,
         facultyId: facultyId,
         types: types,
         program: program,
         studentsCount: studentsCount,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Subject]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Subject copyWith({
    Object? id = _Undefined,
    String? code,
    String? name,
    int? units,
    Object? hours = _Undefined,
    Object? yearLevel = _Undefined,
    Object? term = _Undefined,
    Object? facultyId = _Undefined,
    List<_i2.SubjectType>? types,
    _i3.Program? program,
    int? studentsCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      units: units ?? this.units,
      hours: hours is double? ? hours : this.hours,
      yearLevel: yearLevel is int? ? yearLevel : this.yearLevel,
      term: term is int? ? term : this.term,
      facultyId: facultyId is int? ? facultyId : this.facultyId,
      types: types ?? this.types.map((e0) => e0).toList(),
      program: program ?? this.program,
      studentsCount: studentsCount ?? this.studentsCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SubjectUpdateTable extends _i1.UpdateTable<SubjectTable> {
  SubjectUpdateTable(super.table);

  _i1.ColumnValue<String, String> code(String value) => _i1.ColumnValue(
    table.code,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<int, int> units(int value) => _i1.ColumnValue(
    table.units,
    value,
  );

  _i1.ColumnValue<double, double> hours(double? value) => _i1.ColumnValue(
    table.hours,
    value,
  );

  _i1.ColumnValue<int, int> yearLevel(int? value) => _i1.ColumnValue(
    table.yearLevel,
    value,
  );

  _i1.ColumnValue<int, int> term(int? value) => _i1.ColumnValue(
    table.term,
    value,
  );

  _i1.ColumnValue<int, int> facultyId(int? value) => _i1.ColumnValue(
    table.facultyId,
    value,
  );

  _i1.ColumnValue<List<_i2.SubjectType>, List<_i2.SubjectType>> types(
    List<_i2.SubjectType> value,
  ) => _i1.ColumnValue(
    table.types,
    value,
  );

  _i1.ColumnValue<_i3.Program, _i3.Program> program(_i3.Program value) =>
      _i1.ColumnValue(
        table.program,
        value,
      );

  _i1.ColumnValue<int, int> studentsCount(int value) => _i1.ColumnValue(
    table.studentsCount,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class SubjectTable extends _i1.Table<int?> {
  SubjectTable({super.tableRelation}) : super(tableName: 'subject') {
    updateTable = SubjectUpdateTable(this);
    code = _i1.ColumnString(
      'code',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    units = _i1.ColumnInt(
      'units',
      this,
    );
    hours = _i1.ColumnDouble(
      'hours',
      this,
    );
    yearLevel = _i1.ColumnInt(
      'yearLevel',
      this,
    );
    term = _i1.ColumnInt(
      'term',
      this,
    );
    facultyId = _i1.ColumnInt(
      'facultyId',
      this,
    );
    types = _i1.ColumnSerializable<List<_i2.SubjectType>>(
      'types',
      this,
    );
    program = _i1.ColumnEnum(
      'program',
      this,
      _i1.EnumSerialization.byName,
    );
    studentsCount = _i1.ColumnInt(
      'studentsCount',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final SubjectUpdateTable updateTable;

  late final _i1.ColumnString code;

  late final _i1.ColumnString name;

  late final _i1.ColumnInt units;

  late final _i1.ColumnDouble hours;

  late final _i1.ColumnInt yearLevel;

  late final _i1.ColumnInt term;

  late final _i1.ColumnInt facultyId;

  late final _i1.ColumnSerializable<List<_i2.SubjectType>> types;

  late final _i1.ColumnEnum<_i3.Program> program;

  late final _i1.ColumnInt studentsCount;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    code,
    name,
    units,
    hours,
    yearLevel,
    term,
    facultyId,
    types,
    program,
    studentsCount,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class SubjectInclude extends _i1.IncludeObject {
  SubjectInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Subject.t;
}

class SubjectIncludeList extends _i1.IncludeList {
  SubjectIncludeList._({
    _i1.WhereExpressionBuilder<SubjectTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Subject.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Subject.t;
}

class SubjectRepository {
  const SubjectRepository._();

  /// Returns a list of [Subject]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Subject>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubjectTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubjectTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Subject>(
      where: where?.call(Subject.t),
      orderBy: orderBy?.call(Subject.t),
      orderByList: orderByList?.call(Subject.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Subject] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Subject?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubjectTable>? where,
    int? offset,
    _i1.OrderByBuilder<SubjectTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SubjectTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Subject>(
      where: where?.call(Subject.t),
      orderBy: orderBy?.call(Subject.t),
      orderByList: orderByList?.call(Subject.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Subject] by its [id] or null if no such row exists.
  Future<Subject?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Subject>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Subject]s in the list and returns the inserted rows.
  ///
  /// The returned [Subject]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Subject>> insert(
    _i1.Session session,
    List<Subject> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Subject>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Subject] and returns the inserted row.
  ///
  /// The returned [Subject] will have its `id` field set.
  Future<Subject> insertRow(
    _i1.Session session,
    Subject row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Subject>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Subject]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Subject>> update(
    _i1.Session session,
    List<Subject> rows, {
    _i1.ColumnSelections<SubjectTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Subject>(
      rows,
      columns: columns?.call(Subject.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subject]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Subject> updateRow(
    _i1.Session session,
    Subject row, {
    _i1.ColumnSelections<SubjectTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Subject>(
      row,
      columns: columns?.call(Subject.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Subject] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Subject?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<SubjectUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Subject>(
      id,
      columnValues: columnValues(Subject.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Subject]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Subject>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SubjectUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SubjectTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SubjectTable>? orderBy,
    _i1.OrderByListBuilder<SubjectTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Subject>(
      columnValues: columnValues(Subject.t.updateTable),
      where: where(Subject.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Subject.t),
      orderByList: orderByList?.call(Subject.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Subject]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Subject>> delete(
    _i1.Session session,
    List<Subject> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Subject>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Subject].
  Future<Subject> deleteRow(
    _i1.Session session,
    Subject row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Subject>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Subject>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SubjectTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Subject>(
      where: where(Subject.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SubjectTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Subject>(
      where: where?.call(Subject.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
