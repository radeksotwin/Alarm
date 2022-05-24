# Alarm

If xcworkspace project would not compile with embeded Pods, deintegrate them and init Podfile one more time:

1. deintegrate

$ sudo gem install cocoapods-deintegrate cocoapods-clean
$ pod deintegrate
$ pod cache clean --all
$ rm Podfile

2. integrate

$ pod init
Add pods in Podfile and:
$ pod install

