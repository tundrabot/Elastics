//
//  Keychain.h
//  CloudwatchPreferences
//
//  Created by Dmitri Goutnik on 07/01/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

@interface Keychain : NSObject {
	NSString	*_awsAccessKeyId;
	NSString	*_awsSecretAccessKey;
}

@property (nonatomic, copy) NSString *awsAccessKeyId;
@property (nonatomic, copy) NSString *awsSecretAccessKey;

@end
