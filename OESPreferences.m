#import "OESPreferences.h"

#define preferenceFile @"/var/mobile/Library/Preferences/com.orangebananaspy.organicemojiscrubber.plist"
#define preferenceID @"com.orangebananaspy.organicemojiscrubber"

static NSString * const kEnabled = @"_Enabled";
static NSString * const kDuration = @"_Duration";
static NSString * const kDamping = @"_Damping";
static NSString * const kVelocity = @"_Velocity";

@interface _CFXPreferences : NSObject
+ (id)copyDefaultPreferences;
- (CFArrayRef)copyKeyListForIdentifier:(CFStringRef)arg1 user:(CFStringRef)arg2 host:(CFStringRef)arg3 container:(CFStringRef)arg4;
- (CFDictionaryRef)copyValuesForKeys:(CFArrayRef)arg1 identifier:(CFStringRef)arg2 user:(CFStringRef)arg3 host:(CFStringRef)arg4 container:(CFStringRef)arg5;
- (void)flushCachesForAppIdentifier:(CFStringRef)arg1 user:(CFStringRef)arg2;
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

// force cfprefsd to write preference to file and update the values of the cache
+ (void)flushPreferences {
  Class prefsClass = NSClassFromString(@"_CFXPreferences");
  if (prefsClass) {
    _CFXPreferences *prefs = (_CFXPreferences *)[prefsClass copyDefaultPreferences];
    [prefs flushCachesForAppIdentifier:(__bridge CFStringRef)preferenceID user:kCFPreferencesCurrentUser];
  }
}

- (instancetype)init {
  self = [super init];
  if(self) {
    // release all local variables when done
    // for this tweak its not needed but its a good example as it is very useful
    // for big tweaks where preferences can get big
    @autoreleasepool {
      Class prefsClass = NSClassFromString(@"_CFXPreferences");
      if (prefsClass) {
        // get the default preferences
        _CFXPreferences *prefs = (_CFXPreferences *)[prefsClass copyDefaultPreferences];
        CFStringRef prefID = (__bridge CFStringRef)preferenceID; // pref ID
        CFStringRef container = (__bridge CFStringRef)@"/User"; // container for prefs

        // array will be released outside of this autoreleasepool
        // copy the list of keys in prefs
        CFArrayRef prefKeys = [prefs copyKeyListForIdentifier:prefID user:kCFPreferencesCurrentUser host:kCFPreferencesCurrentHost container:container];

        // if keys exist and is greater than 0 then copy the key-value pairs as a dictionary
        if (prefKeys && CFArrayGetCount(prefKeys) > 0) {
          preferences = (__bridge NSDictionary *)[prefs copyValuesForKeys:prefKeys identifier:prefID user:kCFPreferencesCurrentUser host:kCFPreferencesCurrentHost container:container];
        }
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
