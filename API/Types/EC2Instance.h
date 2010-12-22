//
//  EC2Instance.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Type.h"
#import "EC2InstanceState.h"

@interface EC2Instance : EC2Type {
@private
	NSString			*_instanceId;
	NSString			*_imageId;
	EC2InstanceState	*_instanceState;
	NSString			*_dnsName;
	NSDate				*_launchTime;
	NSString			*_privateIpAddress;
	NSString			*_ipAddress;
	NSArray				*_tagSet;					// EC2Tag
}

@property (nonatomic, retain, readonly) NSString *instanceId;
@property (nonatomic, retain, readonly) NSString *imageId;
@property (nonatomic, retain, readonly) EC2InstanceState *instanceState;
@property (nonatomic, retain, readonly) NSString *dnsName;
@property (nonatomic, retain, readonly) NSDate *launchTime;
@property (nonatomic, retain, readonly) NSString *ipAddress;
@property (nonatomic, retain, readonly) NSString *privateIpAddress;
@property (nonatomic, retain, readonly) NSArray *tagSet;

// Returns value of "Name" tag if present, nil otherwise
- (NSString *)nameTag;

@end
