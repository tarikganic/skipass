// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get appTitle => 'SkiPass';

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
  String get commonDiscard => 'Odustani';

  @override
  String get commonConfirm => 'Potvrdi';

  @override
  String get commonSelect => 'Odaberi';

  @override
  String get commonNoItemsAvailable => 'Nema dostupnih stavki';

  @override
  String get errorUnableToLoadData => 'Podatke nije moguce ucitati';

  @override
  String get commonRetry => 'Pokusaj ponovo';

  @override
  String get reasonMinLengthError =>
      'Obrazlozenje mora imati najmanje 3 znaka.';

  @override
  String get commonAll => 'Sve';

  @override
  String get commonYes => 'Da';

  @override
  String get commonNo => 'Ne';

  @override
  String get commonNoData => 'Nema podataka';

  @override
  String get commonTotal => 'Ukupno';

  @override
  String get commonBuy => 'Kupi';

  @override
  String get resetFiltersAction => 'Ponisti filtere';

  @override
  String get clearSearchTooltip => 'Ocisti pretragu';

  @override
  String get cancellationReasonLabel => 'Razlog otkazivanja';

  @override
  String discountBadge(String percent) {
    return 'Popust $percent%';
  }

  @override
  String get imagePickFailedMessage =>
      'Odabir slike nije uspio. Pokusajte ponovo.';

  @override
  String get removePhotoAction => 'Ukloni sliku';

  @override
  String get paymentFailedGenericMessage =>
      'Placanje nije uspjelo. Pokusajte ponovo.';

  @override
  String get fieldUsernameLabel => 'Korisnicko ime';

  @override
  String get fieldFirstNameLabel => 'Ime';

  @override
  String get fieldLastNameLabel => 'Prezime';

  @override
  String get fieldEmailLabel => 'E-mail adresa';

  @override
  String get emailHintExample => 'ime@domena.ba';

  @override
  String get fieldPhoneLabel => 'Broj telefona';

  @override
  String get fieldPhoneHint => '+387 61 123 456';

  @override
  String get fieldBirthDateLabel => 'Datum rodjenja';

  @override
  String get dateFieldSelectHint => 'Odaberi datum';

  @override
  String get fieldCityLabel => 'Grad';

  @override
  String get cityDropdownHint => 'Odaberi grad';

  @override
  String get fieldPasswordLabel => 'Lozinka';

  @override
  String get fieldNewPasswordLabel => 'Nova lozinka';

  @override
  String get fieldConfirmNewPasswordLabel => 'Potvrda nove lozinke';

  @override
  String get passwordMinLengthHelper => 'Najmanje 4 znaka.';

  @override
  String get showPasswordTooltip => 'Prikazi lozinku';

  @override
  String get hidePasswordTooltip => 'Sakrij lozinku';

  @override
  String get statusOrderPending => 'Ceka placanje';

  @override
  String get statusOrderConfirmed => 'Potvrdena';

  @override
  String get statusOrderCompleted => 'Zavrsena';

  @override
  String get statusOrderCancelled => 'Otkazana';

  @override
  String get statusTicketPending => 'Neaktivna';

  @override
  String get statusTicketActive => 'Aktivna';

  @override
  String get statusTicketUsed => 'U upotrebi';

  @override
  String get statusTicketExpired => 'Istekla';

  @override
  String get statusIncidentReported => 'Prijavljen';

  @override
  String get statusIncidentInProgress => 'U toku';

  @override
  String get statusIncidentResolved => 'Rijesen';

  @override
  String get statusIncidentRejected => 'Odbijen';

  @override
  String get statusCrowdLow => 'Slaba guzva';

  @override
  String get statusCrowdModerate => 'Umjerena guzva';

  @override
  String get statusCrowdHigh => 'Velika guzva';

  @override
  String get statusCrowdVeryHigh => 'Izuzetna guzva';

  @override
  String get statusOpen => 'Otvorena';

  @override
  String get statusClosed => 'Zatvorena';

  @override
  String get statusUnknown => 'Nepoznato';

  @override
  String get statusUrgentLabel => 'Hitno';

  @override
  String get navHome => 'Pocetna';

  @override
  String get navTrails => 'Staze';

  @override
  String get navPurchase => 'Kupovina';

  @override
  String get navTickets => 'Karte';

  @override
  String get navBenefits => 'Pogodnosti';

  @override
  String get navProfile => 'Profil';

  @override
  String get loginHeaderTitle => 'Dobro dosli';

  @override
  String get loginHeaderSubtitle =>
      'Prijavite se za kupovinu ski pass karata\ni pregled staza u realnom vremenu.';

  @override
  String get loginUsernameHint => 'npr. mobile';

  @override
  String get loginPasswordHint => 'Unesite lozinku';

  @override
  String get loginForgotPasswordLink => 'Zaboravljena lozinka?';

  @override
  String get loginSubmitButton => 'Prijavi se';

  @override
  String get loginNoAccountLabel => 'Nemate racun?';

  @override
  String get loginRegisterLink => 'Registrujte se';

  @override
  String get registerAppBarTitle => 'Registracija';

  @override
  String get registerHeading => 'Kreirajte racun';

  @override
  String get registerRequiredFieldsNote =>
      'Polja oznacena zvjezdicom su obavezna.';

  @override
  String get registerUsernameHint => 'npr. skijas.haris';

  @override
  String get registerPhoneHelper =>
      'Koristi se za kontakt u slucaju prijave incidenta.';

  @override
  String get registerCitiesUnavailable => 'Gradovi trenutno nisu dostupni';

  @override
  String get fieldConfirmPasswordLabel => 'Potvrda lozinke';

  @override
  String get registerSubmitButton => 'Kreiraj racun';

  @override
  String get registerBackToLogin => 'Nazad na prijavu';

  @override
  String get registerMinorNotice =>
      'Napomena: za maloljetne korisnike kupovinu karata potvrdjuje roditelj ili staratelj.';

  @override
  String get registerSuccessMessage =>
      'Racun je kreiran. Dobro dosli u SkiPass!';

  @override
  String get forgotPasswordAppBarTitle => 'Reset lozinke';

  @override
  String get forgotPasswordHeadingReset => 'Unesite novu lozinku';

  @override
  String get forgotPasswordHeadingRequest => 'Zaboravljena lozinka';

  @override
  String get forgotPasswordSubtitleReset =>
      'Unesite kod koji ste dobili i odaberite novu lozinku.';

  @override
  String get forgotPasswordSubtitleRequest =>
      'Unesite e-mail adresu sa kojom ste registrovani i poslacemo vam kod za reset lozinke.';

  @override
  String get forgotPasswordSendCodeButton => 'Posalji kod';

  @override
  String get forgotPasswordCodeSentInfo =>
      'Ako je adresa registrovana, poslali smo kod za reset lozinke.';

  @override
  String get forgotPasswordResetCodeLabel => 'Kod za reset';

  @override
  String get forgotPasswordSetNewButton => 'Postavi novu lozinku';

  @override
  String get forgotPasswordResendOtherAddress => 'Posalji kod na drugu adresu';

  @override
  String get forgotPasswordSuccessMessage =>
      'Lozinka je promijenjena. Prijavite se novom lozinkom.';

  @override
  String get devNoticeTitle => 'Razvojno okruzenje';

  @override
  String get devNoticeCopyTooltip => 'Kopiraj kod';

  @override
  String get devNoticeBody =>
      'Kod je automatski popunjen jer e-mail servis jos nije aktivan. U produkciji kod stize na e-mail adresu.';

  @override
  String get homeGreetingMorning => 'Dobro jutro';

  @override
  String get homeGreetingAfternoon => 'Dobar dan';

  @override
  String get homeGreetingEvening => 'Dobro vece';

  @override
  String get homeDefaultUserName => 'Skijasu';

  @override
  String homeResortOpenUntil(String time) {
    return 'Otvoreno danas do $time';
  }

  @override
  String homeResortClosed(String opening, String closing) {
    return 'Zatvoreno - radno vrijeme $opening - $closing';
  }

  @override
  String get homeCurrentOnTrail => 'Trenutno na stazi';

  @override
  String homeSnowDepthLabel(int cm) {
    return '$cm cm snijega';
  }

  @override
  String get homeLatestAnnouncements => 'Najnovije obavijesti';

  @override
  String get homeNoActiveAnnouncements => 'Trenutno nema aktivnih obavijesti.';

  @override
  String get homeFeaturedBenefits => 'Izdvojene pogodnosti';

  @override
  String get homeNoFeaturedBenefits => 'Trenutno nema izdvojenih pogodnosti.';

  @override
  String get homeRecommendedTitle => 'Preporuceno za vas';

  @override
  String get homeNoRecommendations => 'Trenutno nemamo preporuke za vas.';

  @override
  String recommendationReasonPurchasedCategory(String category) {
    return 'Jer ste ranije kupili iz kategorije $category';
  }

  @override
  String recommendationReasonViewedCategory(String category) {
    return 'Jer cesto pregledate kategoriju $category';
  }

  @override
  String recommendationReasonUsedPartner(String partner) {
    return 'Jer ste koristili usluge partnera $partner';
  }

  @override
  String recommendationReasonPreferredBrand(String brand) {
    return 'Jer preferirate brend $brand';
  }

  @override
  String get recommendationReasonPopularFallback =>
      'Popularno medju korisnicima';

  @override
  String get homeTrailsOpenLabel => 'otvorenih';

  @override
  String get homeLiftsCardTitle => 'Ski liftovi';

  @override
  String get homeLiftsOperationalLabel => 'u pogonu';

  @override
  String homeActiveTicketsMessage(String count) {
    return 'Imate $count za danas';
  }

  @override
  String get homeNoActiveTicketMessage => 'Nemate aktivnu kartu';

  @override
  String get homeShowQrHint => 'Prikazite QR kod na ulazu na lift.';

  @override
  String get homeBuyTicketHint => 'Kupite ski pass i krenite na stazu.';

  @override
  String get homeQrCodeButton => 'QR kod';

  @override
  String get trailsAppBarTitle => 'Staze i liftovi';

  @override
  String get trailsSearchHint => 'Pretrazi stazu po nazivu ili oznaci';

  @override
  String get trailsFilterOpen => 'Otvorene';

  @override
  String get liftsFilterAll => 'Svi';

  @override
  String get liftsFilterOperational => 'U pogonu';

  @override
  String get liftsFilterNonOperational => 'Van pogona';

  @override
  String get trailsEmptyTitle => 'Nema staza za zadate uslove';

  @override
  String get trailsEmptyMessageFiltered =>
      'Pokusajte promijeniti pretragu ili filtere.';

  @override
  String get trailsEmptyMessageNone => 'Staze jos nisu unesene u sistem.';

  @override
  String get trailMetricLength => 'Duzina';

  @override
  String get trailMetricElevation => 'Visinska razlika';

  @override
  String get trailMetricSnow => 'Snijeg';

  @override
  String get trailNightSkiingLabel => 'Nocno skijanje';

  @override
  String trailIncidentReportsCount(int count) {
    return '$count prijava';
  }

  @override
  String get liftsEmptyTitle => 'Nema liftova za zadate uslove';

  @override
  String get liftsEmptyMessage =>
      'Promijenite filter da vidite ostale liftove.';

  @override
  String liftRideDurationSuffix(int minutes) {
    return '$minutes min voznje';
  }

  @override
  String liftCurrentRiders(int count) {
    return '$count korisnika trenutno';
  }

  @override
  String liftCapacityLabel(int capacity) {
    return 'Kapacitet $capacity/h';
  }

  @override
  String get liftOutOfServiceNotice =>
      'Lift je van pogona zbog prijavljenog kvara. Servis je u toku.';

  @override
  String get trailDetailsDefaultTitle => 'Detalji staze';

  @override
  String get trailReportProblemButton => 'Prijavi problem';

  @override
  String get trailAboutSectionTitle => 'O stazi';

  @override
  String get trailConditionsHistoryTitle => 'Historija uslova';

  @override
  String get trailNoConditionsRecorded =>
      'Za ovu stazu jos nisu evidentirani uslovi.';

  @override
  String get trailReviewsTitle => 'Ocjene staze';

  @override
  String get trailCodeLabel => 'Oznaka staze';

  @override
  String get trailCrowdLabel => 'Procijenjena guzva';

  @override
  String get trailSnowCoverLabel => 'Snjezni pokrivac';

  @override
  String get trailSnowmakingLabel => 'Vjestacki snijeg';

  @override
  String get benefitsSearchHint => 'Pretrazi pogodnost, uslugu ili brend';

  @override
  String get myBenefitsTitle => 'Moje pogodnosti';

  @override
  String get benefitsEmptyTitle => 'Nema pogodnosti za zadate uslove';

  @override
  String get benefitsEmptyMessage =>
      'Pokusajte drugu pretragu ili odaberite drugu kategoriju.';

  @override
  String get benefitNotYetRated => 'Jos nije ocijenjeno';

  @override
  String get benefitDetailsDefaultTitle => 'Detalji pogodnosti';

  @override
  String get benefitPurchaseConfirmTitle => 'Potvrda kupovine';

  @override
  String benefitPurchaseConfirmMessage(
    int quantity,
    String name,
    String total,
  ) {
    return 'Kupiti $quantity × $name u ukupnom iznosu od $total?';
  }

  @override
  String benefitPurchaseSuccessMessage(String name) {
    return '$name je uspjesno kupljeno. Pregled je dostupan u \"Moje pogodnosti\".';
  }

  @override
  String benefitRatingsSummary(String average, int count) {
    return '$average · $count ocjena';
  }

  @override
  String get benefitCategoryLabel => 'Kategorija';

  @override
  String get benefitPartnerLabel => 'Partner';

  @override
  String get benefitBrandLabel => 'Brend';

  @override
  String get benefitRegularPriceLabel => 'Redovna cijena';

  @override
  String get benefitDiscountedPriceLabel => 'Cijena sa popustom';

  @override
  String get benefitDescriptionSectionTitle => 'Opis';

  @override
  String get benefitInactiveNotice =>
      'Ova pogodnost trenutno nije dostupna za kupovinu.';

  @override
  String get benefitUserReviewsTitle => 'Ocjene korisnika';

  @override
  String get benefitQuantityLabel => 'Kolicina';

  @override
  String get benefitCancelPurchaseTitle => 'Otkazivanje kupovine';

  @override
  String benefitCancelSuccessMessage(String name) {
    return 'Kupovina \"$name\" je otkazana.';
  }

  @override
  String get myBenefitsEmptyTitle => 'Jos niste kupili nijednu pogodnost';

  @override
  String get myBenefitsEmptyMessage =>
      'Iznajmljivanje opreme, obuke i ugostiteljska ponuda dostupni su u sekciji Pogodnosti.';

  @override
  String benefitCancellationReasonLine(String reason) {
    return 'Razlog otkazivanja: $reason';
  }

  @override
  String get benefitCancelPurchaseButton => 'Otkazi kupovinu';

  @override
  String get myIncidentsAppBarTitle => 'Moje prijave';

  @override
  String get incidentNewReportButton => 'Nova prijava';

  @override
  String get incidentStatusReportedFilter => 'Prijavljeni';

  @override
  String get incidentStatusResolvedFilter => 'Rijeseni';

  @override
  String get incidentStatusRejectedFilter => 'Odbijeni';

  @override
  String get incidentsEmptyTitleNone => 'Nemate prijavljenih incidenata';

  @override
  String get incidentsEmptyTitleFiltered => 'Nema prijava u ovom statusu';

  @override
  String get incidentsEmptyMessage =>
      'Ako primijetite problem na stazi ili liftu, prijavite ga kako bi osoblje moglo reagovati.';

  @override
  String get incidentRejectionReasonTitle => 'Razlog odbijanja';

  @override
  String get incidentStaffNoteTitle => 'Obrazlozenje osoblja';

  @override
  String get reportIncidentAppBarTitle => 'Prijava incidenta';

  @override
  String get selectIncidentTypeError => 'Odaberite tip incidenta.';

  @override
  String get selectTrailError => 'Odaberite stazu na koju se prijava odnosi.';

  @override
  String get selectLiftError => 'Odaberite ski lift na koji se prijava odnosi.';

  @override
  String get incidentReportSuccessMessage =>
      'Prijava je poslana. Osoblje skijalista je obavijesteno.';

  @override
  String get coordinatesInvalidFormatError =>
      'Koordinate nisu u ispravnom formatu.';

  @override
  String get incidentEmptyTitle => 'Prijava trenutno nije moguca';

  @override
  String get incidentEmptyMessage =>
      'Tipovi incidenata jos nisu definisani u sistemu.';

  @override
  String get incidentSafetyNotice =>
      'U slucaju tezih povreda odmah pozovite hitnu pomoc. Ova prijava sluzi za obavjestavanje osoblja skijalista.';

  @override
  String get incidentTypeLabel => 'Tip incidenta';

  @override
  String get incidentLocationLabel => 'Lokacija incidenta';

  @override
  String get targetTrailLabel => 'Staza';

  @override
  String get targetLiftLabel => 'Ski lift';

  @override
  String get trailsUnavailableHint => 'Staze nisu dostupne';

  @override
  String get liftsUnavailableHint => 'Liftovi nisu dostupni';

  @override
  String get problemDescriptionLabel => 'Opis problema';

  @override
  String get problemDescriptionHint => 'Opisite sta se dogodilo i gdje tacno.';

  @override
  String get minTenCharsHelper => 'Najmanje 10 znakova.';

  @override
  String get submitReportButton => 'Posalji prijavu';

  @override
  String get coordinatesFieldTitle => 'Koordinate lokacije';

  @override
  String get coordinatesFieldSubtitle =>
      'Odaberite najblizu tacku ili unesite tacne koordinate.';

  @override
  String get knownSpotBase => 'Baza skijalista';

  @override
  String get knownSpotMiddle => 'Sredina staze';

  @override
  String get knownSpotTop => 'Vrh staze';

  @override
  String get knownSpotLiftStart => 'Polazna stanica lifta';

  @override
  String get geoLatitudeName => 'Geografska sirina';

  @override
  String get geoLongitudeName => 'Geografska duzina';

  @override
  String coordinateRequiredError(String name) {
    return '$name je obavezna.';
  }

  @override
  String get coordinateFormatError => 'Unesite broj u formatu 43.7107';

  @override
  String coordinateRangeError(String name, int min, int max) {
    return '$name mora biti izmedju $min i $max.';
  }

  @override
  String get photoSectionTitle => 'Fotografija (opciono)';

  @override
  String get cameraButton => 'Kamera';

  @override
  String get galleryButton => 'Galerija';

  @override
  String get notificationsAppBarTitle => 'Notifikacije';

  @override
  String get markAllReadAction => 'Oznaci sve';

  @override
  String get markAllReadSuccessMessage =>
      'Sve notifikacije su oznacene kao procitane.';

  @override
  String get notificationsEmptyTitle => 'Nemate notifikacija';

  @override
  String get notificationsEmptyMessage =>
      'Obavijesti o narudzbama, placanjima i prijavama stizat ce na ovaj ekran.';

  @override
  String get ordersAppBarTitle => 'Historija narudzbi';

  @override
  String get orderStatusConfirmedFilter => 'Potvrdene';

  @override
  String get orderStatusCompletedFilter => 'Zavrsene';

  @override
  String get orderStatusCancelledFilter => 'Otkazane';

  @override
  String get ordersEmptyTitleNone => 'Jos nemate narudzbi';

  @override
  String get ordersEmptyTitleFiltered => 'Nema narudzbi u ovom statusu';

  @override
  String get ordersEmptyMessageNone =>
      'Kada kupite ski pass kartu, narudzba ce se pojaviti ovdje.';

  @override
  String get ordersEmptyMessageFiltered =>
      'Promijenite filter da vidite ostale narudzbe.';

  @override
  String get orderDetailsDefaultTitle => 'Detalji narudzbe';

  @override
  String get orderCancelTitle => 'Otkazivanje narudzbe';

  @override
  String get orderCancelButton => 'Otkazi narudzbu';

  @override
  String orderCancelSuccessMessage(String orderNumber) {
    return 'Narudzba $orderNumber je otkazana.';
  }

  @override
  String get paymentReceivedMessage => 'Placanje je zaprimljeno.';

  @override
  String get orderTicketCountLabel => 'Broj karata';

  @override
  String get orderPaymentMethodLabel => 'Nacin placanja';

  @override
  String get orderTotalAmountLabel => 'Ukupan iznos';

  @override
  String get orderPaidLabel => 'Placeno';

  @override
  String get orderRefundedLabel => 'Vraceno';

  @override
  String get orderAwaitingPaymentNotice =>
      'Narudzba ceka evidentirano placanje. Karte postaju aktivne cim placanje bude potvrdeno na blagajni ili kroz aplikaciju.';

  @override
  String get orderPayNowButton => 'Plati narudzbu';

  @override
  String get paymentsHistoryTitle => 'Evidencija placanja';

  @override
  String get paymentNotCompleted => 'Nije zavrseno';

  @override
  String get ticketsInOrderTitle => 'Karte u narudzbi';

  @override
  String get paymentStatusPartiallyRefunded => 'Djelimicno vraceno';

  @override
  String get paymentStatusFailed => 'Neuspjelo';

  @override
  String get logoutDialogTitle => 'Odjava';

  @override
  String get logoutDialogMessage => 'Da li ste sigurni da se zelite odjaviti?';

  @override
  String get logoutConfirmButton => 'Odjavi se';

  @override
  String get myActivitiesSectionTitle => 'Moje aktivnosti';

  @override
  String orderCountSubtitle(int count) {
    return '$count narudzbi';
  }

  @override
  String get myBenefitsMenuSubtitle => 'Kupljene usluge i oprema';

  @override
  String get myReportsMenuSubtitle => 'Prijavljeni incidenti';

  @override
  String get notificationsMenuSubtitle => 'Obavijesti o narudzbama i prijavama';

  @override
  String get resortAnnouncementsMenuTitle => 'Obavijesti skijalista';

  @override
  String get resortAnnouncementsMenuSubtitle =>
      'Vremenski uslovi, akcije i zatvaranja';

  @override
  String get accountSettingsSectionTitle => 'Postavke racuna';

  @override
  String get editProfileMenuTitle => 'Uredi profil';

  @override
  String get editProfileMenuSubtitle => 'Licni podaci i slika';

  @override
  String get changePasswordMenuSubtitle => 'Uz potvrdu trenutne lozinke';

  @override
  String get appVersionFooter => 'SkiPass · verzija 1.0.0';

  @override
  String get profileEmailLabel => 'E-mail';

  @override
  String get profilePhoneLabel => 'Telefon';

  @override
  String get profilePhoneNotSet => 'Nije unesen';

  @override
  String get profileCityNotSet => 'Nije odabran';

  @override
  String get profileMemberSinceLabel => 'Clan od';

  @override
  String get editProfileAppBarTitle => 'Uredi profil';

  @override
  String get profileUpdateSuccessMessage => 'Profil je uspjesno azuriran.';

  @override
  String get editProfileCitiesUnavailable => 'Gradovi nisu dostupni';

  @override
  String get saveChangesButton => 'Sacuvaj izmjene';

  @override
  String get pickerCameraOption => 'Slikaj kamerom';

  @override
  String get pickerGalleryOption => 'Odaberi iz galerije';

  @override
  String get changePasswordAppBarTitle => 'Promjena lozinke';

  @override
  String get changePasswordSecurityNotice =>
      'Iz sigurnosnih razloga promjena lozinke ponistava sve aktivne sesije, pa ce biti potrebna ponovna prijava.';

  @override
  String get changePasswordConfirmDialogMessage =>
      'Nakon promjene lozinke bicete odjavljeni sa svih uredjaja. Nastaviti?';

  @override
  String get changePasswordConfirmButton => 'Promijeni';

  @override
  String get currentPasswordLabel => 'Trenutna lozinka';

  @override
  String get changePasswordSubmitButton => 'Promijeni lozinku';

  @override
  String get changePasswordSuccessMessage =>
      'Lozinka je promijenjena. Prijavite se ponovo.';

  @override
  String get purchaseAppBarTitle => 'Kupovina karte';

  @override
  String get selectTicketTypeError => 'Odaberite tip karte.';

  @override
  String get selectStartDateError => 'Odaberite datum pocetka vazenja karte.';

  @override
  String get maxTicketsPerOrderError =>
      'U jednoj narudzbi je moguce kupiti najvise 20 karata.';

  @override
  String get ticketsAddedToCartMessage =>
      'Karte su dodane u korpu. Unesite imena nosilaca prije slanja narudzbe.';

  @override
  String get emptyCartError => 'Korpa je prazna. Dodajte najmanje jednu kartu.';

  @override
  String get selectPaymentMethodError => 'Odaberite nacin placanja.';

  @override
  String missingHolderNameError(int number) {
    return 'Unesite ime i prezime nosioca za kartu broj $number.';
  }

  @override
  String get orderConfirmTitle => 'Potvrda narudzbe';

  @override
  String orderConfirmMessage(String tickets, String total) {
    return 'Naruciti $tickets u ukupnom iznosu od $total?';
  }

  @override
  String get orderPlaceButton => 'Naruci';

  @override
  String get paymentCancelledMessage =>
      'Placanje je otkazano. Narudzba je sacuvana i ceka uplatu.';

  @override
  String get paymentFailedRetryFromOrdersMessage =>
      'Placanje nije uspjelo. Pokusajte ponovo iz Narudzbi.';

  @override
  String get purchaseUnavailableTitle => 'Kupovina trenutno nije moguca';

  @override
  String get purchaseUnavailableMessage =>
      'Skijaliste jos nije objavilo cjenovnik ski pass karata. Pokusajte ponovo kasnije.';

  @override
  String get newTicketSectionTitle => 'Nova karta';

  @override
  String get ticketTypeLabel => 'Tip karte';

  @override
  String ticketTypePriceOption(String name, String price) {
    return '$name · $price/dan';
  }

  @override
  String get startDateLabel => 'Datum pocetka vazenja';

  @override
  String get daysCountLabel => 'Broj dana';

  @override
  String maxDaysAllowedHelper(String days) {
    return 'Odabrani tip karte dozvoljava najvise $days.';
  }

  @override
  String get ticketsCountLabel => 'Broj karata';

  @override
  String get multipleTicketsHelper =>
      'Kupite vise karata odjednom za porodicu ili grupu.';

  @override
  String get addToCartButton => 'Dodaj u korpu';

  @override
  String cartSectionTitle(String count) {
    return 'Korpa ($count)';
  }

  @override
  String get paymentMethodLabel => 'Nacin placanja';

  @override
  String get paymentMethodsUnavailableHint => 'Nacini placanja nisu dostupni';

  @override
  String get submitOrderButton => 'Posalji narudzbu';

  @override
  String get pricePerTicketLabel => 'Cijena po karti';

  @override
  String totalForTicketsLabel(String tickets) {
    return 'Ukupno za $tickets';
  }

  @override
  String get removeTicketTooltip => 'Ukloni kartu';

  @override
  String get ticketHolderFirstNameLabel => 'Ime nosioca';

  @override
  String get orderConfirmationAppBarTitle => 'Narudzba poslana';

  @override
  String get orderReceivedTitle => 'Narudzba je zaprimljena';

  @override
  String orderNumberLabel(String number) {
    return 'Broj narudzbe: $number';
  }

  @override
  String get orderStatusLabel => 'Status narudzbe';

  @override
  String get orderDateLabel => 'Datum narudzbe';

  @override
  String get purchasedTicketsTitle => 'Kupljene karte';

  @override
  String get ticketsAwaitingPaymentTitle => 'Karte cekaju potvrdu placanja';

  @override
  String get ticketsAwaitingPaymentBody =>
      'Nakon evidentiranog placanja karte postaju aktivne i QR kod se moze koristiti na ulazu na ski lift.';

  @override
  String get backToPurchaseButton => 'Nazad na kupovinu';

  @override
  String get reviewThanksMessage => 'Hvala na ocjeni!';

  @override
  String get reviewUpdatedMessage => 'Vasa ocjena je azurirana.';

  @override
  String get reviewDeleteTitle => 'Brisanje ocjene';

  @override
  String get reviewDeleteMessage =>
      'Da li ste sigurni da zelite obrisati svoju ocjenu?';

  @override
  String get reviewDeleteSuccessMessage => 'Ocjena je obrisana.';

  @override
  String get reviewNoRatingsYet =>
      'Jos nema ocjena. Budite prvi koji ce ocijeniti.';

  @override
  String reviewsCountLabel(int count) {
    return '$count ocjena korisnika';
  }

  @override
  String get leaveReviewButton => 'Ostavi ocjenu';

  @override
  String get editReviewButton => 'Uredi ocjenu';

  @override
  String get deleteReviewTooltip => 'Obrisi ocjenu';

  @override
  String get yourReviewTitle => 'Vasa ocjena';

  @override
  String get closeTooltip => 'Zatvori';

  @override
  String get reviewCommentHint => 'Podijelite svoje iskustvo (opciono)';

  @override
  String get saveReviewButton => 'Sacuvaj ocjenu';

  @override
  String get myTicketsAppBarTitle => 'Moje karte';

  @override
  String get orderHistoryTooltip => 'Historija narudzbi';

  @override
  String get activeTicketsTab => 'Aktivne';

  @override
  String get allTicketsTab => 'Sve karte';

  @override
  String get noActiveTicketsTitle => 'Nemate aktivnih karata';

  @override
  String get noActiveTicketsMessage =>
      'Kupite ski pass kartu i ovdje ce se pojaviti sa QR kodom.';

  @override
  String get noPurchasedTicketsTitle => 'Jos nemate kupljenih karata';

  @override
  String get noPurchasedTicketsMessage =>
      'Sve kupljene karte, ukljucujuci istekle, bit ce prikazane ovdje.';

  @override
  String get loadMoreButton => 'Ucitaj jos';

  @override
  String get ticketHolderLabel => 'Nosilac';

  @override
  String get ticketValidLabel => 'Vazi';

  @override
  String get ticketDurationLabel => 'Trajanje';

  @override
  String get ticketScansLabel => 'Skeniranja';

  @override
  String get showQrButton => 'Prikazi QR kod';

  @override
  String get ticketUnavailablePending =>
      'QR kod postaje dostupan nakon evidentiranog placanja.';

  @override
  String get ticketUnavailableCancelled =>
      'Karta je otkazana i ne moze se koristiti.';

  @override
  String ticketUnavailableExpired(String date) {
    return 'Karta je istekla $date.';
  }

  @override
  String ticketNotYetValid(String date) {
    return 'Karta pocinje vaziti $date.';
  }

  @override
  String ticketNoLongerValid(String date) {
    return 'Karta je vazila do $date.';
  }

  @override
  String get ticketUnavailableGeneric => 'Karta trenutno nije upotrebljiva.';

  @override
  String orderLinkLabel(String number) {
    return 'Narudzba $number';
  }

  @override
  String get orderAwaitingPaymentBadge => 'Ceka evidentirano placanje';

  @override
  String get ticketQrAppBarTitle => 'QR kod karte';

  @override
  String get copyCodeTooltip => 'Kopiraj kod karte';

  @override
  String get codeCopiedMessage => 'Kod karte je kopiran.';

  @override
  String get showCodeInstruction =>
      'Pokazite ovaj kod zaposleniku na ulazu na ski lift.';

  @override
  String get ticketHolderLabelFull => 'Nosilac karte';

  @override
  String get skiResortLabel => 'Skijaliste';

  @override
  String get scanCountLabel => 'Broj skeniranja';

  @override
  String get lastScanLabel => 'Posljednje skeniranje';

  @override
  String get announcementsAppBarTitle => 'Obavijesti';

  @override
  String get showAllAnnouncementsTooltip => 'Prikazi sve obavijesti';

  @override
  String get showUrgentOnlyTooltip => 'Prikazi samo hitne';

  @override
  String get noUrgentAnnouncementsTitle => 'Nema hitnih obavijesti';

  @override
  String get noActiveAnnouncementsTitle => 'Nema aktivnih obavijesti';

  @override
  String get announcementsEmptyMessage =>
      'Ovdje ce se pojaviti obavijesti o vremenu, zatvaranju staza i akcijskim ponudama.';

  @override
  String get readMoreLabel => 'Detaljnije';

  @override
  String get announcementDetailsAppBarTitle => 'Obavijest';

  @override
  String get announcementUrgentBadge => 'Hitna obavijest';

  @override
  String get announcementPublishedByLabel => 'Objavio';

  @override
  String get announcementValidUntilLabel => 'Vazi do';

  @override
  String get removeImageConfirmTitle => 'Ukloniti sliku?';

  @override
  String get removeImageConfirmMessage =>
      'Slika ce biti uklonjena. Ovu radnju mozete ponistiti samo ponovnim dodavanjem slike prije nego sacuvate izmjene.';
}
