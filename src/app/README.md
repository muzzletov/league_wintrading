# wintrading

Win trading app

### first install google api x86 atom image using the device manager

```
./emulator -avd $(./emulator -list-avds) -writable-system -no-snapshot-load
./adb root
./adb remount
./adb shell

echo "10.0.2.2        scp-service" >> /etc/hosts
```

our pod is accessible and we can make our requests now