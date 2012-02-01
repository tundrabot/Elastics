//
//  EC2Instance.h
//  Elastics
//
//  Created by Dmitri Goutnik on 21/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSType.h"
#import "EC2InstanceState.h"
#import "EC2Placement.h"
#import "EC2Group.h"
#import "EC2Monitoring.h"

@interface EC2Instance : AWSType {
@private
	NSString			*_instanceId;
	NSString			*_imageId;
	EC2InstanceState	*_instanceState;
	NSString			*_instanceType;
	NSString			*_dnsName;
	NSDate				*_launchTime;
	EC2Placement		*_placement;
	NSString			*_platform;
	EC2Monitoring		*_monitoring;
	NSString			*_privateIpAddress;
	NSString			*_ipAddress;
	NSArray				*_tagSet;   // EC2Tag
}

@property (nonatomic, retain, readonly) NSString *instanceId;
@property (nonatomic, retain, readonly) NSString *imageId;
@property (nonatomic, retain, readonly) EC2InstanceState *instanceState;
@property (nonatomic, retain, readonly) NSString *instanceType;
@property (nonatomic, retain, readonly) NSString *dnsName;
@property (nonatomic, retain, readonly) NSDate *launchTime;
@property (nonatomic, retain, readonly) EC2Placement *placement;
@property (nonatomic, retain, readonly) NSString *platform;
@property (nonatomic, retain, readonly) EC2Monitoring *monitoring;
@property (nonatomic, retain, readonly) NSString *privateIpAddress;
@property (nonatomic, retain, readonly) NSString *ipAddress;
@property (nonatomic, retain, readonly) NSArray *tagSet;

// List of Security Groups from owning reservation
- (NSArray *)groupSet;

// The groupId of first security group from the security groups list
- (NSString *)securityGroup;

// Returns value of "Name" tag if present, nil otherwise
- (NSString *)nameTag;

// Returns value of "aws:autoscaling:groupName" tag if present, nil otherwise
- (NSString *)autoscalingGroupName;

// Return value of "Name" tag if present, instanceId otherwise
- (NSString *)title;

@end
