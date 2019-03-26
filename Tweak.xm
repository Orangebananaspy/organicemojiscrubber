#include <substrate.h>
#import "OESPreferences.h"

// taking advantage of the debug flag to disable logging in production
// OBSLog also gives a bit more detailed output and its easier to find
// in the console app provided with MacOSX
#ifdef DEBUG
#   define OBSLog(x, ...) NSLog(@"*** OBSLogger *** : %s %d: " x, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define OBSLog(x, ...) (void)0
#endif

// if you look at the actual header its actually UIKBKeyView but it
// doesn't matter as we only want the functionality from what is within
// the UIView API (Read more on polymorphic objects if confused)
@interface UIKeyboardEmojiCategoryBar : UIView
@property (nonatomic,retain) UIView * scrubView;
- (CGRect)categorySelectedCircleRect:(long long)arg1;
- (void)animateScrubberToRect:(CGRect)arg1;
- (void)setSelectedIndex:(unsigned long long)arg1;
// custom properties and or functions
- (void)animateScrubberWithBlock:(void (^)(void))animationBlock completion:(void (^)(BOOL))completionBlock;
@end

static OESPreferences *preferences = nil;

%group main

%hook UIKeyboardEmojiCategoryBar
- (void)updateCategoryOnBar:(unsigned long long)arg1 {
  BOOL isScrubbing = MSHookIvar<BOOL>(self, "_isScrubbing");
  if (!isScrubbing) {
    // select index so the keyboard can remember previous selected
    // category when the user comes back
    [self setSelectedIndex:arg1];

    // get the rect for the index we are on currently
    CGRect rect = [self categorySelectedCircleRect:arg1];
    [self animateScrubberWithBlock:^{
      // animate to position
      self.scrubView.frame = rect;
    } completion:nil];
  }
}

- (void)animateScrubberToRect:(CGRect)rect {
  [self animateScrubberWithBlock:^{
    // animate to rect
    self.scrubView.frame = rect;
  } completion:nil];
}

// this new function helps lessen duplicate code and also provides an easy
// to edit values in the future. This is better than changing values for
// all duplicated code that use the same values
%new
- (void)animateScrubberWithBlock:(void (^)(void))animationBlock completion:(void (^)(BOOL))completionBlock {
  // always prepare for the worst and check if parameters exist otherwise
  // a crash can occur if another tweak messes with this function
  [UIView animateWithDuration:[preferences duration] delay:0.0f
    usingSpringWithDamping:[preferences damping] initialSpringVelocity:[preferences velocity]
    options:UIViewAnimationOptionCurveEaseInOut animations:^{
    if (animationBlock) animationBlock();
  } completion:^(BOOL finished) {
    if (completionBlock) completionBlock(finished);
  }];
}
%end

%end

%ctor {
  // long-term objects will be allocated within and released when tweak
  // is at the end of its lifetime
  @autoreleasepool {
    // check if process is springboard or an application
    // this prevents our tweak from running in non-application (with UI)
    // processes and also prevents bad behaving tweaks to invoke our tweak
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    if (args.count != 0) {
      NSString *executablePath = args[0];
      if (executablePath) {
        NSString *processName = [executablePath lastPathComponent];
        BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
        BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
        if (isSpringBoard || isApplication) {
          // if no preferences then get one
          if (!preferences) {
	          preferences = [OESPreferences sharedInstance];
	        }

          // expect the worse so check if preferences exists now
          if (preferences && [preferences isEnabled]) {
            // run the main group
            %init(main);
          }
        }
      }
    }
  }
}
