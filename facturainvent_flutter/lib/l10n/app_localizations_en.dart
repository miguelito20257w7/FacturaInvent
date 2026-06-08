// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FacturaInvent';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeDescription =>
      'This app helps you to add your products in your POS';

  @override
  String get importXmlFromDian => 'Import XML invoices from DIAN';

  @override
  String get organizeProducts => 'Organize your products automatically';

  @override
  String get exportToExcel => 'Export to Excel with one tap';

  @override
  String get continueLabel => 'Continue';

  @override
  String get tabBusinesses => 'Businesses';

  @override
  String get tabCreate => 'Create';

  @override
  String get tabExport => 'Export';

  @override
  String get tabSearch => 'Search';

  @override
  String get navigation => 'Navigation';

  @override
  String get noBusinesses => 'No businesses';

  @override
  String get addBusinessToStart => 'Add a business to start';

  @override
  String get noProducts => 'No products';

  @override
  String get importXmlToAddProducts => 'Import an XML to add products';

  @override
  String nitColon(String nit) {
    return 'NIT: $nit';
  }

  @override
  String businessColon(String name) {
    return 'Business: $name';
  }

  @override
  String get deleteBusinessOrChangeName => 'Delete Business / Change Name';

  @override
  String get thisActionCantBeUndone => 'This action can\'t be undone';

  @override
  String get delete => 'Delete';

  @override
  String get deleteQuestion => 'Delete?';

  @override
  String get changeName => 'Change Name';

  @override
  String get newName => 'New Name';

  @override
  String get addBusinessAndProducts => 'Add a business and its products here';

  @override
  String get addXml => 'Add XML';

  @override
  String get importBusiness => 'Import Business';

  @override
  String get importDatabase => 'Import Database';

  @override
  String get importStore => 'Import .store';

  @override
  String get importJson => 'Import JSON';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get shareJson => 'Share JSON';

  @override
  String get chooseJsonFile => 'Choose a JSON backup file to import';

  @override
  String get jsonRecommendation =>
      'JSON is portable between iOS / macOS / Android.';

  @override
  String importedSummary(int empresas, int productos) {
    return 'Imported $empresas businesses and $productos products';
  }

  @override
  String get jsonReadyToShare => 'JSON ready to share';

  @override
  String get importConfirmTitle => 'Replace all data?';

  @override
  String get importConfirmBody =>
      'This will permanently delete every business and product before restoring the file. This action cannot be undone.';

  @override
  String get replaceAll => 'Replace all';

  @override
  String get importSuccessIcon => 'Import successful';

  @override
  String get jsonSharedSuccess => 'JSON shared';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get startOver => 'Start Over';

  @override
  String get error => 'Error';

  @override
  String get areYouSureCancel => 'Are you sure you want to cancel?';

  @override
  String get allDataWillBeLost => 'All the data will be lost';

  @override
  String get reviewProducts => 'Review Products';

  @override
  String newProducts(int count) {
    return 'New products ($count)';
  }

  @override
  String existingProducts(int count) {
    return 'Existing products ($count)';
  }

  @override
  String get importSuccessful => 'Import successful!';

  @override
  String productsImportedSuccessfully(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products imported successfully',
      one: '1 product imported successfully',
    );
    return '$_temp0';
  }

  @override
  String get importAnotherXml => 'Import another XML';

  @override
  String get preview => 'Preview product';

  @override
  String get productInfoAndBarcode => 'Product info and barcode';

  @override
  String foundInBill(String value) {
    return 'Found in bill: $value';
  }

  @override
  String get barcode => 'Bar code';

  @override
  String barcodeColon(String value) {
    return 'Bar code: $value';
  }

  @override
  String barcodeShortColon(String value) {
    return 'Barcode: $value';
  }

  @override
  String get internCode => 'Intern Code';

  @override
  String internCodeColon(String value) {
    return 'Intern Code: $value';
  }

  @override
  String get advanced => 'Advanced';

  @override
  String get packageToUnit => 'Package to unit';

  @override
  String unitsPerPackage(int count) {
    return 'Units per package: $count';
  }

  @override
  String get unitsPerPackageLabel => 'Units per package: ';

  @override
  String get quantity => 'Quantity';

  @override
  String get uploadItems => 'Upload items:';

  @override
  String get price => 'Price';

  @override
  String priceColon(String value) {
    return 'Price: $value';
  }

  @override
  String priceWithDiscount(String value) {
    return 'Price with discount: $value';
  }

  @override
  String get hasDiscount => 'Has discount';

  @override
  String get discount => 'Discount';

  @override
  String get removeFromImport => 'Remove from import';

  @override
  String get modifyProduct => 'Modify product';

  @override
  String get change => 'Change';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get search => 'Search';

  @override
  String get searchPrompt => 'Search businesses or products';

  @override
  String get products => 'Products';

  @override
  String get newXlsxFile => 'New Xlsx File';

  @override
  String get firstAddXmlFile => 'First you need to add a XML file';

  @override
  String get excelGenerated => 'Excel generated';

  @override
  String get fileReadyToExport => 'The file is ready to export.';

  @override
  String get shareExcel => 'Share Excel';

  @override
  String get saveTo => 'Save to...';

  @override
  String xmlPrefixColon(String value) {
    return 'XML: $value';
  }

  @override
  String get success => 'Success';
}
