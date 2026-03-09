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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'subject_type.dart' as _i2;
import 'program.dart' as _i3;
import 'package:citesched_client/src/protocol/protocol.dart' as _i4;

abstract class Subject implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
