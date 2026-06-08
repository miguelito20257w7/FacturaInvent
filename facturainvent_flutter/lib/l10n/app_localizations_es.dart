// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'FacturaInvent';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeDescription =>
      'Esta aplicación te ayuda a agregar tus productos a tu POS';

  @override
  String get importXmlFromDian => 'Importa facturas XML de la DIAN';

  @override
  String get organizeProducts => 'Organiza tus productos automáticamente';

  @override
  String get exportToExcel => 'Exporta a Excel con un toque';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get tabBusinesses => 'Empresas';

  @override
  String get tabCreate => 'Crear';

  @override
  String get tabExport => 'Exportar';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get navigation => 'Navegación';

  @override
  String get noBusinesses => 'No hay empresas';

  @override
  String get addBusinessToStart => 'Agrega una empresa para comenzar';

  @override
  String get noProducts => 'No hay productos';

  @override
  String get importXmlToAddProducts => 'Importa un XML para agregar productos';

  @override
  String nitColon(String nit) {
    return 'NIT: $nit';
  }

  @override
  String businessColon(String name) {
    return 'Empresa: $name';
  }

  @override
  String get deleteBusinessOrChangeName => 'Eliminar empresa / Cambiar nombre';

  @override
  String get thisActionCantBeUndone => 'Esta acción es irreversible';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteQuestion => '¿Eliminar?';

  @override
  String get changeName => 'Cambiar nombre';

  @override
  String get newName => 'Nuevo nombre';

  @override
  String get addBusinessAndProducts =>
      'Agrega una empresa y sus productos aquí';

  @override
  String get addXml => 'Agregar XML';

  @override
  String get importBusiness => 'Importar empresa';

  @override
  String get importDatabase => 'Importar base de datos';

  @override
  String get importStore => 'Importar .store';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get shareJson => 'Compartir JSON';

  @override
  String get chooseJsonFile =>
      'Selecciona un archivo de respaldo JSON para importar';

  @override
  String get jsonRecommendation =>
      'JSON es portable entre iOS / macOS / Android.';

  @override
  String importedSummary(int empresas, int productos) {
    return 'Importadas $empresas empresas y $productos productos';
  }

  @override
  String get jsonReadyToShare => 'JSON listo para compartir';

  @override
  String get importConfirmTitle => '¿Reemplazar todos los datos?';

  @override
  String get importConfirmBody =>
      'Esto eliminará permanentemente todas las empresas y productos antes de restaurar el archivo. Esta acción no se puede deshacer.';

  @override
  String get replaceAll => 'Reemplazar todo';

  @override
  String get importSuccessIcon => 'Importación exitosa';

  @override
  String get jsonSharedSuccess => 'JSON compartido';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Volver';

  @override
  String get close => 'Cerrar';

  @override
  String get done => 'Listo';

  @override
  String get ok => 'OK';

  @override
  String get startOver => 'Empezar de nuevo';

  @override
  String get error => 'Error';

  @override
  String get areYouSureCancel => '¿Estás seguro de que quieres cancelar?';

  @override
  String get allDataWillBeLost => 'Todos los datos se perderán';

  @override
  String get reviewProducts => 'Revisar productos';

  @override
  String newProducts(int count) {
    return 'Productos nuevos ($count)';
  }

  @override
  String existingProducts(int count) {
    return 'Productos existentes ($count)';
  }

  @override
  String get importSuccessful => '¡Importación exitosa!';

  @override
  String productsImportedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos importados correctamente',
      one: '1 producto importado correctamente',
    );
    return '$_temp0';
  }

  @override
  String get importAnotherXml => 'Importar otro XML';

  @override
  String get preview => 'Vista previa';

  @override
  String get productInfoAndBarcode => 'Información del producto';

  @override
  String foundInBill(String value) {
    return 'Encontrado en factura: $value';
  }

  @override
  String get barcode => 'Código de barras';

  @override
  String barcodeColon(String value) {
    return 'Código de barras: $value';
  }

  @override
  String barcodeShortColon(String value) {
    return 'Barras: $value';
  }

  @override
  String get internCode => 'Código interno';

  @override
  String internCodeColon(String value) {
    return 'Código interno: $value';
  }

  @override
  String get advanced => 'Avanzado';

  @override
  String get packageToUnit => 'Paquete a unidad';

  @override
  String unitsPerPackage(int count) {
    return 'Unidades por paquete: $count';
  }

  @override
  String get unitsPerPackageLabel => 'Unidades por paquete: ';

  @override
  String get quantity => 'Cantidad';

  @override
  String get uploadItems => 'Subir items:';

  @override
  String get price => 'Precio';

  @override
  String priceColon(String value) {
    return 'Precio: $value';
  }

  @override
  String priceWithDiscount(String value) {
    return 'Precio con descuento: $value';
  }

  @override
  String get hasDiscount => 'Tiene descuento';

  @override
  String get discount => 'Descuento';

  @override
  String get removeFromImport => 'Eliminar de la importación';

  @override
  String get modifyProduct => 'Modificar producto';

  @override
  String get change => 'Cambiar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get search => 'Buscar';

  @override
  String get searchPrompt => 'Buscar empresas o productos';

  @override
  String get products => 'Productos';

  @override
  String get newXlsxFile => 'Nuevo archivo XLSX';

  @override
  String get firstAddXmlFile => 'Primero agrega un archivo XML';

  @override
  String get excelGenerated => 'Excel generado';

  @override
  String get fileReadyToExport => 'El archivo está listo para exportar.';

  @override
  String get shareExcel => 'Compartir Excel';

  @override
  String get saveTo => 'Guardar en...';

  @override
  String xmlPrefixColon(String value) {
    return 'XML: $value';
  }

  @override
  String get success => 'Éxito';
}
