import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState {
  final bool mostrarAgregarXML;
  final bool mostrarConvertirAExcel;
  final bool convirtiendoAExcel;
  final bool mostrarAgregarBaseDeDatos;
  final bool showCancelButton;

  const AppState({
    this.mostrarAgregarXML = false,
    this.mostrarConvertirAExcel = false,
    this.convirtiendoAExcel = false,
    this.mostrarAgregarBaseDeDatos = false,
    this.showCancelButton = false,
  });

  AppState copyWith({
    bool? mostrarAgregarXML,
    bool? mostrarConvertirAExcel,
    bool? convirtiendoAExcel,
    bool? mostrarAgregarBaseDeDatos,
    bool? showCancelButton,
  }) {
    return AppState(
      mostrarAgregarXML: mostrarAgregarXML ?? this.mostrarAgregarXML,
      mostrarConvertirAExcel: mostrarConvertirAExcel ?? this.mostrarConvertirAExcel,
      convirtiendoAExcel: convirtiendoAExcel ?? this.convirtiendoAExcel,
      mostrarAgregarBaseDeDatos: mostrarAgregarBaseDeDatos ?? this.mostrarAgregarBaseDeDatos,
      showCancelButton: showCancelButton ?? this.showCancelButton,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => const AppState();

  void setMostrarAgregarXML(bool value) =>
      state = state.copyWith(mostrarAgregarXML: value);

  void setMostrarConvertirAExcel(bool value) =>
      state = state.copyWith(mostrarConvertirAExcel: value);

  void setConvirtiendoAExcel(bool value) =>
      state = state.copyWith(convirtiendoAExcel: value);

  void setMostrarAgregarBaseDeDatos(bool value) =>
      state = state.copyWith(mostrarAgregarBaseDeDatos: value);

  void setShowCancelButton(bool value) =>
      state = state.copyWith(showCancelButton: value);
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);
