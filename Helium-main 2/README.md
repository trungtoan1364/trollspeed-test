# Helium
Status Bar Widgets for TrollStore iPhones on iOS 14+. Works on Jailbroken devices as well.

More widgets to come in future updates!

**Note:** on iOS 16+, you must enable developer mode for this to work properly.

## Building
[Theos](https://theos.dev) is required to compile the app. The SDK used is iOS 15.0, but you can use any SDK you want.
To change the SDK, go to the `Makefile` and modify the `TARGET` to your SDK version:
```
TARGET := iphone:clang:[SDK Version]:[Minimum Version]
```
Run `./ipabuild.sh` to build the ipa. The resulting tipa should be in a folder called 'build'.

## Tested Devices
- iPhone 13 Pro (iOS 15.3.1, Jailed & Jailbroken)
- iPhone X (iOS 16.1.1, Jailed & Jailbroken)
- iPhone X (iOS 16.6.1, Jailed)
- iPad 7th Generation (iOS 14.8.1, Jailed & Jailbroken)
- iPad 7th Generation (iOS 16.7.2, Jailbroken)

## Credits
- [TrollSpeed](https://github.com/Lessica/TrollSpeed) for the AssistiveTouch logic allowing this to work.
- [Cowabunga](https://github.com/leminlimez/Cowabunga) for part of the code.
- [AsakuraFuuko](https://github.com/AsakuraFuuko) for forking and updating.