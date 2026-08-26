# SkiPass

Seminarski rad iz predmeta **Razvoj softvera II** - Fakultet informacijskih tehnologija Mostar.

**Student:** Tarik Ganić (IB210116)

SkiPass je sistem za digitalizaciju poslovanja ski centra. Sastoji se od REST API servisa,
desktop aplikacije za osoblje i mobilne aplikacije za skijaše.

> **Trenutni status: faza 4 - REST API, mobilna i desktop aplikacija, RabbitMQ worker servis i Stripe placanje.**
> Sistem preporuke se implementira u narednoj fazi.

---

## Sadržaj

- [Brzi start](#brzi-start)
- [Arhitektura](#arhitektura)
- [Model baze podataka](#model-baze-podataka)
- [Pokretanje aplikacije](#pokretanje-aplikacije)
- [Vanjski servisi](#vanjski-servisi)
- [RabbitMQ worker servis](#rabbitmq-worker-servis)
- [Placanje (Stripe)](#placanje-stripe)
- [Mobilna aplikacija](#mobilna-aplikacija)
- [Desktop aplikacija](#desktop-aplikacija)
- [Korisnički podaci za pristup](#korisnički-podaci-za-pristup)
- [Pregled API endpointa](#pregled-api-endpointa)
- [Implementirana pravila](#implementirana-pravila)

---

## Brzi start

Kompletan redoslijed za pokretanje cijelog sistema od nule, bez prethodnog konteksta o projektu:

1. **Preduslovi** - instalirati .NET SDK 10, Docker Desktop (ili lokalni SQL Server), Flutter
   3.47+ i kreirati besplatan Stripe test nalog. Detalji: [Preduslovi](#preduslovi).
2. **Konfiguracija** - `cp .env.example .env`, pa popuniti `JWT_KEY`, `DB_PASSWORD`,
   `STRIPE_SECRET_KEY` i `STRIPE_WEBHOOK_SECRET`. Detalji: [Konfiguracija](#1-konfiguracija)
   i [Plaćanje (Stripe)](#placanje-stripe).
3. **Pokretanje backend-a** - iz korijena repozitorija:
   ```bash
   docker compose up --build
   ```
   Ovim se podižu SQL Server, RabbitMQ, API (`http://localhost:5000`, Swagger na `/swagger`)
   i Worker servis - sve u jednoj Docker mreži, bez ijednog dodatnog ručnog koraka. Baza,
   migracije i seed podaci se kreiraju automatski pri prvom pokretanju API-ja.
4. **Mobilna aplikacija** (skijaš) - iz `mobile/skipass_mobile`:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
   ```
   Detalji i build APK-a: [Mobilna aplikacija](#mobilna-aplikacija).
5. **Desktop aplikacija** (osoblje/administrator) - iz `desktop/skipass_desktop`:
   ```bash
   flutter run -d windows
   ```
   Adresa API-ja je već `localhost` po defaultu. Detalji i build EXE-a:
   [Desktop aplikacija](#desktop-aplikacija).
6. **Prijava** - bilo kojim nalogom iz [Korisnički podaci za pristup](#korisnički-podaci-za-pristup)
   (sve lozinke su `test`).

Nijedan korak ne zahtijeva ručno kreiranje baze, pokretanje SQL skripti niti ručnu
registraciju korisnika. Jedine dvije stvarne veze prema internetu koje sistem ostvaruje
su Stripe (obavezan sandbox za plaćanje, po specifikaciji zadatka) i opciono SMTP
(Mailtrap sandbox za e-mailove iz Worker servisa) - detaljno objašnjeno u
[Vanjski servisi](#vanjski-servisi). Sve ostalo (API, baza, RabbitMQ, oba klijenta)
radi isključivo unutar `localhost`/Docker mreže.

---

## Arhitektura

Backend je organizovan prema principima čiste arhitekture, u šest projekata (dva servisa
koja se pokreću odvojeno - API i Worker - dijele samo domensku logiku i ugovor o porukama):

```
backend/
├── SkiPass.slnx
└── src/
    ├── SkiPass.Domain/          entiteti, enumeracije, state machine pravila
    ├── SkiPass.Application/     DTO objekti, ugovori servisa, custom izuzeci
    ├── SkiPass.Infrastructure/  EF Core DbContext, konfiguracije, migracije, servisi
    ├── SkiPass.API/             kontroleri, middleware, autentifikacija, Swagger
    ├── SkiPass.Contracts/       poruke dijeljene izmedju API-ja i Worker-a (RabbitMQ ugovor)
    └── SkiPass.Worker/          odvojen mikroservis - konzumira RabbitMQ, salje e-mail (SMTP)

mobile/
└── skipass_mobile/
    └── lib/
        ├── core/                API klijent, tema, konfiguracija, validatori
        ├── models/              modeli koji odgovaraju DTO objektima API-ja
        ├── services/            pozivi API-ja grupisani po domenu
        ├── providers/           stanje aplikacije (provider)
        ├── widgets/             zajedničke komponente dizajn sistema
        └── screens/             ekrani aplikacije

desktop/
└── skipass_desktop/
    └── lib/
        ├── core/                API klijent, tema, konfiguracija, validatori
        ├── models/              modeli koji odgovaraju DTO objektima API-ja
        ├── services/            pozivi API-ja grupisani po domenu (uklj. PDF izvještaje)
        ├── providers/           stanje aplikacije (provider)
        ├── widgets/             zajedničke komponente dizajn sistema (tabele, dijalozi)
        └── screens/             ekrani administracije
```

Mobilna i desktop aplikacija su **odvojeni Flutter projekti** sa istim arhitekturnim
principima i istom paletom boja, ali odvojenom implementacijom - mobilna je optimizovana
za dodir i uski ekran, desktop za rad mišem nad tabelarnim prikazima.

Tok podataka je jednosmjeran: **kontroler → servis → DbContext**. Kontroleri ne sadrže
poslovnu logiku niti pristupaju bazi direktno, a klijentu se nikada ne vraćaju entiteti,
nego isključivo DTO objekti.

Mobilna aplikacija prati isti princip: **ekran → servis → API klijent**. Ekrani ne
sastavljaju HTTP pozive niti parsiraju JSON, nego rade sa tipiziranim modelima.

**Tehnologije:** .NET 10, ASP.NET Core Web API, Entity Framework Core 10, Microsoft SQL Server,
ASP.NET Identity, JWT autentifikacija, Swagger / OpenAPI, Flutter 3.47 (Dart 3.13).

---

## Model baze podataka

Baza se zove **`210116`** (broj indeksa bez `IB` prefiksa) i sadrži **35 tabela**.

### Glavne tabele (20)

| Tabela | Uloga |
|---|---|
| `Users` | poslovni profili korisnika (skijaš, osoblje, administrator) |
| `SkiResorts` | skijalište - krovni entitet sistema |
| `Trails` | ski staze sa statusom, težinom i procijenjenom gužvom |
| `TrailConditionLogs` | evidencija stanja staza (snježni pokrivač, uslovi) |
| `SkiLifts` | ski liftovi sa statusom rada i brojem korisnika |
| `LiftMaintenanceRecords` | evidencija kvarova i održavanja liftova |
| `TicketTypes` | tipovi ski pass karata sa cjenovnikom |
| `SkiPassOrders` | narudžbe karata (jedna narudžba, više karata) |
| `SkiPassTickets` | pojedinačne karte sa jedinstvenim QR kodom |
| `Payments` | transakcije plaćanja i povrata sredstava |
| `TicketValidations` | zapisi skeniranja QR koda na ski liftu |
| `Partners` | partnerske firme |
| `Benefits` | dodatne pogodnosti i partnerske usluge |
| `BenefitPurchases` | kupljene pogodnosti (signal za sistem preporuke) |
| `BenefitViews` | historija pregleda pogodnosti (signal za sistem preporuke) |
| `Incidents` | prijave incidenata sa GPS lokacijom |
| `Announcements` | obavijesti skijališta |
| `Notifications` | sistemske notifikacije korisnicima |
| `Reviews` | ocjene staza, pogodnosti i skijališta |
| `WeatherLogs` | evidencija vremenskih uslova |

### Referentne tabele (8 + ASP.NET Identity)

`Countries`, `Cities`, `TrailDifficulties`, `LiftTypes`, `IncidentTypes`,
`BenefitCategories`, `AnnouncementCategories`, `PaymentMethods`, te sedam
ASP.NET Identity tabela (`AspNetUsers`, `AspNetRoles`, `AspNetUserRoles`,
`AspNetUserClaims`, `AspNetUserLogins`, `AspNetRoleClaims`, `AspNetUserTokens`).

Svi strani ključevi definisani su kroz EF konfiguraciju (`Data/Configurations/`),
uz referencijalni integritet na nivou baze. Brisanje je kaskadno samo tamo gdje
podređeni zapis nema smisla bez roditelja (karte uz narudžbu, evidencija stanja uz stazu),
a u ostalim slučajevima je onemogućeno uz jasnu poruku korisniku.

---

## Pokretanje aplikacije

### Preduslovi

- [.NET SDK 10.0](https://dotnet.microsoft.com/download) ili noviji
- Microsoft SQL Server (lokalna instalacija) **ili** Docker Desktop
- Besplatan Stripe test/sandbox nalog ([dashboard.stripe.com/register](https://dashboard.stripe.com/register)) - potreban za `Stripe:SecretKey` i `Stripe:WebhookSecret`; API namjerno odbija da se pokrene bez njih (isto ponašanje kao za `Jwt:Key`)

### 1. Konfiguracija

Sve tajne se drže u `.env` datoteci u korijenu projekta. Kopirajte predložak i popunite vrijednosti:

```bash
cp .env.example .env
```

Obavezno promijenite `JWT_KEY` (najmanje 32 znaka) i `DB_PASSWORD`, te popunite
`STRIPE_SECRET_KEY` i `STRIPE_WEBHOOK_SECRET` (vidi [Placanje (Stripe)](#placanje-stripe)).

Ako koristite **lokalno instaliran SQL Server sa Windows autentifikacijom**, u `.env` postavite:

```
DB_HOST=localhost
DB_TRUSTED_CONNECTION=true
```

Ako koristite **Docker ili SQL autentifikaciju**, ostavite `DB_TRUSTED_CONNECTION=false`
i popunite `DB_USER` i `DB_PASSWORD`.

### 2a. Pokretanje kroz Docker

```bash
docker compose up --build
```

Podiže se SQL Server, RabbitMQ, API i Worker servis - četiri kontejnera, svaki
u sopstvenoj mreži (`skipass-network`). API je dostupan na `http://localhost:5000`.

### 2b. Pokretanje lokalno bez Dockera

```bash
dotnet run --project backend/src/SkiPass.API
```

API je dostupan na `http://localhost:5000`, a Swagger dokumentacija na
`http://localhost:5000/swagger`.

Migracije i seed podaci se primjenjuju automatski pri pokretanju - nije potrebno
ručno kreirati bazu niti pokretati skripte.

Za lokalno slanje e-mailova (bez Dockera) potrebno je odvojeno pokrenuti i Worker servis
(vidi [RabbitMQ worker servis](#rabbitmq-worker-servis)) - API i Worker su dva odvojena
procesa i pokreću se odvojenim komandama, isto kao u Docker-u.

### Rad sa migracijama

```bash
dotnet dotnet-ef migrations add NazivMigracije --project backend/src/SkiPass.Infrastructure --startup-project backend/src/SkiPass.API
```

---

## Vanjski servisi

Sistem radi u potpunosti lokalno (Docker mreža `skipass-network` kada se pokreće preko
`docker compose`); jedine dvije stvarne veze prema internetu su:

- **Stripe** (`api.stripe.com`) - test/sandbox nalog. Obavezan je po specifikaciji zadatka
  (integracija plaćanja mora ići preko stvarnog sandbox okruženja, ne smije biti
  simulirana) - koriste ga backend (`PaymentService`) i mobilna aplikacija
  (`flutter_stripe` PaymentSheet). Nikad se ne kontaktira produkcijski Stripe nalog.
- **SMTP (Mailtrap sandbox)** - koristi isključivo `SkiPass.Worker` za slanje e-mailova
  iz sistemskih notifikacija; potpuno je opciono i izolovano od ostatka sistema - ako SMTP
  podaci nisu podešeni u `.env`, Worker se i dalje normalno pokreće i konzumira RabbitMQ
  red, samo pojedinačno slanje e-maila neuspije uz jasnu grešku u logu. E-mailovi
  zavrsavaju u Mailtrap test inboxu, nikad ne stižu stvarnim primaocima.

Nema nikakvih drugih vanjskih poziva - bez telemetrije, analitike, licencnih provjera,
mapa ili vremenskih API-ja i slično (podaci o vremenskim uslovima su statični seed
podaci, ne dohvaćaju se uživo). API, baza, RabbitMQ i oba klijenta (mobilni i desktop)
međusobno komuniciraju isključivo preko `localhost`/Docker mreže.

---

## RabbitMQ worker servis

`SkiPass.Worker` je stvarno odvojen mikroservis - sopstveni proces, sopstveni `Dockerfile`,
sopstveni unos u `docker-compose.yml` (`skipass-worker`) - a ne `BackgroundService` unutar
API projekta. Referencira samo `SkiPass.Contracts` (poruku `EmailNotificationMessage`), ne
cijelu aplikaciju.

**Tok:** svaka sistemska notifikacija koja se upiše u `Notifications` tabelu (bilo gdje u
servisnom sloju) se automatski objavljuje na RabbitMQ red `skipass.email-notifications`
preko jedne tačke integracije - `ApplicationDbContext.SaveChangesAsync` prepoznaje nove
`Notification` zapise nakon uspješnog upisa i poziva `IEmailQueuePublisher`
(`SkiPass.Infrastructure/Messaging/RabbitMqEmailPublisher.cs`). `SkiPass.Worker` konzumira
taj red (`AsyncEventingBasicConsumer`) i stvarno šalje e-mail preko SMTP-a (MailKit).
Neuspjelo slanje se ponavlja sa eksponencijalnim odmakom (1s → 2s → 4s → 8s), uz logovanje
svakog pokušaja - ne guta se tiho.

Pokretanje bez Dockera (npr. dva odvojena terminala):

```bash
dotnet run --project backend/src/SkiPass.Worker
```

Bez podešenog `SMTP_USERNAME`/`SMTP_PASSWORD` u `.env`, Worker se i dalje pokreće i
konzumira red - slanje pojedinačnog e-maila će neuspjeti uz jasnu grešku u logu (stvaran
pokušaj SMTP konekcije, ne tiho preskakanje), što je i očekivano dok se ne unesu stvarni
SMTP podaci (npr. Gmail app password ili [Mailtrap](https://mailtrap.io) sandbox nalog).

---

## Placanje (Stripe)

Online plaćanje ide preko [Stripe](https://stripe.com) test/sandbox naloga (besplatna
registracija). Simulirano plaćanje je namjerno izbjegnuto - klijent nikad sam sebi ne može
označiti plaćanje kao uspješno; jedino mjesto gdje se narudžba stvarno potvrđuje je
`PaymentService.HandleStripeWebhookAsync`, pozvano preko `POST /api/Payments/webhook/stripe`.

**Tok plaćanja:**

1. `POST /api/Payments` (`PaymentService.InitiateAsync`) - ako je odabrani način plaćanja
   online (`PaymentMethod.IsOnline`), server otvara Stripe `PaymentIntent` (iznos se
   preračunava iz BAM u EUR preko fiksnog kursa valutnog odbora, `1 EUR = 1.95583 BAM` -
   Stripe ne podržava BAM direktno) i vraća `stripeClientSecret`/`stripePublishableKey`.
2. Mobilna aplikacija prikazuje Stripe **PaymentSheet unutar aplikacije**
   (`flutter_stripe`) - nema preusmjeravanja na eksterni browser.
3. Stripe potvrđuje uspješno plaćanje pozivom webhook-a na server, koji tek tada mijenja
   status narudžbe u `Confirmed` i aktivira karte (`CompletePaymentAsync` - ista, dijeljena
   logika koju koristi i ručna potvrda od strane osoblja za plaćanje na licu mjesta).
4. Povrat sredstava (`POST /api/Payments/{id}/refund`, samo administrator) prvo stvarno
   izvršava povrat kod Stripe-a, pa tek onda ažurira lokalni zapis.

### Podešavanje

1. Kreirajte besplatan nalog na [dashboard.stripe.com/register](https://dashboard.stripe.com/register).
2. Test ključevi: [dashboard.stripe.com/test/apikeys](https://dashboard.stripe.com/test/apikeys) →
   `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY` u `.env`.
3. Webhook secret - za lokalni razvoj najlakše preko [Stripe CLI](https://docs.stripe.com/stripe-cli):
   ```bash
   stripe listen --forward-to localhost:5000/api/Payments/webhook/stripe
   ```
   Ispisani `whsec_...` kod se upisuje u `STRIPE_WEBHOOK_SECRET`. Za produkcijski webhook
   endpoint, kreira se ručno na [dashboard.stripe.com/test/webhooks](https://dashboard.stripe.com/test/webhooks).
4. Testne kartice: `4242 4242 4242 4242` (uspješno), `4000 0000 0000 9995` (odbijeno) -
   bilo koji budući datum isteka i bilo koji CVC.

API namjerno **odbija da se pokrene** bez `Stripe:SecretKey`/`Stripe:WebhookSecret`
(`ConfigurationValidator`, ista provjera kao za `Jwt:Key` i konekcijski string).

---

## Mobilna aplikacija

Mobilni dio je klijentska aplikacija za skijaše, izrađena u Flutteru.

### Pokretanje

Adresa API-ja se ne hardkodira nego prosljeđuje pri pokretanju:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

`10.0.2.2` je standardna adresa hosta iz Android emulatora i ujedno je
podrazumijevana vrijednost, pa `flutter run` radi i bez dodatnih parametara.

Build instalacijske datoteke:

```bash
flutter build apk --release
```

### Implementirane funkcionalnosti

| Ekran | Sadržaj |
|---|---|
| Prijava i registracija | JWT prijava, registracija skijaša, reset lozinke u dva koraka |
| Početna | vremenski uslovi, broj otvorenih staza i aktivnih liftova, najnovije obavijesti, izdvojene pogodnosti |
| Staze | pretraga i filteri po težini i statusu, detalji staze, historija snježnih uslova, ocjene |
| Ski liftovi | status rada, trenutna popunjenost, evidencija kvarova |
| Kupovina karata | odabir tipa karte, datuma, broja dana i broja karata; korpa za više karata odjednom; **plaćanje karticom unutar aplikacije preko Stripe PaymentSheet-a** |
| Moje karte | aktivne i sve karte, QR kod za ulazak na ski lift |
| Narudžbe | historija kupovina, detalji narudžbe sa kartama i evidencijom plaćanja, otkazivanje, ponovni pokušaj plaćanja za neplaćenu narudžbu |
| Pogodnosti | pretraga po kategorijama, detalji, kupovina, ocjenjivanje |
| Incidenti | prijava sa lokacijom i fotografijom, pregled statusa vlastitih prijava |
| Obavijesti | obavijesti skijališta sa punim tekstom i slikom |
| Notifikacije | sistemske notifikacije sa automatskim osvježavanjem broja nepročitanih |
| Profil | izmjena ličnih podataka i slike, promjena lozinke |

### Dizajn sistem

Boje, tipografija, razmaci i komponente definisani su na jednom mjestu u
`lib/core/theme/` i `lib/widgets/`, pa se isti vizuelni jezik koristi kroz cijelu
aplikaciju. Podržane su svijetla i tamna tema.

Sve liste imaju definisana stanja učitavanja, greške i praznog prikaza. Nedostupne
akcije prikazane su u onemogućenom stanju uz objašnjenje razloga, a nepovratne
akcije traže potvrdu.

### Testovi

```bash
flutter test
```

Pokreće 28 testova: validatori i formatiranje, poslovna pravila na klijentu, te
widget testovi koji iscrtavaju ekrane nad **stvarnim odgovorima API-ja**
snimljenim sa pokrenutog servera (`test/fixtures/`).

Uz pokrenut API, provjera svih endpointa koje mobilna aplikacija koristi:

```bash
bash backend/api-test.sh
```

---

## Desktop aplikacija

Desktop dio je administrativna Windows aplikacija za osoblje i administratore, izrađena u
istom Flutteru kao i mobilna, ali kao zaseban projekat prilagođen radu mišem.

### Pokretanje

Desktop aplikacija se izvršava na istoj mašini kao i server, pa se povezuje direktno na
`localhost` (bez posebne adrese kao kod Android emulatora):

```bash
cd desktop/skipass_desktop
flutter run -d windows
```

Build instalacijske datoteke:

```bash
flutter build windows --release
```

Prijava je ograničena na role `Staff` i `Admin` - nalog sa rolom `Skier` klijent odbija
prije slanja zahtjeva serveru, jer desktop aplikacija nema smisla za skijaše.

### Implementirane funkcionalnosti

| Ekran | Sadržaj |
|---|---|
| Karte | pregled karata i tipova karata, ručna validacija karte na liftu, detalji narudžbe sa plaćanjima i povratom sredstava |
| Staze i ski liftovi | CRUD staza i liftova, evidencija stanja staze, prijava i praćenje kvarova liftova sa promjenom statusa |
| Usluge | CRUD pogodnosti i partnera, filter po kategoriji |
| Incidenti | kanban tabla po statusu (prijavljeno / u toku / riješeno / odbijeno) sa obrazloženjem pri zatvaranju |
| Obavijesti | hitne i aktivne obavijesti, CRUD sa slikom, datumom objave i isteka |
| Notifikacije | pregled i označavanje kao pročitano |
| Izvještaji | prodaja karata po danima (graf, filter perioda i skijališta) i top 5 korisnika; oba izvještaja se preuzimaju i štampaju kao PDF |
| Korisnici | CRUD korisnika sa dodjelom role - samo administrator |
| Referentni podaci | CRUD nad svih osam šifarnika kroz jedan generički ekran |
| Profil | izmjena ličnih podataka i slike, promjena lozinke |

Svaki CRUD ekran nad referentnim podacima dijeli isti generički obrazac
(`ReferenceTableConfig` + `ReferenceItemFormDialog`) umjesto osam gotovo identičnih formi,
a padajuće liste su uvijek popunjene iz baze - nikada slobodan tekst za entitet koji ima
svoju šifarniku tabelu.

### Testovi

```bash
cd desktop/skipass_desktop
flutter analyze
flutter test
```

---

## Korisnički podaci za pristup

Seed kreira šest korisnika. Lozinke se konfigurišu kroz `.env`
(`SEED_ADMIN_PASSWORD`, `SEED_STAFF_PASSWORD`, `SEED_SKIER_PASSWORD`),
a podrazumijevana vrijednost je `test`.

| Kontekst | Korisničko ime | Lozinka | Rola |
|---|---|---|---|
| Desktop verzija | `desktop` | `test` | Admin |
| Mobilna verzija | `mobile` | `test` | Skier |
| Osoblje skijališta | `osoblje` | `test` | Staff |
| Osoblje skijališta | `osoblje2` | `test` | Staff |
| Dodatni skijaš | `mobile2` | `test` | Skier |
| Dodatni skijaš | `mobile3` | `test` | Skier |

Dodatno postoje demo skijaši `mobile4`-`mobile7` (lozinka `test`) sa bogatijom historijom
narudžbi, karata i recenzija - radi realističnijeg prikaza pri prezentaciji.

**Prijava:**

```bash
curl -X POST http://localhost:5000/api/Auth/login -H "Content-Type: application/json" -d "{\"username\":\"desktop\",\"password\":\"test\"}"
```

Dobiveni `accessToken` se šalje kao `Authorization: Bearer <token>` zaglavlje.

---

## Pregled API endpointa

Svaki list endpoint je **obavezno straničen** (`page`, `pageSize` - maksimalno 100)
i podržava **najmanje jedan parametar pretrage**, uz sortiranje (`sortBy`, `sortDescending`).

### Autentifikacija

| Metoda | Ruta | Pristup |
|---|---|---|
| `POST` | `/api/Auth/login` | anoniman |
| `POST` | `/api/Auth/register` | anoniman |
| `GET` | `/api/Auth/me` | prijavljen |
| `PUT` | `/api/Auth/me` | prijavljen |
| `POST` | `/api/Auth/change-password` | prijavljen |
| `POST` | `/api/Auth/forgot-password` | anoniman |
| `POST` | `/api/Auth/reset-password` | anoniman |
| `POST` | `/api/Auth/logout` | prijavljen |

Kod za reset lozinke generiše ASP.NET Identity token provider, vrijedi jedan sat i
nigdje se ne čuva u čitljivom obliku. Slanje koda e-mailom preuzima pomoćni servis
u narednoj fazi; u razvojnom okruženju API vraća kod u odgovoru kako bi tok bio
testabilan bez e-mail servisa.

### Referentni podaci (CRUD)

`/api/Countries`, `/api/Cities`, `/api/TrailDifficulties`, `/api/LiftTypes`,
`/api/IncidentTypes`, `/api/BenefitCategories`, `/api/AnnouncementCategories`,
`/api/PaymentMethods`

Svaki od njih nudi `GET` (pretraga), `GET /lookup` (padajuće liste), `GET /{id}`,
`POST`, `PUT /{id}`, `DELETE /{id}`. Čitanje je dostupno svim prijavljenim korisnicima,
a izmjene isključivo administratoru. Dodatno, `/api/Enums` izlaže enumeracije sistema
(statusi, tipovi) za punjenje padajućih lista na klijentima.

### Glavni entiteti

| Resurs | Ruta | Posebne operacije |
|---|---|---|
| Korisnici | `/api/Users` | samo administrator |
| Skijališta | `/api/SkiResorts` | `GET /{id}/weather/latest` |
| Staze | `/api/Trails` | `PATCH /{id}/status`, `GET /{id}/conditions` |
| Stanje staza | `/api/trail-conditions` | |
| Ski liftovi | `/api/SkiLifts` | `PATCH /{id}/status`, `GET /{id}/maintenance` |
| Kvarovi liftova | `/api/lift-maintenance` | `PATCH /{id}/status` |
| Tipovi karata | `/api/ticket-types` | |
| Narudžbe | `/api/Orders` | `PATCH /{id}/status`, `GET /{id}/tickets` |
| Karte | `/api/Tickets` | `POST /validate` (QR), `GET /validations` |
| Plaćanja | `/api/Payments` | `POST /{id}/confirm` (ručno, osoblje), `POST /{id}/refund`, `POST /webhook/stripe` (anonimno, potpis se provjerava unutar servisa) |
| Partneri | `/api/Partners` | |
| Pogodnosti | `/api/Benefits` | `POST /{id}/views`, `GET /views` |
| Kupljene pogodnosti | `/api/benefit-purchases` | `PATCH /{id}/status` |
| Incidenti | `/api/Incidents` | `PATCH /{id}/status` |
| Obavijesti | `/api/Announcements` | |
| Notifikacije | `/api/Notifications` | `GET /unread-count`, `PATCH /{id}/read`, `PATCH /read-all` |
| Vremenski uslovi | `/api/weather-logs` | |
| Ocjene | `/api/Reviews` | |
| Početna (mobilni) | `/api/Home/summary` | objedinjeni prikaz jednim pozivom |
| Izvještaji (desktop) | `/api/Reports/sales-by-day`, `/api/Reports/top-users` | agregatni podaci za PDF izvještaje |
| Upload slika | `/api/Files/images/{kategorija}` | validacija MIME tipa i magic bytes |

Zdravlje servisa: `GET /health` (dostupno anonimno).

---

## Implementirana pravila

**Autentifikacija i autorizacija**
- JWT sa validacijom potpisa; svi endpointi zahtijevaju autentifikaciju osim `login` i `register`.
- Role-based autorizacija (`Skier`, `Staff`, `Admin`); nazivi rola u seed podacima
  odgovaraju nazivima u `[Authorize(Roles = ...)]` atributima.
- `userId` se za operacije nad vlastitim podacima uvijek čita iz tokena, nikada iz rute ili tijela zahtjeva.
- Register endpoint ne prihvata rolu od klijenta - novi korisnik uvijek dobija rolu `Skier`.
- Odjava i promjena lozinke rotiraju sigurnosni pečat, čime se token stvarno invalidira na serveru.

**Poslovna logika**
- Centralizovana state machine logika u `Domain/Rules/` za narudžbe, karte, incidente i kvarove liftova.
- Cijene se u potpunosti računaju na serveru iz važećeg cjenovnika - klijent nikada ne šalje iznos.
- Plaćanje se finalizira serverski i idempotentno je (Stripe webhook, ne klijent); povrat se
  računa iz stvarno naplaćenog iznosa i stvarno se izvršava kod Stripe-a.
- Otkazivanje i odbijanje zahtijevaju razlog, uz audit trag (ko je promijenio status i kada)
  i notifikaciju korisniku.
- Soft delete uz provjeru povezanih zapisa i jasnu poruku zašto brisanje nije moguće.

**Kvalitet implementacije**
- `async/await` kroz cijeli stack, bez `.Result` i `.Wait()`.
- Sva vremena u UTC-u.
- Custom izuzeci (`NotFoundException`, `BusinessException`, `ValidationException`,
  `ForbiddenAccessException`, `ReferencedEntityException`) mapirani middleware-om na HTTP statuse.
- Klijentu se ne izlažu stack trace ni interni detalji; greške se logiraju serverski uz `TraceId`.
- Serverska validacija sa porukama koje eksplicitno navode format i ograničenja unosa.
- Enumeracije umjesto magic numbera, statička klasa `Roles` umjesto magic stringova.
- QR kodovi i brojevi narudžbi generišu se preko `RandomNumberGenerator`.
- Lookup liste referentnih podataka keširane preko `IMemoryCache`, uz invalidaciju pri izmjeni.
- Svi servisi koji koriste `DbContext` registrovani su kao `Scoped`.
- Višestruki `SaveChangesAsync` pozivi unutar jedne operacije obuhvaćeni su eksplicitnom transakcijom.

**Konfiguracija**
- Sve tajne isključivo u `.env`; `appsettings.json` ne sadrži nijednu tajnu.
- Konekcijski string se sastavlja na jednom mjestu iz pojedinačnih `.env` vrijednosti.
- CORS se konfiguriše jednom, sa eksplicitno navedenim dozvoljenim adresama.
- Docker image tagovi su eksplicitno verzionisani.
