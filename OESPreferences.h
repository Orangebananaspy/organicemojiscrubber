#ifndef OESPreferences_h
#define OESPreferences_h

// a preference class provides a cleaner interface
// which doesn't clutter your tweak
@interface OESPreferences : NSObject
+ (instancetype)sharedInstance;
- (void)flushPreferences;
- (NSDictionary *)defaults;
- (BOOL)isEnabled;
- (CGFloat)duration;
- (CGFloat)damping;
- (CGFloat)velocity;
@end

#endif /* OESPreferences_h */
