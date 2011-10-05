//
//  Preferences.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

// Distributed notification sent when preferences are changed
extern NSString *const kPreferencesDidChangeNotification;

// Distributed notification sent when main application terminates
extern NSString *const kPreferencesShouldTerminateNotification;

// AWS regions as stored in prefs and selected in combo
enum {
	kPreferencesAWSUSEastRegion,
	kPreferencesAWSUSWestRegion,
	kPreferencesAWSEURegion,
	kPreferencesAWSAsiaPacificSingaporeRegion,
	kPreferencesAWSAsiaPacificJapanRegion,
};

enum {
	kPreferencesTerminalApplicationTerminal,
	kPreferencesTerminalApplicationiTerm,
};

enum {
	kPreferencesRdpApplicationCoRD,
};

@interface NSUserDefaults (ElasticsPreferences)

- (NSDictionary *)defaultElasticsPreferences;

@property (nonatomic, assign) NSInteger accountId;
@property (nonatomic, assign) NSInteger region;				// from the enum above
@property (nonatomic, readonly) NSString *awsRegion;		// translated as expected by AWS API
@property (nonatomic, assign) NSInteger refreshInterval;
@property (nonatomic, assign, getter=isRefreshOnMenuOpen) BOOL refreshOnMenuOpen;
@property (nonatomic, assign) NSString *sshPrivateKeyFile;
@property (nonatomic, assign) NSString *sshUserName;
@property (nonatomic, assign) NSInteger terminalApplication;
@property (nonatomic, assign, getter=isOpenInTerminalTab) BOOL openInTerminalTab;
@property (nonatomic, assign) NSInteger rdpApplication;
@property (nonatomic, assign, getter=isSortInstancesByTitle) BOOL sortInstancesByTitle;

@property (nonatomic, assign, getter=isFirstLaunch) BOOL firstLaunch;

@end
