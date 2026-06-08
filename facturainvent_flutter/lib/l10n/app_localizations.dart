import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FacturaInvent'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'This app helps you to add your products in your POS'**
  String get welcomeDescription;

  /// No description provided for @importXmlFromDian.
  ///
  /// In en, this message translates to:
  /// **'Import XML invoices from DIAN'**
  String get importXmlFromDian;

  /// No description provided for @organizeProducts.
  ///
  /// In en, this message translates to:
  /// **'Organize your products automatically'**
  String get organizeProducts;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel with one tap'**
  String get exportToExcel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @tabBusinesses.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get tabBusinesses;

  /// No description provided for @tabCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tabCreate;

  /// No description provided for @tabExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get tabExport;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @noBusinesses.
  ///
  /// In en, this message translates to:
  /// **'No businesses'**
  String get noBusinesses;

  /// No description provided for @addBusinessToStart.
  ///
  /// In en, this message translates to:
  /// **'Add a business to start'**
  String get addBusinessToStart;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @importXmlToAddProducts.
  ///
  /// In en, this message translates to:
  /// **'Import an XML to add products'**
  String get importXmlToAddProducts;

  /// No description provided for @nitColon.
  ///
  /// In en, this message translates to:
  /// **'NIT: {nit}'**
  String nitColon(String nit);

  /// No description provided for @businessColon.
  ///
  /// In en, this message translates to:
  /// **'Business: {name}'**
  String businessColon(String name);

  /// No description provided for @deleteBusinessOrChangeName.
  ///
  /// In en, this message translates to:
  /// **'Delete Business / Change Name'**
  String get deleteBusinessOrChangeName;

  /// No description provided for @thisActionCantBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone'**
  String get thisActionCantBeUndone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteQuestion;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get changeName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get newName;

  /// No description provided for @addBusinessAndProducts.
  ///
  /// In en, this message translates to:
  /// **'Add a business and its products here'**
  String get addBusinessAndProducts;

  /// No description provided for @addXml.
  ///
  /// In en, this message translates to:
  /// **'Add XML'**
  String get addXml;

  /// No description provided for @importBusiness.
  ///
  /// In en, this message translates to:
  /// **'Import Business'**
  String get importBusiness;

  /// No description provided for @importDatabase.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// No description provided for @importStore.
  ///
  /// In en, this message translates to:
  /// **'Import .store'**
  String get importStore;

  /// No description provided for @importJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJson;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @shareJson.
  ///
  /// In en, this message translates to:
  /// **'Share JSON'**
  String get shareJson;

  /// No description provided for @chooseJsonFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a JSON backup file to import'**
  String get chooseJsonFile;

  /// No description provided for @jsonRecommendation.
  ///
  /// In en, this message translates to:
  /// **'JSON is portable between iOS / macOS / Android.'**
  String get jsonRecommendation;

  /// No description provided for @importedSummary.
  ///
  /// In en, this message translates to:
  /// **'Imported {empresas} businesses and {productos} products'**
  String importedSummary(int empresas, int productos);

  /// No description provided for @jsonReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'JSON ready to share'**
  String get jsonReadyToShare;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete every business and product before restoring the file. This action cannot be undone.'**
  String get importConfirmBody;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get replaceAll;

  /// No description provided for @importSuccessIcon.
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccessIcon;

  /// No description provided for @jsonSharedSuccess.
  ///
  /// In en, this message translates to:
  /// **'JSON shared'**
  String get jsonSharedSuccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get startOver;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @areYouSureCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get areYouSureCancel;

  /// No description provided for @allDataWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'All the data will be lost'**
  String get allDataWillBeLost;

  /// No description provided for @reviewProducts.
  ///
  /// In en, this message translates to:
  /// **'Review Products'**
  String get reviewProducts;

  /// No description provided for @newProducts.
  ///
  /// In en, this message translates to:
  /// **'New products ({count})'**
  String newProducts(int count);

  /// No description provided for @existingProducts.
  ///
  /// In en, this message translates to:
  /// **'Existing products ({count})'**
  String existingProducts(int count);

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get importSuccessful;

  /// No description provided for @productsImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product imported successfully} other{{count} products imported successfully}}'**
  String productsImportedSuccessfully(int count);

  /// No description provided for @importAnotherXml.
  ///
  /// In en, this message translates to:
  /// **'Import another XML'**
  String get importAnotherXml;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview product'**
  String get preview;

  /// No description provided for @productInfoAndBarcode.
  ///
  /// In en, this message translates to:
  /// **'Product info and barcode'**
  String get productInfoAndBarcode;

  /// No description provided for @foundInBill.
  ///
  /// In en, this message translates to:
  /// **'Found in bill: {value}'**
  String foundInBill(String value);

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Bar code'**
  String get barcode;

  /// No description provided for @barcodeColon.
  ///
  /// In en, this message translates to:
  /// **'Bar code: {value}'**
  String barcodeColon(String value);

  /// No description provided for @barcodeShortColon.
  ///
  /// In en, this message translates to:
  /// **'Barcode: {value}'**
  String barcodeShortColon(String value);

  /// No description provided for @internCode.
  ///
  /// In en, this message translates to:
  /// **'Intern Code'**
  String get internCode;

  /// No description provided for @internCodeColon.
  ///
  /// In en, this message translates to:
  /// **'Intern Code: {value}'**
  String internCodeColon(String value);

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @packageToUnit.
  ///
  /// In en, this message translates to:
  /// **'Package to unit'**
  String get packageToUnit;

  /// No description provided for @unitsPerPackage.
  ///
  /// In en, this message translates to:
  /// **'Units per package: {count}'**
  String unitsPerPackage(int count);

  /// No description provided for @unitsPerPackageLabel.
  ///
  /// In en, this message translates to:
  /// **'Units per package: '**
  String get unitsPerPackageLabel;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @uploadItems.
  ///
  /// In en, this message translates to:
  /// **'Upload items:'**
  String get uploadItems;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceColon.
  ///
  /// In en, this message translates to:
  /// **'Price: {value}'**
  String priceColon(String value);

  /// No description provided for @priceWithDiscount.
  ///
  /// In en, this message translates to:
  /// **'Price with discount: {value}'**
  String priceWithDiscount(String value);

  /// No description provided for @hasDiscount.
  ///
  /// In en, this message translates to:
  /// **'Has discount'**
  String get hasDiscount;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @removeFromImport.
  ///
  /// In en, this message translates to:
  /// **'Remove from import'**
  String get removeFromImport;

  /// No description provided for @modifyProduct.
  ///
  /// In en, this message translates to:
  /// **'Modify product'**
  String get modifyProduct;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search businesses or products'**
  String get searchPrompt;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @newXlsxFile.
  ///
  /// In en, this message translates to:
  /// **'New Xlsx File'**
  String get newXlsxFile;

  /// No description provided for @firstAddXmlFile.
  ///
  /// In en, this message translates to:
  /// **'First you need to add a XML file'**
  String get firstAddXmlFile;

  /// No description provided for @excelGenerated.
  ///
  /// In en, this message translates to:
  /// **'Excel generated'**
  String get excelGenerated;

  /// No description provided for @fileReadyToExport.
  ///
  /// In en, this message translates to:
  /// **'The file is ready to export.'**
  String get fileReadyToExport;

  /// No description provided for @shareExcel.
  ///
  /// In en, this message translates to:
  /// **'Share Excel'**
  String get shareExcel;

  /// No description provided for @saveTo.
  ///
  /// In en, this message translates to:
  /// **'Save to...'**
  String get saveTo;

  /// No description provided for @xmlPrefixColon.
  ///
  /// In en, this message translates to:
  /// **'XML: {value}'**
  String xmlPrefixColon(String value);

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
