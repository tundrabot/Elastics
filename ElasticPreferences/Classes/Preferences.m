//
//  Preferences.m
//  ElasticPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "Preferences.h"
#import "AWSConstants.h"

// Distributed notification sent when preferences are changed
NSString *const kPreferencesDidChangeNotification		= @"com.tundrabot.Elastic.PreferencesDidChangeNotification";

// Distributed notification sent when main application terminates
NSString *const kPreferencesShouldTerminateNotification	= @"com.tundrabot.Elastic.PreferencesShouldTerminateNotification";

// Preference dictionary keys
NSString *const kPreferencesAWSRegionKey			= @"awsRegion";
NSString *const kPreferencesRefreshIntervalKey		= @"refreshInterval";
NSString *const kPreferencesRefreshOnMenuOpenKey	= @"refreshOnMenuOpen";
NSString *const kPreferencesFirstLaunchKey			= @"firstLaunch";

// AWS regions as stored in prefs and selected in combo
enum {
	kPreferencesAWSUSEastRegion,
	kPreferencesAWSUSWestRegion,
	kPreferencesAWSEURegion,
	kPreferencesAWSAsiaPacificRegion,
};

static NSDictionary *_defaults;

@implementation NSUserDefaults (ElasticPreferences)

@dynamic firstLaunch;

- (NSDictionary *)defaultElasticPreferences
{
	if (!_defaults) {
		_defaults = [[NSDictionary alloc]
					 initWithObjectsAndKeys:
						// region is US East
						[NSNumber numberWithInt:kPreferencesAWSUSEastRegion], kPreferencesAWSRegionKey,
						// refresh every 3 minutes
						[NSNumber numberWithFloat:180], kPreferencesRefreshIntervalKey,
						// refresh on menu open
						[NSNumber numberWithBool:YES], kPreferencesRefreshOnMenuOpenKey,
						// first launch
						[NSNumber numberWithBool:YES], kPreferencesFirstLaunchKey,
						nil];
	}
	return _defaults;
}

- (NSString *)awsRegion
{
	switch ([self integerForKey:kPreferencesAWSRegionKey]) {
		case kPreferencesAWSUSEastRegion:
			return kAWSUSEastRegion;
		case kPreferencesAWSUSWestRegion:
			return kAWSUSWestRegion;
		case kPreferencesAWSEURegion:
			return kAWSEURegion;
		case kPreferencesAWSAsiaPacificRegion:
			return kAWSAsiaPacificRegion;
		default:
			return nil;
	}
}

- (NSInteger)refreshInterval
{
	return [self integerForKey:kPreferencesRefreshIntervalKey];
}

- (BOOL)refreshOnMenuOpen
{
	return [self boolForKey:kPreferencesRefreshOnMenuOpenKey];
}

- (BOOL)isFirstLaunch
{
	return [self boolForKey:kPreferencesFirstLaunchKey];
}

- (void)setFirstLaunch:(BOOL)value
{
	[self setBool:value forKey:kPreferencesFirstLaunchKey];
}

@end
