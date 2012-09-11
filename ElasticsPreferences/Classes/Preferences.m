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
static NSString *const kPreferencesAccountIdKey                             = @"accountId";
static NSString *const kPreferencesAWSRegionKey                             = @"awsRegion";
static NSString *const kPreferencesRefreshIntervalKey                       = @"refreshInterval";
static NSString *const kPreferencesRefreshOnMenuOpenKey                     = @"refreshOnMenuOpen";
static NSString *const kPreferencesSortInstancesByTitleKey                  = @"sortInstancesByTitle";
static NSString *const kPreferencesHideTerminatedInstancesKey               = @"hideTerminatedInstances";
static NSString *const kPreferencesRegionUSEastActiveKey                    = @"regionUSEastActive";
static NSString *const kPreferencesRegionUSWestNorthCaliforniaActiveKey     = @"regionUSWestNorthCaliforniaActive";
static NSString *const kPreferencesRegionUSWestOregonActiveKey              = @"regionUSWestOregonActive";
static NSString *const kPreferencesRegionEUActiveKey                        = @"regionEUActive";
static NSString *const kPreferencesRegionAsiaPacificSingaporeActiveKey      = @"regionAsiaPacificSingaporeActive";
static NSString *const kPreferencesRegionAsiaPacificJapanActiveKey          = @"regionAsiaPacificJapanActive";
static NSString *const kPreferencesRegionSouthAmericaSaoPauloActiveKey      = @"regionSouthAmericaSaoPauloActive";
static NSString *const kPreferencesRegionUSGovCloudActiveKey                = @"regionUSGovCloudActive";
static NSString *const kPreferencesSshPrivateKeyFileKey                     = @"sshPrivateKeyFile";
static NSString *const kPreferencesSshUserNameKey                           = @"sshUserName";
static NSString *const kPreferencesSshPortKey                               = @"sshPort";
static NSString *const kPreferencesSshOptionsKey                            = @"sshOptions";
static NSString *const kPreferencesUsingPublicDNSKey                        = @"sshUsingPublicDNS";
static NSString *const kPreferencesTerminalApplicationKey                   = @"terminalApplication";
static NSString *const kPreferencesOpenInTerminalTabKey                     = @"openInTerminalTab";
static NSString *const kPreferencesRdpApplicationKey                        = @"rdpApplication";
static NSString *const kPreferencesFirstLaunchKey                           = @"firstLaunch";

@implementation NSUserDefaults (ElasticsPreferences)

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
                      [NSNumber numberWithBool:NO], kPreferencesUsingPublicDNSKey,
                      [NSNumber numberWithBool:YES], kPreferencesFirstLaunchKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionUSEastActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionUSWestNorthCaliforniaActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionUSWestOregonActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionEUActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionAsiaPacificSingaporeActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionAsiaPacificJapanActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionSouthAmericaSaoPauloActiveKey,
                      [NSNumber numberWithBool:YES], kPreferencesRegionUSGovCloudActiveKey,
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
	NSInteger region = [self integerForKey:kPreferencesAWSRegionKey];
    NSArray *activeRegions = self.activeRegions;
    
    // if currently selected default region was turned off, choose first active region as default
    if (![activeRegions containsObject:[NSNumber numberWithInteger:region]]) {
        region = [[activeRegions objectAtIndex:0] integerValue];
        self.region = region;
    }
    
    return region;
}

- (void)setRegion:(NSInteger)region
{
	[self setInteger:region forKey:kPreferencesAWSRegionKey];
}

- (NSString *)_awsRegionFromRegion:(NSInteger)region
{
	switch (region) {
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
		case kPreferencesAWSUSGovCloudRegion:
			return kAWSUSGovCloudRegion;
		default:
			return nil;
	}
}

- (NSString *)awsRegion
{
	return [self _awsRegionFromRegion:self.region];
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

- (NSArray *)activeRegions
{
    NSMutableArray *result = [NSMutableArray array];
    
    if (self.isRegionUSEastActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSUSEastRegion]];
    if (self.isRegionUSWestNorthCaliforniaActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSUSWestNorthCaliforniaRegion]];
    if (self.isRegionUSWestOregonActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSUSWestOregonRegion]];
    if (self.isRegionEUActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSEURegion]];
    if (self.isRegionAsiaPacificSingaporeActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSAsiaPacificSingaporeRegion]];
    if (self.isRegionAsiaPacificJapanActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSAsiaPacificJapanRegion]];
    if (self.isRegionSouthAmericaSaoPauloActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSSouthAmericaSaoPauloRegion]];
    if (self.isRegionUSGovCloudActive)
        [result addObject:[NSNumber numberWithInteger:kPreferencesAWSUSGovCloudRegion]];
    
    return result;
}

- (void)setActiveRegions:(NSArray *)value
{
    self.regionUSEastActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSUSEastRegion]];
    self.regionUSWestNorthCaliforniaActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSUSWestNorthCaliforniaRegion]];
    self.regionUSWestOregonActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSUSWestOregonRegion]];
    self.regionEUActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSEURegion]];
    self.regionAsiaPacificSingaporeActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSAsiaPacificSingaporeRegion]];
    self.regionAsiaPacificJapanActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSAsiaPacificJapanRegion]];
    self.regionSouthAmericaSaoPauloActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSSouthAmericaSaoPauloRegion]];
    self.regionUSGovCloudActive = [value containsObject:[NSNumber numberWithInteger:kPreferencesAWSUSGovCloudRegion]];
}

- (NSArray *)activeAWSRegions
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSNumber *region in self.activeRegions) {
        [result addObject:[self _awsRegionFromRegion:[region integerValue]]];
    }
    
    return result;
}

- (BOOL)isRegionUSEastActive
{
    return [self boolForKey:kPreferencesRegionUSEastActiveKey];
}

- (void)setRegionUSEastActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionUSEastActiveKey];
}

- (BOOL)isRegionUSWestNorthCaliforniaActive
{
    return [self boolForKey:kPreferencesRegionUSWestNorthCaliforniaActiveKey];
}

- (void)setRegionUSWestNorthCaliforniaActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionUSWestNorthCaliforniaActiveKey];
}

- (BOOL)isRegionUSWestOregonActive
{
    return [self boolForKey:kPreferencesRegionUSWestOregonActiveKey];
}

- (void)setRegionUSWestOregonActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionUSWestOregonActiveKey];
}

- (BOOL)isRegionEUActive
{
    return [self boolForKey:kPreferencesRegionEUActiveKey];
}

- (void)setRegionEUActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionEUActiveKey];
}

- (BOOL)isRegionAsiaPacificSingaporeActive
{
    return [self boolForKey:kPreferencesRegionAsiaPacificSingaporeActiveKey];
}

- (void)setRegionAsiaPacificSingaporeActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionAsiaPacificSingaporeActiveKey];
}

- (BOOL)isRegionAsiaPacificJapanActive
{
    return [self boolForKey:kPreferencesRegionAsiaPacificJapanActiveKey];
}

- (void)setRegionAsiaPacificJapanActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionAsiaPacificJapanActiveKey];
}

- (BOOL)isRegionSouthAmericaSaoPauloActive
{
    return [self boolForKey:kPreferencesRegionSouthAmericaSaoPauloActiveKey];
}

- (void)setRegionSouthAmericaSaoPauloActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionSouthAmericaSaoPauloActiveKey];
}

- (BOOL)isRegionUSGovCloudActive
{
    return [self boolForKey:kPreferencesRegionUSGovCloudActiveKey];
}

- (void)setRegionUSGovCloudActive:(BOOL)value
{
    [self setBool:value forKey:kPreferencesRegionUSGovCloudActiveKey];
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

- (NSUInteger)sshPort
{
    return [self integerForKey:kPreferencesSshPortKey];
}

- (void)setSshPort:(NSUInteger)value
{
    [self setInteger:value forKey:kPreferencesSshPortKey];
}

- (NSString *)sshOptions
{
    return [self stringForKey:kPreferencesSshOptionsKey];
}

- (void)setSshOptions:(NSString *)value
{
    if (![self.sshOptions isEqualToString:value])
        [self setObject:value forKey:kPreferencesSshOptionsKey];
}

- (BOOL)isUsingPublicDNS
{
	return [self boolForKey:kPreferencesUsingPublicDNSKey];
}

- (void)setUsingPublicDNS:(BOOL)value
{
	[self setBool:value forKey:kPreferencesUsingPublicDNSKey];
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
