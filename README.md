# Organic Emoji Scrubber
This is a simple tweak to mainly outline the most basic usages of ARC within the Theos environment while making a Cydia Tweak.

## ARC
**Automatic Reference Counting (ARC)** is simply put a feature of the clang compiler to assist developers in managing memory automatically. Previous to ARC developers had to retain, and release their initialized memory objects manually. You can read more about it on [Wikipedia](https://en.wikipedia.org/wiki/Automatic_Reference_Counting) or [iPhoneDevWiki](http://iphonedevwiki.net/index.php/Using_ARC_in_tweaks) which talks in detail about ARC with Theos.

## Code Examples
### Makefile
This will enable ARC project wide
```makefile
OrganicEmojiScrubber_CFLAGS = -fobjc-arc
```

### Tweak.xm
Sometimes within our tweaks we like to create many objects. Now some from those many objects will be only every used once for a calculation. After that you have no use for this object so instead of removing this object with all the other long-term objects when your tweak is at the end of its lifetime you can remove it right after you are done with it. This saves you time when deallocating the long-term objects and it even increases memory during the lifetime of the tweak. This technique is crucial in tweak development especially when you hook into SpringBoard or such processes that are active for the entirety of the devices lifetime until a respring or a reboot occurs. You can make use of this early freeing of objects by placing the part of the code within an `@autoreleasepool`.
```objective-c
@autoreleasepool {
  // once the object is out of scope it will be released as there are no strong pointers attached to it
  Object *obj = [[Object alloc] init];
}

Object *obj;
@autoreleasepool {
  // Object is not released as there is a strong pointer outside the scope
  obj = [[Object alloc] init];
}
```
You can read more in detail about in these articles:
- <http://www.galloway.me.uk/2012/02/a-look-under-arcs-hood-episode-3/>
- <https://imnotyourson.com/autoreleasepool-in-arc/>
