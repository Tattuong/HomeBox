# HomeBox

**Quản lý toàn bộ ngôi nhà** — Smart home management app for Android & iOS.

## Application ID

- Android: `com.homeboxmng.homebox`
- iOS: `com.homeboxmng.homebox`

## Features

- **Lưu** — Track stored items
- **Nội thất** — Furniture inventory
- **Thiết bị điện** — Smart devices with controls
- **Hóa đơn** — Bill tracking & reminders
- **Bảo hành** — Warranty expiry tracking
- **Hướng dẫn PDF** — Store & open PDF manuals
- **Chi phí sửa chữa** — Repair cost tracking
- **Room images** — Living room, bedroom, bathroom, kitchen
- **Shop & Stars** — Earn stars or buy via Google Play
- **Themes, skins, backgrounds** — Unlock with stars

## IAP Products

See `iap_config/GOOGLE_PLAY_PRODUCTS.md`

Remote config: `https://api2.blwsmartware.net/R233.json`

## Build

```bash
flutter pub get
flutter build appbundle --release
```
