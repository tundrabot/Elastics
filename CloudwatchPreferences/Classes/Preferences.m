//
//  Preferences.m
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "Preferences.h"
#import "AWSConstants.h"

// Distributed notification sent when preferences are changed
NSString *const kPreferencesDidChangeNotification	= @"com.tundrabot.Cloudwatch.PreferencesDidChangeNotification";

// Preference dictionary keys
NSString *const kPreferencesAWSAccessKeyIdKey		= @"awsAccessKeyId";
NSString *const kPreferencesAWSSecretAccessKeyKey	= @"awsSecretAccessKey";
NSString *const kPreferencesAWSRegionKey			= @"awsRegion";
NSString *const kPreferencesRefreshIntervalKey		= @"refreshInterval";
NSString *const kPreferencesRefreshOnMenuOpenKey	= @"refreshOnMenuOpen";

// AWS regions as stored in prefs and selected in combo
enum {
	kPreferencesAWSUSEastRegion,
	kPreferencesAWSUSWestRegion,
	kPreferencesAWSEURegion,
	kPreferencesAWSAsiaPacificRegion,
};

static NSDictionary *_defaults;

@implementation NSUserDefaults (CloudwatchPreferences)

- (NSDictionary *)defaultCloudwatchPreferences
{
	if (!_defaults) {
		_defaults = [[NSDictionary alloc]
					 initWithObjectsAndKeys:
						// region is US East
						[NSNumber numberWithInt:kPreferencesAWSUSEastRegion], kPreferencesAWSRegionKey,
						// refresh every minute
						[NSNumber numberWithFloat:60], kPreferencesRefreshIntervalKey,
						// refresh on menu open
						[NSNumber numberWithBool:YES], kPreferencesRefreshOnMenuOpenKey,
						nil];
	}
	return _defaults;
}

- (NSString *)awsAccessKeyId
{
	return [self stringForKey:kPreferencesAWSAccessKeyIdKey];
}

- (NSString *)awsSecretAccessKey
{
	return [self stringForKey:kPreferencesAWSSecretAccessKeyKey];
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

- (NSTimeInterval)refreshInterval
{
	return (NSTimeInterval)[self integerForKey:kPreferencesRefreshIntervalKey];
}

- (BOOL)refreshOnMenuOpen
{
	return [self boolForKey:kPreferencesRefreshOnMenuOpenKey];
}

@end
