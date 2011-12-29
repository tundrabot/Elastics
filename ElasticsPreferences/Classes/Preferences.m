//
//  Preferences.m
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import "Preferences.h"
#import "AWSConstants.h"

// Distributed notification sent when preferences are changed
NSString *const kPreferencesDidChangeNotification       = @"com.tundrabot.Elastics.PreferencesDidChangeNotification";

// Distributed notification sent when main application terminates
NSString *const kPreferencesShouldTerminateNotification = @"com.tundrabot.Elastics.PreferencesShouldTerminateNotification";

// Preference dictionary keys
static NSString *const kPreferencesAccountIdKey                 = @"accountId";
static NSString *const kPreferencesAWSRegionKey                 = @"awsRegion";
static NSString *const kPreferencesRefreshIntervalKey           = @"refreshInterval";
static NSString *const kPreferencesRefreshOnMenuOpenKey         = @"refreshOnMenuOpen";
static NSString *const kPreferencesSortInstancesByTitleKey      = @"sortInstancesByTitle";
static NSString *const kPreferencesHideTerminatedInstancesKey	= @"hideTerminatedInstances";
static NSString *const kPreferencesSshPrivateKeyFileKey         = @"sshPrivateKeyFile";
static NSString *const kPreferencesSshUserNameKey               = @"sshUserName";
static NSString *const kPreferencesTerminalApplicationKey       = @"terminalApplication";
static NSString *const kPreferencesOpenInTerminalTabKey         = @"openInTerminalTab";
static NSString *const kPreferencesRdpApplicationKey            = @"rdpApplication";

static NSString *const kPreferencesFirstLaunchKey               = @"firstLaunch";

@implementation NSUserDefaults (ElasticsPreferences)

@dynamic awsRegion;
@dynamic refreshInterval;
@dynamic refreshOnMenuOpen;
@dynamic sshPrivateKeyFile;
@dynamic sshUserName;
@dynamic firstLaunch;

- (NSDictionary *)defaultElasticsPreferences
{
    static NSDictionary *s_defaults;
    
	if (!s_defaults) {
		s_defaults = [[NSDictionary alloc]
					 initWithObjectsAndKeys:
						[NSNumber numberWithInt:kPreferencesAWSUSEastRegion], kPreferencesAWSRegionKey,
						[NSNumber numberWithFloat:180], kPreferencesRefreshIntervalKey,
						[NSNumber numberWithBool:YES], kPreferencesRefreshOnMenuOpenKey,
						[NSNumber numberWithBool:NO], kPreferencesSortInstancesByTitleKey,
                        [NSNumber numberWithBool:NO], kPreferencesHideTerminatedInstancesKey,
						@"root", kPreferencesSshUserNameKey,
						[NSNumber numberWithBool:YES], kPreferencesFirstLaunchKey,
						nil];
	}
	return s_defaults;
}

- (NSInteger)accountId
{
	return [self integerForKey:kPreferencesAccountIdKey];
}

- (void)setAccountId:(NSInteger)value
{
	[self setInteger:value forKey:kPreferencesAccountIdKey];
}

- (NSInteger)region
{
	return [self integerForKey:kPreferencesAWSRegionKey];
}

- (void)setRegion:(NSInteger)region
{
	[self setInteger:region forKey:kPreferencesAWSRegionKey];
}

- (NSString *)awsRegion
{
	switch ([self integerForKey:kPreferencesAWSRegionKey]) {
		case kPreferencesAWSUSEastRegion:
			return kAWSUSEastRegion;
		case kPreferencesAWSUSWestNorthCaliforniaRegion:
			return kAWSUSWestNorthCaliforniaRegion;
		case kPreferencesAWSUSWestOregonRegion:
			return kAWSUSWestOregonRegion;
		case kPreferencesAWSEURegion:
			return kAWSEURegion;
		case kPreferencesAWSAsiaPacificSingaporeRegion:
			return kAWSAsiaPacificSingaporeRegion;
		case kPreferencesAWSAsiaPacificJapanRegion:
			return kAWSAsiaPacificJapanRegion;
		case kPreferencesAWSSouthAmericaSaoPauloRegion:
			return kAWSSouthAmericaSaoPauloRegion;
		default:
			return nil;
	}
}

//- (void)setAwsRegion:(NSString *)value
//{
//	NSInteger region = kPreferencesAWSUSEastRegion;
//	
//	if ([value isEqualToString:kAWSUSEastRegion])
//		region = kPreferencesAWSUSEastRegion;
//	else if ([value isEqualToString:kAWSUSWestRegion])
//		region = kPreferencesAWSUSWestRegion;
//	else if ([value isEqualToString:kAWSEURegion])
//		region = kPreferencesAWSEURegion;
//	else if ([value isEqualToString:kAWSAsiaPacificSingaporeRegion])
//		region = kPreferencesAWSAsiaPacificSingaporeRegion;
//	
//	[self setInteger:region forKey:kPreferencesAWSRegionKey];
//}

- (NSInteger)refreshInterval
{
	return [self integerForKey:kPreferencesRefreshIntervalKey];
}

- (void)setRefreshInterval:(NSInteger)value
{
	[self setInteger:value forKey:kPreferencesRefreshIntervalKey];
}

- (BOOL)isRefreshOnMenuOpen
{
	return [self boolForKey:kPreferencesRefreshOnMenuOpenKey];
}

- (void)setRefreshOnMenuOpen:(BOOL)value
{
	[self setBool:value forKey:kPreferencesRefreshOnMenuOpenKey];
}

- (BOOL)isSortInstancesByTitle
{
	return [self boolForKey:kPreferencesSortInstancesByTitleKey];
}

- (void)setSortInstancesByTitle:(BOOL)value
{
	[self setBool:value forKey:kPreferencesSortInstancesByTitleKey];
}

- (BOOL)isHideTerminatedInstances
{
	return [self boolForKey:kPreferencesHideTerminatedInstancesKey];
}

- (void)setHideTerminatedInstances:(BOOL)value
{
	[self setBool:value forKey:kPreferencesHideTerminatedInstancesKey];
}

- (NSString *)sshPrivateKeyFile
{
	return [self stringForKey:kPreferencesSshPrivateKeyFileKey];
}

- (void)setSshPrivateKeyFile:(NSString *)value
{
	[self setObject:value forKey:kPreferencesSshPrivateKeyFileKey];
}

- (NSString *)sshUserName
{
	return [self stringForKey:kPreferencesSshUserNameKey];
}

- (void)setSshUserName:(NSString *)value
{
	[self setObject:value forKey:kPreferencesSshUserNameKey];
}

- (NSInteger)terminalApplication
{
	return [self integerForKey:kPreferencesTerminalApplicationKey];
}

- (void)setTerminalApplication:(NSInteger)value
{
	[self setInteger:value forKey:kPreferencesTerminalApplicationKey];
}

- (BOOL)isOpenInTerminalTab
{
	return [self boolForKey:kPreferencesOpenInTerminalTabKey];
}

- (void)setOpenInTerminalTab:(BOOL)value
{
	[self setBool:value forKey:kPreferencesOpenInTerminalTabKey];
}

- (NSInteger)rdpApplication
{
	return [self integerForKey:kPreferencesRdpApplicationKey];
}

- (void)setRdpApplication:(NSInteger)value
{
	[self setInteger:value forKey:kPreferencesRdpApplicationKey];
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
