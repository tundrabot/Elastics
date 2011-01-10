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

@property (nonatomic, assign) NSString *awsRegion;
@property (nonatomic, assign) NSInteger refreshInterval;
@property (nonatomic, assign, getter=isRefreshOnMenuOpen) BOOL refreshOnMenuOpen;
@property (nonatomic, assign) NSString *keypairPrivateKeyFile;
@property (nonatomic, assign) NSString *sshUserName;

@property (nonatomic, assign, getter=isFirstLaunch) BOOL firstLaunch;
@end
