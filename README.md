# Alarm

Compile error case due to denied permission:

If AlarmTest.xcworkspace project would not compile with embedded Pods, deintegrate them and initialize Podfile one more time.
Change directory to project's folder and enter following commands:

1. Deintegration

$ sudo gem install cocoapods-deintegrate cocoapods-clean

$ pod deintegrate

$ pod cache clean --all

$ rm Podfile


2. Integratetion

$ pod init

Type pod 'SCLAlertView' in Podfile and:

$ pod install

$ open AlarmTest.xcworkspace

