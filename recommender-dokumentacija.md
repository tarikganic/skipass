# Sistem preporuke - dokumentacija

Modul preporuke predlaže korisniku pogodnosti (`Benefits`) koje bi mu mogle biti zanimljive,
na osnovu njegove stvarne aktivnosti u aplikaciji. Pristup je **hibridni**: content-based
preporuka na osnovu ličnih signala korisnika, sa **popularity-based** rezervnim prikazom
(fallback) kada za korisnika još nema dovoljno signala.

## Gdje se nalazi u kodu

| Sloj | Fajl |
|---|---|
| Algoritam | `backend/src/SkiPass.Infrastructure/Services/RecommenderService.cs` |
| Ugovor servisa | `backend/src/SkiPass.Application/Services/Interfaces/IDomainServices.cs` (`IRecommenderService`) |
| DTO / kodovi razloga | `backend/src/SkiPass.Application/DTOs/Recommendations/RecommendationDtos.cs` |
| API endpoint | `backend/src/SkiPass.API/Controllers/RecommendationsController.cs` - `GET /api/Recommendations/benefits?take=` |
| Prikaz u aplikaciji | `mobile/skipass_mobile/lib/screens/home/home_screen.dart` (sekcija "Izdvojene pogodnosti" na Početnoj) |

## Signali koji ulaze u preporuku

Signali se stvarno upisuju u bazu tokom koristenja aplikacije - ništa se ne simulira:

- **`BenefitPurchases`** - koje je kategorije pogodnosti korisnik do sada stvarno kupovao.
- **`BenefitViews`** - koje je kategorije pogodnosti korisnik pregledao, i koliko dugo
  (`DurationSeconds`) - duže gledanje i veći broj pregleda povećavaju znacaj kategorije.
- Partneri (`Partner`) čije je usluge korisnik već kupio ili pregledao.
- Brend (`Brand`) opreme koji korisnik najčešće bira, izveden iz kupovina i pregleda.

## Algoritam (content-based dio)

Za svakog korisnika se izdvoje najviše tri kategorije iz kupovina i najviše tri iz pregleda
(`MaxSignalCategories = 3`), zatim najčešće korišteni partner(i) i preferirani brend. Svaka
aktivna pogodnost koju korisnik još nije kupio dobija bodovni skor (`Score`) sabiranjem
težina za svaki signal koji se poklapa:

| Signal | Težina |
|---|---|
| Kategorija koju je korisnik već kupovao | 3 |
| Kategorija koju je korisnik samo pregledao (bez kupovine) | 2 |
| Partner koji je korisnik već koristio | 2 |
| Preferirani brend korisnika | 2 |

Kategorija se boduje samo jednom po pogodnosti (kupovina ima prednost nad pregledom za istu
kategoriju), dok se partner i brend boduju nezavisno i mogu se sabrati sa kategorijom.
Pogodnosti se potom sortiraju opadajuće po `Score`, a pri izjednačenju po prosječnoj ocjeni
(`AverageRating`).

## Popularity-based fallback

Ako korisnik nema nijedan signal (novi korisnik, ili nijedna dostupna pogodnost se ne
poklapa ni sa jednim signalom), vraćaju se najbolje ocijenjene aktivne pogodnosti
(`AverageRating`, pa `RatingCount`), uz kod razloga `PopularFallback`. `AverageRating` i
`RatingCount` se ne prikupljaju a zatim ignorišu - stvarno se koriste za rangiranje u ovoj
grani algoritma i realno se preračunavaju iz `Reviews` tabele
(`SkiPassTicketService`/seed `RecalculateBenefitRatingsAsync`) nakon svake nove recenzije.

## Objašnjive preporuke

Svaka preporučena pogodnost nosi listu `Reasons` (`RecommendationReasonDto`) - kod razloga i
prateći podatak (naziv kategorije, partnera ili brenda) za svaki signal koji je doprinio
skoru. Mobilna aplikacija ovo prevodi u čitljivu rečenicu ispod pogodnosti na Početnoj
(`home_screen.dart`, `_reasonText`), npr. "Jer ste kupovali u kategoriji Iznajmljivanje
opreme" - korisnik uvijek vidi zašto mu je nešto konkretno predloženo, nikad samo listu bez
objašnjenja.

## Primjer odgovora API-ja

```json
[
  {
    "id": 4,
    "name": "Iznajmljivanje kacige",
    "benefitCategoryName": "Iznajmljivanje opreme",
    "score": 5,
    "reasons": [
      { "code": "PurchasedCategory", "categoryName": "Iznajmljivanje opreme" },
      { "code": "UsedPartner", "partnerName": "Alpina Sport" }
    ]
  }
]
```
