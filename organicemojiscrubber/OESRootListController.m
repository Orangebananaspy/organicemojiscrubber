#import "OESRootListController.h"
#import "NSTask.h"
#import "../OESPreferences.h"

static NSString * const kDuration = @"_Duration";
static NSString * const kDamping = @"_Damping";
static NSString * const kVelocity = @"_Velocity";

@implementation OESRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"OESRoot" target:self];
	}

	return _specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	// this is a personal preference but I don't like the blue highlight in buttons
	// so I turn them to black
	if (cell.type == PSButtonCell) {
		cell.titleLabel.textColor = [UIColor blackColor];
	}

	return cell;
}

- (void)restoreToDefaults {
	// here is something neat because the tweak hooks into the UIKit/UIKitCore
	// it is loaded into Preferences as well, so we can actually use the classes
	// we packed in them like Preferences, and because of the sharedInstances we
	// don't waste memory allocating a new one. For a tweak as small as this
	// using something like this is absolutely trivial and an overkill at its best
	Class preferenceClass = NSClassFromString(@"OESPreferences");
	if (preferenceClass) { // make sure we have the class otherwise a crash will occur
		NSDictionary *defaultPrefs = [[preferenceClass sharedInstance] defaults];

		PSSpecifier *durationSpec = [self specifierForID:kDuration];
		PSSpecifier *dampingSpec = [self specifierForID:kDamping];
		PSSpecifier *velocitySpec = [self specifierForID:kVelocity];

		[self setPreferenceValue:defaultPrefs[kDuration] specifier:durationSpec];
		[self setPreferenceValue:defaultPrefs[kDamping] specifier:dampingSpec];
		[self setPreferenceValue:defaultPrefs[kVelocity] specifier:velocitySpec];

		[self reloadSpecifiers];
	}
}

// respring is better to reload prefs as it doesn't allow
// for a build up of tweaks memory while user tinkers with the settings
// and post notifications are sent to reload the preferences
// for this tweak it doesn't matter but more so for tweaks like NudeKeys
// where images and big files are loaded
- (void)respring {
	// it is cleaner than using posix or
	// calling a function within the tweak
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/bin/killall"];
	[task setArguments:@[@"-9", @"SpringBoard"]];
	[task launch];
	[task waitUntilExit];
}
@end
