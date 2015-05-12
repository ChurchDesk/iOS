# SHPUIInjection

###Setup

Import header in `AppDelegate`.

```
#import "SHPUIInjection.h"
```

Put this in your `application:didFinishLaunchingWithOptions:`.

```
#if TARGET_IPHONE_SIMULATOR
  [SHPUIInjection enable]
#endif
````
