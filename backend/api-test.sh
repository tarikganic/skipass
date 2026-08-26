#!/usr/bin/env bash
# Provjera svih endpointa koje koristi mobilna aplikacija.
BASE="http://localhost:5000"
PASS=0
FAIL=0
FAILED_LIST=""

check() {
  local name="$1"; local expected="$2"; local actual="$3"; local extra="$4"
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS+1))
    printf "  OK   %-52s %s %s\n" "$name" "$actual" "$extra"
  else
    FAIL=$((FAIL+1))
    FAILED_LIST="$FAILED_LIST\n    - $name (ocekivano $expected, dobiveno $actual)"
    printf "  FAIL %-52s %s (ocekivano %s)\n" "$name" "$actual" "$expected"
  fi
}

# vraca http kod, tijelo sprema u $BODY
req() {
  local method="$1"; local path="$2"; local data="$3"; local token="$4"
  local args=(-s -o /tmp/resp.json -w "%{http_code}" -X "$method" "$BASE$path")
  [ -n "$token" ] && args+=(-H "Authorization: Bearer $token")
  if [ -n "$data" ]; then
    args+=(-H "Content-Type: application/json" -d "$data")
  fi
  local code
  code=$(curl "${args[@]}")
  echo "$code"
}

json_field() { sed -n "s/.*\"$1\":\([0-9.]*\).*/\1/p" /tmp/resp.json | head -1; }
json_str()   { sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" /tmp/resp.json | head -1; }
total()      { sed -n 's/.*"totalCount":\([0-9]*\).*/\1/p' /tmp/resp.json | head -1; }

echo "==================================================================="
echo " AUTENTIFIKACIJA"
echo "==================================================================="
code=$(req POST /api/Auth/login '{"username":"mobile","password":"test"}')
check "POST /api/Auth/login" 200 "$code"
TOKEN=$(json_str accessToken)
USER_ID=$(json_field userId)

code=$(req POST /api/Auth/login '{"username":"mobile","password":"pogresna"}')
check "POST /api/Auth/login (pogresna lozinka -> 409)" 409 "$code"

code=$(req POST /api/Auth/login '{"username":"","password":""}')
check "POST /api/Auth/login (prazna polja -> 400)" 400 "$code"

code=$(req GET /api/Auth/me "" "$TOKEN")
check "GET  /api/Auth/me" 200 "$code" "($(json_str fullName))"

code=$(req GET /api/Auth/me "")
check "GET  /api/Auth/me (bez tokena -> 401)" 401 "$code"

code=$(req POST /api/Auth/forgot-password '{"email":"skijas@skipass.ba"}')
check "POST /api/Auth/forgot-password" 200 "$code"

code=$(req POST /api/Auth/register '{"username":"mobile","firstName":"A","lastName":"B","email":"x@y.ba","password":"test","confirmPassword":"test"}')
check "POST /api/Auth/register (zauzeto ime -> 400)" 400 "$code"

echo ""
echo "==================================================================="
echo " POCETNA STRANICA"
echo "==================================================================="
code=$(req GET /api/Home/summary "" "$TOKEN")
check "GET  /api/Home/summary" 200 "$code" "(staza: $(json_field totalTrailCount), liftova: $(json_field totalLiftCount))"
cp /tmp/resp.json /tmp/home_summary.json
RESORT_ID=$(json_field skiResortId)

code=$(req GET "/api/SkiResorts/$RESORT_ID/weather/latest" "" "$TOKEN")
check "GET  /api/SkiResorts/{id}/weather/latest" 200 "$code"

echo ""
echo "==================================================================="
echo " STAZE I LIFTOVI"
echo "==================================================================="
code=$(req GET "/api/Trails?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/Trails (stranicenje)" 200 "$code" "(ukupno: $(total))"
cp /tmp/resp.json /tmp/trails.json

code=$(req GET "/api/Trails?page=1&pageSize=20&query=Vlasic" "" "$TOKEN")
check "GET  /api/Trails?query=" 200 "$code" "(pogodaka: $(total))"

code=$(req GET "/api/Trails?page=1&pageSize=20&isOpen=true" "" "$TOKEN")
check "GET  /api/Trails?isOpen=true" 200 "$code" "(otvorenih: $(total))"

code=$(req GET "/api/Trails?page=1&pageSize=20&trailDifficultyId=1" "" "$TOKEN")
check "GET  /api/Trails?trailDifficultyId=" 200 "$code" "(plavih: $(total))"

code=$(req GET "/api/Trails?page=1&pageSize=20&sortBy=length&sortDescending=true" "" "$TOKEN")
check "GET  /api/Trails?sortBy=length" 200 "$code"

code=$(req GET "/api/Trails?page=1&pageSize=200" "" "$TOKEN")
check "GET  /api/Trails (pageSize>100 se ogranicava)" 200 "$code" "(pageSize: $(json_field pageSize))"

code=$(req GET /api/Trails/1 "" "$TOKEN")
check "GET  /api/Trails/{id}" 200 "$code"
cp /tmp/resp.json /tmp/trail_details.json

code=$(req GET /api/Trails/9999 "" "$TOKEN")
check "GET  /api/Trails/{id} (nepostojeci -> 404)" 404 "$code"

code=$(req GET "/api/Trails/1/conditions?page=1&pageSize=5" "" "$TOKEN")
check "GET  /api/Trails/{id}/conditions" 200 "$code" "(zapisa: $(total))"
cp /tmp/resp.json /tmp/trail_conditions.json

code=$(req GET "/api/SkiLifts?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/SkiLifts" 200 "$code" "(ukupno: $(total))"
cp /tmp/resp.json /tmp/lifts.json

code=$(req GET "/api/SkiLifts?page=1&pageSize=20&isOperational=false" "" "$TOKEN")
check "GET  /api/SkiLifts?isOperational=false" 200 "$code" "(van pogona: $(total))"

echo ""
echo "==================================================================="
echo " REFERENTNI PODACI (padajuce liste)"
echo "==================================================================="
for res in Cities TrailDifficulties BenefitCategories PaymentMethods IncidentTypes Trails SkiLifts; do
  code=$(req GET "/api/$res/lookup" "" "$TOKEN")
  count=$(grep -o "\"id\"" /tmp/resp.json | wc -l | tr -d " ")
  check "GET  /api/$res/lookup" 200 "$code" "(stavki: $count)"
done

echo ""
echo "==================================================================="
echo " KUPOVINA KARATA"
echo "==================================================================="
code=$(req GET "/api/ticket-types?page=1&pageSize=50&isActive=true" "" "$TOKEN")
check "GET  /api/ticket-types" 200 "$code" "(tipova: $(total))"
cp /tmp/resp.json /tmp/ticket_types.json

TOMORROW=$(date -d "+1 day" +%Y-%m-%d)
ORDER_JSON="{\"paymentMethodId\":1,\"note\":\"Test\",\"items\":[{\"ticketTypeId\":3,\"holderFirstName\":\"Lejla\",\"holderLastName\":\"Music\",\"validFrom\":\"$TOMORROW\",\"numberOfDays\":3}]}"
code=$(req POST /api/Orders "$ORDER_JSON" "$TOKEN")
check "POST /api/Orders" 201 "$code" "(iznos: $(json_field totalAmount))"
cp /tmp/resp.json /tmp/order_details.json
NEW_ORDER_ID=$(json_field skiPassOrderId)

YESTERDAY=$(date -d "-1 day" +%Y-%m-%d)
BAD_ORDER="{\"paymentMethodId\":1,\"items\":[{\"ticketTypeId\":3,\"holderFirstName\":\"A\",\"holderLastName\":\"B\",\"validFrom\":\"$YESTERDAY\",\"numberOfDays\":3}]}"
code=$(req POST /api/Orders "$BAD_ORDER" "$TOKEN")
check "POST /api/Orders (datum u proslosti -> 400)" 400 "$code"

TOO_MANY="{\"paymentMethodId\":1,\"items\":[{\"ticketTypeId\":1,\"holderFirstName\":\"A\",\"holderLastName\":\"B\",\"validFrom\":\"$TOMORROW\",\"numberOfDays\":99}]}"
code=$(req POST /api/Orders "$TOO_MANY" "$TOKEN")
check "POST /api/Orders (previse dana -> 400)" 400 "$code"

code=$(req GET "/api/Orders?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/Orders" 200 "$code" "(narudzbi: $(total))"
cp /tmp/resp.json /tmp/orders.json

code=$(req GET "/api/Orders?page=1&pageSize=20&status=Pending" "" "$TOKEN")
check "GET  /api/Orders?status=Pending" 200 "$code" "(na cekanju: $(total))"

code=$(req GET "/api/Orders/$NEW_ORDER_ID" "" "$TOKEN")
check "GET  /api/Orders/{id}" 200 "$code"

code=$(req PATCH "/api/Orders/$NEW_ORDER_ID/status" '{"status":"Cancelled","cancellationReason":"Testno otkazivanje narudzbe."}' "$TOKEN")
check "PATCH /api/Orders/{id}/status (otkazivanje)" 200 "$code" "($(json_str status))"

code=$(req PATCH "/api/Orders/$NEW_ORDER_ID/status" '{"status":"Confirmed"}' "$TOKEN")
check "PATCH /api/Orders/{id}/status (nedozvoljen prelaz -> 409)" 409 "$code"

echo ""
echo "==================================================================="
echo " KARTE"
echo "==================================================================="
code=$(req GET "/api/Tickets?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/Tickets" 200 "$code" "(karata: $(total))"
cp /tmp/resp.json /tmp/tickets.json

code=$(req GET "/api/Tickets?page=1&pageSize=20&status=Active" "" "$TOKEN")
check "GET  /api/Tickets?status=Active" 200 "$code" "(aktivnih: $(total))"

TODAY=$(date +%Y-%m-%d)
code=$(req GET "/api/Tickets?page=1&pageSize=20&validOnDate=$TODAY" "" "$TOKEN")
check "GET  /api/Tickets?validOnDate=" 200 "$code" "(vazi danas: $(total))"

echo ""
echo "==================================================================="
echo " POGODNOSTI"
echo "==================================================================="
code=$(req GET "/api/Benefits?page=1&pageSize=20&isActive=true" "" "$TOKEN")
check "GET  /api/Benefits" 200 "$code" "(pogodnosti: $(total))"
cp /tmp/resp.json /tmp/benefits.json

code=$(req GET "/api/Benefits?page=1&pageSize=20&query=skija" "" "$TOKEN")
check "GET  /api/Benefits?query=" 200 "$code" "(pogodaka: $(total))"

code=$(req GET "/api/Benefits?page=1&pageSize=20&benefitCategoryId=1" "" "$TOKEN")
check "GET  /api/Benefits?benefitCategoryId=" 200 "$code" "(u kategoriji: $(total))"

code=$(req GET "/api/Benefits?page=1&pageSize=20&sortBy=rating&sortDescending=true" "" "$TOKEN")
check "GET  /api/Benefits?sortBy=rating" 200 "$code"

code=$(req GET /api/Benefits/1 "" "$TOKEN")
check "GET  /api/Benefits/{id}" 200 "$code"
cp /tmp/resp.json /tmp/benefit_details.json

code=$(req POST /api/Benefits/1/views '{"benefitId":1,"durationSeconds":42}' "$TOKEN")
check "POST /api/Benefits/{id}/views (signal preporuke)" 200 "$code"

code=$(req GET "/api/Benefits/views?page=1&pageSize=10" "" "$TOKEN")
check "GET  /api/Benefits/views" 200 "$code" "(pregleda: $(total))"

code=$(req POST /api/benefit-purchases '{"benefitId":2,"quantity":2}' "$TOKEN")
check "POST /api/benefit-purchases" 201 "$code" "(iznos: $(json_field totalPrice))"
PURCHASE_ID=$(json_field id)

code=$(req GET "/api/benefit-purchases?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/benefit-purchases" 200 "$code" "(kupovina: $(total))"
cp /tmp/resp.json /tmp/benefit_purchases.json

code=$(req PATCH "/api/benefit-purchases/$PURCHASE_ID/status" '{"status":"Cancelled","cancellationReason":"Testno otkazivanje."}' "$TOKEN")
check "PATCH /api/benefit-purchases/{id}/status" 200 "$code" "($(json_str status))"

echo ""
echo "==================================================================="
echo " INCIDENTI"
echo "==================================================================="
INC='{"incidentTypeId":2,"description":"Testna prijava - poledica na donjem dijelu staze.","latitude":43.7107,"longitude":18.2686,"trailId":1}'
code=$(req POST /api/Incidents "$INC" "$TOKEN")
check "POST /api/Incidents" 201 "$code" "($(json_str status))"

BAD_INC='{"incidentTypeId":2,"description":"Kratko","latitude":43.7,"longitude":18.2,"trailId":1}'
code=$(req POST /api/Incidents "$BAD_INC" "$TOKEN")
check "POST /api/Incidents (prekratak opis -> 400)" 400 "$code"

NO_TARGET='{"incidentTypeId":2,"description":"Opis dovoljne duzine za validaciju.","latitude":43.7,"longitude":18.2}'
code=$(req POST /api/Incidents "$NO_TARGET" "$TOKEN")
check "POST /api/Incidents (bez staze i lifta -> 400)" 400 "$code"

code=$(req GET "/api/Incidents?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/Incidents" 200 "$code" "(prijava: $(total))"
cp /tmp/resp.json /tmp/incidents.json

code=$(req GET "/api/Incidents?page=1&pageSize=20&status=Reported" "" "$TOKEN")
check "GET  /api/Incidents?status=Reported" 200 "$code" "(prijavljenih: $(total))"

echo ""
echo "==================================================================="
echo " OBAVIJESTI I NOTIFIKACIJE"
echo "==================================================================="
code=$(req GET "/api/Announcements?page=1&pageSize=20&currentlyVisible=true" "" "$TOKEN")
check "GET  /api/Announcements?currentlyVisible=true" 200 "$code" "(obavijesti: $(total))"
cp /tmp/resp.json /tmp/announcements.json

code=$(req GET "/api/Announcements?page=1&pageSize=20&isUrgent=true&currentlyVisible=true" "" "$TOKEN")
check "GET  /api/Announcements?isUrgent=true" 200 "$code" "(hitnih: $(total))"

code=$(req GET "/api/Notifications?page=1&pageSize=20" "" "$TOKEN")
check "GET  /api/Notifications" 200 "$code" "(notifikacija: $(total))"
cp /tmp/resp.json /tmp/notifications.json
NOTIF_ID=$(json_field id)

code=$(req GET /api/Notifications/unread-count "" "$TOKEN")
check "GET  /api/Notifications/unread-count" 200 "$code" "(neprocitanih: $(json_field unreadCount))"

code=$(req PATCH "/api/Notifications/$NOTIF_ID/read" "" "$TOKEN")
check "PATCH /api/Notifications/{id}/read" 200 "$code"

code=$(req PATCH /api/Notifications/read-all "" "$TOKEN")
check "PATCH /api/Notifications/read-all" 200 "$code"

echo ""
echo "==================================================================="
echo " OCJENE"
echo "==================================================================="
code=$(req GET "/api/Reviews?page=1&pageSize=10&trailId=1" "" "$TOKEN")
check "GET  /api/Reviews?trailId=" 200 "$code" "(ocjena: $(total))"
cp /tmp/resp.json /tmp/reviews.json

# Ocjena je jedinstvena po korisniku i stavci, pa se ranija testna ocjena prvo uklanja.
req GET "/api/Reviews?page=1&pageSize=50&trailId=2&userId=$USER_ID" "" "$TOKEN" > /dev/null
OLD_REVIEW_ID=$(json_field id)
if [ -n "$OLD_REVIEW_ID" ]; then
  req DELETE "/api/Reviews/$OLD_REVIEW_ID" "" "$TOKEN" > /dev/null
fi

code=$(req POST /api/Reviews '{"targetType":"Trail","rating":4,"comment":"Testna ocjena staze.","trailId":2}' "$TOKEN")
check "POST /api/Reviews" 201 "$code"
REVIEW_ID=$(json_field id)

code=$(req POST /api/Reviews '{"targetType":"Trail","rating":5,"comment":"Duplikat.","trailId":2}' "$TOKEN")
check "POST /api/Reviews (duplikat -> 409)" 409 "$code"

code=$(req POST /api/Reviews '{"targetType":"Trail","rating":9,"trailId":3}' "$TOKEN")
check "POST /api/Reviews (ocjena van 1-5 -> 400)" 400 "$code"

code=$(req PUT "/api/Reviews/$REVIEW_ID" '{"rating":5,"comment":"Azurirana ocjena."}' "$TOKEN")
check "PUT  /api/Reviews/{id}" 200 "$code"

code=$(req DELETE "/api/Reviews/$REVIEW_ID" "" "$TOKEN")
check "DELETE /api/Reviews/{id}" 200 "$code"

echo ""
echo "==================================================================="
echo " PROFIL I SIGURNOST"
echo "==================================================================="
code=$(req PUT /api/Auth/me '{"firstName":"Lejla","lastName":"Music","email":"skijas@skipass.ba","phone":"+387 62 300 300","cityId":2}' "$TOKEN")
check "PUT  /api/Auth/me" 200 "$code"

code=$(req PUT /api/Auth/me '{"firstName":"L","lastName":"M","email":"nije-email"}' "$TOKEN")
check "PUT  /api/Auth/me (neispravan e-mail -> 400)" 400 "$code"

code=$(req GET "/api/Users?page=1&pageSize=5" "" "$TOKEN")
check "GET  /api/Users (skijas nema pravo -> 403)" 403 "$code"

code=$(req POST /api/Tickets/validate '{"qrCode":"SP-SEEDFAMILY00001","skiLiftId":1}' "$TOKEN")
check "POST /api/Tickets/validate (skijas nema pravo -> 403)" 403 "$code"

echo ""
echo "==================================================================="
echo " REZULTAT"
echo "==================================================================="
echo "  Uspjesno: $PASS"
echo "  Neuspjesno: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  printf "  Neuspjeli testovi:%b\n" "$FAILED_LIST"
  exit 1
fi
echo "  Svi endpointi koje koristi mobilna aplikacija rade ispravno."
