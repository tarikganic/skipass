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

  /// Naziv aplikacije.
  ///
  /// In bs, this message translates to:
  /// **'SkiPass'**
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

  /// No description provided for @commonDiscard.
  ///
  /// In bs, this message translates to:
  /// **'Odustani'**
  String get commonDiscard;

  /// No description provided for @commonConfirm.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdi'**
  String get commonConfirm;

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

  /// No description provided for @errorUnableToLoadData.
  ///
  /// In bs, this message translates to:
  /// **'Podatke nije moguce ucitati'**
  String get errorUnableToLoadData;

  /// No description provided for @commonRetry.
  ///
  /// In bs, this message translates to:
  /// **'Pokusaj ponovo'**
  String get commonRetry;

  /// No description provided for @reasonMinLengthError.
  ///
  /// In bs, this message translates to:
  /// **'Obrazlozenje mora imati najmanje 3 znaka.'**
  String get reasonMinLengthError;

  /// No description provided for @commonAll.
  ///
  /// In bs, this message translates to:
  /// **'Sve'**
  String get commonAll;

  /// No description provided for @commonYes.
  ///
  /// In bs, this message translates to:
  /// **'Da'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In bs, this message translates to:
  /// **'Ne'**
  String get commonNo;

  /// No description provided for @commonNoData.
  ///
  /// In bs, this message translates to:
  /// **'Nema podataka'**
  String get commonNoData;

  /// No description provided for @commonTotal.
  ///
  /// In bs, this message translates to:
  /// **'Ukupno'**
  String get commonTotal;

  /// No description provided for @commonBuy.
  ///
  /// In bs, this message translates to:
  /// **'Kupi'**
  String get commonBuy;

  /// No description provided for @resetFiltersAction.
  ///
  /// In bs, this message translates to:
  /// **'Ponisti filtere'**
  String get resetFiltersAction;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Ocisti pretragu'**
  String get clearSearchTooltip;

  /// No description provided for @cancellationReasonLabel.
  ///
  /// In bs, this message translates to:
  /// **'Razlog otkazivanja'**
  String get cancellationReasonLabel;

  /// No description provided for @discountBadge.
  ///
  /// In bs, this message translates to:
  /// **'Popust {percent}%'**
  String discountBadge(String percent);

  /// No description provided for @imagePickFailedMessage.
  ///
  /// In bs, this message translates to:
  /// **'Odabir slike nije uspio. Pokusajte ponovo.'**
  String get imagePickFailedMessage;

  /// No description provided for @removePhotoAction.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni sliku'**
  String get removePhotoAction;

  /// No description provided for @paymentFailedGenericMessage.
  ///
  /// In bs, this message translates to:
  /// **'Placanje nije uspjelo. Pokusajte ponovo.'**
  String get paymentFailedGenericMessage;

  /// No description provided for @fieldUsernameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Korisnicko ime'**
  String get fieldUsernameLabel;

  /// No description provided for @fieldFirstNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ime'**
  String get fieldFirstNameLabel;

  /// No description provided for @fieldLastNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Prezime'**
  String get fieldLastNameLabel;

  /// No description provided for @fieldEmailLabel.
  ///
  /// In bs, this message translates to:
  /// **'E-mail adresa'**
  String get fieldEmailLabel;

  /// No description provided for @emailHintExample.
  ///
  /// In bs, this message translates to:
  /// **'ime@domena.ba'**
  String get emailHintExample;

  /// No description provided for @fieldPhoneLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj telefona'**
  String get fieldPhoneLabel;

  /// No description provided for @fieldPhoneHint.
  ///
  /// In bs, this message translates to:
  /// **'+387 61 123 456'**
  String get fieldPhoneHint;

  /// No description provided for @fieldBirthDateLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum rodjenja'**
  String get fieldBirthDateLabel;

  /// No description provided for @dateFieldSelectHint.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi datum'**
  String get dateFieldSelectHint;

  /// No description provided for @fieldCityLabel.
  ///
  /// In bs, this message translates to:
  /// **'Grad'**
  String get fieldCityLabel;

  /// No description provided for @cityDropdownHint.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi grad'**
  String get cityDropdownHint;

  /// No description provided for @fieldPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka'**
  String get fieldPasswordLabel;

  /// No description provided for @fieldNewPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nova lozinka'**
  String get fieldNewPasswordLabel;

  /// No description provided for @fieldConfirmNewPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda nove lozinke'**
  String get fieldConfirmNewPasswordLabel;

  /// No description provided for @passwordMinLengthHelper.
  ///
  /// In bs, this message translates to:
  /// **'Najmanje 4 znaka.'**
  String get passwordMinLengthHelper;

  /// No description provided for @showPasswordTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Prikazi lozinku'**
  String get showPasswordTooltip;

  /// No description provided for @hidePasswordTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Sakrij lozinku'**
  String get hidePasswordTooltip;

  /// No description provided for @statusOrderPending.
  ///
  /// In bs, this message translates to:
  /// **'Ceka placanje'**
  String get statusOrderPending;

  /// No description provided for @statusOrderConfirmed.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdena'**
  String get statusOrderConfirmed;

  /// No description provided for @statusOrderCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Zavrsena'**
  String get statusOrderCompleted;

  /// No description provided for @statusOrderCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Otkazana'**
  String get statusOrderCancelled;

  /// No description provided for @statusTicketPending.
  ///
  /// In bs, this message translates to:
  /// **'Neaktivna'**
  String get statusTicketPending;

  /// No description provided for @statusTicketActive.
  ///
  /// In bs, this message translates to:
  /// **'Aktivna'**
  String get statusTicketActive;

  /// No description provided for @statusTicketUsed.
  ///
  /// In bs, this message translates to:
  /// **'U upotrebi'**
  String get statusTicketUsed;

  /// No description provided for @statusTicketExpired.
  ///
  /// In bs, this message translates to:
  /// **'Istekla'**
  String get statusTicketExpired;

  /// No description provided for @statusIncidentReported.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljen'**
  String get statusIncidentReported;

  /// No description provided for @statusIncidentInProgress.
  ///
  /// In bs, this message translates to:
  /// **'U toku'**
  String get statusIncidentInProgress;

  /// No description provided for @statusIncidentResolved.
  ///
  /// In bs, this message translates to:
  /// **'Rijesen'**
  String get statusIncidentResolved;

  /// No description provided for @statusIncidentRejected.
  ///
  /// In bs, this message translates to:
  /// **'Odbijen'**
  String get statusIncidentRejected;

  /// No description provided for @statusCrowdLow.
  ///
  /// In bs, this message translates to:
  /// **'Slaba guzva'**
  String get statusCrowdLow;

  /// No description provided for @statusCrowdModerate.
  ///
  /// In bs, this message translates to:
  /// **'Umjerena guzva'**
  String get statusCrowdModerate;

  /// No description provided for @statusCrowdHigh.
  ///
  /// In bs, this message translates to:
  /// **'Velika guzva'**
  String get statusCrowdHigh;

  /// No description provided for @statusCrowdVeryHigh.
  ///
  /// In bs, this message translates to:
  /// **'Izuzetna guzva'**
  String get statusCrowdVeryHigh;

  /// No description provided for @statusOpen.
  ///
  /// In bs, this message translates to:
  /// **'Otvorena'**
  String get statusOpen;

  /// No description provided for @statusClosed.
  ///
  /// In bs, this message translates to:
  /// **'Zatvorena'**
  String get statusClosed;

  /// No description provided for @statusUnknown.
  ///
  /// In bs, this message translates to:
  /// **'Nepoznato'**
  String get statusUnknown;

  /// No description provided for @statusUrgentLabel.
  ///
  /// In bs, this message translates to:
  /// **'Hitno'**
  String get statusUrgentLabel;

  /// No description provided for @navHome.
  ///
  /// In bs, this message translates to:
  /// **'Pocetna'**
  String get navHome;

  /// No description provided for @navTrails.
  ///
  /// In bs, this message translates to:
  /// **'Staze'**
  String get navTrails;

  /// No description provided for @navPurchase.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina'**
  String get navPurchase;

  /// No description provided for @navTickets.
  ///
  /// In bs, this message translates to:
  /// **'Karte'**
  String get navTickets;

  /// No description provided for @navBenefits.
  ///
  /// In bs, this message translates to:
  /// **'Pogodnosti'**
  String get navBenefits;

  /// No description provided for @navProfile.
  ///
  /// In bs, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @loginHeaderTitle.
  ///
  /// In bs, this message translates to:
  /// **'Dobro dosli'**
  String get loginHeaderTitle;

  /// No description provided for @loginHeaderSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijavite se za kupovinu ski pass karata\ni pregled staza u realnom vremenu.'**
  String get loginHeaderSubtitle;

  /// No description provided for @loginUsernameHint.
  ///
  /// In bs, this message translates to:
  /// **'npr. mobile'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In bs, this message translates to:
  /// **'Unesite lozinku'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPasswordLink.
  ///
  /// In bs, this message translates to:
  /// **'Zaboravljena lozinka?'**
  String get loginForgotPasswordLink;

  /// No description provided for @loginSubmitButton.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi se'**
  String get loginSubmitButton;

  /// No description provided for @loginNoAccountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nemate racun?'**
  String get loginNoAccountLabel;

  /// No description provided for @loginRegisterLink.
  ///
  /// In bs, this message translates to:
  /// **'Registrujte se'**
  String get loginRegisterLink;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Registracija'**
  String get registerAppBarTitle;

  /// No description provided for @registerHeading.
  ///
  /// In bs, this message translates to:
  /// **'Kreirajte racun'**
  String get registerHeading;

  /// No description provided for @registerRequiredFieldsNote.
  ///
  /// In bs, this message translates to:
  /// **'Polja oznacena zvjezdicom su obavezna.'**
  String get registerRequiredFieldsNote;

  /// No description provided for @registerUsernameHint.
  ///
  /// In bs, this message translates to:
  /// **'npr. skijas.haris'**
  String get registerUsernameHint;

  /// No description provided for @registerPhoneHelper.
  ///
  /// In bs, this message translates to:
  /// **'Koristi se za kontakt u slucaju prijave incidenta.'**
  String get registerPhoneHelper;

  /// No description provided for @registerCitiesUnavailable.
  ///
  /// In bs, this message translates to:
  /// **'Gradovi trenutno nisu dostupni'**
  String get registerCitiesUnavailable;

  /// No description provided for @fieldConfirmPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda lozinke'**
  String get fieldConfirmPasswordLabel;

  /// No description provided for @registerSubmitButton.
  ///
  /// In bs, this message translates to:
  /// **'Kreiraj racun'**
  String get registerSubmitButton;

  /// No description provided for @registerBackToLogin.
  ///
  /// In bs, this message translates to:
  /// **'Nazad na prijavu'**
  String get registerBackToLogin;

  /// No description provided for @registerMinorNotice.
  ///
  /// In bs, this message translates to:
  /// **'Napomena: za maloljetne korisnike kupovinu karata potvrdjuje roditelj ili staratelj.'**
  String get registerMinorNotice;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Racun je kreiran. Dobro dosli u SkiPass!'**
  String get registerSuccessMessage;

  /// No description provided for @forgotPasswordAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Reset lozinke'**
  String get forgotPasswordAppBarTitle;

  /// No description provided for @forgotPasswordHeadingReset.
  ///
  /// In bs, this message translates to:
  /// **'Unesite novu lozinku'**
  String get forgotPasswordHeadingReset;

  /// No description provided for @forgotPasswordHeadingRequest.
  ///
  /// In bs, this message translates to:
  /// **'Zaboravljena lozinka'**
  String get forgotPasswordHeadingRequest;

  /// No description provided for @forgotPasswordSubtitleReset.
  ///
  /// In bs, this message translates to:
  /// **'Unesite kod koji ste dobili i odaberite novu lozinku.'**
  String get forgotPasswordSubtitleReset;

  /// No description provided for @forgotPasswordSubtitleRequest.
  ///
  /// In bs, this message translates to:
  /// **'Unesite e-mail adresu sa kojom ste registrovani i poslacemo vam kod za reset lozinke.'**
  String get forgotPasswordSubtitleRequest;

  /// No description provided for @forgotPasswordSendCodeButton.
  ///
  /// In bs, this message translates to:
  /// **'Posalji kod'**
  String get forgotPasswordSendCodeButton;

  /// No description provided for @forgotPasswordCodeSentInfo.
  ///
  /// In bs, this message translates to:
  /// **'Ako je adresa registrovana, poslali smo kod za reset lozinke.'**
  String get forgotPasswordCodeSentInfo;

  /// No description provided for @forgotPasswordResetCodeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kod za reset'**
  String get forgotPasswordResetCodeLabel;

  /// No description provided for @forgotPasswordSetNewButton.
  ///
  /// In bs, this message translates to:
  /// **'Postavi novu lozinku'**
  String get forgotPasswordSetNewButton;

  /// No description provided for @forgotPasswordResendOtherAddress.
  ///
  /// In bs, this message translates to:
  /// **'Posalji kod na drugu adresu'**
  String get forgotPasswordResendOtherAddress;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka je promijenjena. Prijavite se novom lozinkom.'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @devNoticeTitle.
  ///
  /// In bs, this message translates to:
  /// **'Razvojno okruzenje'**
  String get devNoticeTitle;

  /// No description provided for @devNoticeCopyTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Kopiraj kod'**
  String get devNoticeCopyTooltip;

  /// No description provided for @devNoticeBody.
  ///
  /// In bs, this message translates to:
  /// **'Kod je automatski popunjen jer e-mail servis jos nije aktivan. U produkciji kod stize na e-mail adresu.'**
  String get devNoticeBody;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In bs, this message translates to:
  /// **'Dobro jutro'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In bs, this message translates to:
  /// **'Dobar dan'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In bs, this message translates to:
  /// **'Dobro vece'**
  String get homeGreetingEvening;

  /// No description provided for @homeDefaultUserName.
  ///
  /// In bs, this message translates to:
  /// **'Skijasu'**
  String get homeDefaultUserName;

  /// No description provided for @homeResortOpenUntil.
  ///
  /// In bs, this message translates to:
  /// **'Otvoreno danas do {time}'**
  String homeResortOpenUntil(String time);

  /// No description provided for @homeResortClosed.
  ///
  /// In bs, this message translates to:
  /// **'Zatvoreno - radno vrijeme {opening} - {closing}'**
  String homeResortClosed(String opening, String closing);

  /// No description provided for @homeCurrentOnTrail.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno na stazi'**
  String get homeCurrentOnTrail;

  /// No description provided for @homeSnowDepthLabel.
  ///
  /// In bs, this message translates to:
  /// **'{cm} cm snijega'**
  String homeSnowDepthLabel(int cm);

  /// No description provided for @homeLatestAnnouncements.
  ///
  /// In bs, this message translates to:
  /// **'Najnovije obavijesti'**
  String get homeLatestAnnouncements;

  /// No description provided for @homeNoActiveAnnouncements.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno nema aktivnih obavijesti.'**
  String get homeNoActiveAnnouncements;

  /// No description provided for @homeFeaturedBenefits.
  ///
  /// In bs, this message translates to:
  /// **'Izdvojene pogodnosti'**
  String get homeFeaturedBenefits;

  /// No description provided for @homeNoFeaturedBenefits.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno nema izdvojenih pogodnosti.'**
  String get homeNoFeaturedBenefits;

  /// No description provided for @homeRecommendedTitle.
  ///
  /// In bs, this message translates to:
  /// **'Preporuceno za vas'**
  String get homeRecommendedTitle;

  /// No description provided for @homeNoRecommendations.
  ///
  /// In bs, this message translates to:
  /// **'Trenutno nemamo preporuke za vas.'**
  String get homeNoRecommendations;

  /// No description provided for @recommendationReasonPurchasedCategory.
  ///
  /// In bs, this message translates to:
  /// **'Jer ste ranije kupili iz kategorije {category}'**
  String recommendationReasonPurchasedCategory(String category);

  /// No description provided for @recommendationReasonViewedCategory.
  ///
  /// In bs, this message translates to:
  /// **'Jer cesto pregledate kategoriju {category}'**
  String recommendationReasonViewedCategory(String category);

  /// No description provided for @recommendationReasonUsedPartner.
  ///
  /// In bs, this message translates to:
  /// **'Jer ste koristili usluge partnera {partner}'**
  String recommendationReasonUsedPartner(String partner);

  /// No description provided for @recommendationReasonPreferredBrand.
  ///
  /// In bs, this message translates to:
  /// **'Jer preferirate brend {brand}'**
  String recommendationReasonPreferredBrand(String brand);

  /// No description provided for @recommendationReasonPopularFallback.
  ///
  /// In bs, this message translates to:
  /// **'Popularno medju korisnicima'**
  String get recommendationReasonPopularFallback;

  /// No description provided for @homeTrailsOpenLabel.
  ///
  /// In bs, this message translates to:
  /// **'otvorenih'**
  String get homeTrailsOpenLabel;

  /// No description provided for @homeLiftsCardTitle.
  ///
  /// In bs, this message translates to:
  /// **'Ski liftovi'**
  String get homeLiftsCardTitle;

  /// No description provided for @homeLiftsOperationalLabel.
  ///
  /// In bs, this message translates to:
  /// **'u pogonu'**
  String get homeLiftsOperationalLabel;

  /// No description provided for @homeActiveTicketsMessage.
  ///
  /// In bs, this message translates to:
  /// **'Imate {count} za danas'**
  String homeActiveTicketsMessage(String count);

  /// No description provided for @homeNoActiveTicketMessage.
  ///
  /// In bs, this message translates to:
  /// **'Nemate aktivnu kartu'**
  String get homeNoActiveTicketMessage;

  /// No description provided for @homeShowQrHint.
  ///
  /// In bs, this message translates to:
  /// **'Prikazite QR kod na ulazu na lift.'**
  String get homeShowQrHint;

  /// No description provided for @homeBuyTicketHint.
  ///
  /// In bs, this message translates to:
  /// **'Kupite ski pass i krenite na stazu.'**
  String get homeBuyTicketHint;

  /// No description provided for @homeQrCodeButton.
  ///
  /// In bs, this message translates to:
  /// **'QR kod'**
  String get homeQrCodeButton;

  /// No description provided for @trailsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Staze i liftovi'**
  String get trailsAppBarTitle;

  /// No description provided for @trailsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi stazu po nazivu ili oznaci'**
  String get trailsSearchHint;

  /// No description provided for @trailsFilterOpen.
  ///
  /// In bs, this message translates to:
  /// **'Otvorene'**
  String get trailsFilterOpen;

  /// No description provided for @liftsFilterAll.
  ///
  /// In bs, this message translates to:
  /// **'Svi'**
  String get liftsFilterAll;

  /// No description provided for @liftsFilterOperational.
  ///
  /// In bs, this message translates to:
  /// **'U pogonu'**
  String get liftsFilterOperational;

  /// No description provided for @liftsFilterNonOperational.
  ///
  /// In bs, this message translates to:
  /// **'Van pogona'**
  String get liftsFilterNonOperational;

  /// No description provided for @trailsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema staza za zadate uslove'**
  String get trailsEmptyTitle;

  /// No description provided for @trailsEmptyMessageFiltered.
  ///
  /// In bs, this message translates to:
  /// **'Pokusajte promijeniti pretragu ili filtere.'**
  String get trailsEmptyMessageFiltered;

  /// No description provided for @trailsEmptyMessageNone.
  ///
  /// In bs, this message translates to:
  /// **'Staze jos nisu unesene u sistem.'**
  String get trailsEmptyMessageNone;

  /// No description provided for @trailMetricLength.
  ///
  /// In bs, this message translates to:
  /// **'Duzina'**
  String get trailMetricLength;

  /// No description provided for @trailMetricElevation.
  ///
  /// In bs, this message translates to:
  /// **'Visinska razlika'**
  String get trailMetricElevation;

  /// No description provided for @trailMetricSnow.
  ///
  /// In bs, this message translates to:
  /// **'Snijeg'**
  String get trailMetricSnow;

  /// No description provided for @trailNightSkiingLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nocno skijanje'**
  String get trailNightSkiingLabel;

  /// No description provided for @trailIncidentReportsCount.
  ///
  /// In bs, this message translates to:
  /// **'{count} prijava'**
  String trailIncidentReportsCount(int count);

  /// No description provided for @liftsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema liftova za zadate uslove'**
  String get liftsEmptyTitle;

  /// No description provided for @liftsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Promijenite filter da vidite ostale liftove.'**
  String get liftsEmptyMessage;

  /// No description provided for @liftRideDurationSuffix.
  ///
  /// In bs, this message translates to:
  /// **'{minutes} min voznje'**
  String liftRideDurationSuffix(int minutes);

  /// No description provided for @liftCurrentRiders.
  ///
  /// In bs, this message translates to:
  /// **'{count} korisnika trenutno'**
  String liftCurrentRiders(int count);

  /// No description provided for @liftCapacityLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kapacitet {capacity}/h'**
  String liftCapacityLabel(int capacity);

  /// No description provided for @liftOutOfServiceNotice.
  ///
  /// In bs, this message translates to:
  /// **'Lift je van pogona zbog prijavljenog kvara. Servis je u toku.'**
  String get liftOutOfServiceNotice;

  /// No description provided for @trailDetailsDefaultTitle.
  ///
  /// In bs, this message translates to:
  /// **'Detalji staze'**
  String get trailDetailsDefaultTitle;

  /// No description provided for @trailReportProblemButton.
  ///
  /// In bs, this message translates to:
  /// **'Prijavi problem'**
  String get trailReportProblemButton;

  /// No description provided for @trailAboutSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'O stazi'**
  String get trailAboutSectionTitle;

  /// No description provided for @trailConditionsHistoryTitle.
  ///
  /// In bs, this message translates to:
  /// **'Historija uslova'**
  String get trailConditionsHistoryTitle;

  /// No description provided for @trailNoConditionsRecorded.
  ///
  /// In bs, this message translates to:
  /// **'Za ovu stazu jos nisu evidentirani uslovi.'**
  String get trailNoConditionsRecorded;

  /// No description provided for @trailReviewsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Ocjene staze'**
  String get trailReviewsTitle;

  /// No description provided for @trailCodeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Oznaka staze'**
  String get trailCodeLabel;

  /// No description provided for @trailCrowdLabel.
  ///
  /// In bs, this message translates to:
  /// **'Procijenjena guzva'**
  String get trailCrowdLabel;

  /// No description provided for @trailSnowCoverLabel.
  ///
  /// In bs, this message translates to:
  /// **'Snjezni pokrivac'**
  String get trailSnowCoverLabel;

  /// No description provided for @trailSnowmakingLabel.
  ///
  /// In bs, this message translates to:
  /// **'Vjestacki snijeg'**
  String get trailSnowmakingLabel;

  /// No description provided for @benefitsSearchHint.
  ///
  /// In bs, this message translates to:
  /// **'Pretrazi pogodnost, uslugu ili brend'**
  String get benefitsSearchHint;

  /// No description provided for @myBenefitsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Moje pogodnosti'**
  String get myBenefitsTitle;

  /// No description provided for @benefitsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema pogodnosti za zadate uslove'**
  String get benefitsEmptyTitle;

  /// No description provided for @benefitsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Pokusajte drugu pretragu ili odaberite drugu kategoriju.'**
  String get benefitsEmptyMessage;

  /// No description provided for @benefitNotYetRated.
  ///
  /// In bs, this message translates to:
  /// **'Jos nije ocijenjeno'**
  String get benefitNotYetRated;

  /// No description provided for @benefitDetailsDefaultTitle.
  ///
  /// In bs, this message translates to:
  /// **'Detalji pogodnosti'**
  String get benefitDetailsDefaultTitle;

  /// No description provided for @benefitPurchaseConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda kupovine'**
  String get benefitPurchaseConfirmTitle;

  /// No description provided for @benefitPurchaseConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Kupiti {quantity} × {name} u ukupnom iznosu od {total}?'**
  String benefitPurchaseConfirmMessage(int quantity, String name, String total);

  /// No description provided for @benefitPurchaseSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'{name} je uspjesno kupljeno. Pregled je dostupan u \"Moje pogodnosti\".'**
  String benefitPurchaseSuccessMessage(String name);

  /// No description provided for @benefitRatingsSummary.
  ///
  /// In bs, this message translates to:
  /// **'{average} · {count} ocjena'**
  String benefitRatingsSummary(String average, int count);

  /// No description provided for @benefitCategoryLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kategorija'**
  String get benefitCategoryLabel;

  /// No description provided for @benefitPartnerLabel.
  ///
  /// In bs, this message translates to:
  /// **'Partner'**
  String get benefitPartnerLabel;

  /// No description provided for @benefitBrandLabel.
  ///
  /// In bs, this message translates to:
  /// **'Brend'**
  String get benefitBrandLabel;

  /// No description provided for @benefitRegularPriceLabel.
  ///
  /// In bs, this message translates to:
  /// **'Redovna cijena'**
  String get benefitRegularPriceLabel;

  /// No description provided for @benefitDiscountedPriceLabel.
  ///
  /// In bs, this message translates to:
  /// **'Cijena sa popustom'**
  String get benefitDiscountedPriceLabel;

  /// No description provided for @benefitDescriptionSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Opis'**
  String get benefitDescriptionSectionTitle;

  /// No description provided for @benefitInactiveNotice.
  ///
  /// In bs, this message translates to:
  /// **'Ova pogodnost trenutno nije dostupna za kupovinu.'**
  String get benefitInactiveNotice;

  /// No description provided for @benefitUserReviewsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Ocjene korisnika'**
  String get benefitUserReviewsTitle;

  /// No description provided for @benefitQuantityLabel.
  ///
  /// In bs, this message translates to:
  /// **'Kolicina'**
  String get benefitQuantityLabel;

  /// No description provided for @benefitCancelPurchaseTitle.
  ///
  /// In bs, this message translates to:
  /// **'Otkazivanje kupovine'**
  String get benefitCancelPurchaseTitle;

  /// No description provided for @benefitCancelSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina \"{name}\" je otkazana.'**
  String benefitCancelSuccessMessage(String name);

  /// No description provided for @myBenefitsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Jos niste kupili nijednu pogodnost'**
  String get myBenefitsEmptyTitle;

  /// No description provided for @myBenefitsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Iznajmljivanje opreme, obuke i ugostiteljska ponuda dostupni su u sekciji Pogodnosti.'**
  String get myBenefitsEmptyMessage;

  /// No description provided for @benefitCancellationReasonLine.
  ///
  /// In bs, this message translates to:
  /// **'Razlog otkazivanja: {reason}'**
  String benefitCancellationReasonLine(String reason);

  /// No description provided for @benefitCancelPurchaseButton.
  ///
  /// In bs, this message translates to:
  /// **'Otkazi kupovinu'**
  String get benefitCancelPurchaseButton;

  /// No description provided for @myIncidentsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Moje prijave'**
  String get myIncidentsAppBarTitle;

  /// No description provided for @incidentNewReportButton.
  ///
  /// In bs, this message translates to:
  /// **'Nova prijava'**
  String get incidentNewReportButton;

  /// No description provided for @incidentStatusReportedFilter.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljeni'**
  String get incidentStatusReportedFilter;

  /// No description provided for @incidentStatusResolvedFilter.
  ///
  /// In bs, this message translates to:
  /// **'Rijeseni'**
  String get incidentStatusResolvedFilter;

  /// No description provided for @incidentStatusRejectedFilter.
  ///
  /// In bs, this message translates to:
  /// **'Odbijeni'**
  String get incidentStatusRejectedFilter;

  /// No description provided for @incidentsEmptyTitleNone.
  ///
  /// In bs, this message translates to:
  /// **'Nemate prijavljenih incidenata'**
  String get incidentsEmptyTitleNone;

  /// No description provided for @incidentsEmptyTitleFiltered.
  ///
  /// In bs, this message translates to:
  /// **'Nema prijava u ovom statusu'**
  String get incidentsEmptyTitleFiltered;

  /// No description provided for @incidentsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Ako primijetite problem na stazi ili liftu, prijavite ga kako bi osoblje moglo reagovati.'**
  String get incidentsEmptyMessage;

  /// No description provided for @incidentRejectionReasonTitle.
  ///
  /// In bs, this message translates to:
  /// **'Razlog odbijanja'**
  String get incidentRejectionReasonTitle;

  /// No description provided for @incidentStaffNoteTitle.
  ///
  /// In bs, this message translates to:
  /// **'Obrazlozenje osoblja'**
  String get incidentStaffNoteTitle;

  /// No description provided for @reportIncidentAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijava incidenta'**
  String get reportIncidentAppBarTitle;

  /// No description provided for @selectIncidentTypeError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite tip incidenta.'**
  String get selectIncidentTypeError;

  /// No description provided for @selectTrailError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite stazu na koju se prijava odnosi.'**
  String get selectTrailError;

  /// No description provided for @selectLiftError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite ski lift na koji se prijava odnosi.'**
  String get selectLiftError;

  /// No description provided for @incidentReportSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Prijava je poslana. Osoblje skijalista je obavijesteno.'**
  String get incidentReportSuccessMessage;

  /// No description provided for @coordinatesInvalidFormatError.
  ///
  /// In bs, this message translates to:
  /// **'Koordinate nisu u ispravnom formatu.'**
  String get coordinatesInvalidFormatError;

  /// No description provided for @incidentEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijava trenutno nije moguca'**
  String get incidentEmptyTitle;

  /// No description provided for @incidentEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Tipovi incidenata jos nisu definisani u sistemu.'**
  String get incidentEmptyMessage;

  /// No description provided for @incidentSafetyNotice.
  ///
  /// In bs, this message translates to:
  /// **'U slucaju tezih povreda odmah pozovite hitnu pomoc. Ova prijava sluzi za obavjestavanje osoblja skijalista.'**
  String get incidentSafetyNotice;

  /// No description provided for @incidentTypeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tip incidenta'**
  String get incidentTypeLabel;

  /// No description provided for @incidentLocationLabel.
  ///
  /// In bs, this message translates to:
  /// **'Lokacija incidenta'**
  String get incidentLocationLabel;

  /// No description provided for @targetTrailLabel.
  ///
  /// In bs, this message translates to:
  /// **'Staza'**
  String get targetTrailLabel;

  /// No description provided for @targetLiftLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ski lift'**
  String get targetLiftLabel;

  /// No description provided for @trailsUnavailableHint.
  ///
  /// In bs, this message translates to:
  /// **'Staze nisu dostupne'**
  String get trailsUnavailableHint;

  /// No description provided for @liftsUnavailableHint.
  ///
  /// In bs, this message translates to:
  /// **'Liftovi nisu dostupni'**
  String get liftsUnavailableHint;

  /// No description provided for @problemDescriptionLabel.
  ///
  /// In bs, this message translates to:
  /// **'Opis problema'**
  String get problemDescriptionLabel;

  /// No description provided for @problemDescriptionHint.
  ///
  /// In bs, this message translates to:
  /// **'Opisite sta se dogodilo i gdje tacno.'**
  String get problemDescriptionHint;

  /// No description provided for @minTenCharsHelper.
  ///
  /// In bs, this message translates to:
  /// **'Najmanje 10 znakova.'**
  String get minTenCharsHelper;

  /// No description provided for @submitReportButton.
  ///
  /// In bs, this message translates to:
  /// **'Posalji prijavu'**
  String get submitReportButton;

  /// No description provided for @coordinatesFieldTitle.
  ///
  /// In bs, this message translates to:
  /// **'Koordinate lokacije'**
  String get coordinatesFieldTitle;

  /// No description provided for @coordinatesFieldSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite najblizu tacku ili unesite tacne koordinate.'**
  String get coordinatesFieldSubtitle;

  /// No description provided for @knownSpotBase.
  ///
  /// In bs, this message translates to:
  /// **'Baza skijalista'**
  String get knownSpotBase;

  /// No description provided for @knownSpotMiddle.
  ///
  /// In bs, this message translates to:
  /// **'Sredina staze'**
  String get knownSpotMiddle;

  /// No description provided for @knownSpotTop.
  ///
  /// In bs, this message translates to:
  /// **'Vrh staze'**
  String get knownSpotTop;

  /// No description provided for @knownSpotLiftStart.
  ///
  /// In bs, this message translates to:
  /// **'Polazna stanica lifta'**
  String get knownSpotLiftStart;

  /// No description provided for @geoLatitudeName.
  ///
  /// In bs, this message translates to:
  /// **'Geografska sirina'**
  String get geoLatitudeName;

  /// No description provided for @geoLongitudeName.
  ///
  /// In bs, this message translates to:
  /// **'Geografska duzina'**
  String get geoLongitudeName;

  /// No description provided for @coordinateRequiredError.
  ///
  /// In bs, this message translates to:
  /// **'{name} je obavezna.'**
  String coordinateRequiredError(String name);

  /// No description provided for @coordinateFormatError.
  ///
  /// In bs, this message translates to:
  /// **'Unesite broj u formatu 43.7107'**
  String get coordinateFormatError;

  /// No description provided for @coordinateRangeError.
  ///
  /// In bs, this message translates to:
  /// **'{name} mora biti izmedju {min} i {max}.'**
  String coordinateRangeError(String name, int min, int max);

  /// No description provided for @photoSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Fotografija (opciono)'**
  String get photoSectionTitle;

  /// No description provided for @cameraButton.
  ///
  /// In bs, this message translates to:
  /// **'Kamera'**
  String get cameraButton;

  /// No description provided for @galleryButton.
  ///
  /// In bs, this message translates to:
  /// **'Galerija'**
  String get galleryButton;

  /// No description provided for @notificationsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Notifikacije'**
  String get notificationsAppBarTitle;

  /// No description provided for @markAllReadAction.
  ///
  /// In bs, this message translates to:
  /// **'Oznaci sve'**
  String get markAllReadAction;

  /// No description provided for @markAllReadSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Sve notifikacije su oznacene kao procitane.'**
  String get markAllReadSuccessMessage;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nemate notifikacija'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Obavijesti o narudzbama, placanjima i prijavama stizat ce na ovaj ekran.'**
  String get notificationsEmptyMessage;

  /// No description provided for @ordersAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Historija narudzbi'**
  String get ordersAppBarTitle;

  /// No description provided for @orderStatusConfirmedFilter.
  ///
  /// In bs, this message translates to:
  /// **'Potvrdene'**
  String get orderStatusConfirmedFilter;

  /// No description provided for @orderStatusCompletedFilter.
  ///
  /// In bs, this message translates to:
  /// **'Zavrsene'**
  String get orderStatusCompletedFilter;

  /// No description provided for @orderStatusCancelledFilter.
  ///
  /// In bs, this message translates to:
  /// **'Otkazane'**
  String get orderStatusCancelledFilter;

  /// No description provided for @ordersEmptyTitleNone.
  ///
  /// In bs, this message translates to:
  /// **'Jos nemate narudzbi'**
  String get ordersEmptyTitleNone;

  /// No description provided for @ordersEmptyTitleFiltered.
  ///
  /// In bs, this message translates to:
  /// **'Nema narudzbi u ovom statusu'**
  String get ordersEmptyTitleFiltered;

  /// No description provided for @ordersEmptyMessageNone.
  ///
  /// In bs, this message translates to:
  /// **'Kada kupite ski pass kartu, narudzba ce se pojaviti ovdje.'**
  String get ordersEmptyMessageNone;

  /// No description provided for @ordersEmptyMessageFiltered.
  ///
  /// In bs, this message translates to:
  /// **'Promijenite filter da vidite ostale narudzbe.'**
  String get ordersEmptyMessageFiltered;

  /// No description provided for @orderDetailsDefaultTitle.
  ///
  /// In bs, this message translates to:
  /// **'Detalji narudzbe'**
  String get orderDetailsDefaultTitle;

  /// No description provided for @orderCancelTitle.
  ///
  /// In bs, this message translates to:
  /// **'Otkazivanje narudzbe'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelButton.
  ///
  /// In bs, this message translates to:
  /// **'Otkazi narudzbu'**
  String get orderCancelButton;

  /// No description provided for @orderCancelSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba {orderNumber} je otkazana.'**
  String orderCancelSuccessMessage(String orderNumber);

  /// No description provided for @paymentReceivedMessage.
  ///
  /// In bs, this message translates to:
  /// **'Placanje je zaprimljeno.'**
  String get paymentReceivedMessage;

  /// No description provided for @orderTicketCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj karata'**
  String get orderTicketCountLabel;

  /// No description provided for @orderPaymentMethodLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nacin placanja'**
  String get orderPaymentMethodLabel;

  /// No description provided for @orderTotalAmountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ukupan iznos'**
  String get orderTotalAmountLabel;

  /// No description provided for @orderPaidLabel.
  ///
  /// In bs, this message translates to:
  /// **'Placeno'**
  String get orderPaidLabel;

  /// No description provided for @orderRefundedLabel.
  ///
  /// In bs, this message translates to:
  /// **'Vraceno'**
  String get orderRefundedLabel;

  /// No description provided for @orderAwaitingPaymentNotice.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba ceka evidentirano placanje. Karte postaju aktivne cim placanje bude potvrdeno na blagajni ili kroz aplikaciju.'**
  String get orderAwaitingPaymentNotice;

  /// No description provided for @orderPayNowButton.
  ///
  /// In bs, this message translates to:
  /// **'Plati narudzbu'**
  String get orderPayNowButton;

  /// No description provided for @paymentsHistoryTitle.
  ///
  /// In bs, this message translates to:
  /// **'Evidencija placanja'**
  String get paymentsHistoryTitle;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In bs, this message translates to:
  /// **'Nije zavrseno'**
  String get paymentNotCompleted;

  /// No description provided for @ticketsInOrderTitle.
  ///
  /// In bs, this message translates to:
  /// **'Karte u narudzbi'**
  String get ticketsInOrderTitle;

  /// No description provided for @paymentStatusPartiallyRefunded.
  ///
  /// In bs, this message translates to:
  /// **'Djelimicno vraceno'**
  String get paymentStatusPartiallyRefunded;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In bs, this message translates to:
  /// **'Neuspjelo'**
  String get paymentStatusFailed;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In bs, this message translates to:
  /// **'Odjava'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In bs, this message translates to:
  /// **'Da li ste sigurni da se zelite odjaviti?'**
  String get logoutDialogMessage;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In bs, this message translates to:
  /// **'Odjavi se'**
  String get logoutConfirmButton;

  /// No description provided for @myActivitiesSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Moje aktivnosti'**
  String get myActivitiesSectionTitle;

  /// No description provided for @orderCountSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'{count} narudzbi'**
  String orderCountSubtitle(int count);

  /// No description provided for @myBenefitsMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupljene usluge i oprema'**
  String get myBenefitsMenuSubtitle;

  /// No description provided for @myReportsMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Prijavljeni incidenti'**
  String get myReportsMenuSubtitle;

  /// No description provided for @notificationsMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Obavijesti o narudzbama i prijavama'**
  String get notificationsMenuSubtitle;

  /// No description provided for @resortAnnouncementsMenuTitle.
  ///
  /// In bs, this message translates to:
  /// **'Obavijesti skijalista'**
  String get resortAnnouncementsMenuTitle;

  /// No description provided for @resortAnnouncementsMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Vremenski uslovi, akcije i zatvaranja'**
  String get resortAnnouncementsMenuSubtitle;

  /// No description provided for @accountSettingsSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Postavke racuna'**
  String get accountSettingsSectionTitle;

  /// No description provided for @editProfileMenuTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi profil'**
  String get editProfileMenuTitle;

  /// No description provided for @editProfileMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Licni podaci i slika'**
  String get editProfileMenuSubtitle;

  /// No description provided for @changePasswordMenuSubtitle.
  ///
  /// In bs, this message translates to:
  /// **'Uz potvrdu trenutne lozinke'**
  String get changePasswordMenuSubtitle;

  /// No description provided for @appVersionFooter.
  ///
  /// In bs, this message translates to:
  /// **'SkiPass · verzija 1.0.0'**
  String get appVersionFooter;

  /// No description provided for @profileEmailLabel.
  ///
  /// In bs, this message translates to:
  /// **'E-mail'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In bs, this message translates to:
  /// **'Telefon'**
  String get profilePhoneLabel;

  /// No description provided for @profilePhoneNotSet.
  ///
  /// In bs, this message translates to:
  /// **'Nije unesen'**
  String get profilePhoneNotSet;

  /// No description provided for @profileCityNotSet.
  ///
  /// In bs, this message translates to:
  /// **'Nije odabran'**
  String get profileCityNotSet;

  /// No description provided for @profileMemberSinceLabel.
  ///
  /// In bs, this message translates to:
  /// **'Clan od'**
  String get profileMemberSinceLabel;

  /// No description provided for @editProfileAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Uredi profil'**
  String get editProfileAppBarTitle;

  /// No description provided for @profileUpdateSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Profil je uspjesno azuriran.'**
  String get profileUpdateSuccessMessage;

  /// No description provided for @editProfileCitiesUnavailable.
  ///
  /// In bs, this message translates to:
  /// **'Gradovi nisu dostupni'**
  String get editProfileCitiesUnavailable;

  /// No description provided for @saveChangesButton.
  ///
  /// In bs, this message translates to:
  /// **'Sacuvaj izmjene'**
  String get saveChangesButton;

  /// No description provided for @pickerCameraOption.
  ///
  /// In bs, this message translates to:
  /// **'Slikaj kamerom'**
  String get pickerCameraOption;

  /// No description provided for @pickerGalleryOption.
  ///
  /// In bs, this message translates to:
  /// **'Odaberi iz galerije'**
  String get pickerGalleryOption;

  /// No description provided for @changePasswordAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Promjena lozinke'**
  String get changePasswordAppBarTitle;

  /// No description provided for @changePasswordSecurityNotice.
  ///
  /// In bs, this message translates to:
  /// **'Iz sigurnosnih razloga promjena lozinke ponistava sve aktivne sesije, pa ce biti potrebna ponovna prijava.'**
  String get changePasswordSecurityNotice;

  /// No description provided for @changePasswordConfirmDialogMessage.
  ///
  /// In bs, this message translates to:
  /// **'Nakon promjene lozinke bicete odjavljeni sa svih uredjaja. Nastaviti?'**
  String get changePasswordConfirmDialogMessage;

  /// No description provided for @changePasswordConfirmButton.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni'**
  String get changePasswordConfirmButton;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In bs, this message translates to:
  /// **'Trenutna lozinka'**
  String get currentPasswordLabel;

  /// No description provided for @changePasswordSubmitButton.
  ///
  /// In bs, this message translates to:
  /// **'Promijeni lozinku'**
  String get changePasswordSubmitButton;

  /// No description provided for @changePasswordSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Lozinka je promijenjena. Prijavite se ponovo.'**
  String get changePasswordSuccessMessage;

  /// No description provided for @purchaseAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina karte'**
  String get purchaseAppBarTitle;

  /// No description provided for @selectTicketTypeError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite tip karte.'**
  String get selectTicketTypeError;

  /// No description provided for @selectStartDateError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite datum pocetka vazenja karte.'**
  String get selectStartDateError;

  /// No description provided for @maxTicketsPerOrderError.
  ///
  /// In bs, this message translates to:
  /// **'U jednoj narudzbi je moguce kupiti najvise 20 karata.'**
  String get maxTicketsPerOrderError;

  /// No description provided for @ticketsAddedToCartMessage.
  ///
  /// In bs, this message translates to:
  /// **'Karte su dodane u korpu. Unesite imena nosilaca prije slanja narudzbe.'**
  String get ticketsAddedToCartMessage;

  /// No description provided for @emptyCartError.
  ///
  /// In bs, this message translates to:
  /// **'Korpa je prazna. Dodajte najmanje jednu kartu.'**
  String get emptyCartError;

  /// No description provided for @selectPaymentMethodError.
  ///
  /// In bs, this message translates to:
  /// **'Odaberite nacin placanja.'**
  String get selectPaymentMethodError;

  /// No description provided for @missingHolderNameError.
  ///
  /// In bs, this message translates to:
  /// **'Unesite ime i prezime nosioca za kartu broj {number}.'**
  String missingHolderNameError(int number);

  /// No description provided for @orderConfirmTitle.
  ///
  /// In bs, this message translates to:
  /// **'Potvrda narudzbe'**
  String get orderConfirmTitle;

  /// No description provided for @orderConfirmMessage.
  ///
  /// In bs, this message translates to:
  /// **'Naruciti {tickets} u ukupnom iznosu od {total}?'**
  String orderConfirmMessage(String tickets, String total);

  /// No description provided for @orderPlaceButton.
  ///
  /// In bs, this message translates to:
  /// **'Naruci'**
  String get orderPlaceButton;

  /// No description provided for @paymentCancelledMessage.
  ///
  /// In bs, this message translates to:
  /// **'Placanje je otkazano. Narudzba je sacuvana i ceka uplatu.'**
  String get paymentCancelledMessage;

  /// No description provided for @paymentFailedRetryFromOrdersMessage.
  ///
  /// In bs, this message translates to:
  /// **'Placanje nije uspjelo. Pokusajte ponovo iz Narudzbi.'**
  String get paymentFailedRetryFromOrdersMessage;

  /// No description provided for @purchaseUnavailableTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupovina trenutno nije moguca'**
  String get purchaseUnavailableTitle;

  /// No description provided for @purchaseUnavailableMessage.
  ///
  /// In bs, this message translates to:
  /// **'Skijaliste jos nije objavilo cjenovnik ski pass karata. Pokusajte ponovo kasnije.'**
  String get purchaseUnavailableMessage;

  /// No description provided for @newTicketSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nova karta'**
  String get newTicketSectionTitle;

  /// No description provided for @ticketTypeLabel.
  ///
  /// In bs, this message translates to:
  /// **'Tip karte'**
  String get ticketTypeLabel;

  /// No description provided for @ticketTypePriceOption.
  ///
  /// In bs, this message translates to:
  /// **'{name} · {price}/dan'**
  String ticketTypePriceOption(String name, String price);

  /// No description provided for @startDateLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum pocetka vazenja'**
  String get startDateLabel;

  /// No description provided for @daysCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj dana'**
  String get daysCountLabel;

  /// No description provided for @maxDaysAllowedHelper.
  ///
  /// In bs, this message translates to:
  /// **'Odabrani tip karte dozvoljava najvise {days}.'**
  String maxDaysAllowedHelper(String days);

  /// No description provided for @ticketsCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj karata'**
  String get ticketsCountLabel;

  /// No description provided for @multipleTicketsHelper.
  ///
  /// In bs, this message translates to:
  /// **'Kupite vise karata odjednom za porodicu ili grupu.'**
  String get multipleTicketsHelper;

  /// No description provided for @addToCartButton.
  ///
  /// In bs, this message translates to:
  /// **'Dodaj u korpu'**
  String get addToCartButton;

  /// No description provided for @cartSectionTitle.
  ///
  /// In bs, this message translates to:
  /// **'Korpa ({count})'**
  String cartSectionTitle(String count);

  /// No description provided for @paymentMethodLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nacin placanja'**
  String get paymentMethodLabel;

  /// No description provided for @paymentMethodsUnavailableHint.
  ///
  /// In bs, this message translates to:
  /// **'Nacini placanja nisu dostupni'**
  String get paymentMethodsUnavailableHint;

  /// No description provided for @submitOrderButton.
  ///
  /// In bs, this message translates to:
  /// **'Posalji narudzbu'**
  String get submitOrderButton;

  /// No description provided for @pricePerTicketLabel.
  ///
  /// In bs, this message translates to:
  /// **'Cijena po karti'**
  String get pricePerTicketLabel;

  /// No description provided for @totalForTicketsLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ukupno za {tickets}'**
  String totalForTicketsLabel(String tickets);

  /// No description provided for @removeTicketTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Ukloni kartu'**
  String get removeTicketTooltip;

  /// No description provided for @ticketHolderFirstNameLabel.
  ///
  /// In bs, this message translates to:
  /// **'Ime nosioca'**
  String get ticketHolderFirstNameLabel;

  /// No description provided for @orderConfirmationAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba poslana'**
  String get orderConfirmationAppBarTitle;

  /// No description provided for @orderReceivedTitle.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba je zaprimljena'**
  String get orderReceivedTitle;

  /// No description provided for @orderNumberLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj narudzbe: {number}'**
  String orderNumberLabel(String number);

  /// No description provided for @orderStatusLabel.
  ///
  /// In bs, this message translates to:
  /// **'Status narudzbe'**
  String get orderStatusLabel;

  /// No description provided for @orderDateLabel.
  ///
  /// In bs, this message translates to:
  /// **'Datum narudzbe'**
  String get orderDateLabel;

  /// No description provided for @purchasedTicketsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Kupljene karte'**
  String get purchasedTicketsTitle;

  /// No description provided for @ticketsAwaitingPaymentTitle.
  ///
  /// In bs, this message translates to:
  /// **'Karte cekaju potvrdu placanja'**
  String get ticketsAwaitingPaymentTitle;

  /// No description provided for @ticketsAwaitingPaymentBody.
  ///
  /// In bs, this message translates to:
  /// **'Nakon evidentiranog placanja karte postaju aktivne i QR kod se moze koristiti na ulazu na ski lift.'**
  String get ticketsAwaitingPaymentBody;

  /// No description provided for @backToPurchaseButton.
  ///
  /// In bs, this message translates to:
  /// **'Nazad na kupovinu'**
  String get backToPurchaseButton;

  /// No description provided for @reviewThanksMessage.
  ///
  /// In bs, this message translates to:
  /// **'Hvala na ocjeni!'**
  String get reviewThanksMessage;

  /// No description provided for @reviewUpdatedMessage.
  ///
  /// In bs, this message translates to:
  /// **'Vasa ocjena je azurirana.'**
  String get reviewUpdatedMessage;

  /// No description provided for @reviewDeleteTitle.
  ///
  /// In bs, this message translates to:
  /// **'Brisanje ocjene'**
  String get reviewDeleteTitle;

  /// No description provided for @reviewDeleteMessage.
  ///
  /// In bs, this message translates to:
  /// **'Da li ste sigurni da zelite obrisati svoju ocjenu?'**
  String get reviewDeleteMessage;

  /// No description provided for @reviewDeleteSuccessMessage.
  ///
  /// In bs, this message translates to:
  /// **'Ocjena je obrisana.'**
  String get reviewDeleteSuccessMessage;

  /// No description provided for @reviewNoRatingsYet.
  ///
  /// In bs, this message translates to:
  /// **'Jos nema ocjena. Budite prvi koji ce ocijeniti.'**
  String get reviewNoRatingsYet;

  /// No description provided for @reviewsCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'{count} ocjena korisnika'**
  String reviewsCountLabel(int count);

  /// No description provided for @leaveReviewButton.
  ///
  /// In bs, this message translates to:
  /// **'Ostavi ocjenu'**
  String get leaveReviewButton;

  /// No description provided for @editReviewButton.
  ///
  /// In bs, this message translates to:
  /// **'Uredi ocjenu'**
  String get editReviewButton;

  /// No description provided for @deleteReviewTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Obrisi ocjenu'**
  String get deleteReviewTooltip;

  /// No description provided for @yourReviewTitle.
  ///
  /// In bs, this message translates to:
  /// **'Vasa ocjena'**
  String get yourReviewTitle;

  /// No description provided for @closeTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Zatvori'**
  String get closeTooltip;

  /// No description provided for @reviewCommentHint.
  ///
  /// In bs, this message translates to:
  /// **'Podijelite svoje iskustvo (opciono)'**
  String get reviewCommentHint;

  /// No description provided for @saveReviewButton.
  ///
  /// In bs, this message translates to:
  /// **'Sacuvaj ocjenu'**
  String get saveReviewButton;

  /// No description provided for @myTicketsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Moje karte'**
  String get myTicketsAppBarTitle;

  /// No description provided for @orderHistoryTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Historija narudzbi'**
  String get orderHistoryTooltip;

  /// No description provided for @activeTicketsTab.
  ///
  /// In bs, this message translates to:
  /// **'Aktivne'**
  String get activeTicketsTab;

  /// No description provided for @allTicketsTab.
  ///
  /// In bs, this message translates to:
  /// **'Sve karte'**
  String get allTicketsTab;

  /// No description provided for @noActiveTicketsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nemate aktivnih karata'**
  String get noActiveTicketsTitle;

  /// No description provided for @noActiveTicketsMessage.
  ///
  /// In bs, this message translates to:
  /// **'Kupite ski pass kartu i ovdje ce se pojaviti sa QR kodom.'**
  String get noActiveTicketsMessage;

  /// No description provided for @noPurchasedTicketsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Jos nemate kupljenih karata'**
  String get noPurchasedTicketsTitle;

  /// No description provided for @noPurchasedTicketsMessage.
  ///
  /// In bs, this message translates to:
  /// **'Sve kupljene karte, ukljucujuci istekle, bit ce prikazane ovdje.'**
  String get noPurchasedTicketsMessage;

  /// No description provided for @loadMoreButton.
  ///
  /// In bs, this message translates to:
  /// **'Ucitaj jos'**
  String get loadMoreButton;

  /// No description provided for @ticketHolderLabel.
  ///
  /// In bs, this message translates to:
  /// **'Nosilac'**
  String get ticketHolderLabel;

  /// No description provided for @ticketValidLabel.
  ///
  /// In bs, this message translates to:
  /// **'Vazi'**
  String get ticketValidLabel;

  /// No description provided for @ticketDurationLabel.
  ///
  /// In bs, this message translates to:
  /// **'Trajanje'**
  String get ticketDurationLabel;

  /// No description provided for @ticketScansLabel.
  ///
  /// In bs, this message translates to:
  /// **'Skeniranja'**
  String get ticketScansLabel;

  /// No description provided for @showQrButton.
  ///
  /// In bs, this message translates to:
  /// **'Prikazi QR kod'**
  String get showQrButton;

  /// No description provided for @ticketUnavailablePending.
  ///
  /// In bs, this message translates to:
  /// **'QR kod postaje dostupan nakon evidentiranog placanja.'**
  String get ticketUnavailablePending;

  /// No description provided for @ticketUnavailableCancelled.
  ///
  /// In bs, this message translates to:
  /// **'Karta je otkazana i ne moze se koristiti.'**
  String get ticketUnavailableCancelled;

  /// No description provided for @ticketUnavailableExpired.
  ///
  /// In bs, this message translates to:
  /// **'Karta je istekla {date}.'**
  String ticketUnavailableExpired(String date);

  /// No description provided for @ticketNotYetValid.
  ///
  /// In bs, this message translates to:
  /// **'Karta pocinje vaziti {date}.'**
  String ticketNotYetValid(String date);

  /// No description provided for @ticketNoLongerValid.
  ///
  /// In bs, this message translates to:
  /// **'Karta je vazila do {date}.'**
  String ticketNoLongerValid(String date);

  /// No description provided for @ticketUnavailableGeneric.
  ///
  /// In bs, this message translates to:
  /// **'Karta trenutno nije upotrebljiva.'**
  String get ticketUnavailableGeneric;

  /// No description provided for @orderLinkLabel.
  ///
  /// In bs, this message translates to:
  /// **'Narudzba {number}'**
  String orderLinkLabel(String number);

  /// No description provided for @orderAwaitingPaymentBadge.
  ///
  /// In bs, this message translates to:
  /// **'Ceka evidentirano placanje'**
  String get orderAwaitingPaymentBadge;

  /// No description provided for @ticketQrAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'QR kod karte'**
  String get ticketQrAppBarTitle;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Kopiraj kod karte'**
  String get copyCodeTooltip;

  /// No description provided for @codeCopiedMessage.
  ///
  /// In bs, this message translates to:
  /// **'Kod karte je kopiran.'**
  String get codeCopiedMessage;

  /// No description provided for @showCodeInstruction.
  ///
  /// In bs, this message translates to:
  /// **'Pokazite ovaj kod zaposleniku na ulazu na ski lift.'**
  String get showCodeInstruction;

  /// No description provided for @ticketHolderLabelFull.
  ///
  /// In bs, this message translates to:
  /// **'Nosilac karte'**
  String get ticketHolderLabelFull;

  /// No description provided for @skiResortLabel.
  ///
  /// In bs, this message translates to:
  /// **'Skijaliste'**
  String get skiResortLabel;

  /// No description provided for @scanCountLabel.
  ///
  /// In bs, this message translates to:
  /// **'Broj skeniranja'**
  String get scanCountLabel;

  /// No description provided for @lastScanLabel.
  ///
  /// In bs, this message translates to:
  /// **'Posljednje skeniranje'**
  String get lastScanLabel;

  /// No description provided for @announcementsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Obavijesti'**
  String get announcementsAppBarTitle;

  /// No description provided for @showAllAnnouncementsTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Prikazi sve obavijesti'**
  String get showAllAnnouncementsTooltip;

  /// No description provided for @showUrgentOnlyTooltip.
  ///
  /// In bs, this message translates to:
  /// **'Prikazi samo hitne'**
  String get showUrgentOnlyTooltip;

  /// No description provided for @noUrgentAnnouncementsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema hitnih obavijesti'**
  String get noUrgentAnnouncementsTitle;

  /// No description provided for @noActiveAnnouncementsTitle.
  ///
  /// In bs, this message translates to:
  /// **'Nema aktivnih obavijesti'**
  String get noActiveAnnouncementsTitle;

  /// No description provided for @announcementsEmptyMessage.
  ///
  /// In bs, this message translates to:
  /// **'Ovdje ce se pojaviti obavijesti o vremenu, zatvaranju staza i akcijskim ponudama.'**
  String get announcementsEmptyMessage;

  /// No description provided for @readMoreLabel.
  ///
  /// In bs, this message translates to:
  /// **'Detaljnije'**
  String get readMoreLabel;

  /// No description provided for @announcementDetailsAppBarTitle.
  ///
  /// In bs, this message translates to:
  /// **'Obavijest'**
  String get announcementDetailsAppBarTitle;

  /// No description provided for @announcementUrgentBadge.
  ///
  /// In bs, this message translates to:
  /// **'Hitna obavijest'**
  String get announcementUrgentBadge;

  /// No description provided for @announcementPublishedByLabel.
  ///
  /// In bs, this message translates to:
  /// **'Objavio'**
  String get announcementPublishedByLabel;

  /// No description provided for @announcementValidUntilLabel.
  ///
  /// In bs, this message translates to:
  /// **'Vazi do'**
  String get announcementValidUntilLabel;
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
