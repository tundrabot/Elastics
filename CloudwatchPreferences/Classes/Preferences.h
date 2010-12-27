//
//  PreferenceKeys.h
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 26/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

enum PreferencesAWSRegionEnum {
	kPreferencesAWSUSEastRegion,
	kPreferencesAWSUSWestRegion,
	kPreferencesAWSEURegion,
	kPreferencesAWSAsiaPacificRegion,
};

extern NSString *const kPreferencesDidChangeNotification;

extern NSString *const kPreferencesAWSAccessKeyIdKey;
extern NSString *const kPreferencesAWSSecretAccessKeyKey;
extern NSString *const kPreferencesAWSRegionKey;
extern NSString *const kPreferencesRefreshIntervalKey;
extern NSString *const kPreferencesRefreshOnMenuOpenKey;

