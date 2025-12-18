# FlightBooking (SwiftUI + MVVM + SwiftData)

Student iOS app for searching flights and managing bookings, integrated with a Swagger-defined backend (multi-service).  
UI is built with **SwiftUI**, architecture is **MVVM + UseCases + Repositories**, local persistence via **SwiftData** (cache/history).


## Features

- **Flight search** with pagination (`Load more`)
- **Offer details** + **price-check** before booking
- **Booking flow**
  - Create **draft** booking
  - Create **payment intent**
  - **Confirm** booking
  - **Cancel** booking
- **My Trips**
  - List bookings from server
  - Booking details (passengers/contact/status)
- **Locations autocomplete** for From/To inputs
- UX handling for expired offers: **“Offer expired”** on `404/409`


## Tech Stack

- SwiftUI
- MVVM (View ↔ ViewModel)
- Domain layer (UseCases, Models)
- Data layer (Repositories, DTO, Networking)
- SwiftData (offline cache + search history)
- Guest identity bootstrap (Bearer token + `X-Device-Id`)
- Robust networking:
  - `X-Trace-Id`
  - `Idempotency-Key` for write operations
  - fractional-seconds ISO8601 date decoding support


## Backend / API Services

Swagger uses **4 services** (localhost ports):

- **Identity**: `http://localhost:8081`
- **Catalog (Locations)**: `http://localhost:8082`
- **Offers/Flights**: `http://localhost:8083`
- **Booking/Payments**: `http://localhost:8084`

The app auto-attaches identity for booking/payments via:
- `Authorization: Bearer <token>` (guest token)
- `X-Device-Id: <stable-device-id>`
- `Idempotency-Key` for POST/PUT/PATCH/DELETE

> Note: On **Simulator**, `localhost` works as expected.  
> On a physical device, you must replace `localhost` with your Mac’s LAN IP.


## Getting Started

### 1) Requirements
- Xcode (recommended: latest stable)
- iOS Simulator
- Backend services running on ports **8081–8084**

*Note: you can find backend project [here](https://github.com/wlwlaa/FlightBackend)*

### 2) Run backend
Start your [backend services](https://github.com/wlwlaa/FlightBackend) so these endpoints are reachable:
- `POST /v1/auth/guest` (8081)
- `GET /v1/locations/autocomplete` (8082)
- `POST /v1/flights/search`, `GET /v1/flights/search` (8083)
- `POST /v1/bookings`, `GET /v1/bookings`, `POST /v1/payments/intent`, `POST /v1/bookings/{id}/confirm`, `POST /v1/bookings/{id}/cancel` (8084)

### 3) Allow HTTP (ATS) for localhost
Because backend runs on `http://localhost:*`, add this to **Info.plist**:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSIncludesSubdomains</key>
      <true/>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

### 4) Open & Run
-	Open the Xcode project/workspace
-	Select an iOS Simulator
-	Run


### Configuration

Base URLs are configured in App/DI/AppContainer.swift inside AppConfig:
-	identityBaseURL
-	catalogBaseURL
-	offersBaseURL
-	bookingBaseURL


### User Flows to Demo (Checklist)
1.	**Search:** enter route (HEL → BCN), pick dates, search
2.	**Results pagination:** tap Load more
3.	**Offer details:** open an offer, view baggage/rules
4.	**Book:**
    -	tap Book → price-check runs
    -	fill contact + passengers (document number required)
    -	create draft
5.	**Pay & Confirm**
6.	**Trips:**
    -	booking appears in list
    -	open Trip Details
7.	**Cancel booking**
8.	**Offer expired:**
	-	if backend returns 404/409 on details/price-check, UI shows “Offer expired”

## Project Structure (High-level)
```
App/
  DI/ (AppContainer)
  Navigation/ (Router)
Core/
  Network/ (APIClient, IdentityAware client, errors, coders)
  Identity/ (Guest auth, device id)
Domain/
  Models/
  Repositories/ (protocols)
  UseCases/
Data/
  Remote/ (API + DTO)
  Repositories/ (remote implementations)
  Local/ (SwiftData models + cache/history)
Features/
  Search/
  Results/
  OfferDetails/
  Booking/
  Trips/
```

## Notes / Troubleshooting

### “Decode failed… missing”

Usually means server returns a JSON shape that differs from DTO expectations.
-	The app is tolerant to missing validUntil in booking offers (defaults to .distantFuture)
-	ISO8601 dates with fractional seconds are supported in JSONDecoder.iso8601

### Simulator vs Device
-	Simulator: http://localhost:808x works
-	Device: replace localhost with your Mac IP and update ATS exceptions accordingly

### Idempotency

Write endpoints send Idempotency-Key automatically to avoid duplicate operations.


## License

[MIT licence.](https://github.com/wlwlaa/FlightBooking/blob/main/LICENSE)


