import 'package:freezed_annotation/freezed_annotation.dart';

part 'empresa.freezed.dart';
part 'empresa.g.dart';

@freezed
class Empresa with _$Empresa {
  const factory Empresa({
    String? id,
    @Default('') String nombre,
    @Default('') String nit,
  }) = _Empresa;

  factory Empresa.fromJson(Map<String, dynamic> json) => _$EmpresaFromJson(json);
}
