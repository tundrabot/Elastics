//
//  Preferences.h
//  ElasticPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

// Distributed notification sent when preferences are changed
extern NSString *const kPreferencesDidChangeNotification;

// Distributed notification sent when main application terminates
extern NSString *const kPreferencesShouldTerminateNotification;

@interface NSUserDefaults (ElasticPreferences)
- (NSDictionary *)defaultElasticPreferences;

- (NSString *)awsRegion;
- (NSInteger)refreshInterval;
- (BOOL)refreshOnMenuOpen;
- (NSString *)keypairPrivateKeyFile;
- (NSString *)sshUserName;

@property (nonatomic, assign, getter=isFirstLaunch) BOOL firstLaunch;
@end
