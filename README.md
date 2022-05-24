# Alarm

Compile error case:

If AlarmTest.xcworkspace project would not compile with embedded Pods, deintegrate them and init Podfile one more time.



1. Deintegration

$ sudo gem install cocoapods-deintegrate cocoapods-clean

$ pod deintegrate

$ pod cache clean --all

$ rm Podfile



2. Integratetion

$ pod init

Add pods in Podfile and:

$ pod install

$ open AlarmTest.xcworkspace

