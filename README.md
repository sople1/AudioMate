# Easy audio control for your Mac.

Control all your audio devices from the status bar, receive system notifications when relevant events happen on your audio devices and more. For more information, please visit [AudioMate's website](http://audiomateapp.com).

<img src="https://github.com/sonicbee9/AudioMate/raw/develop/Docs/AudioMate.png" class="center">

### Getting Started

(Make sure [CocoaPods](http://cocoapods.org) is installed)

```bash
$ git clone --recursive git@github.com:sonicbee9/AudioMate.git
$ pod install
```

### Keeping Dependencies Up To Date

```bash
$ git submodule sync
$ git submodule update
$ pod update
```

### Build & Run

1. Open `AMCoreAudio.xcworkspace` in Xcode 5.x (or later)
2. Hit Run (Cmd + R)

### Requirements

* Xcode 5.x (for development)
* Mac OS X 10.7 or later
* 64-bit

### External Dependencies

(Managed either with Cocoapods or git submodules)

* [AMCoreAudio](https://github.com/sonicbee9/AMCoreAudio)
* [LVDebounce](https://github.com/layervault/LVDebounce)
* [LetsMove](https://github.com/potionfactory/LetsMove)
* [StartAtLoginController](https://github.com/alexzielenski/StartAtLoginController)
* [yoursway-create-dmg](https://github.com/andreyvit/yoursway-create-dmg)

### Further Development & Patches

Do you want to contribute to the project? Please fork, patch, and then submit a pull request!

### License

AudioMate was written by Ruben Nine ([@sonicbee9](https://twitter.com/sonicbee9)) in 2012, 2013, 2014 (open-sourced in July 2014) and is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
