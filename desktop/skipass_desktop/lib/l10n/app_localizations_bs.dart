// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get appTitle => 'SkiPass Administracija';

  @override
  String get languageLabel => 'Jezik';

  @override
  String get languageBosnian => 'Bosanski';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get commonSave => 'Sacuvaj';

  @override
  String get commonCancel => 'Otkazi';

  @override
  String get commonDelete => 'Obrisi';

  @override
  String get commonEdit => 'Izmijeni';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonRefresh => 'Osvjezi';

  @override
  String get commonSearchHint => 'Pretrazi...';

  @override
  String get commonNoData => 'Nema podataka';

  @override
  String get commonClose => 'Zatvori';

  @override
  String get commonConfirm => 'Potvrdi';

  @override
  String get commonDismiss => 'Odustani';

  @override
  String get commonRetry => 'Pokusaj ponovo';

  @override
  String get commonUnableToLoad => 'Podatke nije moguce ucitati';

  @override
  String get commonSelect => 'Odaberi';

  @override
  String get commonNoItemsAvailable => 'Nema dostupnih stavki';

  @override
  String get commonUnknown => 'Nepoznato';

  @override
  String get commonEditShort => 'Uredi';

  @override
  String get commonImageTypeLabel => 'slike';

  @override
  String get commonCodeLabel => 'Oznaka';

  @override
  String get commonDescriptionLabel => 'Opis';

  @override
  String get commonResortLabel => 'Skijaliste';

  @override
  String get commonNameLabel => 'Naziv';

  @override
  String commonNumberRequiredMessage(String label) {
    return '$label mora biti broj.';
  }

  @override
  String commonPositiveRangeMessage(String label, double max) {
    return '$label mora biti izmedju 0.01 i $max.';
  }

  @override
  String get commonLengthLabel => 'Duzina (m)';

  @override
  String get commonLengthShort => 'Duzina';

  @override
  String get commonRemove => 'Ukloni';

  @override
  String get commonComplete => 'Zavrsi';

  @override
  String commonIntRequiredMessage(String label) {
    return '$label mora biti cijeli broj.';
  }

  @override
  String commonIntRangeMessage(String label, int min, int max) {
    return '$label mora biti izmedju $min i $max.';
  }

  @override
  String get sideNavAppName => 'SkiPass';

  @override
  String get sideNavReportIncident => 'Prijavi problem';

  @override
  String get appFeedbackReasonMinLength =>
      'Obrazlozenje mora imati najmanje 3 znaka.';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleStaff => 'Osoblje';

  @override
  String get loginScreenTagline => 'Administracija skijalista';

  @override
  String get loginScreenDescription =>
      'Upravljajte kartama, stazama, liftovima, incidentima i obavijestima na jednom mjestu.';

  @override
  String get loginScreenTitle => 'Prijava';

  @override
  String get loginScreenSubtitle =>
      'Unesite kredencijale osoblja ili administratora.';

  @override
  String get loginScreenUsernameLabel => 'Korisnicko ime';

  @override
  String get loginScreenUsernameHint => 'npr. desktop';

  @override
  String get loginScreenPasswordLabel => 'Lozinka';

  @override
  String get loginScreenPasswordHint => 'Unesite lozinku';

  @override
  String get loginScreenSubmit => 'Prijavi se';

  @override
  String get changePasswordDialogSuccess => 'Lozinka je uspjesno promijenjena.';

  @override
  String get changePasswordDialogTitle => 'Promjena lozinke';

  @override
  String get changePasswordDialogCurrentLabel => 'Trenutna lozinka';

  @override
  String get changePasswordDialogNewLabel => 'Nova lozinka';

  @override
  String get changePasswordDialogConfirmLabel => 'Potvrda nove lozinke';

  @override
  String get navTickets => 'Karte';

  @override
  String get navResorts => 'Staze i ski liftovi';

  @override
  String get navBenefits => 'Usluge';

  @override
  String get navIncidents => 'Incidenti';

  @override
  String get navAnnouncements => 'Obavijesti';

  @override
  String get navNotifications => 'Notifikacije';

  @override
  String get navReports => 'Izvjestaji';

  @override
  String get navUsers => 'Korisnici';

  @override
  String get navReferenceData => 'Referentni podaci';

  @override
  String get profileDialogUpdateSuccess => 'Profil je azuriran.';

  @override
  String get profileDialogTitle => 'Moj profil';

  @override
  String get profileDialogLogout => 'Odjava';

  @override
  String get profileDialogLogoutConfirmMessage =>
      'Da li se zelite odjaviti sa naloga?';

  @override
  String get profileDialogChangePhoto => 'Promijeni sliku';

  @override
  String get profileDialogFirstNameLabel => 'Ime';

  @override
  String get profileDialogLastNameLabel => 'Prezime';

  @override
  String get profileDialogEmailLabel => 'E-mail';

  @override
  String get profileDialogPhoneLabel => 'Telefon (opciono)';

  @override
  String get profileDialogBirthDateLabel => 'Datum rodjenja (opciono)';

  @override
  String get profileDialogCityLabel => 'Grad (opciono)';

  @override
  String get profileDialogChangePassword => 'Promijeni lozinku';

  @override
  String get resortsTabTrails => 'Staze';

  @override
  String get resortsTabLifts => 'Ski liftovi';

  @override
  String get trailDeleteConfirmTitle => 'Brisanje staze';

  @override
  String trailDeleteConfirmMessage(String trailName) {
    return 'Obrisati stazu \"$trailName\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get trailDeleteSuccess => 'Staza je obrisana.';

  @override
  String get trailsSearchHint => 'Pretrazi stazu po nazivu ili oznaci';

  @override
  String get trailsAllDifficulties => 'Sve tezine';

  @override
  String get trailsAddButton => 'Dodaj stazu';

  @override
  String get trailsEmptyTitle => 'Nema unesenih staza';

  @override
  String get trailsEmptyMessage => 'Dodajte prvu stazu skijalista.';

  @override
  String get trailConditionButton => 'Stanje staze';

  @override
  String liftOpenMaintenanceCount(int count) {
    return '$count kvar(ova)';
  }

  @override
  String get liftDeleteConfirmTitle => 'Brisanje lifta';

  @override
  String liftDeleteConfirmMessage(String liftName) {
    return 'Obrisati lift \"$liftName\"?';
  }

  @override
  String get liftDeleteSuccess => 'Lift je obrisan.';

  @override
  String get liftsSearchHint => 'Pretrazi lift po nazivu ili oznaci';

  @override
  String get commonAllStatuses => 'Svi statusi';

  @override
  String get liftStatusOperational => 'U pogonu';

  @override
  String get liftStatusNotOperational => 'Van pogona';

  @override
  String get liftsAddButton => 'Dodaj lift';

  @override
  String get liftsEmptyTitle => 'Nema unesenih liftova';

  @override
  String liftRidersLabel(int current, int capacity) {
    return '$current/$capacity korisnika';
  }

  @override
  String get liftMaintenanceButton => 'Odrzavanje';

  @override
  String get skiLiftFormDialogEditTitle => 'Uredi ski lift';

  @override
  String get skiLiftFormDialogNewTitle => 'Novi ski lift';

  @override
  String get skiLiftFormDialogNameLabel => 'Naziv lifta';

  @override
  String get skiLiftFormDialogCodeHint => 'LIFT-01';

  @override
  String get skiLiftFormDialogLiftTypeLabel => 'Tip lifta';

  @override
  String get skiLiftFormDialogCapacityLabel => 'Kapacitet (osoba/h)';

  @override
  String get skiLiftFormDialogCapacityShort => 'Kapacitet';

  @override
  String get skiLiftFormDialogDurationLabel => 'Trajanje voznje (min)';

  @override
  String get skiLiftFormDialogDurationShort => 'Trajanje voznje';

  @override
  String get skiLiftFormDialogOperationalSwitch => 'Lift je u pogonu';

  @override
  String get trailFormDialogEditTitle => 'Uredi stazu';

  @override
  String get trailFormDialogNewTitle => 'Nova staza';

  @override
  String get trailFormDialogNameLabel => 'Naziv staze';

  @override
  String get trailFormDialogCodeHint => 'STAZA-01';

  @override
  String get trailFormDialogDifficultyLabel => 'Tezina staze';

  @override
  String get trailFormDialogVerticalDropLabel => 'Visinska razlika (m)';

  @override
  String get trailFormDialogVerticalDropShort => 'Visinska razlika';

  @override
  String get trailFormDialogOpenSwitch => 'Staza je otvorena';

  @override
  String get trailFormDialogNightSkiingSwitch => 'Nocno skijanje';

  @override
  String get trailFormDialogSnowmakingSwitch => 'Vjestacki snijeg';

  @override
  String get trailFormDialogPhotoLabel => 'Fotografija';

  @override
  String get trailFormDialogAddPhoto => 'Dodaj sliku';

  @override
  String trailConditionDialogTitle(String trailName) {
    return 'Evidencija stanja - $trailName';
  }

  @override
  String get trailConditionDialogSaveButton => 'Sacuvaj evidenciju';

  @override
  String get trailConditionDialogSnowDepthLabel => 'Snjezni pokrivac (cm)';

  @override
  String get trailConditionDialogSnowDepthError =>
      'Snjezni pokrivac mora biti izmedju 0 i 800 cm.';

  @override
  String get trailConditionDialogOpenSwitch => 'Staza otvorena';

  @override
  String get trailConditionDialogNoteLabel => 'Opis uslova';

  @override
  String get trailConditionDialogNoteHint =>
      'npr. poledica na donjem dijelu staze';

  @override
  String get trailConditionDialogHistoryTitle => 'Historija evidencije';

  @override
  String get trailConditionDialogHistoryEmpty =>
      'Jos nema evidentiranih zapisa.';

  @override
  String trailConditionDialogSnowDepthValue(int depth) {
    return '$depth cm';
  }

  @override
  String get liftMaintenanceDialogReportSuccess => 'Kvar je evidentiran.';

  @override
  String get liftMaintenanceDialogCompleteTitle => 'Zavrsetak servisa';

  @override
  String get liftMaintenanceDialogCancelTitle => 'Otkazivanje prijave';

  @override
  String get liftMaintenanceDialogReasonLabel => 'Obrazlozenje';

  @override
  String get liftMaintenanceDialogStatusUpdateSuccess =>
      'Status kvara je azuriran.';

  @override
  String liftMaintenanceDialogTitle(String liftName) {
    return 'Odrzavanje - $liftName';
  }

  @override
  String get liftMaintenanceDialogDescriptionLabel => 'Opis kvara';

  @override
  String get liftMaintenanceDialogShutdownSwitch =>
      'Zahtijeva obustavu rada lifta';

  @override
  String get liftMaintenanceDialogReportButton => 'Prijavi kvar';

  @override
  String get liftMaintenanceDialogHistoryTitle => 'Evidencija odrzavanja';

  @override
  String get liftMaintenanceDialogHistoryEmpty => 'Nema evidentiranih kvarova.';

  @override
  String get liftMaintenanceDialogShutdownSuffix => 'zahtijeva obustavu';

  @override
  String get liftMaintenanceStatusReported => 'Prijavljen';

  @override
  String get liftMaintenanceStatusInProgress => 'U toku';

  @override
  String get liftMaintenanceStatusCompleted => 'Zavrseno';

  @override
  String get liftMaintenanceStatusCancelled => 'Otkazano';

  @override
  String get liftMaintenanceActionStart => 'Zapocni servis';

  @override
  String get ticketsTabTypes => 'Tipovi karata';

  @override
  String get ticketFilterStatusPending => 'Neaktivna';

  @override
  String get ticketFilterStatusActive => 'Aktivna';

  @override
  String get ticketFilterStatusUsed => 'U upotrebi';

  @override
  String get ticketFilterStatusExpired => 'Istekla';

  @override
  String get ticketFilterStatusCancelled => 'Otkazana';

  @override
  String get ticketsSearchHint =>
      'Pretrazi po nosiocu, QR kodu ili broju narudzbe';

  @override
  String get ticketsValidateButton => 'Validiraj kartu';

  @override
  String get ticketsEmptyTitle => 'Nema karata za zadate uslove';

  @override
  String get ticketTypeDeleteConfirmTitle => 'Brisanje tipa karte';

  @override
  String ticketTypeDeleteConfirmMessage(String typeName) {
    return 'Obrisati tip karte \"$typeName\"?';
  }

  @override
  String get ticketTypeDeleteSuccess => 'Tip karte je obrisan.';

  @override
  String get ticketTypeAddButton => 'Novi tip karte';

  @override
  String get ticketTypesEmptyTitle => 'Nema definisanih tipova karata';

  @override
  String get ticketTypesEmptyMessage =>
      'Dodajte prvi tip ski pass karte i odredite cijenu.';

  @override
  String get ticketTypeInactiveLabel => 'Neaktivan';

  @override
  String ticketTypePriceLabel(String price, int maxDays) {
    return '$price/dan · do $maxDays dana';
  }

  @override
  String ticketTypeDiscountSuffix(String percent) {
    return ' · popust $percent%';
  }

  @override
  String get orderDetailCancelTitle => 'Otkazivanje narudzbe';

  @override
  String get orderDetailCancelReasonLabel => 'Razlog otkazivanja';

  @override
  String get orderDetailCancelConfirmButton => 'Otkazi narudzbu';

  @override
  String get orderDetailStatusChangeTitle => 'Promjena statusa';

  @override
  String orderDetailStatusChangeMessage(String status) {
    return 'Prebaciti narudzbu u status \"$status\"?';
  }

  @override
  String get orderDetailStatusUpdateSuccess => 'Status narudzbe je azuriran.';

  @override
  String get orderDetailRefundTitle => 'Povrat sredstava';

  @override
  String get orderDetailRefundReasonLabel => 'Razlog povrata';

  @override
  String get orderDetailRefundConfirmButton => 'Izvrsi povrat';

  @override
  String get orderDetailRefundSuccess => 'Povrat sredstava je evidentiran.';

  @override
  String get orderDetailDefaultTitle => 'Narudzba';

  @override
  String get orderDetailDateLabel => 'Datum narudzbe';

  @override
  String get orderDetailPaymentMethodLabel => 'Nacin placanja';

  @override
  String get orderDetailTicketCountLabel => 'Broj karata';

  @override
  String get orderDetailTotalLabel => 'Ukupan iznos';

  @override
  String get orderDetailPaidLabel => 'Placeno';

  @override
  String get orderDetailRefundedLabel => 'Vraceno';

  @override
  String get orderDetailPaymentsTitle => 'Placanja';

  @override
  String get orderDetailPaymentNotCompleted => 'Nije zavrseno';

  @override
  String get orderDetailRefundButton => 'Povrat';

  @override
  String get ticketTypeDialogEditTitle => 'Uredi tip karte';

  @override
  String get ticketTypeDialogPricePerDayLabel => 'Cijena po danu (KM)';

  @override
  String get ticketTypeDialogPriceShort => 'Cijena';

  @override
  String get ticketTypeDialogMaxDaysLabel => 'Maksimalan broj dana';

  @override
  String get ticketTypeDialogDiscountLabel => 'Popust (%)';

  @override
  String get ticketTypeDialogMinAgeLabel => 'Minimalna dob';

  @override
  String get ticketTypeDialogMaxAgeLabel => 'Maksimalna dob';

  @override
  String get ticketTypeDialogActiveSwitch => 'Aktivan (dostupan za kupovinu)';

  @override
  String get validateTicketDialogTitle => 'Validacija karte';

  @override
  String get validateTicketDialogSubtitle =>
      'Unesite ili skenirajte QR kod karte.';

  @override
  String get validateTicketDialogLiftLabel => 'Ski lift';

  @override
  String get validateTicketDialogNoLiftsAvailable => 'Nema liftova u pogonu';

  @override
  String get validateTicketDialogQrLabel => 'QR kod karte';

  @override
  String get validateTicketDialogScanTooltip => 'Skeniraj kamerom';

  @override
  String get validateTicketDialogQrMinLengthError =>
      'QR kod mora imati najmanje 8 znakova.';

  @override
  String get validateTicketDialogSubmitButton => 'Validiraj';

  @override
  String get validateTicketDialogResultValid => 'Karta je vazeca';

  @override
  String get validateTicketDialogResultInvalid => 'Karta nije prihvacena';

  @override
  String validateTicketDialogHolderLabel(String name) {
    return 'Nosilac: $name';
  }

  @override
  String get usersScreenDeleteSelfError =>
      'Ne mozete obrisati vlastiti korisnicki racun.';

  @override
  String get usersScreenDeleteConfirmTitle => 'Brisanje korisnika';

  @override
  String usersScreenDeleteConfirmMessage(String userName) {
    return 'Obrisati korisnika \"$userName\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get usersScreenDeleteSuccess => 'Korisnik je obrisan.';

  @override
  String get usersScreenSearchHint =>
      'Pretrazi po imenu, e-mailu ili korisnickom imenu';

  @override
  String get usersScreenAllRoles => 'Sve role';

  @override
  String get roleSkier => 'Skijas';

  @override
  String get usersScreenAddButton => 'Novi korisnik';

  @override
  String get usersScreenEmptyTitle => 'Nema pronadjenih korisnika';

  @override
  String usersScreenOrderCount(int count) {
    return '$count narudzbi';
  }

  @override
  String get usersScreenNeverLoggedIn => 'Nikad prijavljen';

  @override
  String usersScreenLastLogin(String date) {
    return 'Prijava: $date';
  }

  @override
  String get userFormDialogEditTitle => 'Uredi korisnika';

  @override
  String get userFormDialogRoleLabel => 'Rola';

  @override
  String get userFormDialogNewPasswordLabel => 'Nova lozinka (opciono)';

  @override
  String get userFormDialogConfirmPasswordLabel => 'Potvrda lozinke';

  @override
  String get userFormDialogActiveSwitch => 'Aktivan korisnik';

  @override
  String get incidentsScreenResolveTitle => 'Rjesavanje incidenta';

  @override
  String get incidentsScreenRejectTitle => 'Odbijanje prijave';

  @override
  String get incidentsScreenStatusUpdateSuccess =>
      'Status incidenta je azuriran.';

  @override
  String get incidentsScreenDeleteConfirmTitle => 'Brisanje prijave';

  @override
  String incidentsScreenDeleteConfirmMessage(int incidentId) {
    return 'Obrisati prijavu #$incidentId? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get incidentsScreenDeleteSuccess => 'Prijava je obrisana.';

  @override
  String get incidentsScreenSearchHint => 'Pretrazi po opisu ili prijavitelju';

  @override
  String get incidentsColumnReported => 'Prijavljeno';

  @override
  String get incidentsColumnInProgress => 'U toku';

  @override
  String get incidentsColumnResolved => 'Rijeseno';

  @override
  String get incidentsColumnRejected => 'Odbijeno';

  @override
  String get incidentsColumnEmpty => 'Nema prijava';

  @override
  String get incidentsUrgentLabel => 'Hitno';

  @override
  String get incidentsScreenDeleteTooltip => 'Obrisi prijavu';

  @override
  String get incidentsActionTakeOver => 'Preuzmi';

  @override
  String get incidentsActionResolve => 'Rijesi';

  @override
  String get incidentsActionReject => 'Odbij';

  @override
  String get reportIncidentDialogSuccess => 'Incident je prijavljen.';

  @override
  String get reportIncidentDialogSubtitle =>
      'Prijava kvara ili incidenta na skijalistu';

  @override
  String get reportIncidentDialogSubmitButton => 'Prijavi';

  @override
  String get reportIncidentDialogTypeLabel => 'Tip incidenta';

  @override
  String get reportIncidentDialogTrailSegment => 'Staza';

  @override
  String get reportIncidentDialogLiftSegment => 'Ski lift';

  @override
  String get reportIncidentDialogNoRecords => 'Nema unesenih zapisa';

  @override
  String get reportIncidentDialogDescriptionLabel => 'Opis problema';

  @override
  String get reportIncidentDialogAddPhoto => 'Dodaj sliku (opciono)';

  @override
  String get reportIncidentDialogPhotoSelected => 'Slika odabrana';

  @override
  String get announcementsScreenDeleteConfirmTitle => 'Brisanje obavijesti';

  @override
  String announcementsScreenDeleteConfirmMessage(String title) {
    return 'Obrisati obavijest \"$title\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get announcementsScreenDeleteSuccess => 'Obavijest je obrisana.';

  @override
  String get announcementsScreenAddButton => 'Dodaj novu obavijest';

  @override
  String get announcementsScreenSearchHint => 'Pretrazi po naslovu ili tekstu';

  @override
  String get announcementsScreenAllCategories => 'Sve kategorije';

  @override
  String get announcementsScreenEmptyTitle => 'Nema unesenih obavijesti';

  @override
  String get announcementsScreenUrgentSectionTitle => 'Hitne obavijesti';

  @override
  String get announcementsScreenActiveSectionTitle => 'Aktivne obavijesti';

  @override
  String get announcementsScreenOthersEmpty => 'Nema ostalih obavijesti.';

  @override
  String get announcementsScreenInactiveLabel => 'Neaktivna';

  @override
  String announcementsScreenPublishedLabel(String date) {
    return 'objavljeno $date';
  }

  @override
  String announcementsScreenExpiresLabel(String date) {
    return 'istice $date';
  }

  @override
  String get announcementFormDialogExpiryError =>
      'Datum isteka mora biti nakon datuma objave.';

  @override
  String get announcementFormDialogPublishedLabel => 'Datum objave';

  @override
  String get announcementFormDialogExpiryHelpText => 'Datum isteka';

  @override
  String get announcementFormDialogEditTitle => 'Uredi obavijest';

  @override
  String get announcementFormDialogNewTitle => 'Nova obavijest';

  @override
  String get announcementFormDialogTitleLabel => 'Naslov';

  @override
  String get announcementFormDialogContentLabel => 'Tekst obavijesti';

  @override
  String get announcementFormDialogContentShort => 'Tekst';

  @override
  String get announcementFormDialogCategoryLabel => 'Kategorija';

  @override
  String get announcementFormDialogExpiryLabel => 'Datum isteka (opciono)';

  @override
  String get announcementFormDialogUrgentSwitch => 'Hitna obavijest';

  @override
  String get announcementFormDialogActiveSwitch =>
      'Aktivna (vidljiva korisnicima)';

  @override
  String get benefitsTabPartners => 'Partneri';

  @override
  String get benefitDeleteConfirmTitle => 'Brisanje usluge';

  @override
  String benefitDeleteConfirmMessage(String benefitName) {
    return 'Obrisati uslugu \"$benefitName\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get benefitDeleteSuccess => 'Usluga je obrisana.';

  @override
  String get benefitsSearchHint => 'Pretrazi uslugu po nazivu';

  @override
  String get benefitsAddButton => 'Dodaj novu uslugu';

  @override
  String get benefitsEmptyTitle => 'Nema unesenih usluga';

  @override
  String get benefitsEmptyMessage => 'Dodajte prvu uslugu ili pogodnost.';

  @override
  String get partnerDeleteConfirmTitle => 'Brisanje partnera';

  @override
  String partnerDeleteConfirmMessage(String partnerName) {
    return 'Obrisati partnera \"$partnerName\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get partnerDeleteSuccess => 'Partner je obrisan.';

  @override
  String get partnersSearchHint => 'Pretrazi partnera po nazivu';

  @override
  String get partnersAddButton => 'Dodaj partnera';

  @override
  String get partnersEmptyTitle => 'Nema unesenih partnera';

  @override
  String partnerBenefitCountLabel(int count) {
    return '$count usluga';
  }

  @override
  String get benefitFormDialogEditTitle => 'Uredi uslugu';

  @override
  String get benefitFormDialogNewTitle => 'Nova usluga';

  @override
  String get benefitFormDialogNameLabel => 'Naziv usluge';

  @override
  String get benefitFormDialogPartnerLabel => 'Partner (opciono)';

  @override
  String get benefitFormDialogPriceLabel => 'Cijena (KM)';

  @override
  String get benefitFormDialogPriceError => 'Cijena mora biti pozitivan broj.';

  @override
  String get benefitFormDialogDiscountError =>
      'Popust mora biti izmedju 0 i 100.';

  @override
  String get benefitFormDialogBrandLabel => 'Brend (opciono)';

  @override
  String get benefitFormDialogActiveSwitch => 'Aktivna (dostupna za kupovinu)';

  @override
  String get benefitFormDialogAddPhoto => 'Dodaj sliku';

  @override
  String get partnerFormDialogEditTitle => 'Uredi partnera';

  @override
  String get partnerFormDialogNewTitle => 'Novi partner';

  @override
  String get partnerFormDialogNameLabel => 'Naziv partnera';

  @override
  String get partnerFormDialogContactEmailLabel => 'Kontakt e-mail';

  @override
  String get partnerFormDialogContactPhoneLabel => 'Kontakt telefon';

  @override
  String get partnerFormDialogWebsiteLabel => 'Web stranica';

  @override
  String get partnerFormDialogAddressLabel => 'Adresa';

  @override
  String get partnerFormDialogActiveSwitch => 'Aktivan partner';

  @override
  String get notificationsScreenMarkAllSuccess =>
      'Sve notifikacije su oznacene kao procitane.';

  @override
  String get notificationsScreenMarkAllButton => 'Oznaci sve kao procitano';

  @override
  String get notificationsScreenEmptyTitle => 'Nema notifikacija';

  @override
  String referenceDataScreenDeleteBlockedError(int count) {
    return 'Nije moguce obrisati - postoje povezani zapisi ($count).';
  }

  @override
  String get referenceDataScreenDeleteConfirmTitle => 'Brisanje zapisa';

  @override
  String referenceDataScreenDeleteConfirmMessage(String name) {
    return 'Obrisati \"$name\"? Ova akcija se ne moze ponistiti.';
  }

  @override
  String get referenceDataScreenDeleteSuccess => 'Zapis je obrisan.';

  @override
  String get referenceDataScreenSearchHint => 'Pretrazi po nazivu';

  @override
  String get referenceDataScreenAllCountries => 'Sve drzave';

  @override
  String referenceDataScreenAddButton(String label) {
    return 'Dodaj: $label';
  }

  @override
  String referenceDataScreenSortOrderLabel(int order) {
    return 'Redoslijed: $order';
  }

  @override
  String referenceDataScreenRelatedCountLabel(int count) {
    return '$count povezano';
  }

  @override
  String referenceItemFormDialogEditTitle(String label) {
    return 'Uredi: $label';
  }

  @override
  String referenceItemFormDialogNewTitle(String label) {
    return 'Novo: $label';
  }

  @override
  String get referenceItemFormDialogIsoCodeLabel => 'ISO oznaka';

  @override
  String get referenceItemFormDialogIsoCodeError =>
      'ISO oznaka mora imati 2 ili 3 slova, npr. BA ili BIH.';

  @override
  String get referenceItemFormDialogCountryLabel => 'Drzava';

  @override
  String get referenceItemFormDialogNoCountriesHint => 'Prvo unesite drzavu';

  @override
  String get referenceItemFormDialogPostalCodeLabel =>
      'Postanski broj (opciono)';

  @override
  String get referenceItemFormDialogPostalCodeError =>
      'Postanski broj mora imati tacno 5 cifara.';

  @override
  String get referenceItemFormDialogDescriptionLabel => 'Opis (opciono)';

  @override
  String get referenceItemFormDialogColorLabel => 'Boja (HEX)';

  @override
  String get referenceItemFormDialogColorError =>
      'Boja mora biti u HEX formatu, npr. #1E88E5.';

  @override
  String get referenceItemFormDialogSortOrderLabel =>
      'Redoslijed prikaza (0-100)';

  @override
  String get referenceItemFormDialogSortOrderError =>
      'Redoslijed mora biti izmedju 0 i 100.';

  @override
  String get referenceItemFormDialogIconLabel => 'Naziv ikone (opciono)';

  @override
  String get referenceItemFormDialogCodeError =>
      'Oznaka moze sadrzavati velika slova, cifre i podvlaku, npr. PAYPAL.';

  @override
  String get referenceItemFormDialogUrgentSwitch =>
      'Hitno po podrazumijevanoj vrijednosti';

  @override
  String get referenceItemFormDialogOnlineSwitch => 'Placanje putem interneta';

  @override
  String get referenceItemFormDialogActiveSwitch => 'Aktivan nacin placanja';

  @override
  String get reportsScreenDateFromHelp => 'Datum od';

  @override
  String get reportsScreenDateToHelp => 'Datum do';

  @override
  String reportsScreenSaveSuccess(String path) {
    return 'Izvjestaj je sacuvan: $path';
  }

  @override
  String reportsScreenSaveError(String error) {
    return 'Neuspjelo cuvanje izvjestaja: $error';
  }

  @override
  String get reportsScreenSalesTitle => 'Prodaja karata po danima';

  @override
  String get reportsScreenFromLabel => 'Od';

  @override
  String get reportsScreenToLabel => 'Do';

  @override
  String get reportsScreenAllResorts => 'Sva skijalista';

  @override
  String reportsScreenTopUsersTitle(int count) {
    return 'Top $count korisnika';
  }

  @override
  String get reportsScreenDownloadPdf => 'Preuzmi PDF';

  @override
  String get reportsScreenPrint => 'Ispis';

  @override
  String get reportsScreenTotalTickets => 'Ukupno karata';

  @override
  String get reportsScreenTotalRevenue => 'Ukupan prihod';

  @override
  String get reportsScreenNoDataForPeriod =>
      'Nema podataka za odabrani period.';

  @override
  String get reportsScreenTicketCountLegend => 'Broj karata';

  @override
  String get reportsScreenRevenueLegend => 'Prihod (skalirano)';

  @override
  String get reportsScreenNoPurchaseData => 'Nema podataka o kupovinama.';

  @override
  String selectFieldRequiredError(String field) {
    return 'Odaberite $field.';
  }

  @override
  String get removeImageConfirmTitle => 'Ukloniti sliku?';

  @override
  String get removeImageConfirmMessage =>
      'Slika ce biti uklonjena. Ovu radnju mozete ponistiti samo ponovnim dodavanjem slike prije nego sacuvate izmjene.';

  @override
  String get removeImageAction => 'Ukloni sliku';
}
