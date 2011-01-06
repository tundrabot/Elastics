//
//  Preferences.h
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

// Distributed notification sent when preferences are changed
extern NSString *const kPreferencesDidChangeNotification;

@interface NSUserDefaults (CloudwatchPreferences)
- (NSDictionary *)defaultCloudwatchPreferences;

- (NSString *)awsAccessKeyId;
- (NSString *)awsSecretAccessKey;
- (NSString *)awsRegion;
- (NSTimeInterval)refreshInterval;
- (BOOL)refreshOnMenuOpen;
@end
