#import "OESPreferences.h"
#include <dlfcn.h>

#define preferenceFile @"/var/mobile/Library/Preferences/com.orangebananaspy.organicemojiscrubber.plist"
#define preferenceID @"com.orangebananaspy.organicemojiscrubber"

static NSString * const kEnabled = @"_Enabled";
static NSString * const kDuration = @"_Duration";
static NSString * const kDamping = @"_Damping";
static NSString * const kVelocity = @"_Velocity";

@interface CFXPreferences : NSObject
+ (void)flushPreferencesForIdentifier:(CFStringRef)identifier error:(NSError **)error;
+ (NSDictionary *)preferenceForIdentifier:(CFStringRef)identifier error:(NSError **)error;
@end

@implementation OESPreferences {
  NSDictionary *preferences;
  NSDictionary *defaultsPrefs;
}

// so when needed it can be called from different classes
// without reloading the preferences, although this will re-init
// everytime your tweak is reloaded into a new process
+ (instancetype)sharedInstance {
  static OESPreferences *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[OESPreferences alloc] init];
  });

  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if(self) {
    // release all local variables when done
    // for this tweak its not needed but its a good example as it is very useful
    // for big tweaks where preferences can get big
    @autoreleasepool {
      // make sure to use RTLD_NOW as we want to resolve all symbols from the Library
      // before it ever returns
      void *prefsHandle = dlopen("/usr/lib/CFXPreferences.dylib", RTLD_NOW);
      if (handle) {
        Class prefsClass = NSClassFromString(@"CFXPreferences");
        if (prefsClass) {
          preferences = [prefsClass preferenceForIdentifier:(__bridge CFStringRef)preferenceID error:nil];
        }

        // important to close as eventually it will want to deallocate the library from memory
        // also it can only do that when dlclose is called as many times as dlopen
        dlclose(prefsHandle);
      }

      // preferences were not loaded so go the traditional route as a
      // backup so we still have preferences to work from
      if (!preferences) {
        // load data of the file
        NSData *data = [NSData dataWithContentsOfFile:preferenceFile];
        if(data) {
          // if data exists than serialize the plist
          preferences = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
        } else {
          // read in default values
          preferences = [self defaults];
        }
      }
    }
  }
  return self;
}

// force cfprefsd to write preference to file and update the values of the cache
- (void)flushPreferences {
  // the only reason we call dlopen is so we can safely call dlclose because dlopen
  // does not open the library again if it is already opened within the memory of the application
  // but calling dlclose does flag the library removable from memory when needed so this ensures
  // we have the library when we need it and it removes it when it wants so we don't hog the resources
  void *prefsHandle = dlopen("/usr/lib/CFXPreferences.dylib", RTLD_NOW);
  if (handle) {
    Class prefsClass = NSClassFromString(@"CFXPreferences");
    if (prefsClass) {
      [prefsClass flushPreferencesForIdentifier:(__bridge CFStringRef)preferenceID error:nil];
    }

    dlclose(prefsHandle);
  }
}

- (NSDictionary *)defaults {
  if (!defaultsPrefs) {
    defaultsPrefs = @{
      kEnabled: [NSNumber numberWithBool:NO],
      kDuration: [NSNumber numberWithFloat:1.0f],
      kDamping: [NSNumber numberWithFloat:0.8f],
      kVelocity: [NSNumber numberWithFloat:0.5f],
    };
  }

  return defaultsPrefs;
}

- (BOOL)isEnabled {
  // as always expect the worst so make sure that the value for the key exists
  // and if it does then make sure that it can be converted to a bool value
  if (preferences[kEnabled] && [preferences[kEnabled] respondsToSelector:@selector(boolValue)]) {
    return [preferences[kEnabled] boolValue];
  }

  // return no if all else fails
  return NO;
}

- (CGFloat)duration {
  if (preferences[kDuration] && [preferences[kDuration] respondsToSelector:@selector(floatValue)]) {
    return [preferences[kDuration] floatValue];
  }

  return [[self defaults][kDuration] floatValue];
}

- (CGFloat)damping {
  if (preferences[kDamping] && [preferences[kDamping] respondsToSelector:@selector(floatValue)]) {
    return [preferences[kDamping] floatValue];
  }

  return [[self defaults][kDamping] floatValue];
}

- (CGFloat)velocity {
  if (preferences[kVelocity] && [preferences[kVelocity] respondsToSelector:@selector(floatValue)]) {
    return [preferences[kVelocity] floatValue];
  }

  return [[self defaults][kVelocity] floatValue];
}
@end
