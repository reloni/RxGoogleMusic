# RxGoogleMusic: an unofficial API for Google Play Music

![Platform iOS|macOS](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgray.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This framework allows interacting with Google Music API using RxSwift for iOS and macOS.

```
import RxGoogleMusic

let client = GMusicClient(token: /* google api token */)

/// load first 15 radio stations
_ = client.radioStations(maxResults: 15).subscribe(onNext: { stations in
    print("Radio stations: \(stations.items)")
  })
```

See ExampleApps folder for example applications for macOS and iOS.

This framework is under development and not "production ready".
