//
//  EC2InstanceState.h
//  Cloudwatch
//
//  Created by Dmitri Goutnik on 01/12/2010.
//  Copyright 2010 Tundra Bot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EC2Type.h"

enum {
	EC2_INSTANCE_STATE_PENDING = 0,
	EC2_INSTANCE_STATE_RUNNING = 16,
	EC2_INSTANCE_STATE_SHUTTING_DOWN = 32,
	EC2_INSTANCE_STATE_TERMINATED = 48,
	EC2_INSTANCE_STATE_STOPPING = 64,
	EC2_INSTANCE_STATE_STOPPED = 80
};

@interface EC2InstanceState : EC2Type {
@private
	NSInteger	_code;
	NSString	*_name;
}

@property (nonatomic, assign, readonly) NSInteger code;
@property (nonatomic, retain, readonly) NSString *name;

@end
