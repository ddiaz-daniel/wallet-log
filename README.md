# WalletLog

iPhone app that automatically logs Apple Pay payments (merchant, amount, time, location) so you can sort them into categories without exporting anything from your bank. Native SwiftUI + SwiftData, iOS 17+, no third-party dependencies, all data stays on the device.

## How it works

iOS gives apps no access to Wallet history. Instead, the Shortcuts **Transaction** personal automation (iOS 17+) fires on every tap-to-pay and provides Merchant, Amount and Card. It runs WalletLog's **Log Payment** App Intent, which adds the timestamp and GPS location, auto-categorizes the merchant and saves the expense. Changing a category in the editor teaches the app: later payments at the same merchant use your choice.

## Setup (on the iPhone)

1. Shortcuts > Automation > + > **Transaction**.
2. Select all cards and choose **Run Immediately**.
3. Add the action **WalletLog > Log Payment**.
4. Map *Merchant* to Shortcut Input > Merchant, *Amount* to Shortcut Input > Amount, *Card* to Shortcut Input > Card.
5. Set WalletLog's location permission to **Always**.

The same guide is in the app (? button on the Expenses tab).

## Build and run

```
xcodegen generate
DEVELOPER_DIR="/Users/dalen/Downloads/Xcode 2.app/Contents/Developer" xcodebuild -scheme WalletLog \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath build test
```

Install on a device: open `WalletLog.xcodeproj` in Xcode, set your Personal Team under Signing & Capabilities, run on your iPhone, then trust the developer in Settings > General > VPN & Device Management. With a free account the app must be re-installed every 7 days.

Debug builds accept the launch argument `-seedSampleData` to fill an empty store with sample expenses.

## Limitations

- Online and in-app Apple Pay purchases and refunds do not trigger the automation.
- The location is the phone's position at payment time.
- No sync: data is stored on-device only.

## Project structure

- `WalletLog/Models` - `Expense`, `Category`, `MerchantRule` (SwiftData)
- `WalletLog/Services` - `AmountParser`, `LocationService`, `Categorizer`, `MonthlySummary`, `Store`, `SampleData`
- `WalletLog/Intents` - `LogPaymentIntent` and its App Shortcut
- `WalletLog/Views` - expenses list/editor, summary, map, setup guide
- `WalletLogTests` - unit tests
- `project.yml` - XcodeGen spec (the `.xcodeproj` is generated, not committed)
