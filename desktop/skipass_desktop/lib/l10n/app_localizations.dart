import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('bs'),
    Locale('en'),
  ];

  /// Naziv aplikacije prikazan u naslovnoj traci.
  ///
  /// In bs, this message translates to:
  /// **'SkiPass Administracija'**
  String get appTitle;

  /// No description provided for @languageLabel.
  ///
  /// In bs, this message translates to:
  /// **'Jezik'**
  String get languageLabel;

  /// No description provided for @languageBosnian.
  ///
  /// In bs, this message translates to:
  /// **'Bosanski'**
  String get languageBosnian;

  /// No description provided for @languageEnglish.
  ///
  /// In bs, this message translates to:
  /// **'Engleski'**
  String get languageEnglish;

  /// No description provided for @commonSave.
  ///
  /// In bs, this message translates to:
  /// **'Sacuvaj'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In bs, this message translates to:
  /// **'Otkazi'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In bs, this message translates to:
  /// **'Obrisi'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In bs, this message translates to:
  /// **'Izmijeni'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj'**
  String get commonAdd;

  /// No description provided for @commonRefresh.
  ///
  /// In bs, this message translates to:
  /// **'Osvjezi'**
  String get commonRefresh;

  /// No description provided for @commonSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi...'**
  String get commonSearchHint;

  /// No description provided for @commonNoData.
  ///
  /// In bs, this message translates to:
  /// **'Nema podataka'**
  String get commonNoData;

  /// No description provided for @commonClose.
  ///
  /// In bs, this message translates to:
  /// **'Zatvori'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi'**
  String get commonConfirm;

  /// No description provided for @commonDismiss.
  ///
  /// In bs, this message translates to:
  /// **'Odustani'**
  String get commonDismiss;

  /// No description provided for @commonRetry.
  ///
  /// In bs, this message translates to:
  /// **'Pokusaj ponovo'**
  String get commonRetry;

  /// No description provided for @commonUnableToLoad.
  ///
  /// In bs, this message translates to:
  /// **'Podatke nije moguce ucitati'**
  String get commonUnableToLoad;

  /// No description provided for @commonSelect.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi'**
  String get commonSelect;

  /// No description provided for @commonNoItemsAvailable.
  ///
  /// In bs, this message translates to:
  /// **'Nema dostupnih stavki'**
  String get commonNoItemsAvailable;

  /// No description provided for @commonUnknown.
  ///
  /// In bs, this message translates to:
  /// **'Nepoznato'**
  String get commonUnknown;

  /// No description provided for @commonEditShort.
  ///
  /// In bs, this message translates to:
  /// **'Uredi'**
  String get commonEditShort;

  /// No description provided for @commonImageTypeLabel.
  ///
  /// In bs, this message translates to:
  /// **'slike'**
  String get commonImageTypeLabel;

  /// No description provided for @commonCodeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Oznaka'**
  String get commonCodeLabel;

  /// No description provided for @commonDescriptionLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis'**
  String get commonDescriptionLabel;

  /// No description provided for @commonResortLabel.
  ///
  /// In bs, this message translates to:
  /// **'Skijaliste'**
  String get commonResortLabel;

  /// No description provided for @commonNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv'**
  String get commonNameLabel;

  /// No description provided for @commonNumberRequiredMessage.
  ///
  /// In bs, this message translates to:
  /// **'{label} mora biti broj.'**
  String commonNumberRequiredMessage(String label);

  /// No description provided for @commonPositiveRangeMessage.
  ///
  /// In bs, this message translates to:
  /// **'{label} mora biti izmedju 0.01 i {max}.'**
  String commonPositiveRangeMessage(String label, double max);

  /// No description provided for @commonLengthLabel.
  ///
  /// In bs, this message translates to:
  /// **'Duzina (m)'**
  String get commonLengthLabel;

  /// No description provided for @commonLengthShort.
  ///
  /// In bs, this message translates to:
  /// **'Duzina'**
  String get commonLengthShort;

  /// No description provided for @commonRemove.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni'**
  String get commonRemove;

  /// No description provided for @commonComplete.
  ///
  /// In bs, this message translates to:
  /// **'Zavrsi'**
  String get commonComplete;

  /// No description provided for @commonIntRequiredMessage.
  ///
  /// In bs, this message translates to:
  /// **'{label} mora biti cijeli broj.'**
  String commonIntRequiredMessage(String label);

  /// No description provided for @commonIntRangeMessage.
  ///
  /// In bs, this message translates to:
  /// **'{label} mora biti izmedju {min} i {max}.'**
  String commonIntRangeMessage(String label, int min, int max);

  /// No description provided for @sideNavAppName.
  ///
  /// In bs, this message translates to:
  /// **'SkiPass'**
  String get sideNavAppName;

  /// No description provided for @sideNavReportIncident.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi problem'**
  String get sideNavReportIncident;

  /// No description provided for @appFeedbackReasonMinLength.
  ///
  /// In bs, this message translates to:
  /// **'Obrazlozenje mora imati najmanje 3 znaka.'**
  String get appFeedbackReasonMinLength;

  /// No description provided for @roleAdmin.
  ///
  /// In bs, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleStaff.
  ///
  /// In bs, this message translates to:
  /// **'Osoblje'**
  String get roleStaff;

  /// No description provided for @loginScreenTagline.
  ///
  /// In bs, this message translates to:
  /// **'Administracija skijalista'**
  String get loginScreenTagline;

  /// No description provided for @loginScreenDescription.
  ///
  /// In bs, this message translates to:
  /// **'Upravljajte kartama, stazama, liftovima, incidentima i obavijestima na jednom mjestu.'**
  String get loginScreenDescription;

  /// No description provided for @loginScreenTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijava'**
  String get loginScreenTitle;

  /// No description provided for @loginScreenSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Unesite kredencijale osoblja ili administratora.'**
  String get loginScreenSubtitle;

  /// No description provided for @loginScreenUsernameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Korisnicko ime'**
  String get loginScreenUsernameLabel;

  /// No description provided for @loginScreenUsernameHint.
  ///
  /// In bs, this message translates to:
  /// **'npr. desktop'**
  String get loginScreenUsernameHint;

  /// No description provided for @loginScreenPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka'**
  String get loginScreenPasswordLabel;

  /// No description provided for @loginScreenPasswordHint.
  ///
  /// In bs, this message translates to:
  /// **'Unesite lozinku'**
  String get loginScreenPasswordHint;

  /// No description provided for @loginScreenSubmit.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi se'**
  String get loginScreenSubmit;

  /// No description provided for @changePasswordDialogSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka je uspjesno promijenjena.'**
  String get changePasswordDialogSuccess;

  /// No description provided for @changePasswordDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Promjena lozinke'**
  String get changePasswordDialogTitle;

  /// No description provided for @changePasswordDialogCurrentLabel.
  ///
  /// In bs, this message translates to:
  /// **'Trenutna lozinka'**
  String get changePasswordDialogCurrentLabel;

  /// No description provided for @changePasswordDialogNewLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nova lozinka'**
  String get changePasswordDialogNewLabel;

  /// No description provided for @changePasswordDialogConfirmLabel.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda nove lozinke'**
  String get changePasswordDialogConfirmLabel;

  /// No description provided for @navTickets.
  ///
  /// In bs, this message translates to:
  /// **'Karte'**
  String get navTickets;

  /// No description provided for @navResorts.
  ///
  /// In bs, this message translates to:
  /// **'Staze i ski liftovi'**
  String get navResorts;

  /// No description provided for @navBenefits.
  ///
  /// In bs, this message translates to:
  /// **'Usluge'**
  String get navBenefits;

  /// No description provided for @navIncidents.
  ///
  /// In bs, this message translates to:
  /// **'Incidenti'**
  String get navIncidents;

  /// No description provided for @navAnnouncements.
  ///
  /// In bs, this message translates to:
  /// **'Obavijesti'**
  String get navAnnouncements;

  /// No description provided for @navNotifications.
  ///
  /// In bs, this message translates to:
  /// **'Notifikacije'**
  String get navNotifications;

  /// No description provided for @navReports.
  ///
  /// In bs, this message translates to:
  /// **'Izvjestaji'**
  String get navReports;

  /// No description provided for @navUsers.
  ///
  /// In bs, this message translates to:
  /// **'Korisnici'**
  String get navUsers;

  /// No description provided for @navReferenceData.
  ///
  /// In bs, this message translates to:
  /// **'Referentni podaci'**
  String get navReferenceData;

  /// No description provided for @profileDialogUpdateSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Profil je azuriran.'**
  String get profileDialogUpdateSuccess;

  /// No description provided for @profileDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Moj profil'**
  String get profileDialogTitle;

  /// No description provided for @profileDialogLogout.
  ///
  /// In bs, this message translates to:
  /// **'Odjava'**
  String get profileDialogLogout;

  /// No description provided for @profileDialogLogoutConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Da li se zelite odjaviti sa naloga?'**
  String get profileDialogLogoutConfirmMessage;

  /// No description provided for @profileDialogChangePhoto.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni sliku'**
  String get profileDialogChangePhoto;

  /// No description provided for @profileDialogFirstNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ime'**
  String get profileDialogFirstNameLabel;

  /// No description provided for @profileDialogLastNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Prezime'**
  String get profileDialogLastNameLabel;

  /// No description provided for @profileDialogEmailLabel.
  ///
  /// In bs, this message translates to:
  /// **'E-mail'**
  String get profileDialogEmailLabel;

  /// No description provided for @profileDialogPhoneLabel.
  ///
  /// In bs, this message translates to:
  /// **'Telefon (opciono)'**
  String get profileDialogPhoneLabel;

  /// No description provided for @profileDialogBirthDateLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum rodjenja (opciono)'**
  String get profileDialogBirthDateLabel;

  /// No description provided for @profileDialogCityLabel.
  ///
  /// In bs, this message translates to:
  /// **'Grad (opciono)'**
  String get profileDialogCityLabel;

  /// No description provided for @profileDialogChangePassword.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni lozinku'**
  String get profileDialogChangePassword;

  /// No description provided for @resortsTabTrails.
  ///
  /// In bs, this message translates to:
  /// **'Staze'**
  String get resortsTabTrails;

  /// No description provided for @resortsTabLifts.
  ///
  /// In bs, this message translates to:
  /// **'Ski liftovi'**
  String get resortsTabLifts;

  /// No description provided for @trailDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje staze'**
  String get trailDeleteConfirmTitle;

  /// No description provided for @trailDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati stazu \"{trailName}\"? Ova akcija se ne moze ponistiti.'**
  String trailDeleteConfirmMessage(String trailName);

  /// No description provided for @trailDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Staza je obrisana.'**
  String get trailDeleteSuccess;

  /// No description provided for @trailsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi stazu po nazivu ili oznaci'**
  String get trailsSearchHint;

  /// No description provided for @trailsAllDifficulties.
  ///
  /// In bs, this message translates to:
  /// **'Sve tezine'**
  String get trailsAllDifficulties;

  /// No description provided for @trailsAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj stazu'**
  String get trailsAddButton;

  /// No description provided for @trailsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih staza'**
  String get trailsEmptyTitle;

  /// No description provided for @trailsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Dodajte prvu stazu skijalista.'**
  String get trailsEmptyMessage;

  /// No description provided for @trailConditionButton.
  ///
  /// In bs, this message translates to:
  /// **'Stanje staze'**
  String get trailConditionButton;

  /// No description provided for @liftOpenMaintenanceCount.
  ///
  /// In bs, this message translates to:
  /// **'{count} kvar(ova)'**
  String liftOpenMaintenanceCount(int count);

  /// No description provided for @liftDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje lifta'**
  String get liftDeleteConfirmTitle;

  /// No description provided for @liftDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati lift \"{liftName}\"?'**
  String liftDeleteConfirmMessage(String liftName);

  /// No description provided for @liftDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Lift je obrisan.'**
  String get liftDeleteSuccess;

  /// No description provided for @liftsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi lift po nazivu ili oznaci'**
  String get liftsSearchHint;

  /// No description provided for @commonAllStatuses.
  ///
  /// In bs, this message translates to:
  /// **'Svi statusi'**
  String get commonAllStatuses;

  /// No description provided for @liftStatusOperational.
  ///
  /// In bs, this message translates to:
  /// **'U pogonu'**
  String get liftStatusOperational;

  /// No description provided for @liftStatusNotOperational.
  ///
  /// In bs, this message translates to:
  /// **'Van pogona'**
  String get liftStatusNotOperational;

  /// No description provided for @liftsAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj lift'**
  String get liftsAddButton;

  /// No description provided for @liftsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih liftova'**
  String get liftsEmptyTitle;

  /// No description provided for @liftRidersLabel.
  ///
  /// In bs, this message translates to:
  /// **'{current}/{capacity} korisnika'**
  String liftRidersLabel(int current, int capacity);

  /// No description provided for @liftMaintenanceButton.
  ///
  /// In bs, this message translates to:
  /// **'Odrzavanje'**
  String get liftMaintenanceButton;

  /// No description provided for @skiLiftFormDialogSelectRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite skijaliste i tip lifta.'**
  String get skiLiftFormDialogSelectRequired;

  /// No description provided for @skiLiftFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi ski lift'**
  String get skiLiftFormDialogEditTitle;

  /// No description provided for @skiLiftFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Novi ski lift'**
  String get skiLiftFormDialogNewTitle;

  /// No description provided for @skiLiftFormDialogNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv lifta'**
  String get skiLiftFormDialogNameLabel;

  /// No description provided for @skiLiftFormDialogCodeHint.
  ///
  /// In bs, this message translates to:
  /// **'LIFT-01'**
  String get skiLiftFormDialogCodeHint;

  /// No description provided for @skiLiftFormDialogLiftTypeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tip lifta'**
  String get skiLiftFormDialogLiftTypeLabel;

  /// No description provided for @skiLiftFormDialogCapacityLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kapacitet (osoba/h)'**
  String get skiLiftFormDialogCapacityLabel;

  /// No description provided for @skiLiftFormDialogCapacityShort.
  ///
  /// In bs, this message translates to:
  /// **'Kapacitet'**
  String get skiLiftFormDialogCapacityShort;

  /// No description provided for @skiLiftFormDialogDurationLabel.
  ///
  /// In bs, this message translates to:
  /// **'Trajanje voznje (min)'**
  String get skiLiftFormDialogDurationLabel;

  /// No description provided for @skiLiftFormDialogDurationShort.
  ///
  /// In bs, this message translates to:
  /// **'Trajanje voznje'**
  String get skiLiftFormDialogDurationShort;

  /// No description provided for @skiLiftFormDialogOperationalSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Lift je u pogonu'**
  String get skiLiftFormDialogOperationalSwitch;

  /// No description provided for @trailFormDialogSelectRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite skijaliste i tezinu staze.'**
  String get trailFormDialogSelectRequired;

  /// No description provided for @trailFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi stazu'**
  String get trailFormDialogEditTitle;

  /// No description provided for @trailFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nova staza'**
  String get trailFormDialogNewTitle;

  /// No description provided for @trailFormDialogNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv staze'**
  String get trailFormDialogNameLabel;

  /// No description provided for @trailFormDialogCodeHint.
  ///
  /// In bs, this message translates to:
  /// **'STAZA-01'**
  String get trailFormDialogCodeHint;

  /// No description provided for @trailFormDialogDifficultyLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tezina staze'**
  String get trailFormDialogDifficultyLabel;

  /// No description provided for @trailFormDialogVerticalDropLabel.
  ///
  /// In bs, this message translates to:
  /// **'Visinska razlika (m)'**
  String get trailFormDialogVerticalDropLabel;

  /// No description provided for @trailFormDialogVerticalDropShort.
  ///
  /// In bs, this message translates to:
  /// **'Visinska razlika'**
  String get trailFormDialogVerticalDropShort;

  /// No description provided for @trailFormDialogOpenSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Staza je otvorena'**
  String get trailFormDialogOpenSwitch;

  /// No description provided for @trailFormDialogNightSkiingSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Nocno skijanje'**
  String get trailFormDialogNightSkiingSwitch;

  /// No description provided for @trailFormDialogSnowmakingSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Vjestacki snijeg'**
  String get trailFormDialogSnowmakingSwitch;

  /// No description provided for @trailFormDialogPhotoLabel.
  ///
  /// In bs, this message translates to:
  /// **'Fotografija'**
  String get trailFormDialogPhotoLabel;

  /// No description provided for @trailFormDialogAddPhoto.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj sliku'**
  String get trailFormDialogAddPhoto;

  /// No description provided for @trailConditionDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Evidencija stanja - {trailName}'**
  String trailConditionDialogTitle(String trailName);

  /// No description provided for @trailConditionDialogSaveButton.
  ///
  /// In bs, this message translates to:
  /// **'Sacuvaj evidenciju'**
  String get trailConditionDialogSaveButton;

  /// No description provided for @trailConditionDialogSnowDepthLabel.
  ///
  /// In bs, this message translates to:
  /// **'Snjezni pokrivac (cm)'**
  String get trailConditionDialogSnowDepthLabel;

  /// No description provided for @trailConditionDialogSnowDepthError.
  ///
  /// In bs, this message translates to:
  /// **'Snjezni pokrivac mora biti izmedju 0 i 800 cm.'**
  String get trailConditionDialogSnowDepthError;

  /// No description provided for @trailConditionDialogOpenSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Staza otvorena'**
  String get trailConditionDialogOpenSwitch;

  /// No description provided for @trailConditionDialogNoteLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis uslova'**
  String get trailConditionDialogNoteLabel;

  /// No description provided for @trailConditionDialogNoteHint.
  ///
  /// In bs, this message translates to:
  /// **'npr. poledica na donjem dijelu staze'**
  String get trailConditionDialogNoteHint;

  /// No description provided for @trailConditionDialogHistoryTitle.
  ///
  /// In bs, this message translates to:
  /// **'Historija evidencije'**
  String get trailConditionDialogHistoryTitle;

  /// No description provided for @trailConditionDialogHistoryEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Jos nema evidentiranih zapisa.'**
  String get trailConditionDialogHistoryEmpty;

  /// No description provided for @trailConditionDialogSnowDepthValue.
  ///
  /// In bs, this message translates to:
  /// **'{depth} cm'**
  String trailConditionDialogSnowDepthValue(int depth);

  /// No description provided for @liftMaintenanceDialogReportSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Kvar je evidentiran.'**
  String get liftMaintenanceDialogReportSuccess;

  /// No description provided for @liftMaintenanceDialogCompleteTitle.
  ///
  /// In bs, this message translates to:
  /// **'Zavrsetak servisa'**
  String get liftMaintenanceDialogCompleteTitle;

  /// No description provided for @liftMaintenanceDialogCancelTitle.
  ///
  /// In bs, this message translates to:
  /// **'Otkazivanje prijave'**
  String get liftMaintenanceDialogCancelTitle;

  /// No description provided for @liftMaintenanceDialogReasonLabel.
  ///
  /// In bs, this message translates to:
  /// **'Obrazlozenje'**
  String get liftMaintenanceDialogReasonLabel;

  /// No description provided for @liftMaintenanceDialogStatusUpdateSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Status kvara je azuriran.'**
  String get liftMaintenanceDialogStatusUpdateSuccess;

  /// No description provided for @liftMaintenanceDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Odrzavanje - {liftName}'**
  String liftMaintenanceDialogTitle(String liftName);

  /// No description provided for @liftMaintenanceDialogDescriptionLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis kvara'**
  String get liftMaintenanceDialogDescriptionLabel;

  /// No description provided for @liftMaintenanceDialogShutdownSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Zahtijeva obustavu rada lifta'**
  String get liftMaintenanceDialogShutdownSwitch;

  /// No description provided for @liftMaintenanceDialogReportButton.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi kvar'**
  String get liftMaintenanceDialogReportButton;

  /// No description provided for @liftMaintenanceDialogHistoryTitle.
  ///
  /// In bs, this message translates to:
  /// **'Evidencija odrzavanja'**
  String get liftMaintenanceDialogHistoryTitle;

  /// No description provided for @liftMaintenanceDialogHistoryEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Nema evidentiranih kvarova.'**
  String get liftMaintenanceDialogHistoryEmpty;

  /// No description provided for @liftMaintenanceDialogShutdownSuffix.
  ///
  /// In bs, this message translates to:
  /// **'zahtijeva obustavu'**
  String get liftMaintenanceDialogShutdownSuffix;

  /// No description provided for @liftMaintenanceStatusReported.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljen'**
  String get liftMaintenanceStatusReported;

  /// No description provided for @liftMaintenanceStatusInProgress.
  ///
  /// In bs, this message translates to:
  /// **'U toku'**
  String get liftMaintenanceStatusInProgress;

  /// No description provided for @liftMaintenanceStatusCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Zavrseno'**
  String get liftMaintenanceStatusCompleted;

  /// No description provided for @liftMaintenanceStatusCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Otkazano'**
  String get liftMaintenanceStatusCancelled;

  /// No description provided for @liftMaintenanceActionStart.
  ///
  /// In bs, this message translates to:
  /// **'Zapocni servis'**
  String get liftMaintenanceActionStart;

  /// No description provided for @ticketsTabTypes.
  ///
  /// In bs, this message translates to:
  /// **'Tipovi karata'**
  String get ticketsTabTypes;

  /// No description provided for @ticketFilterStatusPending.
  ///
  /// In bs, this message translates to:
  /// **'Neaktivna'**
  String get ticketFilterStatusPending;

  /// No description provided for @ticketFilterStatusActive.
  ///
  /// In bs, this message translates to:
  /// **'Aktivna'**
  String get ticketFilterStatusActive;

  /// No description provided for @ticketFilterStatusUsed.
  ///
  /// In bs, this message translates to:
  /// **'U upotrebi'**
  String get ticketFilterStatusUsed;

  /// No description provided for @ticketFilterStatusExpired.
  ///
  /// In bs, this message translates to:
  /// **'Istekla'**
  String get ticketFilterStatusExpired;

  /// No description provided for @ticketFilterStatusCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Otkazana'**
  String get ticketFilterStatusCancelled;

  /// No description provided for @ticketsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi po nosiocu, QR kodu ili broju narudzbe'**
  String get ticketsSearchHint;

  /// No description provided for @ticketsValidateButton.
  ///
  /// In bs, this message translates to:
  /// **'Validiraj kartu'**
  String get ticketsValidateButton;

  /// No description provided for @ticketsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema karata za zadate uslove'**
  String get ticketsEmptyTitle;

  /// No description provided for @ticketTypeDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje tipa karte'**
  String get ticketTypeDeleteConfirmTitle;

  /// No description provided for @ticketTypeDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati tip karte \"{typeName}\"?'**
  String ticketTypeDeleteConfirmMessage(String typeName);

  /// No description provided for @ticketTypeDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Tip karte je obrisan.'**
  String get ticketTypeDeleteSuccess;

  /// No description provided for @ticketTypeAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Novi tip karte'**
  String get ticketTypeAddButton;

  /// No description provided for @ticketTypesEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema definisanih tipova karata'**
  String get ticketTypesEmptyTitle;

  /// No description provided for @ticketTypesEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Dodajte prvi tip ski pass karte i odredite cijenu.'**
  String get ticketTypesEmptyMessage;

  /// No description provided for @ticketTypeInactiveLabel.
  ///
  /// In bs, this message translates to:
  /// **'Neaktivan'**
  String get ticketTypeInactiveLabel;

  /// No description provided for @ticketTypePriceLabel.
  ///
  /// In bs, this message translates to:
  /// **'{price}/dan · do {maxDays} dana'**
  String ticketTypePriceLabel(String price, int maxDays);

  /// No description provided for @ticketTypeDiscountSuffix.
  ///
  /// In bs, this message translates to:
  /// **' · popust {percent}%'**
  String ticketTypeDiscountSuffix(String percent);

  /// No description provided for @orderDetailCancelTitle.
  ///
  /// In bs, this message translates to:
  /// **'Otkazivanje narudzbe'**
  String get orderDetailCancelTitle;

  /// No description provided for @orderDetailCancelReasonLabel.
  ///
  /// In bs, this message translates to:
  /// **'Razlog otkazivanja'**
  String get orderDetailCancelReasonLabel;

  /// No description provided for @orderDetailCancelConfirmButton.
  ///
  /// In bs, this message translates to:
  /// **'Otkazi narudzbu'**
  String get orderDetailCancelConfirmButton;

  /// No description provided for @orderDetailStatusChangeTitle.
  ///
  /// In bs, this message translates to:
  /// **'Promjena statusa'**
  String get orderDetailStatusChangeTitle;

  /// No description provided for @orderDetailStatusChangeMessage.
  ///
  /// In bs, this message translates to:
  /// **'Prebaciti narudzbu u status \"{status}\"?'**
  String orderDetailStatusChangeMessage(String status);

  /// No description provided for @orderDetailStatusUpdateSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Status narudzbe je azuriran.'**
  String get orderDetailStatusUpdateSuccess;

  /// No description provided for @orderDetailRefundTitle.
  ///
  /// In bs, this message translates to:
  /// **'Povrat sredstava'**
  String get orderDetailRefundTitle;

  /// No description provided for @orderDetailRefundReasonLabel.
  ///
  /// In bs, this message translates to:
  /// **'Razlog povrata'**
  String get orderDetailRefundReasonLabel;

  /// No description provided for @orderDetailRefundConfirmButton.
  ///
  /// In bs, this message translates to:
  /// **'Izvrsi povrat'**
  String get orderDetailRefundConfirmButton;

  /// No description provided for @orderDetailRefundSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Povrat sredstava je evidentiran.'**
  String get orderDetailRefundSuccess;

  /// No description provided for @orderDetailDefaultTitle.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba'**
  String get orderDetailDefaultTitle;

  /// No description provided for @orderDetailDateLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum narudzbe'**
  String get orderDetailDateLabel;

  /// No description provided for @orderDetailPaymentMethodLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nacin placanja'**
  String get orderDetailPaymentMethodLabel;

  /// No description provided for @orderDetailTicketCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj karata'**
  String get orderDetailTicketCountLabel;

  /// No description provided for @orderDetailTotalLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ukupan iznos'**
  String get orderDetailTotalLabel;

  /// No description provided for @orderDetailPaidLabel.
  ///
  /// In bs, this message translates to:
  /// **'Placeno'**
  String get orderDetailPaidLabel;

  /// No description provided for @orderDetailRefundedLabel.
  ///
  /// In bs, this message translates to:
  /// **'Vraceno'**
  String get orderDetailRefundedLabel;

  /// No description provided for @orderDetailPaymentsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Placanja'**
  String get orderDetailPaymentsTitle;

  /// No description provided for @orderDetailPaymentNotCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Nije zavrseno'**
  String get orderDetailPaymentNotCompleted;

  /// No description provided for @orderDetailRefundButton.
  ///
  /// In bs, this message translates to:
  /// **'Povrat'**
  String get orderDetailRefundButton;

  /// No description provided for @ticketTypeDialogSelectResortRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite skijaliste.'**
  String get ticketTypeDialogSelectResortRequired;

  /// No description provided for @ticketTypeDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi tip karte'**
  String get ticketTypeDialogEditTitle;

  /// No description provided for @ticketTypeDialogPricePerDayLabel.
  ///
  /// In bs, this message translates to:
  /// **'Cijena po danu (KM)'**
  String get ticketTypeDialogPricePerDayLabel;

  /// No description provided for @ticketTypeDialogPriceShort.
  ///
  /// In bs, this message translates to:
  /// **'Cijena'**
  String get ticketTypeDialogPriceShort;

  /// No description provided for @ticketTypeDialogMaxDaysLabel.
  ///
  /// In bs, this message translates to:
  /// **'Maksimalan broj dana'**
  String get ticketTypeDialogMaxDaysLabel;

  /// No description provided for @ticketTypeDialogDiscountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Popust (%)'**
  String get ticketTypeDialogDiscountLabel;

  /// No description provided for @ticketTypeDialogMinAgeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Minimalna dob'**
  String get ticketTypeDialogMinAgeLabel;

  /// No description provided for @ticketTypeDialogMaxAgeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Maksimalna dob'**
  String get ticketTypeDialogMaxAgeLabel;

  /// No description provided for @ticketTypeDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivan (dostupan za kupovinu)'**
  String get ticketTypeDialogActiveSwitch;

  /// No description provided for @validateTicketDialogSelectLiftRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite ski lift na kojem se vrsi validacija.'**
  String get validateTicketDialogSelectLiftRequired;

  /// No description provided for @validateTicketDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Validacija karte'**
  String get validateTicketDialogTitle;

  /// No description provided for @validateTicketDialogSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Unesite ili skenirajte QR kod karte.'**
  String get validateTicketDialogSubtitle;

  /// No description provided for @validateTicketDialogLiftLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ski lift'**
  String get validateTicketDialogLiftLabel;

  /// No description provided for @validateTicketDialogNoLiftsAvailable.
  ///
  /// In bs, this message translates to:
  /// **'Nema liftova u pogonu'**
  String get validateTicketDialogNoLiftsAvailable;

  /// No description provided for @validateTicketDialogQrLabel.
  ///
  /// In bs, this message translates to:
  /// **'QR kod karte'**
  String get validateTicketDialogQrLabel;

  /// No description provided for @validateTicketDialogScanTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Skeniraj kamerom'**
  String get validateTicketDialogScanTooltip;

  /// No description provided for @validateTicketDialogQrMinLengthError.
  ///
  /// In bs, this message translates to:
  /// **'QR kod mora imati najmanje 8 znakova.'**
  String get validateTicketDialogQrMinLengthError;

  /// No description provided for @validateTicketDialogSubmitButton.
  ///
  /// In bs, this message translates to:
  /// **'Validiraj'**
  String get validateTicketDialogSubmitButton;

  /// No description provided for @validateTicketDialogResultValid.
  ///
  /// In bs, this message translates to:
  /// **'Karta je vazeca'**
  String get validateTicketDialogResultValid;

  /// No description provided for @validateTicketDialogResultInvalid.
  ///
  /// In bs, this message translates to:
  /// **'Karta nije prihvacena'**
  String get validateTicketDialogResultInvalid;

  /// No description provided for @validateTicketDialogHolderLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nosilac: {name}'**
  String validateTicketDialogHolderLabel(String name);

  /// No description provided for @usersScreenDeleteSelfError.
  ///
  /// In bs, this message translates to:
  /// **'Ne mozete obrisati vlastiti korisnicki racun.'**
  String get usersScreenDeleteSelfError;

  /// No description provided for @usersScreenDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje korisnika'**
  String get usersScreenDeleteConfirmTitle;

  /// No description provided for @usersScreenDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati korisnika \"{userName}\"? Ova akcija se ne moze ponistiti.'**
  String usersScreenDeleteConfirmMessage(String userName);

  /// No description provided for @usersScreenDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Korisnik je obrisan.'**
  String get usersScreenDeleteSuccess;

  /// No description provided for @usersScreenSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi po imenu, e-mailu ili korisnickom imenu'**
  String get usersScreenSearchHint;

  /// No description provided for @usersScreenAllRoles.
  ///
  /// In bs, this message translates to:
  /// **'Sve role'**
  String get usersScreenAllRoles;

  /// No description provided for @roleSkier.
  ///
  /// In bs, this message translates to:
  /// **'Skijas'**
  String get roleSkier;

  /// No description provided for @usersScreenAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Novi korisnik'**
  String get usersScreenAddButton;

  /// No description provided for @usersScreenEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema pronadjenih korisnika'**
  String get usersScreenEmptyTitle;

  /// No description provided for @usersScreenOrderCount.
  ///
  /// In bs, this message translates to:
  /// **'{count} narudzbi'**
  String usersScreenOrderCount(int count);

  /// No description provided for @usersScreenNeverLoggedIn.
  ///
  /// In bs, this message translates to:
  /// **'Nikad prijavljen'**
  String get usersScreenNeverLoggedIn;

  /// No description provided for @usersScreenLastLogin.
  ///
  /// In bs, this message translates to:
  /// **'Prijava: {date}'**
  String usersScreenLastLogin(String date);

  /// No description provided for @userFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi korisnika'**
  String get userFormDialogEditTitle;

  /// No description provided for @userFormDialogRoleLabel.
  ///
  /// In bs, this message translates to:
  /// **'Rola'**
  String get userFormDialogRoleLabel;

  /// No description provided for @userFormDialogNewPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nova lozinka (opciono)'**
  String get userFormDialogNewPasswordLabel;

  /// No description provided for @userFormDialogConfirmPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda lozinke'**
  String get userFormDialogConfirmPasswordLabel;

  /// No description provided for @userFormDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivan korisnik'**
  String get userFormDialogActiveSwitch;

  /// No description provided for @incidentsScreenResolveTitle.
  ///
  /// In bs, this message translates to:
  /// **'Rjesavanje incidenta'**
  String get incidentsScreenResolveTitle;

  /// No description provided for @incidentsScreenRejectTitle.
  ///
  /// In bs, this message translates to:
  /// **'Odbijanje prijave'**
  String get incidentsScreenRejectTitle;

  /// No description provided for @incidentsScreenStatusUpdateSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Status incidenta je azuriran.'**
  String get incidentsScreenStatusUpdateSuccess;

  /// No description provided for @incidentsScreenDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje prijave'**
  String get incidentsScreenDeleteConfirmTitle;

  /// No description provided for @incidentsScreenDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati prijavu #{incidentId}? Ova akcija se ne moze ponistiti.'**
  String incidentsScreenDeleteConfirmMessage(int incidentId);

  /// No description provided for @incidentsScreenDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Prijava je obrisana.'**
  String get incidentsScreenDeleteSuccess;

  /// No description provided for @incidentsScreenSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi po opisu ili prijavitelju'**
  String get incidentsScreenSearchHint;

  /// No description provided for @incidentsColumnReported.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljeno'**
  String get incidentsColumnReported;

  /// No description provided for @incidentsColumnInProgress.
  ///
  /// In bs, this message translates to:
  /// **'U toku'**
  String get incidentsColumnInProgress;

  /// No description provided for @incidentsColumnResolved.
  ///
  /// In bs, this message translates to:
  /// **'Rijeseno'**
  String get incidentsColumnResolved;

  /// No description provided for @incidentsColumnRejected.
  ///
  /// In bs, this message translates to:
  /// **'Odbijeno'**
  String get incidentsColumnRejected;

  /// No description provided for @incidentsColumnEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Nema prijava'**
  String get incidentsColumnEmpty;

  /// No description provided for @incidentsUrgentLabel.
  ///
  /// In bs, this message translates to:
  /// **'Hitno'**
  String get incidentsUrgentLabel;

  /// No description provided for @incidentsScreenDeleteTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Obrisi prijavu'**
  String get incidentsScreenDeleteTooltip;

  /// No description provided for @incidentsActionTakeOver.
  ///
  /// In bs, this message translates to:
  /// **'Preuzmi'**
  String get incidentsActionTakeOver;

  /// No description provided for @incidentsActionResolve.
  ///
  /// In bs, this message translates to:
  /// **'Rijesi'**
  String get incidentsActionResolve;

  /// No description provided for @incidentsActionReject.
  ///
  /// In bs, this message translates to:
  /// **'Odbij'**
  String get incidentsActionReject;

  /// No description provided for @reportIncidentDialogSelectRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite tip incidenta i lokaciju.'**
  String get reportIncidentDialogSelectRequired;

  /// No description provided for @reportIncidentDialogSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Incident je prijavljen.'**
  String get reportIncidentDialogSuccess;

  /// No description provided for @reportIncidentDialogSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijava kvara ili incidenta na skijalistu'**
  String get reportIncidentDialogSubtitle;

  /// No description provided for @reportIncidentDialogSubmitButton.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi'**
  String get reportIncidentDialogSubmitButton;

  /// No description provided for @reportIncidentDialogTypeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tip incidenta'**
  String get reportIncidentDialogTypeLabel;

  /// No description provided for @reportIncidentDialogTrailSegment.
  ///
  /// In bs, this message translates to:
  /// **'Staza'**
  String get reportIncidentDialogTrailSegment;

  /// No description provided for @reportIncidentDialogLiftSegment.
  ///
  /// In bs, this message translates to:
  /// **'Ski lift'**
  String get reportIncidentDialogLiftSegment;

  /// No description provided for @reportIncidentDialogNoRecords.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih zapisa'**
  String get reportIncidentDialogNoRecords;

  /// No description provided for @reportIncidentDialogDescriptionLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis problema'**
  String get reportIncidentDialogDescriptionLabel;

  /// No description provided for @reportIncidentDialogAddPhoto.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj sliku (opciono)'**
  String get reportIncidentDialogAddPhoto;

  /// No description provided for @reportIncidentDialogPhotoSelected.
  ///
  /// In bs, this message translates to:
  /// **'Slika odabrana'**
  String get reportIncidentDialogPhotoSelected;

  /// No description provided for @announcementsScreenDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje obavijesti'**
  String get announcementsScreenDeleteConfirmTitle;

  /// No description provided for @announcementsScreenDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati obavijest \"{title}\"? Ova akcija se ne moze ponistiti.'**
  String announcementsScreenDeleteConfirmMessage(String title);

  /// No description provided for @announcementsScreenDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Obavijest je obrisana.'**
  String get announcementsScreenDeleteSuccess;

  /// No description provided for @announcementsScreenAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj novu obavijest'**
  String get announcementsScreenAddButton;

  /// No description provided for @announcementsScreenSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi po naslovu ili tekstu'**
  String get announcementsScreenSearchHint;

  /// No description provided for @announcementsScreenAllCategories.
  ///
  /// In bs, this message translates to:
  /// **'Sve kategorije'**
  String get announcementsScreenAllCategories;

  /// No description provided for @announcementsScreenEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih obavijesti'**
  String get announcementsScreenEmptyTitle;

  /// No description provided for @announcementsScreenUrgentSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Hitne obavijesti'**
  String get announcementsScreenUrgentSectionTitle;

  /// No description provided for @announcementsScreenActiveSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Aktivne obavijesti'**
  String get announcementsScreenActiveSectionTitle;

  /// No description provided for @announcementsScreenOthersEmpty.
  ///
  /// In bs, this message translates to:
  /// **'Nema ostalih obavijesti.'**
  String get announcementsScreenOthersEmpty;

  /// No description provided for @announcementsScreenInactiveLabel.
  ///
  /// In bs, this message translates to:
  /// **'Neaktivna'**
  String get announcementsScreenInactiveLabel;

  /// No description provided for @announcementsScreenPublishedLabel.
  ///
  /// In bs, this message translates to:
  /// **'objavljeno {date}'**
  String announcementsScreenPublishedLabel(String date);

  /// No description provided for @announcementsScreenExpiresLabel.
  ///
  /// In bs, this message translates to:
  /// **'istice {date}'**
  String announcementsScreenExpiresLabel(String date);

  /// No description provided for @announcementFormDialogSelectRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite kategoriju i skijaliste.'**
  String get announcementFormDialogSelectRequired;

  /// No description provided for @announcementFormDialogExpiryError.
  ///
  /// In bs, this message translates to:
  /// **'Datum isteka mora biti nakon datuma objave.'**
  String get announcementFormDialogExpiryError;

  /// No description provided for @announcementFormDialogPublishedLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum objave'**
  String get announcementFormDialogPublishedLabel;

  /// No description provided for @announcementFormDialogExpiryHelpText.
  ///
  /// In bs, this message translates to:
  /// **'Datum isteka'**
  String get announcementFormDialogExpiryHelpText;

  /// No description provided for @announcementFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi obavijest'**
  String get announcementFormDialogEditTitle;

  /// No description provided for @announcementFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nova obavijest'**
  String get announcementFormDialogNewTitle;

  /// No description provided for @announcementFormDialogTitleLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naslov'**
  String get announcementFormDialogTitleLabel;

  /// No description provided for @announcementFormDialogContentLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tekst obavijesti'**
  String get announcementFormDialogContentLabel;

  /// No description provided for @announcementFormDialogContentShort.
  ///
  /// In bs, this message translates to:
  /// **'Tekst'**
  String get announcementFormDialogContentShort;

  /// No description provided for @announcementFormDialogCategoryLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kategorija'**
  String get announcementFormDialogCategoryLabel;

  /// No description provided for @announcementFormDialogExpiryLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum isteka (opciono)'**
  String get announcementFormDialogExpiryLabel;

  /// No description provided for @announcementFormDialogUrgentSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Hitna obavijest'**
  String get announcementFormDialogUrgentSwitch;

  /// No description provided for @announcementFormDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivna (vidljiva korisnicima)'**
  String get announcementFormDialogActiveSwitch;

  /// No description provided for @benefitsTabPartners.
  ///
  /// In bs, this message translates to:
  /// **'Partneri'**
  String get benefitsTabPartners;

  /// No description provided for @benefitDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje usluge'**
  String get benefitDeleteConfirmTitle;

  /// No description provided for @benefitDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati uslugu \"{benefitName}\"? Ova akcija se ne moze ponistiti.'**
  String benefitDeleteConfirmMessage(String benefitName);

  /// No description provided for @benefitDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Usluga je obrisana.'**
  String get benefitDeleteSuccess;

  /// No description provided for @benefitsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi uslugu po nazivu'**
  String get benefitsSearchHint;

  /// No description provided for @benefitsAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj novu uslugu'**
  String get benefitsAddButton;

  /// No description provided for @benefitsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih usluga'**
  String get benefitsEmptyTitle;

  /// No description provided for @benefitsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Dodajte prvu uslugu ili pogodnost.'**
  String get benefitsEmptyMessage;

  /// No description provided for @partnerDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje partnera'**
  String get partnerDeleteConfirmTitle;

  /// No description provided for @partnerDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati partnera \"{partnerName}\"? Ova akcija se ne moze ponistiti.'**
  String partnerDeleteConfirmMessage(String partnerName);

  /// No description provided for @partnerDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Partner je obrisan.'**
  String get partnerDeleteSuccess;

  /// No description provided for @partnersSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi partnera po nazivu'**
  String get partnersSearchHint;

  /// No description provided for @partnersAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj partnera'**
  String get partnersAddButton;

  /// No description provided for @partnersEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema unesenih partnera'**
  String get partnersEmptyTitle;

  /// No description provided for @partnerBenefitCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'{count} usluga'**
  String partnerBenefitCountLabel(int count);

  /// No description provided for @benefitFormDialogSelectRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite skijaliste i kategoriju.'**
  String get benefitFormDialogSelectRequired;

  /// No description provided for @benefitFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi uslugu'**
  String get benefitFormDialogEditTitle;

  /// No description provided for @benefitFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nova usluga'**
  String get benefitFormDialogNewTitle;

  /// No description provided for @benefitFormDialogNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv usluge'**
  String get benefitFormDialogNameLabel;

  /// No description provided for @benefitFormDialogPartnerLabel.
  ///
  /// In bs, this message translates to:
  /// **'Partner (opciono)'**
  String get benefitFormDialogPartnerLabel;

  /// No description provided for @benefitFormDialogPriceLabel.
  ///
  /// In bs, this message translates to:
  /// **'Cijena (KM)'**
  String get benefitFormDialogPriceLabel;

  /// No description provided for @benefitFormDialogPriceError.
  ///
  /// In bs, this message translates to:
  /// **'Cijena mora biti pozitivan broj.'**
  String get benefitFormDialogPriceError;

  /// No description provided for @benefitFormDialogDiscountError.
  ///
  /// In bs, this message translates to:
  /// **'Popust mora biti izmedju 0 i 100.'**
  String get benefitFormDialogDiscountError;

  /// No description provided for @benefitFormDialogBrandLabel.
  ///
  /// In bs, this message translates to:
  /// **'Brend (opciono)'**
  String get benefitFormDialogBrandLabel;

  /// No description provided for @benefitFormDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivna (dostupna za kupovinu)'**
  String get benefitFormDialogActiveSwitch;

  /// No description provided for @benefitFormDialogAddPhoto.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj sliku'**
  String get benefitFormDialogAddPhoto;

  /// No description provided for @partnerFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi partnera'**
  String get partnerFormDialogEditTitle;

  /// No description provided for @partnerFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Novi partner'**
  String get partnerFormDialogNewTitle;

  /// No description provided for @partnerFormDialogNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv partnera'**
  String get partnerFormDialogNameLabel;

  /// No description provided for @partnerFormDialogContactEmailLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kontakt e-mail'**
  String get partnerFormDialogContactEmailLabel;

  /// No description provided for @partnerFormDialogContactPhoneLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kontakt telefon'**
  String get partnerFormDialogContactPhoneLabel;

  /// No description provided for @partnerFormDialogWebsiteLabel.
  ///
  /// In bs, this message translates to:
  /// **'Web stranica'**
  String get partnerFormDialogWebsiteLabel;

  /// No description provided for @partnerFormDialogAddressLabel.
  ///
  /// In bs, this message translates to:
  /// **'Adresa'**
  String get partnerFormDialogAddressLabel;

  /// No description provided for @partnerFormDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivan partner'**
  String get partnerFormDialogActiveSwitch;

  /// No description provided for @notificationsScreenMarkAllSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Sve notifikacije su oznacene kao procitane.'**
  String get notificationsScreenMarkAllSuccess;

  /// No description provided for @notificationsScreenMarkAllButton.
  ///
  /// In bs, this message translates to:
  /// **'Oznaci sve kao procitano'**
  String get notificationsScreenMarkAllButton;

  /// No description provided for @notificationsScreenEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema notifikacija'**
  String get notificationsScreenEmptyTitle;

  /// No description provided for @referenceDataScreenDeleteBlockedError.
  ///
  /// In bs, this message translates to:
  /// **'Nije moguce obrisati - postoje povezani zapisi ({count}).'**
  String referenceDataScreenDeleteBlockedError(int count);

  /// No description provided for @referenceDataScreenDeleteConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje zapisa'**
  String get referenceDataScreenDeleteConfirmTitle;

  /// No description provided for @referenceDataScreenDeleteConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obrisati \"{name}\"? Ova akcija se ne moze ponistiti.'**
  String referenceDataScreenDeleteConfirmMessage(String name);

  /// No description provided for @referenceDataScreenDeleteSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Zapis je obrisan.'**
  String get referenceDataScreenDeleteSuccess;

  /// No description provided for @referenceDataScreenSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi po nazivu'**
  String get referenceDataScreenSearchHint;

  /// No description provided for @referenceDataScreenAllCountries.
  ///
  /// In bs, this message translates to:
  /// **'Sve drzave'**
  String get referenceDataScreenAllCountries;

  /// No description provided for @referenceDataScreenAddButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj: {label}'**
  String referenceDataScreenAddButton(String label);

  /// No description provided for @referenceDataScreenSortOrderLabel.
  ///
  /// In bs, this message translates to:
  /// **'Redoslijed: {order}'**
  String referenceDataScreenSortOrderLabel(int order);

  /// No description provided for @referenceDataScreenRelatedCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'{count} povezano'**
  String referenceDataScreenRelatedCountLabel(int count);

  /// No description provided for @referenceItemFormDialogSelectCountryRequired.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite drzavu.'**
  String get referenceItemFormDialogSelectCountryRequired;

  /// No description provided for @referenceItemFormDialogEditTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi: {label}'**
  String referenceItemFormDialogEditTitle(String label);

  /// No description provided for @referenceItemFormDialogNewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Novo: {label}'**
  String referenceItemFormDialogNewTitle(String label);

  /// No description provided for @referenceItemFormDialogIsoCodeLabel.
  ///
  /// In bs, this message translates to:
  /// **'ISO oznaka'**
  String get referenceItemFormDialogIsoCodeLabel;

  /// No description provided for @referenceItemFormDialogIsoCodeError.
  ///
  /// In bs, this message translates to:
  /// **'ISO oznaka mora imati 2 ili 3 slova, npr. BA ili BIH.'**
  String get referenceItemFormDialogIsoCodeError;

  /// No description provided for @referenceItemFormDialogCountryLabel.
  ///
  /// In bs, this message translates to:
  /// **'Drzava'**
  String get referenceItemFormDialogCountryLabel;

  /// No description provided for @referenceItemFormDialogNoCountriesHint.
  ///
  /// In bs, this message translates to:
  /// **'Prvo unesite drzavu'**
  String get referenceItemFormDialogNoCountriesHint;

  /// No description provided for @referenceItemFormDialogPostalCodeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Postanski broj (opciono)'**
  String get referenceItemFormDialogPostalCodeLabel;

  /// No description provided for @referenceItemFormDialogPostalCodeError.
  ///
  /// In bs, this message translates to:
  /// **'Postanski broj mora imati tacno 5 cifara.'**
  String get referenceItemFormDialogPostalCodeError;

  /// No description provided for @referenceItemFormDialogDescriptionLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis (opciono)'**
  String get referenceItemFormDialogDescriptionLabel;

  /// No description provided for @referenceItemFormDialogColorLabel.
  ///
  /// In bs, this message translates to:
  /// **'Boja (HEX)'**
  String get referenceItemFormDialogColorLabel;

  /// No description provided for @referenceItemFormDialogColorError.
  ///
  /// In bs, this message translates to:
  /// **'Boja mora biti u HEX formatu, npr. #1E88E5.'**
  String get referenceItemFormDialogColorError;

  /// No description provided for @referenceItemFormDialogSortOrderLabel.
  ///
  /// In bs, this message translates to:
  /// **'Redoslijed prikaza (0-100)'**
  String get referenceItemFormDialogSortOrderLabel;

  /// No description provided for @referenceItemFormDialogSortOrderError.
  ///
  /// In bs, this message translates to:
  /// **'Redoslijed mora biti izmedju 0 i 100.'**
  String get referenceItemFormDialogSortOrderError;

  /// No description provided for @referenceItemFormDialogIconLabel.
  ///
  /// In bs, this message translates to:
  /// **'Naziv ikone (opciono)'**
  String get referenceItemFormDialogIconLabel;

  /// No description provided for @referenceItemFormDialogCodeError.
  ///
  /// In bs, this message translates to:
  /// **'Oznaka moze sadrzavati velika slova, cifre i podvlaku, npr. PAYPAL.'**
  String get referenceItemFormDialogCodeError;

  /// No description provided for @referenceItemFormDialogUrgentSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Hitno po podrazumijevanoj vrijednosti'**
  String get referenceItemFormDialogUrgentSwitch;

  /// No description provided for @referenceItemFormDialogOnlineSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Placanje putem interneta'**
  String get referenceItemFormDialogOnlineSwitch;

  /// No description provided for @referenceItemFormDialogActiveSwitch.
  ///
  /// In bs, this message translates to:
  /// **'Aktivan nacin placanja'**
  String get referenceItemFormDialogActiveSwitch;

  /// No description provided for @reportsScreenDateFromHelp.
  ///
  /// In bs, this message translates to:
  /// **'Datum od'**
  String get reportsScreenDateFromHelp;

  /// No description provided for @reportsScreenDateToHelp.
  ///
  /// In bs, this message translates to:
  /// **'Datum do'**
  String get reportsScreenDateToHelp;

  /// No description provided for @reportsScreenSaveSuccess.
  ///
  /// In bs, this message translates to:
  /// **'Izvjestaj je sacuvan: {path}'**
  String reportsScreenSaveSuccess(String path);

  /// No description provided for @reportsScreenSaveError.
  ///
  /// In bs, this message translates to:
  /// **'Neuspjelo cuvanje izvjestaja: {error}'**
  String reportsScreenSaveError(String error);

  /// No description provided for @reportsScreenSalesTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prodaja karata po danima'**
  String get reportsScreenSalesTitle;

  /// No description provided for @reportsScreenFromLabel.
  ///
  /// In bs, this message translates to:
  /// **'Od'**
  String get reportsScreenFromLabel;

  /// No description provided for @reportsScreenToLabel.
  ///
  /// In bs, this message translates to:
  /// **'Do'**
  String get reportsScreenToLabel;

  /// No description provided for @reportsScreenAllResorts.
  ///
  /// In bs, this message translates to:
  /// **'Sva skijalista'**
  String get reportsScreenAllResorts;

  /// No description provided for @reportsScreenTopUsersTitle.
  ///
  /// In bs, this message translates to:
  /// **'Top {count} korisnika'**
  String reportsScreenTopUsersTitle(int count);

  /// No description provided for @reportsScreenDownloadPdf.
  ///
  /// In bs, this message translates to:
  /// **'Preuzmi PDF'**
  String get reportsScreenDownloadPdf;

  /// No description provided for @reportsScreenPrint.
  ///
  /// In bs, this message translates to:
  /// **'Ispis'**
  String get reportsScreenPrint;

  /// No description provided for @reportsScreenTotalTickets.
  ///
  /// In bs, this message translates to:
  /// **'Ukupno karata'**
  String get reportsScreenTotalTickets;

  /// No description provided for @reportsScreenTotalRevenue.
  ///
  /// In bs, this message translates to:
  /// **'Ukupan prihod'**
  String get reportsScreenTotalRevenue;

  /// No description provided for @reportsScreenNoDataForPeriod.
  ///
  /// In bs, this message translates to:
  /// **'Nema podataka za odabrani period.'**
  String get reportsScreenNoDataForPeriod;

  /// No description provided for @reportsScreenTicketCountLegend.
  ///
  /// In bs, this message translates to:
  /// **'Broj karata'**
  String get reportsScreenTicketCountLegend;

  /// No description provided for @reportsScreenRevenueLegend.
  ///
  /// In bs, this message translates to:
  /// **'Prihod (skalirano)'**
  String get reportsScreenRevenueLegend;

  /// No description provided for @reportsScreenNoPurchaseData.
  ///
  /// In bs, this message translates to:
  /// **'Nema podataka o kupovinama.'**
  String get reportsScreenNoPurchaseData;
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
      <String>['bs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
