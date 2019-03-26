#import "OESPreferences.h"
#define preferenceFile @"/var/mobile/Library/Preferences/com.orangebananaspy.organicemojiscrubber.plist"
#define preferenceID @"com.orangebananaspy.organicemojiscrubber"

static NSString * const kEnabled = @"_Enabled";
static NSString * const kDuration = @"_Duration";
static NSString * const kDamping = @"_Damping";
static NSString * const kVelocity = @"_Velocity";

@interface _CFXPreferences : NSObject
+ (id)copyDefaultPreferences;
- (CFDictionaryRef)copyDictionaryForSourceWithIdentifier:(CFStringRef)arg1;
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

    // this class handles preferences
    Class prefs = NSClassFromString(@"_CFXPreferences");
    if (prefs) {
      // using this for unsandboxed apps ensures that we are up to date
      // and don't read old values from disk as defined by the issues raised by
      // cfprefsd which you can read more on at http://iphonedevwiki.net/index.php/Updating_extensions_for_iOS_8#Preference_saving
      preferences = (__bridge NSDictionary*)[(_CFXPreferences *)[prefs copyDefaultPreferences] copyDictionaryForSourceWithIdentifier:(__bridge CFStringRef)preferenceID];
    }

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
