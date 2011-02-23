//
//  KeychainController.h
//  ElasticsPreferences
//
//  Created by Dmitri Goutnik on 08/01/2011.
//  Copyright 2011 Tundra Bot. All rights reserved.
//

@interface KeychainController : NSObject {
	NSString	*_awsAccessKeyId;
	NSString	*_awsSecretAccessKey;
}

- (void)synchronize;

@property (nonatomic, copy) NSString *awsAccessKeyId;
@property (nonatomic, copy) NSString *awsSecretAccessKey;

@end
