# HomeBox - Google Play In-App Products

**Application ID:** `com.homeboxmng.homebox`  
**Remote Config URL:** `https://api2.blwsmartware.net/R233.json`

## Consumable Products (Star Packs)

| Product ID | Stars | Type |
|------------|-------|------|
| hb_pack_1 | 50 | Consumable |
| hb_pack_2 | 100 | Consumable |
| hb_pack_3 | 200 | Consumable |
| hb_pack_4 | 350 | Consumable |
| hb_pack_5 | 500 | Consumable |
| hb_pack_6 | 750 | Consumable |
| hb_pack_7 | 1000 | Consumable |
| hb_pack_8 | 1500 | Consumable |
| hb_pack_9 | 2200 | Consumable |
| hb_pack_10 | 3000 | Consumable |

## Non-Consumable Products

| Product ID | Description | Type |
|------------|-------------|------|
| hb_remove_ads | Remove all ads permanently | Non-consumable |

## Remote Config

When `disable=1` in R233.json:
- Google Play Billing UI is hidden
- Shop menu remains visible
- Users can still buy features with earned stars

When request fails (network/timeout):
- App uses cached config
- Billing remains available if previously enabled
