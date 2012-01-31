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
	kPreferencesAWSUSWestNorthCaliforniaRegion,
	kPreferencesAWSUSWestOregonRegion,
	kPreferencesAWSEURegion,
	kPreferencesAWSAsiaPacificSingaporeRegion,
	kPreferencesAWSAsiaPacificJapanRegion,
	kPreferencesAWSSouthAmericaSaoPauloRegion,
	kPreferencesAWSUSGovCloudRegion,
};

// Terminal application types
enum {
	kPreferencesTerminalApplicationTerminal,
	kPreferencesTerminalApplicationiTerm,
};

// RDP application types
enum {
	kPreferencesRdpApplicationCoRD,
};

@interface NSUserDefaults (ElasticsPreferences)

- (NSDictionary *)defaultElasticsPreferences;

// Selected account ID
@property (nonatomic, assign) NSInteger accountId;

// Selected region
@property (nonatomic, assign) NSInteger region;				// from the enum above
@property (nonatomic, readonly) NSString *awsRegion;		// translated as expected by AWS API

@property (nonatomic, assign) NSInteger refreshInterval;
@property (nonatomic, assign, getter=isRefreshOnMenuOpen) BOOL refreshOnMenuOpen;

@property (nonatomic, assign, getter=isSortInstancesByTitle) BOOL sortInstancesByTitle;
@property (nonatomic, assign, getter=isHideTerminatedInstances) BOOL hideTerminatedInstances;

@property (nonatomic, assign) NSArray *activeRegions;         // active regions, from the enum above
@property (nonatomic, readonly) NSArray *activeAWSRegions;    // active regions, translated as expected by AWS API
@property (nonatomic, assign, getter=isRegionUSEastActive) BOOL regionUSEastActive;
@property (nonatomic, assign, getter=isRegionUSWestNorthCaliforniaActive) BOOL regionUSWestNorthCaliforniaActive;
@property (nonatomic, assign, getter=isRegionUSWestOregonActive) BOOL regionUSWestOregonActive;
@property (nonatomic, assign, getter=isRegionEUActive) BOOL regionEUActive;
@property (nonatomic, assign, getter=isRegionAsiaPacificSingaporeActive) BOOL regionAsiaPacificSingaporeActive;
@property (nonatomic, assign, getter=isRegionAsiaPacificJapanActive) BOOL regionAsiaPacificJapanActive;
@property (nonatomic, assign, getter=isRegionSouthAmericaSaoPauloActive) BOOL regionSouthAmericaSaoPauloActive;
@property (nonatomic, assign, getter=isRegionUSGovCloudActive) BOOL regionUSGovCloudActive;

@property (nonatomic, assign) NSString *sshPrivateKeyFile;
@property (nonatomic, assign) NSString *sshUserName;
@property (nonatomic, assign) NSUInteger sshPort;

@property (nonatomic, assign) NSInteger terminalApplication;
@property (nonatomic, assign, getter=isOpenInTerminalTab) BOOL openInTerminalTab;

@property (nonatomic, assign) NSInteger rdpApplication;

@property (nonatomic, assign, getter=isFirstLaunch) BOOL firstLaunch;

@end
