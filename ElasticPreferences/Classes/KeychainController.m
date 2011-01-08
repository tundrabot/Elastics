//
//  KeychainController.m
//  ElasticPreferences
//
//  Created by Dmitri Goutnik on 08/01/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

#import "KeychainController.h"
#import "Keychain.h"

@interface KeychainController ()
- (void)_getAwsCredentials;
@end

@implementation KeychainController

@synthesize awsAccessKeyId = _awsAccessKeyId;
@synthesize awsSecretAccessKey = _awsSecretAccessKey;

- (void)_getAwsCredentials
{
	GetAWSCredentials(&_awsAccessKeyId, &_awsSecretAccessKey);
}

- (void)dealloc
{
	TBRelease(_awsAccessKeyId);
	TBRelease(_awsSecretAccessKey);
	[super dealloc];
}

- (void)synchronize
{
	SetAWSCredentials(_awsAccessKeyId, _awsSecretAccessKey);
}

- (NSString *)awsAccessKeyId
{
	if (_awsAccessKeyId == nil)
		[self _getAwsCredentials];

	TBTrace(@"%@", _awsAccessKeyId);
	return _awsAccessKeyId;
}

- (NSString *)awsSecretAccessKey
{
	if (_awsSecretAccessKey == nil)
		[self _getAwsCredentials];
	
	TBTrace(@"%@", _awsSecretAccessKey);
	return _awsSecretAccessKey;
}

@end
